output "log_config_parsers" {
  description = "Configuration details for the parser to be used in terraform module: Luscii/terraform-aws-ecs-fargate-datadog-container-definitions"
  value       = local.parser_config
}

output "log_config_filters" {
  description = "Configuration details for the filters to be used in terraform module: Luscii/terraform-aws-ecs-fargate-datadog-container-definitions"
  value       = local.filters_config
}
