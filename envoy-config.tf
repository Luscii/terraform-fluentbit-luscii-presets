locals {
  # Envoy parser configurations
  # TODO: Add specific envoy parser configurations
  envoy_parsers = []

  # Envoy filter configurations
  # TODO: Add specific envoy filter configurations
  envoy_filters = [
    {
      name  = "modify"
      match = "*" # Will be overridden by container-specific pattern
      add_fields = {
        log_source = "envoy"
      }
    }
  ]

  # Map entry for this technology
  envoy_parsers_map = {
    envoy = local.envoy_parsers
  }

  envoy_filters_map = {
    envoy = local.envoy_filters
  }
}
