locals {
  # Node.js Pino parser configurations
  # These parsers handle Node.js Pino JSON log formats with different timestamp variants
  # Pino supports milliseconds epoch (default) and ISO 8601 timestamps
  nodejs_parsers = [
    # Pino default format with milliseconds epoch timestamp
    # Example: {"level":30,"time":1738755000000,"pid":12345,"hostname":"server-01","msg":"Server started"}
    # Note: Fluent Bit automatically handles numeric time values as seconds/milliseconds since epoch
    # when time_format is not specified. Pino uses milliseconds by default.
    {
      name        = "nodejs_pino_json_epoch"
      format      = "json"
      time_key    = "time"
      time_keep   = false
      filter = {
        match        = "*" # AWS FireLens tag format: <container-name>-firelens-<task-id> in config.tf
        key_name     = "log"
        reserve_data = true
        preserve_key = false
        unescape_key = false
      }
    },
    # Pino with ISO 8601 UTC timestamp
    # Example: {"level":30,"time":"2026-02-05T10:30:00.000Z","msg":"Server started"}
    {
      name        = "nodejs_pino_json_iso"
      format      = "json"
      time_key    = "time"
      time_format = "%Y-%m-%dT%H:%M:%S.%LZ"
      time_keep   = false
      filter = {
        match        = "*"
        key_name     = "log"
        reserve_data = true
        preserve_key = false
        unescape_key = false
      }
    },
    # Pino with ISO 8601 timestamp and timezone offset
    # Example: {"level":30,"time":"2026-02-05T10:30:00.000+00:00","msg":"Server started"}
    {
      name        = "nodejs_pino_json_iso_tz"
      format      = "json"
      time_key    = "time"
      time_format = "%Y-%m-%dT%H:%M:%S.%L%z"
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

  # Node.js Pino filter configurations
  # These filters enrich and process Node.js Pino logs
  # Ordered from most specific to least specific
  nodejs_filters = [
    # Most specific: Health check endpoints
    {
      name  = "grep"
      match = "*" # AWS FireLens tag format: <container-name>-firelens-<task-id>
      # Exclude health check endpoint patterns
      exclude = "log (GET|POST) /(health|healthz|ready|alive|ping)"
    },
    # Specific: Static asset requests
    {
      name  = "grep"
      match = "*" # AWS FireLens tag format: <container-name>-firelens-<task-id>
      # Exclude static asset requests (.js, .css, .png, .jpg, .ico, etc.)
      exclude = "log (GET|POST) /.*\\.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)($|\\?)"
    },
    # Specific: Debug level logs (Pino level 20)
    {
      name  = "grep"
      match = "*" # AWS FireLens tag format: <container-name>-firelens-<task-id>
      # Exclude debug level logs (level: 10=trace, 20=debug)
      exclude = "log \"level\":(10|20)[,}]"
    },
    # Less specific: Heartbeat/keepalive messages
    {
      name  = "grep"
      match = "*" # AWS FireLens tag format: <container-name>-firelens-<task-id>
      # Exclude heartbeat, keepalive, and ping success messages
      exclude = "log (heartbeat|keepalive|ping|alive).*success"
    },
    # Modify filter always last
    {
      name  = "modify"
      match = "*" # AWS FireLens tag format: <container-name>-firelens-<task-id>
      add_fields = {
        log_source = "nodejs"
      }
    }
  ]

  # Map entry for this technology
  nodejs_parsers_map = {
    nodejs = local.nodejs_parsers
  }

  nodejs_filters_map = {
    nodejs = local.nodejs_filters
  }
}
