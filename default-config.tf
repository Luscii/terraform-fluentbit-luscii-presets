locals {
  # Default JSON parser configurations
  # These parsers are always included regardless of log_sources configuration
  # They handle common JSON log formats with various ISO 8601 datetime formats
  # to prevent "invalid time format" errors in Fluent Bit
  default_parsers = [
    # ISO 8601 with timezone offset with colon: 2026-01-15T08:59:58+00:00
    {
      name        = "default_json_tz_colon"
      format      = "json"
      time_key    = "datetime"
      time_format = "%Y-%m-%dT%H:%M:%S%:z"
      time_keep   = false
      filter = {
        match        = "*"
        key_name     = "log"
        reserve_data = true
        preserve_key = false
        unescape_key = false
      }
    },
    # ISO 8601 with timezone offset without colon: 2026-01-15T08:59:58+0000
    {
      name        = "default_json_tz"
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
      name        = "default_json_utc"
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
      name        = "default_json_micro"
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
    }
  ]

  # Default filter configurations
  # These filters are always included regardless of log_sources configuration
  default_filters = []
}
