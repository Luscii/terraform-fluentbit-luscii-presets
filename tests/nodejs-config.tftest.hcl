# Node.js Pino Configuration Tests
# Tests for nodejs-config.tf to validate parser and filter configurations

# Global variables for all tests
variables {
  enabled = true
  name    = "test"
}

# Test: Node.js parsers are defined correctly
run "validate_nodejs_parsers_count" {
  command = plan

  assert {
    condition     = length(local.nodejs_parsers) == 3
    error_message = "Expected 3 Node.js parsers (epoch + 2 ISO variants), got ${length(local.nodejs_parsers)}"
  }
}

# Test: Node.js parsers map is created
run "validate_nodejs_parsers_map" {
  command = plan

  assert {
    condition     = contains(keys(local.nodejs_parsers_map), "nodejs")
    error_message = "nodejs_parsers_map should contain 'nodejs' key"
  }

  assert {
    condition     = length(local.nodejs_parsers_map["nodejs"]) == 3
    error_message = "nodejs_parsers_map['nodejs'] should contain 3 parsers"
  }
}

# Test: Node.js filters are defined correctly
run "validate_nodejs_filters_count" {
  command = plan

  assert {
    condition     = length(local.nodejs_filters) == 5
    error_message = "Expected 5 Node.js filters (4 grep + 1 modify), got ${length(local.nodejs_filters)}"
  }
}

# Test: Node.js filters map is created
run "validate_nodejs_filters_map" {
  command = plan

  assert {
    condition     = contains(keys(local.nodejs_filters_map), "nodejs")
    error_message = "nodejs_filters_map should contain 'nodejs' key"
  }

  assert {
    condition     = length(local.nodejs_filters_map["nodejs"]) == 5
    error_message = "nodejs_filters_map['nodejs'] should contain 5 filters"
  }
}

# Test: Pino JSON parser with milliseconds epoch timestamp
run "validate_pino_json_epoch_parser" {
  command = plan

  assert {
    condition     = local.nodejs_parsers[0].name == "nodejs_pino_json_epoch"
    error_message = "First parser should be nodejs_pino_json_epoch"
  }

  assert {
    condition     = local.nodejs_parsers[0].format == "json"
    error_message = "nodejs_pino_json_epoch should use json format"
  }

  assert {
    condition     = local.nodejs_parsers[0].time_key == "time"
    error_message = "nodejs_pino_json_epoch should use 'time' as time_key"
  }

  assert {
    condition     = local.nodejs_parsers[0].time_keep == false
    error_message = "nodejs_pino_json_epoch should not keep original time field"
  }
}

# Test: Pino JSON parser with ISO 8601 UTC timestamp
run "validate_pino_json_iso_parser" {
  command = plan

  assert {
    condition     = local.nodejs_parsers[1].name == "nodejs_pino_json_iso"
    error_message = "Second parser should be nodejs_pino_json_iso"
  }

  assert {
    condition     = local.nodejs_parsers[1].format == "json"
    error_message = "nodejs_pino_json_iso should use json format"
  }

  assert {
    condition     = local.nodejs_parsers[1].time_format == "%Y-%m-%dT%H:%M:%S.%LZ"
    error_message = "nodejs_pino_json_iso should use ISO 8601 format with milliseconds: %Y-%m-%dT%H:%M:%S.%LZ"
  }

  assert {
    condition     = local.nodejs_parsers[1].time_key == "time"
    error_message = "nodejs_pino_json_iso should use 'time' as time_key"
  }

  assert {
    condition     = local.nodejs_parsers[1].time_keep == false
    error_message = "nodejs_pino_json_iso should not keep original time field"
  }
}

# Test: Pino JSON parser with ISO 8601 timestamp and timezone
run "validate_pino_json_iso_tz_parser" {
  command = plan

  assert {
    condition     = local.nodejs_parsers[2].name == "nodejs_pino_json_iso_tz"
    error_message = "Third parser should be nodejs_pino_json_iso_tz"
  }

  assert {
    condition     = local.nodejs_parsers[2].format == "json"
    error_message = "nodejs_pino_json_iso_tz should use json format"
  }

  assert {
    condition     = local.nodejs_parsers[2].time_format == "%Y-%m-%dT%H:%M:%S.%L%z"
    error_message = "nodejs_pino_json_iso_tz should use ISO 8601 format with milliseconds and timezone: %Y-%m-%dT%H:%M:%S.%L%z"
  }

  assert {
    condition     = local.nodejs_parsers[2].time_key == "time"
    error_message = "nodejs_pino_json_iso_tz should use 'time' as time_key"
  }

  assert {
    condition     = local.nodejs_parsers[2].time_keep == false
    error_message = "nodejs_pino_json_iso_tz should not keep original time field"
  }
}

# Test: All parsers have filter configuration
run "validate_parsers_have_filters" {
  command = plan

  assert {
    condition = alltrue([
      for parser in local.nodejs_parsers :
      can(parser.filter) && parser.filter.key_name == "log"
    ])
    error_message = "All Node.js parsers should have filter configuration with key_name='log'"
  }

  assert {
    condition = alltrue([
      for parser in local.nodejs_parsers :
      can(parser.filter) && parser.filter.reserve_data == true
    ])
    error_message = "All Node.js parsers should preserve data with reserve_data=true"
  }
}

# Test: Health check filter
run "validate_health_check_filter" {
  command = plan

  assert {
    condition     = local.nodejs_filters[0].name == "grep"
    error_message = "First filter should be grep for health checks"
  }

  assert {
    condition     = can(local.nodejs_filters[0].exclude)
    error_message = "Health check filter should have exclude pattern"
  }

  assert {
    condition     = length(regexall("health", local.nodejs_filters[0].exclude)) > 0
    error_message = "Health check filter should exclude 'health' patterns"
  }
}

# Test: Static asset filter
run "validate_static_asset_filter" {
  command = plan

  assert {
    condition     = local.nodejs_filters[1].name == "grep"
    error_message = "Second filter should be grep for static assets"
  }

  assert {
    condition     = can(local.nodejs_filters[1].exclude)
    error_message = "Static asset filter should have exclude pattern"
  }

  assert {
    condition = alltrue([
      length(regexall("js", local.nodejs_filters[1].exclude)) > 0,
      length(regexall("css", local.nodejs_filters[1].exclude)) > 0
    ])
    error_message = "Static asset filter should exclude common file extensions (.js, .css, etc.)"
  }
}

# Test: Debug log filter
run "validate_debug_log_filter" {
  command = plan

  assert {
    condition     = local.nodejs_filters[2].name == "grep"
    error_message = "Third filter should be grep for debug logs"
  }

  assert {
    condition     = can(local.nodejs_filters[2].exclude)
    error_message = "Debug log filter should have exclude pattern"
  }
}

# Test: Heartbeat filter
run "validate_heartbeat_filter" {
  command = plan

  assert {
    condition     = local.nodejs_filters[3].name == "grep"
    error_message = "Fourth filter should be grep for heartbeat messages"
  }

  assert {
    condition     = can(local.nodejs_filters[3].exclude)
    error_message = "Heartbeat filter should have exclude pattern"
  }
}

# Test: Modify filter adds log_source
run "validate_modify_filter" {
  command = plan

  assert {
    condition     = local.nodejs_filters[4].name == "modify"
    error_message = "Fifth filter should be modify filter"
  }

  assert {
    condition     = can(local.nodejs_filters[4].add_fields) && local.nodejs_filters[4].add_fields.log_source == "nodejs"
    error_message = "Modify filter should add log_source='nodejs'"
  }
}

# Test: All filters have match pattern
run "validate_filters_have_match" {
  command = plan

  assert {
    condition = alltrue([
      for filter in local.nodejs_filters :
      can(filter.match) && filter.match != null
    ])
    error_message = "All Node.js filters should have match pattern defined"
  }
}

# Integration Test: Node.js parsers included in technology_parsers_map
run "validate_nodejs_in_technology_parsers_map" {
  command = plan

  assert {
    condition     = contains(keys(local.technology_parsers_map), "nodejs")
    error_message = "technology_parsers_map should include 'nodejs' key"
  }

  assert {
    condition     = length(local.technology_parsers_map["nodejs"]) == 3
    error_message = "technology_parsers_map['nodejs'] should have 3 parsers"
  }
}

# Integration Test: Node.js filters included in technology_filters_map
run "validate_nodejs_in_technology_filters_map" {
  command = plan

  assert {
    condition     = contains(keys(local.technology_filters_map), "nodejs")
    error_message = "technology_filters_map should include 'nodejs' key"
  }

  assert {
    condition     = length(local.technology_filters_map["nodejs"]) == 5
    error_message = "technology_filters_map['nodejs'] should have 5 filters"
  }
}

# Integration Test: Node.js parsers are used when log_sources includes nodejs
run "validate_nodejs_parsers_in_output_with_nodejs_source" {
  command = plan

  variables {
    log_sources = [
      { name = "nodejs", container = "app" }
    ]
  }

  assert {
    condition     = length(local.technology_parsers) >= 3
    error_message = "Output should include at least 3 Node.js parsers when nodejs is in log_sources"
  }
}

# Integration Test: Container-specific match patterns
run "validate_container_specific_match_pattern" {
  command = plan

  variables {
    log_sources = [
      { name = "nodejs", container = "nodejs-app" }
    ]
  }

  assert {
    condition = alltrue([
      for filter in local.technology_filters :
      can(filter.match) && (
        filter.match == "nodejs-app-firelens-*" || 
        filter.match == "*"
      )
      if contains([for s in var.log_sources : s.name], "nodejs")
    ])
    error_message = "Container-specific filters should use 'nodejs-app-firelens-*' match pattern"
  }
}

# Integration Test: Default match pattern when container is wildcard
run "validate_wildcard_container_match_pattern" {
  command = plan

  variables {
    log_sources = [
      { name = "nodejs", container = "*" }
    ]
  }

  assert {
    condition = length([
      for filter in local.technology_filters :
      filter if can(filter.match) && filter.match == "*"
    ]) > 0
    error_message = "Wildcard container should use '*' match pattern"
  }
}
