# Examples

This directory contains examples demonstrating how to use the `terraform-fluentbit-configuration` module in various scenarios.

## Available Examples

### [Complete](./complete/)
A comprehensive example showing all features of the module:
- Multiple log sources (PHP, Nginx, Datadog)
- Multiple containers for the same technology
- Custom parsers and filters
- Integration with ECS Fargate container definitions

## Running the Examples

Each example directory is self-contained and can be run independently:

```bash
cd complete/
terraform init
terraform plan
```

**Note**: The examples use the parent module via relative path (`source = "../../"`). In your actual implementation, you should reference the module from the Terraform Registry or a Git repository.

## Prerequisites

- Terraform >= 1.3
- AWS provider configuration (for complete example with ECS)

## Example Structure

Each example typically contains:
- `main.tf` - Main configuration demonstrating module usage
- `variables.tf` - Input variables for the example
- `outputs.tf` - Outputs showing module results
- `README.md` - Specific documentation for that example
- `versions.tf` - Terraform and provider version constraints
