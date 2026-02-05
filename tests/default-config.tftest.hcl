# Default Configuration Tests
# Tests for default-config.tf to validate default parsers are always included

variables {
  enabled = true
  name    = "test"
}

# Test: Default parsers are defined
run "validate_default_parsers_exist" {
  command = plan

  assert {
    condition     = length(local.default_parsers) == 12
    error_message = "Expected 12 default parsers (4 for 'time', 4 for 'datetime', 4 for 'time_local'), got ${length(local.default_parsers)}"
  }
}

# Test: Default parsers are always included (even with empty log_sources)
run "validate_default_parsers_always_included" {
  command = plan

  variables {
    log_sources = []
  }

  assert {
    condition     = length(local.parser_config) >= 12
    error_message = "Default parsers should be included even with empty log_sources, expected at least 12, got ${length(local.parser_config)}"
  }
}

# Test: Validate parsers appear first in final config
run "validate_default_parsers_order" {
  command = plan

  variables {
    log_sources = [{ name = "php", container = "app" }]
  }

  assert {
    condition     = local.parser_config[0].name == "default_json_time_tz_colon"
    error_message = "Default parsers should appear first in parser_config, got ${local.parser_config[0].name}"
  }
}

# Test: Validate first parser (time field with timezone)
run "validate_default_json_time_tz_colon_parser" {
  command = plan

  assert {
    condition     = local.default_parsers[0].name == "default_json_time_tz_colon"
    error_message = "First default parser should be default_json_time_tz_colon"
  }

  assert {
    condition     = local.default_parsers[0].time_format == "%Y-%m-%dT%H:%M:%S%z"
    error_message = "default_json_time_tz_colon should use time format %Y-%m-%dT%H:%M:%S%z (not %:z)"
  }

  assert {
    condition     = local.default_parsers[0].time_key == "time"
    error_message = "default_json_time_tz_colon should use time_key 'time'"
  }

  assert {
    condition     = local.default_parsers[0].filter.match == "*"
    error_message = "default_json_time_tz_colon should match all logs (*)"
  }
}

# Test: Validate datetime field parser
run "validate_default_json_tz_colon_parser" {
  command = plan

  assert {
    condition     = local.default_parsers[4].name == "default_json_tz_colon"
    error_message = "Fifth parser should be default_json_tz_colon (datetime field)"
  }

  assert {
    condition     = local.default_parsers[4].time_key == "datetime"
    error_message = "default_json_tz_colon should use time_key 'datetime'"
  }

  assert {
    condition     = local.default_parsers[4].time_format == "%Y-%m-%dT%H:%M:%S%z"
    error_message = "default_json_tz_colon should use time format %Y-%m-%dT%H:%M:%S%z (not %:z)"
  }
}

# Test: Validate time_local field parser
run "validate_default_json_time_local_tz_colon_parser" {
  command = plan

  assert {
    condition     = local.default_parsers[8].name == "default_json_time_local_tz_colon"
    error_message = "Ninth parser should be default_json_time_local_tz_colon (time_local field)"
  }

  assert {
    condition     = local.default_parsers[8].time_key == "time_local"
    error_message = "default_json_time_local_tz_colon should use time_key 'time_local'"
  }

  assert {
    condition     = local.default_parsers[8].time_format == "%Y-%m-%dT%H:%M:%S%z"
    error_message = "default_json_time_local_tz_colon should use time format %Y-%m-%dT%H:%M:%S%z (not %:z)"
  }
}

# Test: Validate UTC parsers
run "validate_utc_parsers" {
  command = plan

  assert {
    condition     = local.default_parsers[2].time_format == "%Y-%m-%dT%H:%M:%SZ"
    error_message = "default_json_time_utc should use time format %Y-%m-%dT%H:%M:%SZ"
  }

  assert {
    condition     = local.default_parsers[6].time_format == "%Y-%m-%dT%H:%M:%SZ"
    error_message = "default_json_utc should use time format %Y-%m-%dT%H:%M:%SZ"
  }

  assert {
    condition     = local.default_parsers[10].time_format == "%Y-%m-%dT%H:%M:%SZ"
    error_message = "default_json_time_local_utc should use time format %Y-%m-%dT%H:%M:%SZ"
  }
}

# Test: Validate microsecond parsers use %z not %:z
run "validate_microsecond_parsers_no_colon" {
  command = plan

  assert {
    condition     = local.default_parsers[3].time_format == "%Y-%m-%dT%H:%M:%S.%L%z"
    error_message = "default_json_time_micro should use %z not %:z, got ${local.default_parsers[3].time_format}"
  }

  assert {
    condition     = local.default_parsers[7].time_format == "%Y-%m-%dT%H:%M:%S.%L%z"
    error_message = "default_json_micro should use %z not %:z, got ${local.default_parsers[7].time_format}"
  }

  assert {
    condition     = local.default_parsers[11].time_format == "%Y-%m-%dT%H:%M:%S.%L%z"
    error_message = "default_json_time_local_micro should use %z not %:z, got ${local.default_parsers[11].time_format}"
  }
}

# Test: All parsers have required filter configuration
run "validate_all_parsers_have_filters" {
  command = plan

  assert {
    condition = alltrue([
      for parser in local.default_parsers :
      parser.filter != null && parser.filter.key_name == "log"
    ])
    error_message = "All default parsers should have filter configuration with key_name='log'"
  }

  assert {
    condition = alltrue([
      for parser in local.default_parsers :
      parser.filter.reserve_data == true
    ])
    error_message = "All default parsers should have reserve_data=true to preserve log fields"
  }
}
