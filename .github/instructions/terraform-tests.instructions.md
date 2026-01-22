---
applyTo: "**/*.tftest.hcl,tests/**/*.tf"
---

# Terraform Testing Instructions

## Quick Reference

**When writing Terraform tests:**
- Test files: `*.tftest.hcl` in root or `tests/` directory
- Use `command = plan` for unit tests, `command = apply` for integration tests
- Mock providers with `mock_provider` blocks to avoid creating real infrastructure
- Helper modules in `tests/{setup,final}/` for test-specific resources
- Run tests: `terraform test` (local)

**For comprehensive testing patterns, syntax, and examples, see the **terraform-tests** skill**

**Cross-references:**
- Test syntax and block structure → Use the **terraform-tests** skill
- Mocking patterns → Use the **test-mocking** skill
- Assertion patterns → Use the **test-assertions** skill
- Test organization → Use the **test-organization-patterns** skill

---

## Required Structure

✅ **DO:**
- Name test files with `.tftest.hcl` extension
- Place tests in `tests/` directory
- Use `run` blocks for each test case
- Include descriptive test names: `run "test_resource_creation"`
- Write clear assertion error messages
- Clean up with helper modules or rely on automatic cleanup

❌ **DON'T:**
- Hardcode credentials in test files
- Create dependencies between test runs
- Use vague test names like `run "test1"`
- Skip error message descriptions in assertions
- Mix unit and integration tests in same file

## Test File Naming

✅ **DO:**
```
tests/basic.tftest.hcl
tests/integration.tftest.hcl
tests/unit.tftest.hcl
tests/validation.tftest.hcl
```

❌ **DON'T:**
```
test.hcl                    # Wrong extension
tests/test_basic.tftest.hcl # Redundant "test_" prefix
basicTest.tftest.hcl        # Not kebab-case
```

## Test Organization

⚠️ **ALWAYS:**
- Organize related tests in separate files
- Use helper modules for setup/teardown
- Keep unit tests separate from integration tests
- Group assertions logically within run blocks

✅ **RECOMMENDED:**
```
tests/
├── unit.tftest.hcl        # Fast, mocked tests
├── integration.tftest.hcl # Real resource tests
├── validation.tftest.hcl  # Input validation tests
└── setup/                 # Helper modules
    ├── main.tf
    └── outputs.tf
```

## Assertions

✅ **DO:**
- Write specific, focused assertions
- Include actual values in error messages
- Test both success and failure cases
- Use `try()` for potentially null values

```hcl
# ✅ Good
assert {
  condition     = aws_s3_bucket.bucket.bucket == "my-bucket"
  error_message = "Bucket name was ${aws_s3_bucket.bucket.bucket}, expected 'my-bucket'"
}

# ❌ Bad
assert {
  condition     = aws_s3_bucket.bucket.bucket != ""
  error_message = "Bucket name is wrong"
}
```

❌ **DON'T:**
- Write vague error messages
- Test multiple unrelated things in one assertion
- Assume values are non-null without checking

## Mocking

✅ **DO:**
- Use `mock_provider` for unit tests
- Override expensive resources in integration tests
- Provide realistic mock data
- Document why mocking is used

```hcl
# ✅ Good - Unit test with mocking
mock_provider "aws" {}

run "validate_naming_logic" {
  command = plan  # No real resources
}
```

❌ **DON'T:**
- Mock in integration tests unless necessary
- Use mocking as replacement for proper testing
- Forget to validate mock assumptions

## Variables

✅ **DO:**
- Define global variables for common values
- Override variables per run block when needed
- Use realistic test values
- Document required variables

```hcl
# ✅ Good
variables {
  environment = "test"
  region      = "us-east-1"
}

run "test_dev" {
  variables {
    environment = "dev"  # Override for this test
  }
}
```

❌ **DON'T:**
- Hardcode values in run blocks when reusable
- Use production values in tests
- Leave variables undocumented

## Running Tests

⚠️ **ALWAYS:**
- Run `terraform init` before testing
- Run tests locally before committing
- Check test output for errors
- Ensure cleanup happens automatically

✅ **RECOMMENDED:**
```bash
# Initialize
terraform init

# Run all tests
terraform test

# Run specific test file
terraform test tests/basic.tftest.hcl

# Verbose output
terraform test -verbose
```

## Pre-Commit Checklist

Before committing test files:

- [ ] All test files end with `.tftest.hcl`
- [ ] Tests pass locally: `terraform test`
- [ ] Test names are descriptive
- [ ] Assertions have helpful error messages
- [ ] No hardcoded credentials
- [ ] Mocking is used appropriately (unit tests)
- [ ] Helper modules are documented
- [ ] No dependencies between test runs

## Common Mistakes

❌ **Mistake 1: Tests depend on execution order**
```hcl
# ❌ Bad
run "create_resource" {
  # Creates something
}

run "check_resource" {
  # Assumes previous run succeeded
}
```

✅ **Fix: Make tests independent**
```hcl
# ✅ Good
run "test_resource_creation" {
  # Self-contained test
  variables {
    name = "test-1"
  }
}

run "test_resource_deletion" {
  # Independent test
  variables {
    name = "test-2"
  }
}
```

❌ **Mistake 2: Vague assertion messages**
```hcl
# ❌ Bad
assert {
  condition     = length(local.items) == 5
  error_message = "Wrong count"
}
```

✅ **Fix: Include actual values**
```hcl
# ✅ Good
assert {
  condition     = length(local.items) == 5
  error_message = "Expected 5 items, got ${length(local.items)}"
}
```

❌ **Mistake 3: Missing provider initialization**
```bash
# ❌ Bad - Missing terraform init
$ terraform test
Error: Missing required provider
```

✅ **Fix: Initialize first**
```bash
# ✅ Good
$ terraform init && terraform test
```

## Additional Resources

**For detailed testing documentation:**
- **terraform-tests** skill - Complete testing guide with examples
- **test-mocking** skill - Mocking patterns and strategies
- **test-assertions** skill - Assertion best practices
- **test-organization-patterns** skill - Test structure patterns

**External Resources:**
- [Terraform Tests Overview](https://developer.hashicorp.com/terraform/language/tests)
- [Test Mocking Documentation](https://developer.hashicorp.com/terraform/language/tests/mocking)
- [Write Terraform Tests Tutorial](https://developer.hashicorp.com/terraform/tutorials/configuration-language/test)
