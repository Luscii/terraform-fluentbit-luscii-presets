# Complete Example

This example demonstrates all features of the `terraform-fluentbit-configuration` module with a realistic ECS Fargate setup.

## Features Demonstrated

- Multiple log sources (PHP, Nginx, Datadog APM)
- Multiple containers using the same technology
- Custom parsers for application-specific formats
- Custom filters for log enrichment
- Integration with Luscii ECS Fargate container definitions module

## Architecture

This example simulates a typical microservice with:
- **app container**: PHP application (Laravel)
- **web container**: Nginx web server
- **worker container**: PHP queue worker
- **datadog container**: Datadog APM sidecar (optional)

## Usage

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# The example is designed to show configuration structure
# It will not actually create resources without proper AWS credentials and variables
```

## Configuration Overview

The example shows three different scenarios:

### 1. Basic Multi-Technology Setup
Simple configuration with PHP and Nginx for different containers.

### 2. Advanced Setup with Custom Configuration
Adds custom parsers and filters for application-specific needs.

### 3. Multi-Worker PHP Setup
Multiple PHP containers (app, worker, scheduler) with unified logging configuration.

## Integration with Container Definitions

The outputs from this module are designed to be used directly with:
```hcl
module "container_definitions" {
  source  = "Luscii/terraform-aws-ecs-fargate-datadog-container-definitions"
  version = "~> 0.1.8"

  log_config_parsers = module.log_config.log_config_parsers
  log_config_filters = module.log_config.log_config_filters
}
```

## Expected Outputs

The module will output:
- **log_config_parsers**: List of Fluent Bit parsers for all configured technologies
- **log_config_filters**: List of Fluent Bit filters including grep exclusions and modify enrichments

## Notes

- This example uses relative module source (`../../`) for demonstration
- In production, reference the module from Terraform Registry or Git
- The example includes CloudPosse label module for consistent naming
- Custom parsers and filters are merged with technology-specific configurations
