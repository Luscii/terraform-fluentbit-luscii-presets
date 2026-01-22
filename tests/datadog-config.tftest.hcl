# Datadog Configuration Tests
# Tests for datadog-config.tf to validate parser and filter configurations

variables {
  name = "test-datadog"
  log_sources = [
    {
      name      = "datadog"
      container = "app"
    }
  ]
}

run "validate_datadog_parsers_count" {
  command = plan
  assert {
    condition     = length(local.datadog_parsers) == 1
    error_message = "Expected 1 Datadog parser (json), got ${length(local.datadog_parsers)}"
  }
}

run "validate_datadog_json_parser" {
  command = plan
  assert {
    condition     = local.datadog_parsers[0].name == "datadog_json"
    error_message = "Datadog parser should be datadog_json"
  }
  assert {
    condition     = local.datadog_parsers[0].format == "json"
    error_message = "datadog_json parser should use json format"
  }
  assert {
    condition     = local.datadog_parsers[0].time_key == "datetime"
    error_message = "datadog_json parser should use datetime as time_key"
  }
  assert {
    condition     = local.datadog_parsers[0].time_format == "%Y-%m-%dT%H:%M:%S%z"
    error_message = "datadog_json parser should use ISO 8601 time format"
  }
}

run "validate_datadog_filters_count" {
  command = plan
  assert {
    condition     = length(local.datadog_filters) == 2
    error_message = "Expected 2 Datadog filters (grep, modify), got ${length(local.datadog_filters)}"
  }
}

run "validate_datadog_grep_filter" {
  command = plan
  assert {
    condition     = local.datadog_filters[0].name == "grep"
    error_message = "First Datadog filter should be grep"
  }
  assert {
    condition     = local.datadog_filters[0].regex == "log Luscii APM"
    error_message = "grep filter should match 'log Luscii APM'"
  }
}

run "validate_datadog_modify_filter" {
  command = plan
  assert {
    condition     = local.datadog_filters[1].name == "modify"
    error_message = "Second Datadog filter should be modify"
  }
  assert {
    condition     = local.datadog_filters[1].add_fields.log_source == "datadog"
    error_message = "modify filter should add log_source=datadog"
  }
}

run "validate_datadog_parsers_map" {
  command = plan
  assert {
    condition     = contains(keys(local.datadog_parsers_map), "datadog")
    error_message = "datadog_parsers_map should contain 'datadog' key"
  }
  assert {
    condition     = length(local.datadog_parsers_map["datadog"]) == 1
    error_message = "datadog_parsers_map['datadog'] should contain 1 parser"
  }
}

run "validate_datadog_filters_map" {
  command = plan
  assert {
    condition     = contains(keys(local.datadog_filters_map), "datadog")
    error_message = "datadog_filters_map should contain 'datadog' key"
  }
  assert {
    condition     = length(local.datadog_filters_map["datadog"]) == 2
    error_message = "datadog_filters_map['datadog'] should contain 2 filters"
  }
}

run "validate_container_specific_match" {
  command = plan
  assert {
    condition     = local.technology_filters[0].match == "container-app-*"
    error_message = "Filter match pattern should include container name"
  }
}
