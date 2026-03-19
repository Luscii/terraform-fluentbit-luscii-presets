
# terraform-fluentbit-configuration

Centralized Fluent Bit configuration for Luscii ECS/Fargate workloads, supporting PHP, Nginx, Envoy, Datadog, .NET, and Node.js log parsing and filtering. Implements a parser-filter architecture (see [ADR-0002](docs/adr/0002-parser-filter-architecture.md)).

**Default JSON Parsers:** This module includes default JSON parsers that handle various ISO 8601 datetime formats for `time` (AWS built-in json parser), `datetime` (PHP, general logs), and `time_local` (Nginx, web servers) fields, preventing "invalid time format" errors in Fluent Bit. These parsers are always included regardless of the `log_sources` configuration.

## .NET Logging Support

This module provides full .NET logging support, including:

- Parsers for .NET text, JSON, and Serilog log formats
- Filters for health check/static asset exclusion, profile image warnings, log level filtering, and log source enrichment
- Container-specific match patterns for robust routing
- Comprehensive tests and scenarios (see [ADR-0006](docs/adr/0006-dotnet-pending-implementation.md))

See `dotnet-config.tf`, `tests/dotnet-config.tftest.hcl`, and `docs/features/dotnet-logging.feature` for details.

## Node.js Pino Logging Support

This module provides full Node.js Pino logging support, including:

- Parsers for Pino JSON logs with ISO 8601 timestamp formats (UTC and timezone variants)
- Filters for health check/static asset exclusion, debug log filtering, and log source enrichment
- Container-specific match patterns for robust routing
- Comprehensive tests and scenarios (see [ADR-0007](docs/adr/0007-nodejs-pino-json-parser.md))

**⚠️ Important:** Pino must be configured with `timestamp: pino.stdTimeFunctions.isoTime` - the default millisecond epoch format is not supported.

See `nodejs-config.tf`, `tests/nodejs-config.tftest.hcl`, and `docs/features/nodejs-logging.feature` for details.


## Examples

### Minimal Setup

```terraform
module "fluentbit_config" {
  source = "github.com/Luscii/terraform-fluentbit-configuration"

  name        = "example"
  log_sources = [{ name = "dotnet", container = "dotnet-app" }]
  context     = module.label.context
}
```

### Advanced Setup with .NET Logging

```terraform
module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = "luscii"
  environment = "production"
  name        = "dotnet-app"
}

module "fluentbit_config" {
  source = "github.com/Luscii/terraform-fluentbit-configuration"

  name        = module.label.name
  log_sources = [{ name = "dotnet", container = "dotnet-app" }]
  custom_parsers = [
    # Add custom .NET parser if needed
  ]
  custom_filters = [
    # Add custom .NET filter if needed
  ]
  context = module.label.context
}

# Use outputs for ECS/Fargate task definitions
output "dotnet_parsers" {
  value = module.fluentbit_config.log_config_parsers
}
output "dotnet_filters" {
  value = module.fluentbit_config.log_config_filters
}
```

### Advanced Setup with Node.js Pino Logging

```terraform
module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = "luscii"
  environment = "production"
  name        = "nodejs-app"
}

module "fluentbit_config" {
  source = "github.com/Luscii/terraform-fluentbit-configuration"

  name        = module.label.name
  log_sources = [{ name = "nodejs", container = "nodejs-app" }]
  custom_parsers = [
    # Add custom Node.js parser if needed
  ]
  custom_filters = [
    # Add custom Node.js filter if needed
  ]
  context = module.label.context
}

# Use outputs for ECS/Fargate task definitions
output "nodejs_parsers" {
  value = module.fluentbit_config.log_config_parsers
}
output "nodejs_filters" {
  value = module.fluentbit_config.log_config_filters
}
```

### Pino Configuration Example

**⚠️ IMPORTANT:** Pino's default millisecond epoch format is NOT supported by Fluent Bit. You MUST configure Pino to use ISO 8601 timestamps.

**Required Pino configuration:**

```javascript
const pino = require('pino');

// Configure Pino with ISO 8601 timestamps (REQUIRED)
const logger = pino({ 
  timestamp: pino.stdTimeFunctions.isoTime 
});

logger.info('Server started');
// Output: {"level":30,"time":"2026-02-05T10:30:00.000Z","msg":"Server started"}
```

**Why the default Pino format doesn't work:**

Pino's default configuration outputs timestamps as milliseconds since epoch (e.g., `"time":1738755000000`). Fluent Bit's timestamp parser uses `strptime()`, which cannot parse millisecond epoch integers. See [Fluent Bit discussion #6502](https://github.com/fluent/fluent-bit/discussions/6502) for details.

### Multi-Technology Setup

```terraform
module "fluentbit_config" {
  source = "github.com/Luscii/terraform-fluentbit-configuration"

  name = "multi-tech-app"
  log_sources = [
    { name = "nodejs", container = "api" },
    { name = "nginx", container = "web" },
    { name = "php", container = "worker" }
  ]
  context = module.label.context
}
```

## AWS FireLens Integration

This module generates Fluent Bit parser and filter configurations designed for use with [AWS FireLens for Amazon ECS](https://aws.amazon.com/blogs/containers/under-the-hood-firelens-for-amazon-ecs-tasks/).

### Tag Format

FireLens automatically tags logs from each container using the format:
```
<container-name>-firelens-<task-id>
```

This module generates match patterns that align with this tag format. For example, a container named `app` will have logs tagged as `app-firelens-1234567890abc`, and the module will generate match patterns like `app-firelens-*` to route those logs correctly.

### How It Works

1. Specify your log sources with container names in the `log_sources` variable
2. The module generates technology-specific parsers and filters
3. Match patterns are automatically set to `<container-name>-firelens-*` for container-specific routing
4. Pass the outputs to your ECS container definition module for integration

For more details on how FireLens works under the hood, see the [AWS FireLens blog post](https://aws.amazon.com/blogs/containers/under-the-hood-firelens-for-amazon-ecs-tasks/).

## Configuration

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |

### Providers

No providers.

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_label"></a> [label](#module\_label) | cloudposse/label/null | 0.25.0 |

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br/>See description of individual variables for details.<br/>Leave string and numeric variables as `null` to use default value.<br/>Individual variable settings (non-null) override settings in context object,<br/>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br/>  "additional_tag_map": {},<br/>  "attributes": [],<br/>  "delimiter": null,<br/>  "descriptor_formats": {},<br/>  "enabled": true,<br/>  "environment": null,<br/>  "id_length_limit": null,<br/>  "label_key_case": null,<br/>  "label_order": [],<br/>  "label_value_case": null,<br/>  "labels_as_tags": [<br/>    "unset"<br/>  ],<br/>  "name": null,<br/>  "namespace": null,<br/>  "regex_replace_chars": null,<br/>  "stage": null,<br/>  "tags": {},<br/>  "tenant": null<br/>}</pre> | no |
| <a name="input_custom_filters"></a> [custom\_filters](#input\_custom\_filters) | Additional custom filter definitions to add beyond the standard technology-specific filters.<br/>These will be merged with the filters generated from log\_sources. | <pre>list(object({<br/>    name  = string<br/>    match = optional(string) # Tag pattern to match (e.g., 'app-firelens-*', 'web-firelens-*')<br/>    # Parser filter options<br/>    parser       = optional(string)      # Parser name to apply<br/>    key_name     = optional(string)      # Field name to parse (required for parser filter)<br/>    reserve_data = optional(bool, false) # Preserve all other fields in the record<br/>    preserve_key = optional(bool, false) # Keep the original key field after parsing<br/>    unescape_key = optional(bool, false) # Unescape the key field before parsing<br/>    # Grep filter options<br/>    regex   = optional(string) # Regex pattern to match<br/>    exclude = optional(string) # Regex pattern to exclude<br/>    # Modify filter options<br/>    add_fields    = optional(map(string))  # Fields to add<br/>    rename_fields = optional(map(string))  # Fields to rename (old_name = new_name)<br/>    remove_fields = optional(list(string)) # Fields to remove<br/>    # Nest filter options<br/>    operation     = optional(string)       # nest or lift<br/>    wildcard      = optional(list(string)) # Wildcard patterns<br/>    nest_under    = optional(string)       # Target field for nesting<br/>    nested_under  = optional(string)       # Source field for lifting<br/>    remove_prefix = optional(string)       # Prefix to remove from keys<br/>    add_prefix    = optional(string)       # Prefix to add to keys<br/>  }))</pre> | `[]` | no |
| <a name="input_custom_parsers"></a> [custom\_parsers](#input\_custom\_parsers) | Additional custom parser definitions to add beyond the standard technology-specific parsers.<br/>These will be merged with the parsers generated from log\_sources. | <pre>list(object({<br/>    name   = string<br/>    format = string<br/>    # JSON parser options<br/>    time_key    = optional(string)<br/>    time_format = optional(string)<br/>    time_keep   = optional(bool)<br/>    # Regex parser options<br/>    regex = optional(string)<br/>    # LTSV parser options (tab-separated values)<br/>    # Logfmt parser options<br/>    # Decoder options<br/>    decode_field    = optional(string)<br/>    decode_field_as = optional(string)<br/>    # Type casting<br/>    types = optional(string)<br/>    # Additional options<br/>    skip_empty_values = optional(bool)<br/>    # Filter configuration - controls when and how this parser is applied<br/>    filter = optional(object({<br/>      match        = optional(string)      # Tag pattern to match (e.g., 'app-firelens-*', 'web-firelens-*')<br/>      key_name     = optional(string)      # Field name to parse (e.g., 'log', 'message')<br/>      reserve_data = optional(bool, false) # Preserve all other fields in the record<br/>      preserve_key = optional(bool, false) # Keep the original key field after parsing<br/>      unescape_key = optional(bool, false) # Unescape the key field before parsing<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_log_sources"></a> [log\_sources](#input\_log\_sources) | List of log source configurations. Each source represents a technology/service that generates logs<br/>and requires specific parsing and filtering. The container field is optional and used to create<br/>container-specific match patterns for Fluentbit filters following the AWS FireLens tag format:<br/><container-name>-firelens-<task-id> (e.g., "app-firelens-*" for container "app"). | <pre>list(object({<br/>    name      = string                # Technology name (e.g., "php", "nginx", "envoy", "dotnet")<br/>    container = optional(string, "*") # Container name in ECS task. Defaults to "*" for all containers<br/>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the resource to be labeled. This is used to generate the label key and value. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_log_config_filters"></a> [log\_config\_filters](#output\_log\_config\_filters) | Configuration details for the filters to be used in terraform module: Luscii/terraform-aws-ecs-fargate-datadog-container-definitions |
| <a name="output_log_config_parsers"></a> [log\_config\_parsers](#output\_log\_config\_parsers) | Configuration details for the parser to be used in terraform module: Luscii/terraform-aws-ecs-fargate-datadog-container-definitions |
<!-- END_TF_DOCS -->
