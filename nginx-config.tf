locals {
  # Nginx parser configurations
  # These parsers handle common nginx log formats (access, error)
  nginx_parsers = [
    # 1. ISO 8601 JSON parser (preferred)
    {
      name        = "nginx_json_iso8601"
      format      = "json"
      time_key    = "time_local"
      time_format = "%Y-%m-%dT%H:%M:%S%z"
      time_keep   = false
      filter = {
        match        = "*" # AWS FireLens tag format: <container-name>-firelens-<task-id>
        key_name     = "log"
        reserve_data = true
        preserve_key = false
        unescape_key = false
      }
    },
    # 2. JSON parser (legacy)
    {
      name        = "nginx_json"
      format      = "json"
      time_key    = "time_local"
      time_format = "%d/%b/%Y:%H:%M:%S %z"
      time_keep   = false
      filter = {
        match        = "*" # AWS FireLens tag format: <container-name>-firelens-<task-id>
        key_name     = "log"
        reserve_data = true
        preserve_key = false
        unescape_key = false
      }
    }
  ]

  # Nginx filter configurations
  nginx_filters = [
    {
      name  = "modify"
      match = "*" # AWS FireLens tag format: <container-name>-firelens-<task-id>
      add_fields = {
        log_source = "nginx"
      }
    }
  ]

  # Map entry for this technology
  nginx_parsers_map = {
    nginx = local.nginx_parsers
  }

  nginx_filters_map = {
    nginx = local.nginx_filters
  }
}
