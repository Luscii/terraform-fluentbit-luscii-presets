locals {
  # Nginx parser configurations
  # These parsers handle common nginx log formats (access, error)
  nginx_parsers = [
    {
      name        = "nginx_json"
      format      = "json"
      time_key    = "time_local"
      time_format = "%d/%b/%Y:%H:%M:%S %z"
      time_keep   = false
      filter = {
        match        = "*" # Will be overridden by container-specific pattern
        key_name     = "log"
        reserve_data = true
        preserve_key = false
        unescape_key = false
      }
    },
    {
      name        = "nginx_access"
      format      = "regex"
      regex       = "^(?<remote>[^ ]*) - (?<user>[^ ]*) \\[(?<time>[^\\]]*)\\] \"(?<method>\\S+)(?: +(?<path>[^\\\"]*?)(?: +\\S*)?)?\" (?<code>[^ ]*) (?<size>[^ ]*)(?: \"(?<referer>[^\\\"]*)\" \"(?<agent>[^\\\"]*)\")?$"
      time_key    = "time"
      time_format = "%d/%b/%Y:%H:%M:%S %z"
      filter = {
        match        = "*" # Will be overridden by container-specific pattern
        key_name     = "log"
        reserve_data = true
      }
    },
    {
      name        = "nginx_error"
      format      = "regex"
      regex       = "^(?<time>\\d{4}/\\d{2}/\\d{2} \\d{2}:\\d{2}:\\d{2}) \\[(?<level>\\w+)\\] (?<pid>\\d+).(?<tid>\\d+): (?<message>.*)$"
      time_key    = "time"
      time_format = "%Y/%m/%d %H:%M:%S"
      filter = {
        match        = "*"
        key_name     = "log"
        reserve_data = true
      }
    }
  ]

  # Nginx filter configurations
  nginx_filters = [
    {
      name  = "modify"
      match = "*" # Will be overridden by container-specific pattern
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
