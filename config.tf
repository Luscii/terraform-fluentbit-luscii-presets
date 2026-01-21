locals {
  # Group log sources by technology for easier processing
  log_sources_by_tech = {
    for source in var.log_sources :
    source.name => source...
  }

  # Collect all technology-specific parsers
  technology_parsers = concat(
    flatten([
      for tech, sources in local.log_sources_by_tech :
      lookup(local.technology_parsers_map, tech, [])
    ])
  )

  # Collect all technology-specific filters with container matching
  technology_filters = flatten([
    for source in var.log_sources : [
      for filter in lookup(local.technology_filters_map, source.name, []) :
      merge(filter, {
        # Override match pattern to include container name if specified
        match = source.container != "*" ? "container-${source.container}-*" : filter.match
      })
    ]
  ])

  # Map of technology name to their parsers (populated by tech-specific config files)
  technology_parsers_map = merge(
    local.php_parsers_map,
    local.nginx_parsers_map,
    local.envoy_parsers_map,
    local.dotnet_parsers_map,
  )

  # Map of technology name to their filters (populated by tech-specific config files)
  technology_filters_map = merge(
    local.php_filters_map,
    local.nginx_filters_map,
    local.envoy_filters_map,
    local.dotnet_filters_map,
  )

  # Final combined parsers: technology-specific + custom
  parser_config = distinct(concat(
    local.technology_parsers,
    var.custom_parsers
  ))

  # Final combined filters: technology-specific + custom
  filters_config = distinct(concat(
    local.technology_filters,
    var.custom_filters
  ))
}
