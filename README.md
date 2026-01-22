# terraform-module-template

Template for creating Terraform modules

## Examples

```tf

module "this" {
  source = ""
}

```

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
| <a name="input_custom_filters"></a> [custom\_filters](#input\_custom\_filters) | Additional custom filter definitions to add beyond the standard technology-specific filters.<br/>These will be merged with the filters generated from log\_sources. | <pre>list(object({<br/>    name  = string<br/>    match = optional(string) # Tag pattern to match (e.g., 'docker.*', 'app.logs')<br/>    # Parser filter options<br/>    parser       = optional(string)      # Parser name to apply<br/>    key_name     = optional(string)      # Field name to parse (required for parser filter)<br/>    reserve_data = optional(bool, false) # Preserve all other fields in the record<br/>    preserve_key = optional(bool, false) # Keep the original key field after parsing<br/>    unescape_key = optional(bool, false) # Unescape the key field before parsing<br/>    # Grep filter options<br/>    regex   = optional(string) # Regex pattern to match<br/>    exclude = optional(string) # Regex pattern to exclude<br/>    # Modify filter options<br/>    add_fields    = optional(map(string))  # Fields to add<br/>    rename_fields = optional(map(string))  # Fields to rename (old_name = new_name)<br/>    remove_fields = optional(list(string)) # Fields to remove<br/>    # Nest filter options<br/>    operation     = optional(string)       # nest or lift<br/>    wildcard      = optional(list(string)) # Wildcard patterns<br/>    nest_under    = optional(string)       # Target field for nesting<br/>    nested_under  = optional(string)       # Source field for lifting<br/>    remove_prefix = optional(string)       # Prefix to remove from keys<br/>    add_prefix    = optional(string)       # Prefix to add to keys<br/>  }))</pre> | `[]` | no |
| <a name="input_custom_parsers"></a> [custom\_parsers](#input\_custom\_parsers) | Additional custom parser definitions to add beyond the standard technology-specific parsers.<br/>These will be merged with the parsers generated from log\_sources. | <pre>list(object({<br/>    name   = string<br/>    format = string<br/>    # JSON parser options<br/>    time_key    = optional(string)<br/>    time_format = optional(string)<br/>    time_keep   = optional(bool)<br/>    # Regex parser options<br/>    regex = optional(string)<br/>    # LTSV parser options (tab-separated values)<br/>    # Logfmt parser options<br/>    # Decoder options<br/>    decode_field    = optional(string)<br/>    decode_field_as = optional(string)<br/>    # Type casting<br/>    types = optional(string)<br/>    # Additional options<br/>    skip_empty_values = optional(bool)<br/>    # Filter configuration - controls when and how this parser is applied<br/>    filter = optional(object({<br/>      match        = optional(string)      # Tag pattern to match (e.g., 'docker.*', 'app.logs')<br/>      key_name     = optional(string)      # Field name to parse (e.g., 'log', 'message')<br/>      reserve_data = optional(bool, false) # Preserve all other fields in the record<br/>      preserve_key = optional(bool, false) # Keep the original key field after parsing<br/>      unescape_key = optional(bool, false) # Unescape the key field before parsing<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_log_sources"></a> [log\_sources](#input\_log\_sources) | List of log source configurations. Each source represents a technology/service that generates logs<br/>and requires specific parsing and filtering. The container field is optional and used to create<br/>container-specific match patterns for Fluentbit filters. | <pre>list(object({<br/>    name      = string                # Technology name (e.g., "php", "nginx", "envoy", "dotnet")<br/>    container = optional(string, "*") # Container name in ECS task. Defaults to "*" for all containers<br/>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the resource to be labeled. This is used to generate the label key and value. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_log_config_filters"></a> [log\_config\_filters](#output\_log\_config\_filters) | Configuration details for the filters to be used in terraform module: Luscii/terraform-aws-ecs-fargate-datadog-container-definitions |
| <a name="output_log_config_parsers"></a> [log\_config\_parsers](#output\_log\_config\_parsers) | Configuration details for the parser to be used in terraform module: Luscii/terraform-aws-ecs-fargate-datadog-container-definitions |
<!-- END_TF_DOCS -->
