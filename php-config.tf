locals {
  # PHP parser configurations
  # These parsers handle common PHP log formats including monolog, error logs, etc.
  # Multiple parsers are defined to support different ISO 8601 datetime formats
  php_parsers = [
    # ISO 8601 with timezone offset: 2026-01-15T08:59:58+00:00 or 2026-01-15T08:59:58+0000
    {
      name        = "php_monolog_json_tz_colon"
      format      = "json"
      time_key    = "datetime"
      time_format = "%Y-%m-%dT%H:%M:%S%z"
      time_keep   = false
      filter = {
        match        = "*" # AWS FireLens tag format: <container-name>-firelens-<task-id> in config.tf
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
    # ISO 8601 with microseconds and timezone: 2026-01-15T08:59:58.123456+00:00 or 2026-01-15T08:59:58.123456+0000
    {
      name        = "php_monolog_json_micro"
      format      = "json"
      time_key    = "datetime"
      time_format = "%Y-%m-%dT%H:%M:%S.%L%z"
      time_keep   = false
      filter = {
        match        = "*"
        key_name     = "log"
        reserve_data = true
        preserve_key = false
        unescape_key = false
      }
    },
    # PHP error without timezone (e.g., "03-Feb-2026 15:23:11") - must be before php_error
    {
      name        = "php_error_no_tz"
      format      = "regex"
      regex       = "^\\[(?<time>[^\\]]*)\\] (?<level>\\w+): (?<message>.*)$"
      time_key    = "time"
      time_format = "%d-%b-%Y %H:%M:%S"
      filter = {
        match        = "*"
        key_name     = "log"
        reserve_data = true
      }
    },
    # PHP error with timezone (e.g., "03-Feb-2026 15:23:11 UTC")
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
  # Ordered from most specific to least specific
  php_filters = [
    # Most specific: Access-log style lines with full pattern match
    {
      name  = "grep"
      match = "*" # AWS FireLens tag format: <container-name>-firelens-<task-id>
      # Exclude access-log style lines: "<IP> - <dd/Mon/yyyy:HH:MM:SS +/-ZZZZ> \"<METHOD> /index.php\" <status>"
      exclude = "log ^[\\d\\.]+ - \\d{2}/\\w{3}/\\d{4}:\\d{2}:\\d{2}:\\d{2} [+-]\\d{4} \"\\w+ /index\\.php\" \\d+$"
    },
    # Specific: Structured PHP deprecated notices (msg="PHP Deprecated:")
    {
      name    = "grep"
      match   = "*" # AWS FireLens tag format: <container-name>-firelens-<task-id>
      exclude = "log msg=\"PHP Deprecated:"
    },
    # Specific: Laravel schedule running events
    {
      name    = "grep"
      match   = "*" # AWS FireLens tag format: <container-name>-firelens-<task-id>
      exclude = "log Running \\["
    },
    # Specific: Laravel schedule skipping events
    {
      name    = "grep"
      match   = "*" # AWS FireLens tag format: <container-name>-firelens-<task-id>
      exclude = "log Skipping \\["
    },
    # Specific: Laravel schedule "starting" lifecycle messages
    {
      name    = "grep"
      match   = "*" # AWS FireLens tag format: <container-name>-firelens-<task-id>
      exclude = "log msg=\"starting"
    },
    # Specific: Laravel RUNNING/DONE pattern
    {
      name    = "grep"
      match   = "*" # AWS FireLens tag format: <container-name>-firelens-<task-id>
      exclude = "log (RUNNING|\\.\\.\\. DONE)"
    },
    # Less specific: Unstructured PHP deprecated notices (plain text)
    {
      name    = "grep"
      match   = "*" # AWS FireLens tag format: <container-name>-firelens-<task-id>
      exclude = "log PHP Deprecated:"
    },
    # Less specific: Laravel schedule done events (simple DONE")
    {
      name    = "grep"
      match   = "*" # AWS FireLens tag format: <container-name>-firelens-<task-id>
      exclude = "log DONE\""
    },
    # Less specific: Laravel queue job succeeded
    {
      name    = "grep"
      match   = "*" # AWS FireLens tag format: <container-name>-firelens-<task-id>
      exclude = "log job succeeded"
    },
    # Less specific: Laravel iteration logs
    {
      name    = "grep"
      match   = "*" # AWS FireLens tag format: <container-name>-firelens-<task-id>
      exclude = "log iteration="
    },
    # Modify filter always last
    {
      name  = "modify"
      match = "*" # AWS FireLens tag format: <container-name>-firelens-<task-id>
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
