locals {
  # PHP parser configurations
  # These parsers handle common PHP log formats including monolog, error logs, etc.
  php_parsers = [
    {
      name        = "php_monolog_json"
      format      = "json"
      time_key    = "datetime"
      time_format = "%Y-%m-%dT%H:%M:%S%z"
      time_keep   = false
      filter = {
        match        = "*" # Will be overridden by container-specific pattern in config.tf
        key_name     = "log"
        reserve_data = true
        preserve_key = false
        unescape_key = false
      }
    },
    {
      name   = "php_error"
      format = "regex"
      regex  = "^\\[(?<time>[^\\]]*)\\] (?<level>\\w+): (?<message>.*)$"
      time_key    = "time"
      time_format = "%d-%b-%Y %H:%M:%S %Z"
      filter = {
        match        = "*"
        key_name     = "log"
        reserve_data = true
      }
    }
  ]

  # PHP filter configurations
  # These filters enrich and process PHP logs
  php_filters = [
    {
      name  = "modify"
      match = "*" # Will be overridden by container-specific pattern
      add_fields = {
        log_source = "php"
      }
    }
  ]

  # Map entry for this technology
  php_parsers_map = {
    php = local.php_parsers
  }

  php_filters_map = {
    php = local.php_filters
  }
}
