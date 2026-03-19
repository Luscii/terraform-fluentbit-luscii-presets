locals {
  # .NET parser configurations
  dotnet_parsers = [
    {
      name   = "dotnet_text"
      format = "regex"
      regex  = "^(?<level>\\w+): (?<category>[\\w\\.]+)\\[(?<event_id>\\d+)\\]\\s+(?<message>.*)$"
      types  = "level:string category:string event_id:string message:string"
    },
    {
      name   = "dotnet_json"
      format = "json"
    },
    {
      name   = "dotnet_serilog"
      format = "json"
    }
  ]

  # .NET filter configurations
  dotnet_filters = [
    # 1. Grep filter: exclude health checks/static assets
    {
      name    = "grep"
      match   = "*" # AWS FireLens tag format: <container-name>-firelens-<task-id>
      exclude = "message .*health.*|.*static.*"
    },
    # 2. Grep filter: exclude profile image warnings
    {
      name    = "grep"
      match   = "*" # AWS FireLens tag format: <container-name>-firelens-<task-id>
      exclude = "message .*Image not found for userId.*"
    },
    # 3. Modify filter: enrich with log_source
    {
      name  = "modify"
      match = "*" # AWS FireLens tag format: <container-name>-firelens-<task-id>
      add_fields = {
        log_source = "dotnet"
      }
    },
    # 4. Loglevel filter: drop debug/trace
    {
      name    = "grep"
      match   = "*" # AWS FireLens tag format: <container-name>-firelens-<task-id>
      exclude = "level debug|trace"
    },
    # 5. Loglevel filter: allow info/warn/error
    {
      name  = "grep"
      match = "*" # AWS FireLens tag format: <container-name>-firelens-<task-id>
      regex = "level info|warn|error|critical"
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
