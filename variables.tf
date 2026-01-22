variable "context" {
  type = any
  default = {
    enabled             = true
    namespace           = null
    tenant              = null
    environment         = null
    stage               = null
    name                = null
    delimiter           = null
    attributes          = []
    tags                = {}
    additional_tag_map  = {}
    regex_replace_chars = null
    label_order         = []
    id_length_limit     = null
    label_key_case      = null
    label_value_case    = null
    descriptor_formats  = {}
    # Note: we have to use [] instead of null for unset lists due to
    # https://github.com/hashicorp/terraform/issues/28137
    # which was not fixed until Terraform 1.0.0,
    # but we want the default to be all the labels in `label_order`
    # and we want users to be able to prevent all tag generation
    # by setting `labels_as_tags` to `[]`, so we need
    # a different sentinel to indicate "default"
    labels_as_tags = ["unset"]
  }
  description = <<-EOT
    Single object for setting entire context at once.
    See description of individual variables for details.
    Leave string and numeric variables as `null` to use default value.
    Individual variable settings (non-null) override settings in context object,
    except for attributes, tags, and additional_tag_map, which are merged.
  EOT

  validation {
    condition     = lookup(var.context, "label_key_case", null) == null ? true : contains(["lower", "title", "upper"], var.context["label_key_case"])
    error_message = "Allowed values: `lower`, `title`, `upper`."
  }

  validation {
    condition     = lookup(var.context, "label_value_case", null) == null ? true : contains(["lower", "title", "upper", "none"], var.context["label_value_case"])
    error_message = "Allowed values: `lower`, `title`, `upper`, `none`."
  }
}

variable "name" {
  type        = string
  description = "Name of the resource to be labeled. This is used to generate the label key and value."
}

variable "log_sources" {
  description = <<-EOT
    List of log source configurations. Each source represents a technology/service that generates logs
    and requires specific parsing and filtering. The container field is optional and used to create
    container-specific match patterns for Fluentbit filters.
  EOT
  type = list(object({
    name      = string                # Technology name (e.g., "php", "nginx", "envoy", "dotnet")
    container = optional(string, "*") # Container name in ECS task. Defaults to "*" for all containers
  }))
  default = []

  validation {
    condition = alltrue([
      for source in var.log_sources :
      contains(["php", "nginx", "envoy", "dotnet", "datadog"], source.name)
    ])
    error_message = "Supported log source technologies are: php, nginx, envoy, dotnet, datadog"
  }

  validation {
    condition = length(var.log_sources) == length(distinct([
      for source in var.log_sources :
      "${source.name}-${source.container}"
    ]))
    error_message = "Each combination of technology name and container must be unique"
  }
}

variable "custom_parsers" {
  description = <<-EOT
    Additional custom parser definitions to add beyond the standard technology-specific parsers.
    These will be merged with the parsers generated from log_sources.
  EOT
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
      for parser in var.custom_parsers :
      contains(["json", "regex", "ltsv", "logfmt"], parser.format)
    ])
    error_message = "Parser format must be one of: json, regex, ltsv, logfmt"
  }

  validation {
    condition = alltrue([
      for parser in var.custom_parsers :
      parser.format != "regex" || parser.regex != null
    ])
    error_message = "Regex parser requires 'regex' field to be set"
  }

  validation {
    condition = alltrue([
      for parser in var.custom_parsers :
      parser.filter == null || parser.filter.key_name != null
    ])
    error_message = "When filter is specified, 'key_name' is required to identify which field to parse"
  }
}

variable "custom_filters" {
  description = <<-EOT
    Additional custom filter definitions to add beyond the standard technology-specific filters.
    These will be merged with the filters generated from log_sources.
  EOT
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
      for filter in var.custom_filters :
      filter.name == "parser" ? filter.key_name != null : true
    ])
    error_message = "Parser filter requires 'key_name' to identify which field to parse"
  }

  validation {
    condition = alltrue([
      for filter in var.custom_filters :
      filter.name == "parser" ? filter.parser != null : true
    ])
    error_message = "Parser filter requires 'parser' field to specify which parser to use"
  }

  validation {
    condition = alltrue([
      for filter in var.custom_filters :
      filter.name == "nest" ? filter.operation != null : true
    ])
    error_message = "Nest filter requires 'operation' field (nest or lift)"
  }
}
