---
applyTo: "**/variables.tf"
---
# Terraform Inputs Instructions

## Quick Reference

**When defining module inputs:**
- Use `log_sources` list to specify technologies: "php", "nginx", "envoy", "dotnet"
- Set optional `container` for container-specific filtering (defaults to "*")
- Use `custom_parsers` and `custom_filters` for extensions
- Each technology + container combination must be unique

**Cross-references:**
- Variable descriptions → [documentation.instructions.md](./documentation.instructions.md)
- Variable validation patterns → Use the **terraform-values** skill
- Variable types and complex objects → Use the **terraform-values** skill
- Output structure → [terraform-outputs.instructions.md](./terraform-outputs.instructions.md)
- Terraform code style → [terraform.instructions.md](./terraform.instructions.md)

---

## Overview

This module provides standardized Fluent Bit parser and filter configurations for common technologies used in ECS Fargate services.

## Core Concepts

### Log Sources
The `log_sources` variable is the primary way to configure this module. Each log source represents a technology/service that generates logs requiring specific parsing and filtering.

**Supported Technologies:**
- `php` - PHP application logs (monolog, error logs)
- `nginx` - Nginx web server logs (access, error)
- `envoy` - Envoy proxy logs
- `dotnet` - .NET application logs
- `datadog` - Datadog specific logs (APM, etc)

### Container Matching
Each log source can optionally specify a container name. This is used to create container-specific match patterns for Fluent Bit filters:
- If container is specified (e.g., `"app"`): match pattern becomes `container-app-*`
- If container is `"*"` or omitted: uses wildcard matching for all containers

### Custom Configurations
Users can extend the module with custom parsers and filters beyond the technology-specific defaults:
- `custom_parsers`: Additional parser definitions merged with technology parsers
- `custom_filters`: Additional filter definitions merged with technology filters

## Variable Structure

### log_sources
```hcl
variable "log_sources" {
  type = list(object({
    name      = string                # Technology: "php", "nginx", "envoy", "dotnet"
    container = optional(string, "*") # Container name in ECS task, defaults to "*"
  }))
}
```

**Validations:**
- Technology name must be one of the supported values
- Each combination of technology + container must be unique

**Examples:**
```hcl
# Single technology, specific container
log_sources = [
  { name = "php", container = "app" }
]

# Multiple technologies, different containers
log_sources = [
  { name = "php", container = "app" },
  { name = "nginx", container = "web" }
]

# Technology without container specification (uses wildcard)
log_sources = [
  { name = "envoy" }  # container defaults to "*"
]

# Same technology, multiple containers
log_sources = [
  { name = "php", container = "app" },
  { name = "php", container = "worker" }
]
```

### custom_parsers
Follows the same structure as `log_config_parsers` from the consumer module. See [terraform-outputs.instructions.md](./terraform-outputs.instructions.md) for detailed structure.

**Use cases:**
- Adding parsers for custom application formats
- Handling non-standard log formats
- Supporting technologies not yet built into the module

### custom_filters
Follows the same structure as `log_config_filters` from the consumer module. See [terraform-outputs.instructions.md](./terraform-outputs.instructions.md) for detailed structure.

**Use cases:**
- Adding environment-specific metadata
- Implementing custom log transformations
- Filtering sensitive data from logs

## Implementation Notes

### Adding New Technologies
To add support for a new technology:

1. Create `<technology>-config.tf` with:
   ```hcl
   locals {
     <tech>_parsers = [...]
     <tech>_filters = [...]
     <tech>_parsers_map = { <tech> = local.<tech>_parsers }
     <tech>_filters_map = { <tech> = local.<tech>_filters }
   }
   ```

2. Update `variables.tf` validation to include new technology name

3. Update `config.tf` to merge the new maps:
   ```hcl
   technology_parsers_map = merge(
     # ... existing
     local.<tech>_parsers_map,
   )
   ```

### Match Pattern Override
The module automatically overrides match patterns in technology-specific filters based on the container name specified in `log_sources`. This ensures filters only apply to logs from the intended containers.
