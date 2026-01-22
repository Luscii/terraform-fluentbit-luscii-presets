---
applyTo: "outputs.tf"
---
# Terraform Outputs Instructions

## Quick Reference

**When defining module outputs:**
- `parsers` and `filters` outputs integrate with [terraform-aws-ecs-fargate-datadog-container-definitions](https://github.com/Luscii/terraform-aws-ecs-fargate-datadog-container-definitions)
- Follow Fluent Bit parser and filter structures (see examples below)
- Parser outputs can include optional filter configuration
- Use descriptive output descriptions

**Cross-references:**
- Output descriptions → [documentation.instructions.md](./documentation.instructions.md)
- Output structure and types → Use the **terraform-values** skill
- Integration with inputs → [terraform-inputs.instructions.md](./terraform-inputs.instructions.md)
- Terraform code style → [terraform.instructions.md](./terraform.instructions.md)

**External Documentation:**
- [Fluent Bit Parsers](https://docs.fluentbit.io/manual/data-pipeline/parsers)
- [Fluent Bit Filters](https://docs.fluentbit.io/manual/data-pipeline/filters)

---

## Overview

This module provides Fluent Bit parser and filter configurations to be consumed by the [terraform-aws-ecs-fargate-datadog-container-definitions](https://github.com/Luscii/terraform-aws-ecs-fargate-datadog-container-definitions) module.

**Key Outputs:**
- `parsers` → `log_config_parsers` variable
- `filters` → `log_config_filters` variable

## Integration with Consumer Module

### terraform-aws-ecs-fargate-datadog-container-definitions

This module's outputs are designed to integrate with the [terraform-aws-ecs-fargate-datadog-container-definitions](https://github.com/Luscii/terraform-aws-ecs-fargate-datadog-container-definitions) module, which provides ECS Fargate tasks with Datadog monitoring and logging capabilities.

**Integration Pattern:**
```hcl
module "fluentbit_config" {
  source = "github.com/Luscii/terraform-fluentbit-configuration"

  log_sources = [
    { name = "php", container = "app" }
  ]
}

module "container_definitions" {
  source = "github.com/Luscii/terraform-aws-ecs-fargate-datadog-container-definitions"

  log_config_parsers = module.fluentbit_config.parsers
  log_config_filters = module.fluentbit_config.filters
  # ... other configuration
}
```

## Output Structure Reference

## Output Structure Reference

The outputs must conform to the variable structure expected by the consumer module. Below are the type definitions and validation rules.

### Parsers Output Structure
```hcl
variable "log_config_parsers" {
  description = "Custom parser definitions for Fluent Bit log processing. Each parser can extract and transform log data using formats like json, regex, ltsv, or logfmt. The optional filter section controls when and how the parser is applied to log records. Required for Fluent Bit v3.x YAML configurations. See: https://docs.fluentbit.io/manual/data-pipeline/parsers/configuring-parser and https://docs.fluentbit.io/manual/pipeline/filters/parser"
  type = list(object({
    name   = string
    format = string
    # JSON parser options
    time_key    = optional(string)
    time_format = optional(string)
    time_keep   = optional(bool)
    # Regex parser options
    regex = optional(string)
    # LTSV parser options (tab-separated values)
    # Logfmt parser options
    # Decoder options
    decode_field    = optional(string)
    decode_field_as = optional(string)
    # Type casting
    types = optional(string)
    # Additional options
    skip_empty_values = optional(bool)
    # Filter configuration - controls when and how this parser is applied
    filter = optional(object({
      match        = optional(string)      # Tag pattern to match (e.g., 'docker.*', 'app.logs')
      key_name     = optional(string)      # Field name to parse (e.g., 'log', 'message')
      reserve_data = optional(bool, false) # Preserve all other fields in the record
      preserve_key = optional(bool, false) # Keep the original key field after parsing
      unescape_key = optional(bool, false) # Unescape the key field before parsing
    }))
  }))
  default = []

  validation {
    condition = alltrue([
      for parser in var.log_config_parsers :
      contains(["json", "regex", "ltsv", "logfmt"], parser.format)
    ])
    error_message = "Parser format must be one of: json, regex, ltsv, logfmt"
  }

  validation {
    condition = alltrue([
      for parser in var.log_config_parsers :
      parser.format != "regex" || parser.regex != null
    ])
    error_message = "Regex parser requires 'regex' field to be set"
  }

  validation {
    condition = alltrue([
      for parser in var.log_config_parsers :
      parser.filter == null || parser.filter.key_name != null
    ])
    error_message = "When filter is specified, 'key_name' is required to identify which field to parse"
  }
}
```

**Key Validations:**
- Parser `format` must be one of: `json`, `regex`, `ltsv`, `logfmt`
- Regex parsers require `regex` field
- Parser filters require `key_name` when `filter` is specified

### Filters Output Structure
```hcl
variable "log_config_filters" {
  description = "Custom filter definitions for Fluent Bit log processing. Filters can modify, enrich, or drop log records. Common filter types include grep (include/exclude), modify (add/rename/remove fields), nest (restructure data), and kubernetes (enrich with K8s metadata). See: https://docs.fluentbit.io/manual/pipeline/filters"
  type = list(object({
    name  = string
    match = optional(string) # Tag pattern to match (e.g., 'docker.*', 'app.logs')
    # Parser filter options
    parser       = optional(string)      # Parser name to apply
    key_name     = optional(string)      # Field name to parse (required for parser filter)
    reserve_data = optional(bool, false) # Preserve all other fields in the record
    preserve_key = optional(bool, false) # Keep the original key field after parsing
    unescape_key = optional(bool, false) # Unescape the key field before parsing
    # Grep filter options
    regex   = optional(string) # Regex pattern to match
    exclude = optional(string) # Regex pattern to exclude
    # Modify filter options
    add_fields    = optional(map(string))  # Fields to add
    rename_fields = optional(map(string))  # Fields to rename (old_name = new_name)
    remove_fields = optional(list(string)) # Fields to remove
    # Nest filter options
    operation     = optional(string)       # nest or lift
    wildcard      = optional(list(string)) # Wildcard patterns
    nest_under    = optional(string)       # Target field for nesting
    nested_under  = optional(string)       # Source field for lifting
    remove_prefix = optional(string)       # Prefix to remove from keys
    add_prefix    = optional(string)       # Prefix to add to keys
  }))
  default = []

  validation {
    condition = alltrue([
      for filter in var.log_config_filters :
      filter.name == "parser" ? filter.key_name != null : true
    ])
    error_message = "Parser filter requires 'key_name' to identify which field to parse"
  }

  validation {
    condition = alltrue([
      for filter in var.log_config_filters :
      filter.name == "parser" ? filter.parser != null : true
    ])
    error_message = "Parser filter requires 'parser' field to specify which parser to use"
  }

  validation {
    condition = alltrue([
      for filter in var.log_config_filters :
      filter.name == "nest" ? filter.operation != null : true
    ])
    error_message = "Nest filter requires 'operation' field (nest or lift)"
  }
}
```

**Key Validations:**
- Parser filters require both `parser` and `key_name` fields
- Nest filters require `operation` field (nest or lift)

## Output Examples

### JSON Parser with Filter

```hcl
output "parsers" {
  description = "Fluent Bit parser definitions for integration with terraform-aws-ecs-fargate-datadog-container-definitions"
  value = [
    {
      name   = "docker_json"
      format = "json"
      time_key    = "time"
      time_format = "%Y-%m-%dT%H:%M:%S.%LZ"
      time_keep   = false
      filter = {
        match        = "docker.*"
        key_name     = "log"
        reserve_data = true
        preserve_key = false
        unescape_key = false
      }
    }
  ]
}

output "filters" {
  description = "Fluent Bit filter definitions for integration with terraform-aws-ecs-fargate-datadog-container-definitions"
  value = [
    {
      name  = "modify"
      match = "docker.*"
      add_fields = {
        environment = "production"
        service     = "api"
      }
    },
    {
      name     = "grep"
      match    = "docker.*"
      regex    = "level (ERROR|WARN)"
      exclude  = null
    }
  ]
}
```

### Regex Parser

```hcl
parsers = [
  {
    name   = "nginx_access"
    format = "regex"
    regex  = "^(?<remote>[^ ]*) (?<host>[^ ]*) (?<user>[^ ]*) \\[(?<time>[^\\]]*)\\] \"(?<method>\\S+)(?: +(?<path>[^\\\"]*?)(?: +\\S*)?)?\" (?<code>[^ ]*) (?<size>[^ ]*)(?: \"(?<referer>[^\\\"]*)\" \"(?<agent>[^\\\"]*)\")?$"
    time_key    = "time"
    time_format = "%d/%b/%Y:%H:%M:%S %z"
    filter = {
      match        = "nginx.*"
      key_name     = "log"
      reserve_data = true
    }
  }
]
```

### Nest Filter

```hcl
filters = [
  {
    name       = "nest"
    match      = "app.*"
    operation  = "nest"
    wildcard   = ["level", "message", "timestamp"]
    nest_under = "log_data"
    add_prefix = "original_"
  }
]
```
