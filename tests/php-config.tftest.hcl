# PHP Configuration Tests
# Tests for php-config.tf to validate parser and filter configurations

# Global variables for all tests
variables {
  enabled = true
  name    = "test"
}

# Test: PHP parsers are defined correctly
run "validate_php_parsers_count" {
  command = plan

  assert {
    condition     = length(local.php_parsers) == 5
    error_message = "Expected 5 PHP parsers (4 JSON variants + 1 error parser), got ${length(local.php_parsers)}"
  }
}

# Test: PHP parsers map is created
run "validate_php_parsers_map" {
  command = plan

  assert {
    condition     = contains(keys(local.php_parsers_map), "php")
    error_message = "php_parsers_map should contain 'php' key"
  }

  assert {
    condition     = length(local.php_parsers_map["php"]) == 5
    error_message = "php_parsers_map['php'] should contain 5 parsers"
  }
}

# Test: PHP filters are defined correctly
run "validate_php_filters_count" {
  command = plan

  assert {
    condition     = length(local.php_filters) == 11
    error_message = "Expected 11 PHP filters (10 grep + 1 modify), got ${length(local.php_filters)}"
  }
}

# Test: PHP filters map is created
run "validate_php_filters_map" {
  command = plan

  assert {
    condition     = contains(keys(local.php_filters_map), "php")
    error_message = "php_filters_map should contain 'php' key"
  }

  assert {
    condition     = length(local.php_filters_map["php"]) == 11
    error_message = "php_filters_map['php'] should contain 11 filters"
  }
}

# Test: ISO 8601 datetime parser with timezone colon
run "validate_monolog_json_tz_colon_parser" {
  command = plan

  assert {
    condition     = local.php_parsers[0].name == "php_monolog_json_tz_colon"
    error_message = "First parser should be php_monolog_json_tz_colon"
  }

  assert {
    condition     = local.php_parsers[0].format == "json"
    error_message = "php_monolog_json_tz_colon should use json format"
  }

  assert {
    condition     = local.php_parsers[0].time_format == "%Y-%m-%dT%H:%M:%S%:z"
    error_message = "php_monolog_json_tz_colon should use ISO 8601 format with timezone colon: %Y-%m-%dT%H:%M:%S%:z"
  }

  assert {
    condition     = local.php_parsers[0].time_key == "datetime"
    error_message = "php_monolog_json_tz_colon should use 'datetime' as time_key"
  }

  assert {
    condition     = local.php_parsers[0].time_keep == false
    error_message = "php_monolog_json_tz_colon should not keep original time field"
  }
}

# Test: ISO 8601 datetime parser without timezone colon
run "validate_monolog_json_tz_parser" {
  command = plan

  assert {
    condition     = local.php_parsers[1].name == "php_monolog_json_tz"
    error_message = "Second parser should be php_monolog_json_tz"
  }

  assert {
    condition     = local.php_parsers[1].format == "json"
    error_message = "php_monolog_json_tz should use json format"
  }

  assert {
    condition     = local.php_parsers[1].time_format == "%Y-%m-%dT%H:%M:%S%z"
    error_message = "php_monolog_json_tz should use ISO 8601 format without timezone colon: %Y-%m-%dT%H:%M:%S%z"
  }
}

# Test: ISO 8601 UTC parser with Z indicator
run "validate_monolog_json_utc_parser" {
  command = plan

  assert {
    condition     = local.php_parsers[2].name == "php_monolog_json_utc"
    error_message = "Third parser should be php_monolog_json_utc"
  }

  assert {
    condition     = local.php_parsers[2].format == "json"
    error_message = "php_monolog_json_utc should use json format"
  }

  assert {
    condition     = local.php_parsers[2].time_format == "%Y-%m-%dT%H:%M:%SZ"
    error_message = "php_monolog_json_utc should use ISO 8601 UTC format: %Y-%m-%dT%H:%M:%SZ"
  }
}

# Test: ISO 8601 parser with microseconds
run "validate_monolog_json_micro_parser" {
  command = plan

  assert {
    condition     = local.php_parsers[3].name == "php_monolog_json_micro"
    error_message = "Fourth parser should be php_monolog_json_micro"
  }

  assert {
    condition     = local.php_parsers[3].format == "json"
    error_message = "php_monolog_json_micro should use json format"
  }

  assert {
    condition     = local.php_parsers[3].time_format == "%Y-%m-%dT%H:%M:%S.%L%:z"
    error_message = "php_monolog_json_micro should use ISO 8601 format with microseconds: %Y-%m-%dT%H:%M:%S.%L%:z"
  }
}

# Test: PHP error parser configuration
run "validate_php_error_parser" {
  command = plan

  assert {
    condition     = local.php_parsers[4].name == "php_error"
    error_message = "Fifth parser should be php_error"
  }

  assert {
    condition     = local.php_parsers[4].format == "regex"
    error_message = "php_error should use regex format"
  }

  assert {
    condition     = startswith(local.php_parsers[4].regex, "^\\[")
    error_message = "php_error regex should start with ^\\["
  }

  assert {
    condition     = local.php_parsers[4].time_key == "time"
    error_message = "php_error should use 'time' as time_key"
  }
}

# Test: All JSON parsers have filter configuration
run "validate_json_parsers_have_filters" {
  command = plan

  assert {
    condition     = alltrue([for i in range(4) : contains(keys(local.php_parsers[i]), "filter")])
    error_message = "All JSON parsers should have filter configuration"
  }

  assert {
    condition     = alltrue([for i in range(4) : local.php_parsers[i].filter.key_name == "log"])
    error_message = "All JSON parser filters should use 'log' as key_name"
  }

  assert {
    condition     = alltrue([for i in range(4) : local.php_parsers[i].filter.reserve_data == true])
    error_message = "All JSON parser filters should reserve data"
  }
}

# Test: Grep filters for noise reduction
run "validate_grep_filters" {
  command = plan

  assert {
    condition     = length([for f in local.php_filters : f if f.name == "grep"]) == 10
    error_message = "Expected 10 grep filters for noise reduction"
  }

  assert {
    condition     = alltrue([for f in local.php_filters : contains(keys(f), "exclude") if f.name == "grep"])
    error_message = "All grep filters should have exclude pattern"
  }

  assert {
    condition     = alltrue([for f in local.php_filters : f.match == "*" if f.name == "grep"])
    error_message = "All grep filters should match '*' (to be overridden by container pattern)"
  }
}

# Test: Modify filter adds log_source
run "validate_modify_filter" {
  command = plan

  assert {
    condition     = length([for f in local.php_filters : f if f.name == "modify"]) == 1
    error_message = "Expected exactly 1 modify filter"
  }

  assert {
    condition     = [for f in local.php_filters : f if f.name == "modify"][0].add_fields.log_source == "php"
    error_message = "Modify filter should add log_source='php'"
  }

  assert {
    condition     = [for f in local.php_filters : f if f.name == "modify"][0].match == "*"
    error_message = "Modify filter should match '*' (to be overridden by container pattern)"
  }
}

# Test: Grep filter excludes /index.php requests
run "validate_index_php_exclusion" {
  command = plan

  assert {
    condition     = length([for f in local.php_filters : f if can(regex("index\\\\.php", f.exclude))]) > 0
    error_message = "Should have grep filter to exclude /index.php requests"
  }

  assert {
    condition     = can(regex("index\\\\.php", [for f in local.php_filters : f if can(regex("index\\\\.php", f.exclude))][0].exclude))
    error_message = "Index filter should properly escape .php extension"
  }
}

# Test: Grep filter excludes PHP deprecated warnings
run "validate_deprecated_exclusion" {
  command = plan

  assert {
    condition     = length([for f in local.php_filters : f if can(regex("PHP Deprecated:", f.exclude))]) > 0
    error_message = "Should have grep filter to exclude PHP Deprecated warnings"
  }

  assert {
    condition     = can(regex("PHP Deprecated:", [for f in local.php_filters : f if can(regex("PHP Deprecated:", f.exclude))][0].exclude))
    error_message = "Deprecated filter should match 'PHP Deprecated:' pattern"
  }
}

# Test: Grep filter excludes common noise patterns
run "validate_noise_exclusion" {
  command = plan

  assert {
    condition     = length([for f in local.php_filters : f if can(regex("Running", f.exclude))]) > 0
    error_message = "Should have grep filter to exclude common noise patterns (Running, DONE, Skipping)"
  }
}

# Test: Integration with technology selection
run "validate_php_technology_selection" {
  command = plan

  variables {
    enabled      = true
    technologies = ["php"]
  }

  assert {
    condition     = contains(var.technologies, "php")
    error_message = "PHP should be selectable as a technology"
  }

  assert {
    condition     = length(local.technology_parsers_map) > 0
    error_message = "technology_parsers_map should be populated when PHP is selected"
  }
}

# Test: Parser precedence for datetime formats
run "validate_parser_order" {
  command = plan

  assert {
    condition = (
      local.php_parsers[0].name == "php_monolog_json_tz_colon" &&
      local.php_parsers[1].name == "php_monolog_json_tz" &&
      local.php_parsers[2].name == "php_monolog_json_utc" &&
      local.php_parsers[3].name == "php_monolog_json_micro"
    )
    error_message = "Parsers should be in order: tz_colon, tz, utc, micro to handle common formats first"
  }
}

# Test: All parsers are unique
run "validate_parser_names_unique" {
  command = plan

  assert {
    condition     = length([for p in local.php_parsers : p.name]) == length(toset([for p in local.php_parsers : p.name]))
    error_message = "All parser names should be unique"
  }
}

# Test: Filter count matches expected configuration
run "validate_filter_types" {
  command = plan

  assert {
    condition     = length([for f in local.php_filters : f if f.name == "grep"]) == 10
    error_message = "Should have exactly 10 grep filters"
  }

  assert {
    condition     = length([for f in local.php_filters : f if f.name == "modify"]) == 1
    error_message = "Should have exactly 1 modify filter"
  }
}
