---
applyTo: "**/*.tftest.hcl,tests/**/*.tf"
---

# Terraform Testing Instructions

## Quick Reference

**When writing Terraform tests:**
- Test files: `*.tftest.hcl` in root or `tests/` directory
- File structure: `test` block (optional) → `run` blocks (required) → assertions
- Helper modules in `tests/{setup,final,scenario}/` for test-specific resources
- Use `command = plan` for unit tests (no resources), `command = apply` for integration tests
- Mock providers with `mock_provider` blocks to avoid creating real infrastructure
- Override specific resources/data sources with `override_resource`, `override_data`, `override_module`
- Run tests: `terraform test` (local) or `terraform test -cloud-run=<module-path>` (HCP Terraform)

**Cross-references:**
- Terraform code style → [terraform.instructions.md](./terraform.instructions.md)
- Module documentation → [documentation.instructions.md](./documentation.instructions.md)
- Examples → [examples.instructions.md](./examples.instructions.md)

---

## Overview

Terraform tests allow you to validate module configuration without impacting existing infrastructure. Tests create ephemeral resources, run assertions, and automatically clean up afterward. This enables:

1. **Integration Testing** - Create real infrastructure and validate behavior
2. **Unit Testing** - Validate logic without creating resources (using `command = plan`)
3. **Mocking** - Test without credentials or resource creation
4. **Regression Prevention** - Ensure updates don't introduce breaking changes

## Test File Structure

### File Organization

**Standard Test Directory Layout:**
```
module-root/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
└── tests/
    ├── simple.tftest.hcl          # Basic test file
    ├── integration.tftest.hcl     # Integration tests
    ├── unit.tftest.hcl            # Unit tests with mocking
    ├── setup/                     # Helper module for setup
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── final/                     # Helper module for validation
    │   ├── main.tf
    │   └── variables.tf
    └── mocks/
        └── aws.tfmock.hcl         # Shared mock data
```

**Test File Discovery:**
- Terraform discovers files ending with `.tftest.hcl` or `.tftest.json`
- By default, searches in root directory and `tests/` directory
- Use `-test-directory` flag to specify alternate location
- Organize related tests in subdirectories when needed

### Test File Structure

**Required Components:**

```hcl
# Optional: Configure test execution
test {
  parallel = true  # Enable parallel execution
}

# Optional: Set global variables
variables {
  environment = "test"
  region      = "us-east-1"
}

# Optional: Configure providers
provider "aws" {
  region = "us-east-1"
}

# Required: One or more run blocks
run "test_name" {
  # Test configuration
}
```

**Element Execution Order:**
1. `test` block - Processed first (configuration)
2. `variables` block - Processed at beginning
3. `provider` blocks - Initialized at beginning
4. `run` blocks - Executed sequentially (or in parallel if configured)

## Run Blocks

Run blocks are the core of Terraform tests. Each block simulates a Terraform command execution.

### Basic Run Block Structure

```hcl
run "descriptive_test_name" {
  # Command to execute (default: apply)
  command = plan  # or apply

  # Variables for this run
  variables {
    bucket_name = "test-bucket"
  }

  # Assertions to validate
  assert {
    condition     = aws_s3_bucket.bucket.bucket == "test-bucket"
    error_message = "S3 bucket name did not match expected"
  }

  # Additional assertions
  assert {
    condition     = aws_s3_bucket.bucket.versioning[0].enabled == true
    error_message = "Versioning should be enabled"
  }
}
```

### Run Block Attributes

**Command Execution:**

```hcl
run "test_plan_only" {
  # Execute plan only (unit test - no resources created)
  command = plan
}

run "test_with_apply" {
  # Execute apply (integration test - creates resources)
  command = apply  # This is the default
}
```

**Plan Options:**

```hcl
run "test_with_options" {
  command = apply

  plan_options {
    mode    = "refresh-only"  # or "normal"
    refresh = true            # Enable/disable refresh
    replace = [               # Force replacement
      aws_instance.web
    ]
    target = [                # Target specific resources
      aws_s3_bucket.bucket
    ]
  }
}
```

**Parallel Execution:**

```hcl
# Global parallel setting
test {
  parallel = true
}

run "parallel_test_1" {
  # Implicitly parallel = true from test block
}

run "parallel_test_2" {
  # Also runs in parallel
}

run "sequential_test" {
  # Override global setting
  parallel = false
  # This creates a synchronization point
  # All previous runs must complete before this runs
}
```

**State Management:**

```hcl
run "setup" {
  # Uses main configuration state by default
}

run "setup_alternate" {
  state_key = "alternate"  # Uses separate state file

  module {
    source = "./tests/setup"
  }
}

run "use_alternate_state" {
  state_key = "alternate"  # Shares state with setup_alternate
}
```

## Assertions

Assertions validate that your infrastructure behaves as expected.

### Assertion Structure

```hcl
assert {
  condition     = <boolean expression>
  error_message = "Helpful message when assertion fails"
}
```

### Assertion Best Practices

**1. Clear, Specific Conditions:**

```hcl
# ✅ Good - specific and clear
assert {
  condition     = aws_s3_bucket.bucket.bucket == "expected-bucket-name"
  error_message = "S3 bucket name did not match expected value"
}

# ❌ Bad - vague
assert {
  condition     = aws_s3_bucket.bucket.bucket != ""
  error_message = "Bucket name is wrong"
}
```

**2. Descriptive Error Messages:**

```hcl
# ✅ Good - includes actual value
assert {
  condition     = data.http.index.status_code == 200
  error_message = "Website responded with HTTP status ${data.http.index.status_code}"
}

# ❌ Bad - no context
assert {
  condition     = data.http.index.status_code == 200
  error_message = "Test failed"
}
```

**3. Reference Values Correctly:**

```hcl
run "test_references" {
  variables {
    bucket_prefix = "test"
  }

  # Reference resources
  assert {
    condition     = aws_s3_bucket.bucket.bucket == "${var.bucket_prefix}-bucket"
    error_message = "Invalid bucket name"
  }

  # Reference outputs
  assert {
    condition     = output.bucket_name == "${var.bucket_prefix}-bucket"
    error_message = "Invalid output value"
  }

  # Reference previous run blocks
  assert {
    condition     = output.value == run.setup.bucket_id
    error_message = "Value doesn't match setup output"
  }
}
```

**4. Test Multiple Related Conditions:**

```hcl
# Group related assertions in the same run block
run "validate_s3_configuration" {
  assert {
    condition     = aws_s3_bucket.bucket.bucket == "test-bucket"
    error_message = "Invalid bucket name"
  }

  assert {
    condition     = aws_s3_bucket.bucket.versioning[0].enabled == true
    error_message = "Versioning should be enabled"
  }

  assert {
    condition     = aws_s3_bucket.bucket.server_side_encryption_configuration != null
    error_message = "Encryption should be configured"
  }
}
```

**5. Null Safety:**

```hcl
assert {
  # Use try() for potentially null values
  condition     = try(aws_s3_bucket.bucket.lifecycle_rule[0].enabled, false) == true
  error_message = "Lifecycle rule should be enabled"
}

assert {
  # Use != null for existence checks
  condition     = aws_s3_bucket.bucket.logging != null
  error_message = "Logging configuration is missing"
}
```

## Variables

Variables can be defined at multiple levels with clear precedence rules.

### Variable Precedence

**Highest to Lowest:**
1. Run block `variables` block
2. Test file `variables` block
3. Automatic variable files in test directory (`*.auto.tfvars`, `terraform.tfvars`)
4. Automatic variable files in main configuration directory
5. Command-line variables (`-var`, `-var-file`)
6. Environment variables (`TF_VAR_*`)

### Variable Patterns

**Global Variables:**

```hcl
# Set once, used by all run blocks
variables {
  environment = "test"
  region      = "us-east-1"
}

run "test_one" {
  # Uses global variables
}

run "test_two" {
  # Also uses global variables
}
```

**Override Variables:**

```hcl
variables {
  bucket_prefix = "default"
}

run "use_default" {
  # Uses bucket_prefix = "default"
}

run "override_prefix" {
  variables {
    bucket_prefix = "custom"
  }
  # Uses bucket_prefix = "custom"
}
```

**Reference Variables:**

```hcl
variables {
  base_name = "test"
}

run "setup" {
  variables {
    # Reference global variable
    full_name = "${var.base_name}-setup"
  }

  # Outputs can be used in later run blocks
}

run "use_setup_output" {
  variables {
    # Reference output from previous run
    bucket_id = run.setup.bucket_id
  }
}
```

**Automatic Variable Files:**

```
tests/
├── test.tftest.hcl
├── terraform.tfvars        # Auto-loaded for tests in this directory
├── test.auto.tfvars       # Auto-loaded for tests in this directory
└── setup/
    └── main.tf
```

## Providers

Configure providers for tests separately from main configuration.

### Provider Configuration

**Basic Provider:**

```hcl
provider "aws" {
  region = "us-east-1"
}

run "test" {
  # Uses the configured provider
}
```

**Multiple Providers:**

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "secondary"
  region = "eu-west-1"
}

run "test_multi_region" {
  # Both providers available
}
```

**Provider Per Run Block:**

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "eu"
  region = "eu-west-1"
}

run "test_custom_provider" {
  providers = {
    aws = aws.eu  # Override default provider
  }
}
```

**Dynamic Provider Configuration:**

```hcl
provider "vault" {
  # ... vault configuration ...
}

provider "aws" {
  region     = "us-east-1"
  # Reference outputs from setup run
  access_key = run.vault_setup.aws_access_key
  secret_key = run.vault_setup.aws_secret_key
}

run "vault_setup" {
  module {
    source = "./tests/vault-setup"
  }
  # Only uses vault provider
}

run "use_aws" {
  # Uses aws provider with credentials from vault_setup
}
```

## Helper Modules

Helper modules create test-specific resources outside your main configuration.

### When to Use Helper Modules

**Use Cases:**
1. **Setup** - Create dependencies (VPC, networks, databases)
2. **Validation** - Validate outputs (HTTP checks, data sources)
3. **Cleanup** - Ensure proper resource deletion order
4. **Data Generation** - Generate test data (random names, passwords)

### Helper Module Structure

**Setup Module Example:**

```
tests/
└── setup/
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

```hcl
# tests/setup/main.tf
terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}

resource "random_pet" "bucket_prefix" {
  length = 4
}

output "bucket_prefix" {
  value = random_pet.bucket_prefix.id
}
```

**Using Helper Module:**

```hcl
# tests/integration.tftest.hcl

run "setup" {
  module {
    source = "./tests/setup"
  }
}

run "create_bucket" {
  variables {
    # Use output from setup module
    bucket_name = "${run.setup.bucket_prefix}-test"
  }

  assert {
    condition     = aws_s3_bucket.bucket.bucket == "${run.setup.bucket_prefix}-test"
    error_message = "Bucket name mismatch"
  }
}
```

**Validation Module Example:**

```hcl
# tests/final/main.tf
terraform {
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "3.4.0"
    }
  }
}

variable "endpoint" {
  type = string
}

data "http" "index" {
  url    = var.endpoint
  method = "GET"
}

output "status_code" {
  value = data.http.index.status_code
}
```

```hcl
# tests/integration.tftest.hcl

run "create_website" {
  command = apply
}

run "validate_website" {
  command = plan

  module {
    source = "./tests/final"
  }

  variables {
    endpoint = run.create_website.website_endpoint
  }

  assert {
    condition     = data.http.index.status_code == 200
    error_message = "Website not responding with 200 OK"
  }
}
```

### Helper Module Best Practices

1. **Keep Helper Modules Simple:**
   - Single, focused purpose
   - Minimal dependencies
   - Clear outputs

2. **Document Helper Modules:**
   - Add brief comment explaining purpose
   - Document required variables
   - Document outputs

3. **Reuse Helper Modules:**
   - Create shared helper modules for common patterns
   - Place in `tests/shared/` directory
   - Version helper modules if used across multiple modules

## Mocking

Mocking allows testing without creating real infrastructure or requiring credentials.

### Mock Providers

**Basic Mock Provider:**

```hcl
mock_provider "aws" {}

run "test_without_aws_credentials" {
  variables {
    bucket_name = "test-bucket"
  }

  assert {
    condition     = aws_s3_bucket.bucket.bucket == "test-bucket"
    error_message = "Bucket name mismatch"
  }

  # ARN will be auto-generated by mock provider
  assert {
    condition     = can(regex("^arn:aws:s3:::.*", aws_s3_bucket.bucket.arn))
    error_message = "Invalid ARN format"
  }
}
```

**Generated Data Rules:**

Mocked providers generate data for computed attributes:
- **Numbers**: `0`
- **Booleans**: `false`
- **Strings**: Random 8-character alphanumeric
- **Collections**: Empty collections
- **Objects**: All required attributes generated recursively

**Control When Data is Generated:**

```hcl
# Generate during plan (default is during apply)
mock_provider "aws" {
  override_during = plan
}

run "test" {
  command = plan
  # Data available during plan phase
}
```

### Mock Provider Data

**Provide Specific Values:**

```hcl
mock_provider "aws" {
  mock_resource "aws_s3_bucket" {
    defaults = {
      arn = "arn:aws:s3:::test-bucket"
    }
  }

  mock_data "aws_ami" {
    defaults = {
      id           = "ami-12345678"
      architecture = "x86_64"
    }
  }
}
```

**Shared Mock Data Files:**

```hcl
# tests/mocks/aws.tfmock.hcl
mock_resource "aws_s3_bucket" {
  defaults = {
    arn = "arn:aws:s3:::test-bucket"
  }
}

mock_data "aws_ami" {
  defaults = {
    id = "ami-12345678"
  }
}
```

```hcl
# tests/unit.tftest.hcl
mock_provider "aws" {
  source = "./tests/mocks"
}
```

**Combine Source and Direct Definitions:**

```hcl
mock_provider "aws" {
  source = "./tests/mocks"

  # This takes precedence over definitions in source
  mock_resource "aws_s3_bucket" {
    defaults = {
      arn = "arn:aws:s3:::override-bucket"
    }
  }
}
```

### Override Blocks

Override specific resources, data sources, or modules without mocking the entire provider.

**Override Resource:**

```hcl
mock_provider "aws" {}

# Override specific resource
override_resource {
  target = aws_instance.backend_api
  values = {
    id  = "i-1234567890abcdef0"
    arn = "arn:aws:ec2:us-east-1:123456789012:instance/i-1234567890abcdef0"
  }
}

run "test" {
  # aws_instance.backend_api uses overridden values
  # Other resources use mock provider
}
```

**Override Data Source:**

```hcl
override_data {
  target = data.aws_ami.ubuntu
  values = {
    id           = "ami-12345678"
    architecture = "x86_64"
  }
}
```

**Override Module:**

```hcl
override_module {
  target = module.networking
  outputs = {
    vpc_id     = "vpc-12345678"
    subnet_ids = ["subnet-12345678", "subnet-87654321"]
  }
}

run "test" {
  # module.networking returns overridden outputs
  # Module resources are not created
}
```

**Override Precedence:**

From highest to lowest:
1. Run block overrides
2. File-level overrides
3. Mock provider overrides
4. Provider defaults

```hcl
# File-level override
override_data {
  target = data.aws_s3_object.config
  values = {
    body = "{\"config\": \"default\"}"
  }
}

run "test_default" {
  # Uses file-level override
}

run "test_custom" {
  # Run-block override takes precedence
  override_data {
    target = data.aws_s3_object.config
    values = {
      body = "{\"config\": \"custom\"}"
    }
  }
}
```

**Override in Mock Provider:**

```hcl
mock_provider "aws" {
  # Only applies when mock provider creates the resource
  override_data {
    target = module.credentials.data.aws_s3_object.data_bucket
    values = {
      body = "{\"username\":\"test\",\"password\":\"test\"}"
    }
  }
}
```

### Mocking Best Practices

1. **Use Mocking for Unit Tests:**
   ```hcl
   # Unit test - no real resources
   mock_provider "aws" {}

   run "validate_bucket_name_logic" {
     command = plan

     variables {
       prefix = "test"
       suffix = "bucket"
     }

     assert {
       condition     = aws_s3_bucket.bucket.bucket == "test-bucket"
       error_message = "Name concatenation logic failed"
     }
   }
   ```

2. **Integration Tests Without Mocking:**
   ```hcl
   # Integration test - creates real resources
   provider "aws" {
     region = "us-east-1"
   }

   run "validate_bucket_creation" {
     command = apply

     assert {
       condition     = can(regex("^arn:aws:s3:::.*", aws_s3_bucket.bucket.arn))
       error_message = "Bucket was not created"
     }
   }
   ```

3. **Mock Expensive Resources:**
   ```hcl
   # Mock slow-to-provision resources
   override_resource {
     target = aws_rds_instance.database
   }

   override_resource {
     target = aws_eks_cluster.cluster
   }

   # Test main logic without waiting for RDS/EKS
   run "test_application_config" {
     command = apply
     # Fast execution, tests application logic
   }
   ```

4. **Verify Mock Assumptions:**
   ```hcl
   mock_provider "aws" {
     mock_resource "aws_s3_bucket" {
       defaults = {
         arn = "arn:aws:s3:::test-bucket"
       }
     }
   }

   run "verify_arn_usage" {
     assert {
       # Verify your code handles ARN correctly
       condition     = can(regex("^arn:aws:s3:::", aws_s3_bucket.bucket.arn))
       error_message = "ARN format validation failed"
     }
   }
   ```

## Expecting Failures

Test that your validation and custom conditions work correctly.

### Expect Failures Structure

```hcl
run "test_validation_fails" {
  command = plan

  variables {
    invalid_value = "wrong"
  }

  # This test passes if var.input validation fails
  expect_failures = [
    var.input,
  ]
}
```

### Expect Failures Best Practices

**1. Test Variable Validation:**

```hcl
# main.tf
variable "environment" {
  type = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod"
  }
}
```

```hcl
# tests/validation.tftest.hcl

run "valid_environment" {
  command = plan

  variables {
    environment = "dev"
  }

  # Should succeed without failures
}

run "invalid_environment" {
  command = plan

  variables {
    environment = "invalid"
  }

  # Should fail validation
  expect_failures = [
    var.environment,
  ]
}
```

**2. Test Preconditions:**

```hcl
# main.tf
resource "aws_instance" "web" {
  # ...

  lifecycle {
    precondition {
      condition     = var.instance_type != "t1.micro"
      error_message = "t1.micro is deprecated, use t2.micro or newer"
    }
  }
}
```

```hcl
# tests/preconditions.tftest.hcl

run "valid_instance_type" {
  command = plan

  variables {
    instance_type = "t2.micro"
  }
}

run "deprecated_instance_type" {
  command = plan

  variables {
    instance_type = "t1.micro"
  }

  expect_failures = [
    aws_instance.web,
  ]
}
```

**3. Test Check Blocks:**

```hcl
# main.tf
check "health_check" {
  data "http" "health" {
    url = aws_lb.main.dns_name
  }

  assert {
    condition     = data.http.health.status_code == 200
    error_message = "Health check failed"
  }
}
```

```hcl
# tests/health.tftest.hcl

run "health_check_passes" {
  # Health check should pass
}

run "health_check_fails" {
  # Simulate failure scenario

  expect_failures = [
    check.health_check,
  ]
}
```

**4. Important Notes:**

```hcl
# ⚠️ Use with command = plan
run "test_validation" {
  command = plan  # Recommended

  expect_failures = [
    var.input,
  ]
}

# ❌ Avoid with command = apply
run "test_validation_apply" {
  command = apply  # Can be confusing

  expect_failures = [
    var.input,
  ]
  # If validation fails during plan, test fails
  # even though failure was expected
}
```

```hcl
# ✅ Multiple check blocks allowed
run "test_multiple_checks" {
  command = plan

  expect_failures = [
    check.health_check,
    check.security_check,
    check.compliance_check,
  ]
}

# ⚠️ Only one resource/data source reliably supported
run "test_single_resource" {
  command = plan

  expect_failures = [
    aws_instance.web,  # OK - single resource
  ]
}
```

## Test Organization Patterns

### Pattern 1: Simple Module

**For small modules with straightforward logic:**

```
module-root/
├── main.tf
├── variables.tf
└── tests/
    └── basic.tftest.hcl
```

```hcl
# tests/basic.tftest.hcl

variables {
  name = "test"
}

run "validate_outputs" {
  command = plan

  assert {
    condition     = output.name == "test"
    error_message = "Output mismatch"
  }
}
```

### Pattern 2: Integration and Unit Tests

**Separate integration and unit tests:**

```
tests/
├── integration.tftest.hcl  # Creates real resources
├── unit.tftest.hcl        # Uses mocking
└── setup/
    └── main.tf
```

```hcl
# tests/unit.tftest.hcl
mock_provider "aws" {}

run "unit_test_logic" {
  command = plan
  # Fast, no credentials needed
}
```

```hcl
# tests/integration.tftest.hcl
provider "aws" {
  region = "us-east-1"
}

run "integration_test" {
  command = apply
  # Creates real resources
}
```

### Pattern 3: Comprehensive Test Suite

**For complex modules:**

```
tests/
├── validation.tftest.hcl      # Variable validation tests
├── unit.tftest.hcl            # Unit tests with mocking
├── integration.tftest.hcl     # Integration tests
├── scenarios/
│   ├── public-bucket.tftest.hcl
│   ├── private-bucket.tftest.hcl
│   └── versioned.tftest.hcl
├── setup/
│   └── main.tf
├── final/
│   └── main.tf
└── mocks/
    └── aws.tfmock.hcl
```

### Pattern 4: Multi-Provider Module

```hcl
# tests/multi-provider.tftest.hcl

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "secondary"
  region = "eu-west-1"
}

run "test_primary_region" {
  providers = {
    aws = aws
  }
}

run "test_secondary_region" {
  providers = {
    aws = aws.secondary
  }
}
```

## Running Tests

### Local Execution

```bash
# Run all tests
terraform test

# Run tests in specific directory
terraform test -test-directory=tests/integration

# Run specific test file
terraform test tests/basic.tftest.hcl

# Verbose output
terraform test -verbose

# Filter by test name
terraform test -filter=run.setup
```

### HCP Terraform Execution

**Prerequisites:**
1. Module published to HCP Terraform registry
2. Environment variables configured for test runs
3. Branch-based publishing enabled

**Automatic Runs:**
- Tests run automatically on push to configured branch
- Tests run on pull requests against configured branch

**Manual Runs from CLI:**

```bash
# Run tests remotely using local configuration
terraform test -cloud-run=app.terraform.io/ORG/MODULE/PROVIDER

# Example
terraform test -cloud-run=app.terraform.io/my-org/vpc/aws
```

**Benefits:**
- Uses environment variables from HCP Terraform
- No local credentials needed
- Test results visible in UI
- Centralized test history

## Test Quality Standards

### Well-Written Tests

**1. Clear Test Names:**

```hcl
# ✅ Good - descriptive names
run "validate_bucket_name_format" {}
run "test_encryption_enabled" {}
run "verify_tags_applied" {}

# ❌ Bad - vague names
run "test1" {}
run "check" {}
run "run" {}
```

**2. Focused Run Blocks:**

```hcl
# ✅ Good - single concern
run "validate_bucket_encryption" {
  assert {
    condition     = aws_s3_bucket.bucket.server_side_encryption_configuration != null
    error_message = "Encryption not configured"
  }
}

run "validate_bucket_versioning" {
  assert {
    condition     = aws_s3_bucket.bucket.versioning[0].enabled == true
    error_message = "Versioning not enabled"
  }
}

# ⚠️ Acceptable - related concerns
run "validate_bucket_security" {
  assert {
    condition     = aws_s3_bucket.bucket.server_side_encryption_configuration != null
    error_message = "Encryption not configured"
  }

  assert {
    condition     = aws_s3_bucket.bucket.versioning[0].enabled == true
    error_message = "Versioning not enabled"
  }
}
```

**3. Independent Tests:**

```hcl
# ✅ Good - tests can run independently
run "test_default_configuration" {
  variables {
    name = "test-1"
  }
}

run "test_custom_configuration" {
  variables {
    name = "test-2"
  }
}

# ❌ Bad - tests depend on execution order
run "create_resource" {
  variables {
    name = "test"
  }
}

run "check_resource_exists" {
  # Assumes previous run succeeded
  # Breaks if run in parallel or out of order
}
```

**4. Comprehensive Coverage:**

```hcl
# Test happy path
run "test_valid_input" {
  variables {
    value = "valid"
  }
}

# Test edge cases
run "test_empty_input" {
  variables {
    value = ""
  }
}

# Test error conditions
run "test_invalid_input" {
  variables {
    value = "invalid"
  }

  expect_failures = [
    var.value,
  ]
}
```

### Test Checklist

Before committing tests:

- [ ] All test files end with `.tftest.hcl`
- [ ] Test names are descriptive and unique
- [ ] Each run block has clear purpose
- [ ] Assertions have helpful error messages
- [ ] Helper modules are documented
- [ ] Mocking is used appropriately
- [ ] Tests pass locally: `terraform test`
- [ ] Tests are independent (can run in any order)
- [ ] Coverage includes happy path and edge cases
- [ ] Expected failures are tested
- [ ] No hardcoded credentials or sensitive values

## Common Patterns

### Pattern: Setup → Execute → Validate

```hcl
run "setup_dependencies" {
  module {
    source = "./tests/setup"
  }
}

run "create_infrastructure" {
  command = apply

  variables {
    dependency_id = run.setup_dependencies.output_id
  }
}

run "validate_infrastructure" {
  module {
    source = "./tests/final"
  }

  variables {
    target = run.create_infrastructure.endpoint
  }

  assert {
    condition     = data.http.check.status_code == 200
    error_message = "Infrastructure validation failed"
  }
}
```

### Pattern: Parallel Independent Tests

```hcl
test {
  parallel = true
}

run "test_scenario_a" {
  state_key = "scenario_a"
  variables {
    scenario = "a"
  }
}

run "test_scenario_b" {
  state_key = "scenario_b"
  variables {
    scenario = "b"
  }
}

run "test_scenario_c" {
  state_key = "scenario_c"
  variables {
    scenario = "c"
  }
}

# All three run in parallel
```

### Pattern: Progressive Validation

```hcl
run "plan_validation" {
  command = plan

  assert {
    condition     = aws_s3_bucket.bucket.bucket == "expected-name"
    error_message = "Plan-time validation failed"
  }
}

run "apply_and_validate" {
  command = apply

  assert {
    condition     = can(regex("^arn:aws:s3:::.*", aws_s3_bucket.bucket.arn))
    error_message = "Resource not created"
  }
}

run "runtime_validation" {
  command = plan

  module {
    source = "./tests/final"
  }

  assert {
    condition     = data.http.check.status_code == 200
    error_message = "Runtime validation failed"
  }
}
```

### Pattern: Matrix Testing

```hcl
# Test multiple configurations
run "test_dev_environment" {
  variables {
    environment = "dev"
    instance_type = "t2.micro"
  }
}

run "test_staging_environment" {
  variables {
    environment = "staging"
    instance_type = "t2.small"
  }
}

run "test_prod_environment" {
  variables {
    environment = "prod"
    instance_type = "t2.medium"
  }
}
```

## Best Practices Summary

### Do's

✅ **Organize tests logically** - Group related tests in files
✅ **Use descriptive names** - Test names should explain what is tested
✅ **Write focused assertions** - One concern per assertion
✅ **Use helper modules** - For setup and validation
✅ **Mock appropriately** - Unit tests with mocking, integration without
✅ **Test failure cases** - Use `expect_failures` for validation
✅ **Keep tests independent** - Tests should not depend on execution order
✅ **Use variables** - Avoid hardcoding values
✅ **Document complex tests** - Add comments explaining non-obvious logic
✅ **Run tests regularly** - As part of development workflow

### Don'ts

❌ **Don't hardcode credentials** - Use environment variables or HCP Terraform
❌ **Don't create resource dependencies** - Between independent test runs
❌ **Don't use vague error messages** - Be specific and helpful
❌ **Don't skip cleanup** - Terraform handles this automatically
❌ **Don't mix concerns** - Keep setup, execution, validation separate
❌ **Don't over-mock** - Integration tests should use real providers
❌ **Don't ignore test failures** - Investigate and fix
❌ **Don't commit untested code** - Run tests before commit
❌ **Don't use expect_failures with apply** - Use with plan instead
❌ **Don't duplicate test logic** - Use helper modules for common patterns

## Examples

### Complete Test File Example

```hcl
# tests/s3-website.tftest.hcl

# Configure parallel execution
test {
  parallel = true
}

# Global variables
variables {
  environment = "test"
}

# Provider configuration
provider "aws" {
  region = "us-east-1"
}

# Setup helper module
run "setup" {
  module {
    source = "./tests/setup"
  }
}

# Test bucket creation
run "create_bucket" {
  command = apply

  variables {
    bucket_name = "${run.setup.prefix}-website"
  }

  assert {
    condition     = aws_s3_bucket.bucket.bucket == "${run.setup.prefix}-website"
    error_message = "Bucket name mismatch"
  }

  assert {
    condition     = aws_s3_bucket.bucket.versioning[0].enabled == true
    error_message = "Versioning should be enabled"
  }
}

# Test website files
run "upload_files" {
  assert {
    condition     = aws_s3_object.index.etag == filemd5("./www/index.html")
    error_message = "index.html hash mismatch"
  }

  assert {
    condition     = aws_s3_object.error.etag == filemd5("./www/error.html")
    error_message = "error.html hash mismatch"
  }
}

# Validate website is running
run "validate_website" {
  command = plan

  module {
    source = "./tests/final"
  }

  variables {
    endpoint = run.create_bucket.website_endpoint
  }

  assert {
    condition     = data.http.index.status_code == 200
    error_message = "Website responded with HTTP ${data.http.index.status_code}"
  }
}
```

### Mock Provider Example

```hcl
# tests/unit.tftest.hcl

# Mock AWS provider
mock_provider "aws" {
  # Generate data during plan
  override_during = plan

  # Provide specific ARN format
  mock_resource "aws_s3_bucket" {
    defaults = {
      arn = "arn:aws:s3:::test-bucket"
    }
  }
}

# Unit test without AWS credentials
run "test_bucket_configuration" {
  command = plan

  variables {
    bucket_name = "test-bucket"
    enable_versioning = true
  }

  assert {
    condition     = aws_s3_bucket.bucket.bucket == "test-bucket"
    error_message = "Bucket name logic incorrect"
  }

  assert {
    condition     = can(regex("^arn:aws:s3:::", aws_s3_bucket.bucket.arn))
    error_message = "ARN format validation failed"
  }
}
```

### Override Example

```hcl
# tests/mocked-integration.tftest.hcl

# Use real AWS provider
provider "aws" {
  region = "us-east-1"
}

# Override expensive resources
override_resource {
  target = aws_rds_instance.database
  values = {
    endpoint = "mock-db.us-east-1.rds.amazonaws.com:5432"
  }
}

override_resource {
  target = aws_eks_cluster.cluster
  values = {
    endpoint = "https://mock-eks.us-east-1.eks.amazonaws.com"
  }
}

# Test application without creating expensive resources
run "test_application_integration" {
  command = apply

  assert {
    condition     = aws_instance.app.user_data != null
    error_message = "User data not configured"
  }

  # Can reference mocked resource attributes
  assert {
    condition     = contains(aws_instance.app.user_data, aws_rds_instance.database.endpoint)
    error_message = "Database endpoint not in user data"
  }
}
```

## Practical Lessons Learned

This section contains practical learnings from writing real-world Terraform tests.

### Common Pitfalls and Solutions

#### 1. Terraform Version Compatibility

**Problem:** Some test syntax features are only available in newer Terraform versions.

```hcl
# ❌ Not supported in Terraform < 1.7
test {
  parallel = true
}

# ❌ Not supported in some versions
mock_provider "aws" {
  override_during = plan  # This parameter may not exist
}
```

**Solution:** Check Terraform version and use supported syntax only.

```hcl
# ✅ Works in all versions with test support
variables {
  environment = "test"
}

mock_provider "aws" {}  # No override_during parameter
```

**Best Practice:** Run `terraform test --help` to check supported features for your version.

#### 2. Locals in Run Blocks

**Problem:** `locals {}` blocks cannot be used inside `run` blocks.

```hcl
# ❌ Error: Unsupported block type
run "validate_filters" {
  command = plan

  locals {
    grep_filters = [for f in local.filters : f if f.name == "grep"]
  }

  assert {
    condition     = length(local.grep_filters) == 4
    error_message = "Expected 4 grep filters"
  }
}
```

**Solution:** Use inline expressions instead of locals.

```hcl
# ✅ Use inline for loops
run "validate_filters" {
  command = plan

  assert {
    condition     = length([for f in local.filters : f if f.name == "grep"]) == 4
    error_message = "Expected 4 grep filters"
  }
}
```

**Best Practice:** Keep assertions simple with inline expressions, or split into multiple focused run blocks.

#### 3. Regex Escaping Complexity

**Problem:** Regex escaping in Terraform can be confusing, especially when testing strings that contain backslashes.

```hcl
# ❌ Complex regex escaping
run "validate_regex_pattern" {
  command = plan

  assert {
    condition     = can(regex("^\\^\\[", local.parser.regex))
    error_message = "Regex should start with ^\\["
  }
}
```

**Solution:** Use simpler string functions when possible.

```hcl
# ✅ Use startswith() for simple prefix checks
run "validate_regex_pattern" {
  command = plan

  assert {
    condition     = startswith(local.parser.regex, "^\\[")
    error_message = "Regex should start with ^\\["
  }
}

# ✅ Use contains() for substring checks
run "validate_pattern_content" {
  command = plan

  assert {
    condition     = strcontains(local.filter.exclude, "index.php")
    error_message = "Filter should exclude index.php"
  }
}
```

**Alternative:** Use `can(regex(...))` to check if a pattern matches without worrying about exact escaping.

```hcl
# ✅ Check if pattern exists anywhere in string
run "validate_pattern_exists" {
  command = plan

  assert {
    condition     = length([for f in local.filters : f if can(regex("index\\\\.php", f.exclude))]) > 0
    error_message = "Should have filter excluding index.php"
  }
}
```

#### 4. Provider Initialization

**Problem:** Tests fail with "Missing required provider" even with `mock_provider`.

```bash
$ terraform test tests/config.tftest.hcl
Error: Missing required provider

This configuration requires provider registry.terraform.io/hashicorp/aws,
but that provider isn't available. You may be able to install it automatically
by running:
  terraform init
```

**Solution:** Always run `terraform init` in the module root directory before running tests.

```bash
# ✅ Initialize first
terraform init
terraform test tests/config.tftest.hcl

# ✅ Or combine in one command
terraform init && terraform test
```

**Best Practice:** Add terraform init to CI/CD pipelines before test execution.

#### 5. Testing Complex Filters with For Loops

**Problem:** Testing elements in lists requires careful indexing.

```hcl
# ❌ Error if no matching elements found
run "validate_specific_filter" {
  command = plan

  assert {
    condition     = [for f in local.filters : f if f.name == "grep"][0].exclude == "pattern"
    error_message = "Grep filter not configured correctly"
  }
}
```

**Solution:** Use `length()` check first, then access elements safely.

```hcl
# ✅ Check existence first
run "validate_specific_filter" {
  command = plan

  assert {
    condition     = length([for f in local.filters : f if f.name == "grep"]) > 0
    error_message = "Should have grep filter"
  }

  assert {
    condition     = length([for f in local.filters : f if f.name == "grep" && can(regex("pattern", f.exclude))]) > 0
    error_message = "Grep filter should exclude pattern"
  }
}
```

**Best Practice:** Separate existence checks from content validation.

#### 6. Testing Multiple Variants

**Problem:** Need to test that configuration handles multiple format variations.

```hcl
# Testing multiple datetime format parsers
run "validate_all_datetime_formats" {
  command = plan

  assert {
    condition = (
      local.parsers[0].time_format == "%Y-%m-%dT%H:%M:%S%:z" &&
      local.parsers[1].time_format == "%Y-%m-%dT%H:%M:%S%z" &&
      local.parsers[2].time_format == "%Y-%m-%dT%H:%M:%SZ" &&
      local.parsers[3].time_format == "%Y-%m-%dT%H:%M:%S.%L%:z"
    )
    error_message = "Parsers should cover all ISO 8601 datetime format variants"
  }
}
```

**Best Practice:** Create separate run blocks for each variant to get more specific error messages.

```hcl
# ✅ Better: Separate tests for each variant
run "validate_datetime_tz_colon" {
  command = plan

  assert {
    condition     = local.parsers[0].time_format == "%Y-%m-%dT%H:%M:%S%:z"
    error_message = "Parser 0 should handle timezone with colon format"
  }
}

run "validate_datetime_tz_no_colon" {
  command = plan

  assert {
    condition     = local.parsers[1].time_format == "%Y-%m-%dT%H:%M:%S%z"
    error_message = "Parser 1 should handle timezone without colon format"
  }
}
```

#### 7. Validating Uniqueness

**Problem:** Need to ensure all items in a list are unique.

```hcl
# ✅ Convert to set and compare lengths
run "validate_parser_names_unique" {
  command = plan

  assert {
    condition     = length([for p in local.parsers : p.name]) == length(toset([for p in local.parsers : p.name]))
    error_message = "All parser names should be unique"
  }
}
```

**Best Practice:** Use `toset()` to remove duplicates and compare with original list length.

#### 8. Testing Conditional Logic

**Problem:** Validating that filters apply to correct items.

```hcl
# ✅ Use alltrue() for all-items validation
run "validate_all_json_parsers_have_filters" {
  command = plan

  assert {
    condition     = alltrue([for i in range(4) : contains(keys(local.parsers[i]), "filter")])
    error_message = "All JSON parsers should have filter configuration"
  }

  assert {
    condition     = alltrue([for i in range(4) : local.parsers[i].filter.reserve_data == true])
    error_message = "All JSON parser filters should reserve data"
  }
}
```

**Alternative:** Use conditional filtering in for loops.

```hcl
# ✅ Filter first, then validate
run "validate_grep_filters_all_have_exclude" {
  command = plan

  assert {
    condition     = alltrue([for f in local.filters : contains(keys(f), "exclude") if f.name == "grep"])
    error_message = "All grep filters should have exclude pattern"
  }
}
```

### Test Organization Learnings

#### Group Related Assertions

**Good:** Group related validations in the same run block.

```hcl
run "validate_monolog_parser_complete_config" {
  command = plan

  assert {
    condition     = local.parsers[0].name == "php_monolog_json_tz_colon"
    error_message = "Parser name mismatch"
  }

  assert {
    condition     = local.parsers[0].format == "json"
    error_message = "Parser should use json format"
  }

  assert {
    condition     = local.parsers[0].time_format == "%Y-%m-%dT%H:%M:%S%:z"
    error_message = "Parser should use ISO 8601 format with timezone colon"
  }

  assert {
    condition     = local.parsers[0].time_keep == false
    error_message = "Parser should not keep original time field"
  }
}
```

#### Separate Concerns

**Bad:** Testing unrelated things together makes debugging harder.

```hcl
# ❌ Too many unrelated checks
run "validate_everything" {
  command = plan

  assert {
    condition = length(local.parsers) == 5
    error_message = "Wrong parser count"
  }

  assert {
    condition = length(local.filters) == 5
    error_message = "Wrong filter count"
  }

  assert {
    condition = local.parsers[0].name == "php_monolog_json_tz_colon"
    error_message = "Wrong parser name"
  }
}
```

**Good:** Separate into focused tests.

```hcl
# ✅ Focused tests
run "validate_parser_count" {
  command = plan

  assert {
    condition     = length(local.parsers) == 5
    error_message = "Expected 5 parsers, got ${length(local.parsers)}"
  }
}

run "validate_filter_count" {
  command = plan

  assert {
    condition     = length(local.filters) == 5
    error_message = "Expected 5 filters, got ${length(local.filters)}"
  }
}

run "validate_primary_parser_name" {
  command = plan

  assert {
    condition     = local.parsers[0].name == "php_monolog_json_tz_colon"
    error_message = "First parser should be php_monolog_json_tz_colon"
  }
}
```

### Error Message Best Practices

#### Include Actual Values

**Good:** Error messages that show what went wrong.

```hcl
# ✅ Helpful error with actual value
assert {
  condition     = length(local.parsers) == 5
  error_message = "Expected 5 PHP parsers (4 JSON variants + 1 error parser), got ${length(local.parsers)}"
}
```

**Bad:** Vague error messages.

```hcl
# ❌ Not helpful
assert {
  condition     = length(local.parsers) == 5
  error_message = "Wrong number of parsers"
}
```

#### Be Specific About Expected Behavior

```hcl
# ✅ Explains what should happen
assert {
  condition     = alltrue([for f in local.filters : f.match == "*" if f.name == "grep"])
  error_message = "All grep filters should match '*' (to be overridden by container pattern)"
}
```

### Real-World Test Example

Here's a complete example incorporating all learnings:

```hcl
# tests/php-config.tftest.hcl
# Tests for PHP parser and filter configuration

variables {
  enabled = true
  name    = "test"
}

mock_provider "aws" {}

# Test: Verify parser count
run "validate_parser_count" {
  command = plan

  assert {
    condition     = length(local.php_parsers) == 5
    error_message = "Expected 5 PHP parsers (4 JSON variants + 1 error parser), got ${length(local.php_parsers)}"
  }
}

# Test: Verify primary parser configuration
run "validate_primary_parser" {
  command = plan

  assert {
    condition     = local.php_parsers[0].name == "php_monolog_json_tz_colon"
    error_message = "First parser should be php_monolog_json_tz_colon"
  }

  assert {
    condition     = local.php_parsers[0].time_format == "%Y-%m-%dT%H:%M:%S%:z"
    error_message = "Parser should use ISO 8601 format with timezone colon"
  }
}

# Test: Verify all JSON parsers have filters
run "validate_json_parsers_have_filters" {
  command = plan

  assert {
    condition     = alltrue([for i in range(4) : contains(keys(local.php_parsers[i]), "filter")])
    error_message = "All JSON parsers should have filter configuration"
  }
}

# Test: Verify grep filters use inline expressions
run "validate_grep_filters" {
  command = plan

  assert {
    condition     = length([for f in local.php_filters : f if f.name == "grep"]) == 4
    error_message = "Expected 4 grep filters for noise reduction"
  }

  assert {
    condition     = alltrue([for f in local.php_filters : contains(keys(f), "exclude") if f.name == "grep"])
    error_message = "All grep filters should have exclude pattern"
  }
}

# Test: Verify parser names are unique
run "validate_parser_uniqueness" {
  command = plan

  assert {
    condition     = length([for p in local.php_parsers : p.name]) == length(toset([for p in local.php_parsers : p.name]))
    error_message = "All parser names should be unique"
  }
}
```

### Quick Troubleshooting Guide

| Error | Cause | Solution |
|-------|-------|----------|
| "Unsupported block type: test" | Terraform version too old or syntax not supported | Remove `test {}` block, use only `run` blocks |
| "Unsupported argument: override_during" | Parameter not available in your Terraform version | Remove the parameter from `mock_provider` |
| "Unsupported block type: locals" | Locals cannot be in run blocks | Use inline expressions instead |
| "Missing required provider" | Provider not initialized | Run `terraform init` before `terraform test` |
| "Test assertion failed" with cryptic message | Error message doesn't include actual values | Add `${variable}` to show actual value in error |
| Index out of range | For loop filter returns empty list | Add `length()` check before accessing `[0]` |
| Regex doesn't match | Escaping issues | Use `startswith()`, `contains()`, or `strcontains()` instead |

## Additional Resources

- [Terraform Tests Overview](https://developer.hashicorp.com/terraform/language/tests)
- [Test Mocking Documentation](https://developer.hashicorp.com/terraform/language/tests/mocking)
- [Write Terraform Tests Tutorial](https://developer.hashicorp.com/terraform/tutorials/configuration-language/test)
- [HCP Terraform Test Integration](https://developer.hashicorp.com/terraform/cloud-docs/registry/test)
- [Custom Conditions](https://developer.hashicorp.com/terraform/language/expressions/custom-conditions)
