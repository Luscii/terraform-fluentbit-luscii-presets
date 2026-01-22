locals {
  # Envoy parser configurations
  # These parsers handle Envoy JSON access logs from both AWS App Mesh (legacy) and ECS Service Connect
  # Both use the same Envoy proxy with identical log format, so a single configuration supports both
  envoy_parsers = [
    {
      name        = "envoy_json_access"
      format      = "json"
      time_key    = "start_time"
      time_format = "%Y-%m-%dT%H:%M:%S.%LZ"
      time_keep   = false
      filter = {
        match        = "*" # Will be overridden by container-specific pattern in config.tf
        key_name     = "log"
        reserve_data = true
        preserve_key = false
        unescape_key = false
      }
    }
  ]

  # Envoy filter configurations
  # These filters reduce noise from health checks and add metadata
  envoy_filters = [
    # Exclude health check endpoints - common in both AppMesh and ServiceConnect
    {
      name    = "grep"
      match   = "*" # Will be overridden by container-specific pattern
      exclude = "path /health"
    },
    {
      name    = "grep"
      match   = "*" # Will be overridden by container-specific pattern
      exclude = "path /ready"
    },
    {
      name    = "grep"
      match   = "*" # Will be overridden by container-specific pattern
      exclude = "path /livez"
    },
    {
      name    = "grep"
      match   = "*" # Will be overridden by container-specific pattern
      exclude = "path /readyz"
    },
    # Exclude successful health checks by combined path and status check
    {
      name    = "grep"
      match   = "*" # Will be overridden by container-specific pattern
      # Matches: {"path":"/health...","response_code":200} OR {"path":"/ready...","response_code":200}
      exclude = "log (\\\"path\\\":\\\"/health.*response_code\\\":200|\\\"path\\\":\\\"/ready.*response_code\\\":200)"
    },
    # Add log source identifier
    {
      name  = "modify"
      match = "*" # Will be overridden by container-specific pattern
      add_fields = {
        log_source = "envoy"
      }
    }
  ]

  # Map entry for this technology
  envoy_parsers_map = {
    envoy = local.envoy_parsers
  }

  envoy_filters_map = {
    envoy = local.envoy_filters
  }
}
