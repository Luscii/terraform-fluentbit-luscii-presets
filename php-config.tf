locals {
  # PHP parser configurations
  # These parsers handle common PHP log formats including monolog, error logs, etc.
  # Multiple parsers are defined to support different ISO 8601 datetime formats
  php_parsers = [
    # ISO 8601 with timezone offset with colon: 2026-01-15T08:59:58+00:00
    {
      name        = "php_monolog_json_tz_colon"
      format      = "json"
      time_key    = "datetime"
      time_format = "%Y-%m-%dT%H:%M:%S%:z"
      time_keep   = false
      filter = {
        match        = "*" # Will be overridden by container-specific pattern in config.tf
        key_name     = "log"
        reserve_data = true
        preserve_key = false
        unescape_key = false
      }
    },
    # ISO 8601 with timezone offset without colon: 2026-01-15T08:59:58+0000
    {
      name        = "php_monolog_json_tz"
      format      = "json"
      time_key    = "datetime"
      time_format = "%Y-%m-%dT%H:%M:%S%z"
      time_keep   = false
      filter = {
        match        = "*"
        key_name     = "log"
        reserve_data = true
        preserve_key = false
        unescape_key = false
      }
    },
    # ISO 8601 with Z indicator: 2026-01-15T08:59:58Z
    {
      name        = "php_monolog_json_utc"
      format      = "json"
      time_key    = "datetime"
      time_format = "%Y-%m-%dT%H:%M:%SZ"
      time_keep   = false
      filter = {
        match        = "*"
        key_name     = "log"
        reserve_data = true
        preserve_key = false
        unescape_key = false
      }
    },
    # ISO 8601 with microseconds and timezone: 2026-01-15T08:59:58.123456+00:00
    {
      name        = "php_monolog_json_micro"
      format      = "json"
      time_key    = "datetime"
      time_format = "%Y-%m-%dT%H:%M:%S.%L%:z"
      time_keep   = false
      filter = {
        match        = "*"
        key_name     = "log"
        reserve_data = true
        preserve_key = false
        unescape_key = false
      }
    },
    {
      name        = "php_error"
      format      = "regex"
      regex       = "^\\[(?<time>[^\\]]*)\\] (?<level>\\w+): (?<message>.*)$"
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
      name    = "grep"
      match   = "*" # Will be overridden by container-specific pattern
      # Exclude access-log style lines: "<IP> - <dd/Mon/yyyy:HH:MM:SS +/-ZZZZ> \"<METHOD> /index.php\" <status>"
      exclude = "log ^[\\d\\.]+ - \\d{2}/\\w{3}/\\d{4}:\\d{2}:\\d{2}:\\d{2} [+-]\\d{4} \"\\w+ /index\\.php\" \\d+$"
    },
    {
      # Exclude unstructured PHP deprecated notices (plain PHP error logs)
      name    = "grep"
      match   = "*" # Will be overridden by container-specific pattern
      exclude = "log PHP Deprecated:"
    },
    {
      # Exclude structured PHP deprecated notices where message is in msg="..."
      name    = "grep"
      match   = "*" # Will be overridden by container-specific pattern
      exclude = "log msg=\"PHP Deprecated:"
    },
    # Laravel schedule: running events (e.g. "Running [App\...]" messages)
    {
      name    = "grep"
      match   = "*" # Will be overridden by container-specific pattern
      exclude = "log Running \\["
    },
    # Laravel schedule: done events (e.g. '... DONE"')
    {
      name    = "grep"
      match   = "*" # Will be overridden by container-specific pattern
      exclude = "log DONE\""
    },
    # Laravel schedule: skipping events (e.g. "Skipping [App\...]" messages)
    {
      name    = "grep"
      match   = "*" # Will be overridden by container-specific pattern
      exclude = "log Skipping \\["
    },
    # Laravel queue: job succeeded messages
    {
      name    = "grep"
      match   = "*" # Will be overridden by container-specific pattern
      exclude = "log job succeeded"
    },
    # Laravel schedule: "starting" lifecycle messages
    {
      name    = "grep"
      match   = "*" # Will be overridden by container-specific pattern
      exclude = "log msg=\"starting"
    },
    # Laravel iteration logs (e.g. "iteration=" counters)
    {
      name    = "grep"
      match   = "*" # Will be overridden by container-specific pattern
      exclude = "log iteration="
    },
    {
      name    = "grep"
      match   = "*" # Will be overridden by container-specific pattern
      exclude = "log (RUNNING|\\.\\.\\. DONE)"
    },
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
