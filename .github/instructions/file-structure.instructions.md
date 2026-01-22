---
applyTo: "**"
---

# Terraform Module File and Directory Structure Instructions

## Quick Reference

**Standard Terraform module structure:**
- Root: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, `README.md`, `LICENSE`
- Optional root: `locals.tf`, `backend.tf`, `{resource-type}.tf`
- Directories: `modules/`, `examples/`, `tests/`, `.github/`
- Naming: kebab-case for files/directories, snake_case for resources/variables
- File size: Split files >500 lines by logical grouping
- Repository: `terraform-{provider}-{name}`

**Cross-references:**
- Terraform code style → [terraform.instructions.md](./terraform.instructions.md)
- Module development, composition, providers → Use the **terraform-modules** skill
- Documentation → [documentation.instructions.md](./documentation.instructions.md)
- Examples → [examples.instructions.md](./examples.instructions.md)
- Tests → [terraform-tests.instructions.md](./terraform-tests.instructions.md)
- Visual diagrams → Use the **mermaid-diagrams** skill for module structure visualizations
- Feature file organization → Use the **feature-file-organization** skill for docs/features/ structure
- Refactoring/reorganizing → Use the **terraform-refactoring** skill for safe file/module restructuring

---

## Overview

A well-structured Terraform module follows consistent conventions that make it easy for users to understand, use, and maintain. This guide defines the standard file and directory structure for Terraform modules, particularly those following Luscii standards.

## Repository Naming

### Standard Repository Names

**Format:** `terraform-{provider}-{name}`

**Examples:**
- `terraform-aws-vpc`
- `terraform-aws-ecs-service`
- `terraform-aws-load-balancer`
- `terraform-google-gke-cluster`
- `terraform-azurerm-storage-account`

**Rules:**
- Always start with `terraform-`
- Include provider name (aws, google, azurerm, etc.)
- Use descriptive, concise names for the resource/module purpose
- Use hyphens to separate words in the name portion
- Keep names focused on single infrastructure concerns

**Special Cases:**
- Multi-provider modules: `terraform-multi-{name}` (rare)
- Utility modules: `terraform-{provider}-{utility-name}`

## Root Directory Structure

### Required Files

Every Terraform module **must** include these files:

```
terraform-{provider}-{name}/
├── main.tf           # Primary resource definitions
├── variables.tf      # Input variable declarations
├── outputs.tf        # Output value declarations
├── versions.tf       # Version constraints
└── README.md         # Module documentation
```

**File Purposes:**

**main.tf**
- Primary entry point for the module
- Contains main resource definitions
- Includes data sources
- Contains module calls to CloudPosse label
- May contain central locals

**variables.tf**
- All input variable declarations
- **Required order:** `context` variable first, then alphabetical
- Each variable must have a description
- Include validation blocks where appropriate
- Use type constraints

**outputs.tf**
- All output value declarations
- **Alphabetical order**
- Each output must have a description
- Mark sensitive outputs appropriately
- Document output usage

**versions.tf**
- Terraform version constraints
- Provider version constraints
- Required providers block
- Backend configuration (for root modules only)

**README.md**
- Module description
- Usage examples (minimal and advanced)
- Auto-generated documentation (terraform-docs)
- Prerequisites
- License information

### Recommended Files

These files are strongly recommended:

```
terraform-{provider}-{name}/
├── LICENSE           # License file (especially for public modules)
├── .gitignore        # Git ignore patterns
├── .terraform-docs.yml  # terraform-docs configuration
├── .pre-commit-config.yaml  # Pre-commit hooks configuration
└── .editorconfig     # Editor configuration
```

**LICENSE**
- Required for public modules
- Common choices: Apache 2.0, MIT, MPL-2.0
- Matches organization's license policy

**.gitignore**
- Standard Terraform ignore patterns
- Exclude `.terraform/`, `*.tfstate`, `*.tfvars`
- Exclude `.terraform.lock.hcl` if needed
- Exclude local tfvars files like `local.auto.tfvars` and `local.tfvars`

**.terraform-docs.yml**
- Configuration for terraform-docs
- Specifies output format
- Controls what gets documented

**.pre-commit-config.yaml**
- Pre-commit hooks configuration
- Includes terraform fmt, validate
- Security scanning (checkov, tfsec)
- terraform-docs generation

**.editorconfig**
- Consistent editor settings
- 2-space indentation for .tf files
- UTF-8 encoding
- LF line endings

### Optional Root Files

Create these files when needed:

**locals.tf**
- Local value definitions
- Use when locals are complex or numerous
- Keep simple locals in main.tf

**backend.tf**
- Backend configuration (root modules only)
- State storage configuration
- Remote backend settings

**{resource-type}.tf**
- Resource-specific files for better organization
- Examples: `network.tf`, `security-group.tf`, `iam-role-policies.tf`
- Use when main.tf becomes too large (>500 lines)

**data.tf**
- Data source definitions
- Use when many data sources exist
- Alternative: keep data sources in main.tf

## File Organization Patterns

### Pattern 1: Simple Module

**When to use:** Small modules with <300 lines of code

```
terraform-aws-simple/
├── main.tf           # All resources and data sources
├── variables.tf      # All variables
├── outputs.tf        # All outputs
├── versions.tf       # Version constraints
├── README.md         # Documentation
└── LICENSE           # License file
```

**Characteristics:**
- Everything in standard files
- No additional .tf files
- Single, focused purpose
- Minimal complexity

### Pattern 2: Medium Module

**When to use:** Modules with 300-1000 lines, multiple resource types

```
terraform-aws-medium/
├── main.tf              # Primary resources, data sources, label module
├── variables.tf         # All variables (alphabetical, context first)
├── outputs.tf           # All outputs (alphabetical)
├── versions.tf          # Version constraints
├── locals.tf            # Local value definitions
├── security-group.tf    # Security group resources
├── iam-role-policies.tf # IAM resources
├── README.md            # Documentation
└── LICENSE              # License file
```

**Characteristics:**
- Split by logical resource grouping
- Each file focuses on related resources
- locals.tf for complex local values
- Resource-specific files for clarity

### Pattern 3: Complex Module

**When to use:** Large modules with >1000 lines, multiple concerns

```
terraform-aws-complex/
├── main.tf                 # Core resources, data sources
├── variables.tf            # All variables
├── outputs.tf              # All outputs
├── versions.tf             # Version constraints
├── locals.tf               # Local value definitions
├── network.tf              # Networking resources
├── compute.tf              # Compute resources
├── storage.tf              # Storage resources
├── security.tf             # Security groups, NACLs
├── iam-role-policies.tf    # IAM roles and policies
├── monitoring.tf           # CloudWatch, logging
├── scaling.tf              # Auto-scaling configuration
├── README.md               # Documentation
├── LICENSE                 # License file
└── modules/                # Nested modules
    ├── submodule-a/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md       # If externally usable
    └── submodule-b/
        ├── main.tf         # Internal-only (no README)
        ├── variables.tf
        └── outputs.tf
```

**Characteristics:**
- Multiple resource-type files
- Nested modules for sub-components
- Clear separation of concerns
- Comprehensive organization

## Directory Structure

### modules/ Directory

**Purpose:** Nested/child modules

```
modules/
├── network/              # Public-facing nested module
│   ├── README.md         # Documentation for this module
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── versions.tf
└── internal-helper/      # Internal-only module
    ├── main.tf           # No README = internal use only
    ├── variables.tf
    └── outputs.tf
```

**Best Practices:**
- **With README.md:** Module can be used independently
- **Without README.md:** Internal implementation detail
- Each module is self-contained
- Follow same file structure as root module
- Use descriptive directory names (kebab-case)

**When to Create Nested Modules:**
- Reusable sub-components
- Complex configurations that need encapsulation
- Different combinations of the same resources
- Logical grouping of related resources

### examples/ Directory

**Purpose:** Usage examples demonstrating module usage

**See [examples.instructions.md](./examples.instructions.md) for comprehensive guidance.**

```
examples/
├── README.md             # Overview of all examples
├── basic/                # Minimal example
│   ├── README.md
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── versions.tf
├── complete/             # Full-featured example
│   ├── README.md
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── versions.tf
└── {scenario}/           # Scenario-specific examples
    ├── README.md
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── versions.tf
```

**Best Practices:**
- Each example is independently runnable
- Use `source = "../../"` to reference parent module
- Include README.md in each example directory
- Provide realistic, working configurations
- Document prerequisites and cleanup steps

### tests/ Directory

**Purpose:** Terraform tests for validation

**See [terraform-tests.instructions.md](./terraform-tests.instructions.md) for comprehensive guidance.**

```
tests/
├── basic.tftest.hcl         # Basic tests
├── integration.tftest.hcl   # Integration tests
├── unit.tftest.hcl          # Unit tests with mocking
├── setup/                   # Helper module for test setup
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── final/                   # Helper module for validation
│   ├── main.tf
│   └── variables.tf
└── mocks/                   # Shared mock data
    └── aws.tfmock.hcl
```

**Best Practices:**
- Test files end with `.tftest.hcl`
- Helper modules in subdirectories
- Separate unit and integration tests
- Use mocking for unit tests
- Document test purpose and prerequisites

### .github/ Directory

**Purpose:** GitHub-specific configurations

```
.github/
├── workflows/
│   ├── ci.yml               # Continuous integration
│   ├── pre-commit.yml       # Pre-commit checks
│   ├── release.yml          # Release automation
│   └── terraform-docs.yml   # Documentation generation
├── CODEOWNERS               # Code ownership
├── dependabot.yml           # Dependency updates
└── instructions/            # AI instructions
    ├── terraform.instructions.md
    ├── documentation.instructions.md
    ├── examples.instructions.md
    ├── terraform-tests.instructions.md
    └── file-structure.instructions.md
```

**Best Practices:**
- Automated CI/CD workflows
- Code ownership for reviews
- Automated dependency updates
- AI instructions for consistency

## File Naming Conventions

### Terraform Files

**Standard Files:**
- `main.tf` - Always lowercase, no variations
- `variables.tf` - Always lowercase, plural
- `outputs.tf` - Always lowercase, plural
- `versions.tf` - Always lowercase, plural

**Resource-Specific Files:**
- Use **kebab-case** for multi-word files
- Name after primary resource or functionality
- Be descriptive but concise

**Examples:**
```
✅ Good:
- security-group.tf
- iam-role-policies.tf
- access-logs.tf
- load-balancer.tf
- ecs-service.tf

❌ Bad:
- SecurityGroup.tf (not PascalCase)
- security_group.tf (not snake_case)
- sg.tf (not descriptive)
- aws_security_group.tf (redundant provider prefix)
```

### Test Files

**Format:** `{name}.tftest.hcl`

**Examples:**
```
✅ Good:
- basic.tftest.hcl
- integration.tftest.hcl
- unit.tftest.hcl
- validation.tftest.hcl

❌ Bad:
- test.hcl
- basic_test.tftest.hcl
- basicTest.tftest.hcl
```

### Mock Files

**Format:** `{provider}.tfmock.hcl`

**Examples:**
```
✅ Good:
- aws.tfmock.hcl
- google.tfmock.hcl
- azurerm.tfmock.hcl

❌ Bad:
- mock.hcl
- aws_mock.hcl
```

### Directories

**Use kebab-case for all directories:**

```
✅ Good:
- security-groups/
- load-balancers/
- ecs-services/
- access-logs/

❌ Bad:
- security_groups/
- SecurityGroups/
- securityGroups/
```

## File Size Guidelines

### When to Split Files

**Guidelines:**
- **main.tf > 500 lines:** Split into resource-type files
- **variables.tf > 100 variables:** Consider grouping with comments
- **outputs.tf > 100 outputs:** Consider grouping with comments
- **Single resource type > 300 lines:** Extract to separate file

### Splitting Strategies

**By Resource Type:**
```
main.tf              → Core resources, data sources
network.tf           → VPC, subnets, route tables
compute.tf           → EC2, ECS, Lambda
storage.tf           → S3, EBS, EFS
security.tf          → Security groups, NACLs
iam-role-policies.tf → IAM roles and policies
monitoring.tf        → CloudWatch, logging
```

**By Functionality:**
```
main.tf              → Core infrastructure
access-logs.tf       → Access logging configuration
scaling.tf           → Auto-scaling configuration
encryption.tf        → KMS, encryption settings
networking.tf        → All networking resources
```

**By Lifecycle:**
```
main.tf              → Primary resources
supporting.tf        → Supporting resources
dependencies.tf      → External dependencies
```

## File Content Organization

### main.tf Structure

**Recommended order:**

```hcl
# 1. Data sources (at the top)
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# 2. CloudPosse label module (always near the top)
module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  context = var.context
  name    = var.name
}

# 3. Central locals (if simple)
locals {
  enabled = module.label.enabled
  tags    = module.label.tags
}

# 4. Primary resources (main.tf focus)
resource "aws_ecs_service" "this" {
  name = module.label.id
  # ...
}

# 5. Supporting resources
resource "aws_ecs_task_definition" "this" {
  # ...
}

# 6. Conditional resources
resource "aws_appautoscaling_target" "this" {
  count = local.autoscaling_enabled ? 1 : 0
  # ...
}
```

### variables.tf Structure

**Required order:**

```hcl
# 1. Context variable (ALWAYS FIRST)
variable "context" {
  type = any
  default = {
    enabled             = true
    namespace           = null
    # ... full context definition
  }
  description = <<-EOT
    Single object for setting entire context at once.
    See description of individual variables for details.
  EOT

  validation {
    # ... validations
  }
}

# 2. All other variables (ALPHABETICAL ORDER)
variable "assign_public_ip" {
  type        = bool
  description = "Whether to assign a public IP to tasks"
  default     = false
}

variable "container_definitions" {
  type        = list(any)
  description = "List of container definitions"
}

# ... more variables in alphabetical order
```

**Variable Grouping (Optional):**

```hcl
# CloudPosse context (always first)
variable "context" { }

# ===== Networking Configuration =====
variable "assign_public_ip" { }
variable "subnets" { }
variable "vpc_id" { }

# ===== ECS Configuration =====
variable "cluster_name" { }
variable "desired_count" { }
variable "task_cpu" { }

# Note: Maintain alphabetical order within groups
```

### outputs.tf Structure

**Alphabetical order:**

```hcl
output "cluster_arn" {
  value       = aws_ecs_cluster.this.arn
  description = "ARN of the ECS cluster"
}

output "cluster_name" {
  value       = aws_ecs_cluster.this.name
  description = "Name of the ECS cluster"
}

output "service_arn" {
  value       = aws_ecs_service.this.id
  description = "ARN of the ECS service"
}

# ... more outputs in alphabetical order
```

**Output Grouping (Optional):**

```hcl
# ===== Cluster Outputs =====
output "cluster_arn" { }
output "cluster_name" { }

# ===== Service Outputs =====
output "service_arn" { }
output "service_name" { }

# ===== Network Outputs =====
output "security_group_id" { }
output "subnet_ids" { }

# Note: Maintain alphabetical order within groups
```

### versions.tf Structure

**Standard format:**

```hcl
terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9"  # Use >= 6.0 for newer modules
    }
  }
}

# For root modules only:
# backend "s3" {
#   # Backend configuration
# }
```

## Complete Module Structure Example

### Full Example: terraform-aws-ecs-service

```
terraform-aws-ecs-service/
├── .github/
│   ├── workflows/
│   │   ├── ci.yml
│   │   ├── pre-commit.yml
│   │   └── terraform-docs.yml
│   └── instructions/
│       ├── terraform.instructions.md
│       ├── documentation.instructions.md
│       ├── examples.instructions.md
│       ├── terraform-tests.instructions.md
│       └── file-structure.instructions.md
├── examples/
│   ├── README.md
│   ├── basic/
│   │   ├── README.md
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   └── complete/
│       ├── README.md
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── versions.tf
├── tests/
│   ├── basic.tftest.hcl
│   ├── integration.tftest.hcl
│   ├── setup/
│   │   ├── main.tf
│   │   └── outputs.tf
│   └── final/
│       └── main.tf
├── .editorconfig
├── .gitignore
├── .pre-commit-config.yaml
├── .terraform-docs.yml
├── LICENSE
├── README.md
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── locals.tf
├── security-group.tf
└── iam-role-policies.tf
```

## Best Practices

### Do's

✅ **Follow standard structure** - Use consistent file and directory names
✅ **Keep related code together** - Group related resources in same file
✅ **Use descriptive names** - File names should indicate contents
✅ **Maintain alphabetical order** - Variables and outputs
✅ **Document everything** - README, descriptions, comments
✅ **Split large files** - Keep files focused and manageable
✅ **Use nested modules** - For reusable components
✅ **Include examples** - Demonstrate module usage
✅ **Write tests** - Validate module behavior
✅ **Use .terraform-docs.yml** - Automate documentation generation

### Don'ts

❌ **Don't mix naming conventions** - Stick to kebab-case for files
❌ **Don't create unnecessary files** - Only split when needed
❌ **Don't duplicate code** - Use modules or locals instead
❌ **Don't skip README** - Every module needs documentation
❌ **Don't ignore file size** - Split large files for maintainability
❌ **Don't nest modules deeply** - Keep hierarchy shallow (2-3 levels max)
❌ **Don't use cryptic abbreviations** - Use clear, descriptive names
❌ **Don't skip tests** - Even simple modules need basic tests
❌ **Don't hardcode values** - Use variables for configurable values
❌ **Don't skip examples** - Users need working examples

## File Organization Checklist

Before committing a new module:

- [ ] Repository name follows `terraform-{provider}-{name}` format
- [ ] All required root files present (main.tf, variables.tf, outputs.tf, versions.tf, README.md)
- [ ] Variables in correct order (context first, then alphabetical)
- [ ] Outputs in alphabetical order
- [ ] Large files split appropriately (>500 lines)
- [ ] Resource-type files use kebab-case naming
- [ ] Examples directory with working examples
- [ ] Tests directory with test files
- [ ] .terraform-docs.yml configured
- [ ] .pre-commit-config.yaml set up
- [ ] .gitignore includes standard patterns
- [ ] LICENSE file present
- [ ] README.md complete with examples
- [ ] All files formatted with `terraform fmt`
- [ ] All tests pass with `terraform test`

## Migration Guide

### Restructuring an Existing Module

**When to restructure:**
- main.tf exceeds 500 lines
- Module becomes hard to navigate
- Adding significant new features
- Preparing for public release

**Steps:**

1. **Analyze current structure:**
   ```bash
   # Count lines in files
   wc -l *.tf

   # Identify logical groupings
   grep "^resource" *.tf | cut -d'"' -f2 | sort | uniq -c
   ```

2. **Plan file split:**
   - Group related resources
   - Create resource-type files
   - Keep main.tf for core resources

3. **Create new files:**
   ```bash
   # Example: Extract security groups
   touch security-group.tf
   # Move aws_security_group resources to security-group.tf
   ```

4. **Update documentation:**
   ```bash
   terraform-docs markdown . --output-file README.md
   ```

5. **Test changes:**
   ```bash
   terraform fmt -recursive
   terraform validate
   terraform test
   ```

6. **Update .terraform-docs.yml** if needed

7. **Commit changes:**
   ```bash
   git add .
   git commit -m "refactor: reorganize module file structure"
   ```

## Tool Configuration Examples

### .terraform-docs.yml

```yaml
formatter: markdown

version: 0.20.0

output:
  file: "README.md"
  mode: inject

output-values:
  enabled: false

sort:
  enabled: true
  by: name

settings:
  anchor: true
  color: true
  default: true
  description: false
  escape: true
  hide-empty: false
  html: true
  indent: 3
  lockfile: true
  read-comments: true
  required: true
  sensitive: true
  type: true
```

### .editorconfig

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.tf]
indent_style = space
indent_size = 2

[*.tfvars]
indent_style = space
indent_size = 2

[*.md]
trim_trailing_whitespace = false
```

### .gitignore

```
# Local .terraform directories
**/.terraform/*

# .tfstate files
*.tfstate
*.tfstate.*

# Crash log files
crash.log
crash.*.log

# Exclude all .tfvars files (may contain sensitive data)
*.tfvars
*.tfvars.json

# Ignore override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Ignore CLI configuration files
.terraformrc
terraform.rc

# Ignore lock file (optional, depends on team preference)
# .terraform.lock.hcl
```

### .pre-commit-config.yaml

```yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.88.0
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_docs
        args:
          - --hook-config=--path-to-file=README.md
          - --hook-config=--add-to-existing-file=true
          - --hook-config=--create-file-if-not-exist=true
      - id: terraform_tflint
        args:
          - --args=--config=__GIT_WORKING_DIR__/.tflint.hcl
      - id: terraform_checkov
        args:
          - --args=--config-file __GIT_WORKING_DIR__/.checkov-config.yml

  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
```

## Additional Resources

- [Terraform Module Structure](https://developer.hashicorp.com/terraform/language/modules/develop)
- [Standard Module Structure](https://developer.hashicorp.com/terraform/language/modules/develop/structure)
- [Module Publishing](https://developer.hashicorp.com/terraform/registry/modules/publish)
- [terraform-docs](https://terraform-docs.io/)
- [pre-commit-terraform](https://github.com/antonbabenko/pre-commit-terraform)
