# Central Aggregation & Architecture Tests
# Tests for config.tf to validate technology aggregation and custom parser/filter logic

variables {
  name = "test-arch"
  log_sources = [
    { name = "php", container = "app" },
    { name = "nginx", container = "web" },
    { name = "envoy", container = "envoy" },
    { name = "datadog", container = "app" }
  ]
  custom_parsers = [
    {
      name        = "custom_json"
      format      = "json"
      time_key    = "custom_time"
      time_format = "%Y-%m-%dT%H:%M:%S%z"
      filter = {
        match    = "custom.*"
        key_name = "log"
      }
    }
  ]
  custom_filters = [
    {
      name  = "modify"
      match = "custom.*"
      add_fields = {
        log_source = "custom"
      }
    }
  ]
}

run "validate_technology_parsers_aggregation" {
  command = plan
  assert {
    condition     = length(local.technology_parsers) >= 9
    error_message = "technology_parsers should aggregate all technology-specific parsers (expected at least 9, got ${length(local.technology_parsers)})"
  }
}

run "validate_default_parsers_exist" {
  command = plan
  assert {
    condition     = length(local.default_parsers) == 12
    error_message = "default_parsers should contain 12 JSON parsers for different time formats and time fields (got ${length(local.default_parsers)})"
  }
}

run "validate_default_parsers_in_final_config" {
  command = plan
  assert {
    condition = alltrue([
      for parser_name in ["default_json_time_tz_colon", "default_json_time_tz", "default_json_time_utc", "default_json_time_micro", "default_json_tz_colon", "default_json_tz", "default_json_utc", "default_json_micro", "default_json_time_local_tz_colon", "default_json_time_local_tz", "default_json_time_local_utc", "default_json_time_local_micro"] :
      contains([for p in local.parser_config : p.name], parser_name)
    ])
    error_message = "All 12 default parsers should be included in final parser_config"
  }
}

run "validate_default_parsers_always_included" {
  command = plan
  variables {
    name        = "test-no-sources"
    log_sources = []
  }
  assert {
    condition     = length(local.parser_config) >= 12
    error_message = "Default parsers should be included even when log_sources is empty (got ${length(local.parser_config)} parsers)"
  }
}

run "validate_technology_filters_aggregation" {
  command = plan
  assert {
    condition     = length(local.technology_filters) >= 15
    error_message = "technology_filters should aggregate all technology-specific filters"
  }
}

run "validate_custom_parser_inclusion" {
  command = plan
  assert {
    condition     = contains([for p in local.parser_config : p.name], "custom_json")
    error_message = "Custom parser should be included in parser_config"
  }
}

run "validate_custom_filter_inclusion" {
  command = plan
  assert {
    condition     = contains([for f in local.filters_config : f.name], "modify")
    error_message = "Custom filter should be included in filters_config"
  }
}

run "validate_container_specific_match_patterns" {
  command = plan
  assert {
    condition = alltrue([
      for f in local.technology_filters :
      startswith(f.match, "container-")
    ])
    error_message = "All technology filters should have container-specific match patterns"
  }
}

run "validate_parsers_map_keys" {
  command = plan
  assert {
    condition = alltrue([
      for k in ["php", "nginx", "envoy", "datadog"] :
      contains(keys(local.technology_parsers_map), k)
    ])
    error_message = "technology_parsers_map should contain all technology keys"
  }
}

run "validate_filters_map_keys" {
  command = plan
  assert {
    condition = alltrue([
      for k in ["php", "nginx", "envoy", "datadog"] :
      contains(keys(local.technology_filters_map), k)
    ])
    error_message = "technology_filters_map should contain all technology keys"
  }
}

run "validate_integration_with_consumer" {
  command = plan
  assert {
    condition     = length(local.parser_config) > 0 && length(local.filters_config) > 0
    error_message = "parser_config and filters_config should be non-empty for consumer integration"
  }
}
