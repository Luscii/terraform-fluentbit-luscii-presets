################################################################################
# Basic Example Outputs
################################################################################

output "basic_parsers" {
  description = "Parsers configuration for basic example"
  value       = module.log_config_basic.log_config_parsers
}

output "basic_filters" {
  description = "Filters configuration for basic example"
  value       = module.log_config_basic.log_config_filters
}

output "basic_parsers_count" {
  description = "Number of parsers in basic example"
  value       = length(module.log_config_basic.log_config_parsers)
}

output "basic_filters_count" {
  description = "Number of filters in basic example"
  value       = length(module.log_config_basic.log_config_filters)
}

################################################################################
# Advanced Example Outputs
################################################################################

output "advanced_parsers" {
  description = "Parsers configuration for advanced example (including custom parsers)"
  value       = module.log_config_advanced.log_config_parsers
}

output "advanced_filters" {
  description = "Filters configuration for advanced example (including custom filters)"
  value       = module.log_config_advanced.log_config_filters
}

output "advanced_parsers_count" {
  description = "Number of parsers in advanced example"
  value       = length(module.log_config_advanced.log_config_parsers)
}

output "advanced_filters_count" {
  description = "Number of filters in advanced example"
  value       = length(module.log_config_advanced.log_config_filters)
}

################################################################################
# Workers Example Outputs
################################################################################

output "workers_parsers" {
  description = "Parsers configuration for workers example"
  value       = module.log_config_workers.log_config_parsers
}

output "workers_filters" {
  description = "Filters configuration for workers example"
  value       = module.log_config_workers.log_config_filters
}

output "workers_filters_count" {
  description = "Number of filters in workers example (should show multiple container matches)"
  value       = length(module.log_config_workers.log_config_filters)
}

################################################################################
# Example Usage Output
################################################################################

output "example_usage" {
  description = "Example of how to use these outputs in container definitions module"
  value = {
    parsers = "module.container_definitions.log_config_parsers = module.log_config_advanced.log_config_parsers"
    filters = "module.container_definitions.log_config_filters = module.log_config_advanced.log_config_filters"
  }
}
