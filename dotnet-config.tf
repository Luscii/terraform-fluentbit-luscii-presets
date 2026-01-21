locals {
  # .NET parser configurations
  # TODO: Add specific .NET parser configurations
  dotnet_parsers = []

  # .NET filter configurations
  # TODO: Add specific .NET filter configurations
  dotnet_filters = [
    {
      name  = "modify"
      match = "*" # Will be overridden by container-specific pattern
      add_fields = {
        log_source = "dotnet"
      }
    }
  ]

  # Map entry for this technology
  dotnet_parsers_map = {
    dotnet = local.dotnet_parsers
  }

  dotnet_filters_map = {
    dotnet = local.dotnet_filters
  }
}
