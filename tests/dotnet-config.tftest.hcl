# Dotnet Configuration Tests
# Tests for dotnet-config.tf to validate parser and filter configurations

variables {
  name = "test-dotnet"
  log_sources = [
    {
      name      = "dotnet"
      container = "dotnet-app"
    }
  ]
  log_text_level_category = "info: Microsoft.AspNetCore.Hosting.Diagnostics[2]"
  log_text_request        = "Request finished HTTP/1.1 POST https://api.luscii.com/connect/token - 200 - application/json;+charset=UTF-8 18.4804ms"
  log_health_check        = "info: connect.images.Controllers.SvgImageController[0]      Getting SVG image with id ..."
  log_profile_warning     = "warn: connect.images.Controllers.UserProfileImagesController[0]      Image not found for userId ..."
  log_json                = "{\"Timestamp\":\"2026-01-22T10:30:45Z\",\"Level\":\"Information\",\"Message\":\"User logged in\"}"
  log_serilog             = "{\"@t\":\"2026-01-22T10:30:45Z\",\"@mt\":\"User {UserId} logged in\",\"UserId\":123}"
}

# Test: Dotnet parsers are defined correctly
run "validate_dotnet_parsers_count" {
  command = plan
  assert {
    condition     = length(local.dotnet_parsers) == 3
    error_message = "Expected 3 dotnet parsers (text, json, serilog), got ${length(local.dotnet_parsers)}"
  }
}

# Test: Dotnet parsers map is created
run "validate_dotnet_parsers_map" {
  command = plan
  assert {
    condition     = contains(keys(local.dotnet_parsers_map), "dotnet")
    error_message = "dotnet_parsers_map should contain 'dotnet' key"
  }
  assert {
    condition     = length(local.dotnet_parsers_map["dotnet"]) == 3
    error_message = "dotnet_parsers_map['dotnet'] should contain 3 parsers"
  }
}

# Test: Dotnet filters are defined correctly
run "validate_dotnet_filters_count" {
  command = plan
  assert {
    condition     = length(local.dotnet_filters) == 5
    error_message = "Expected 5 dotnet filters (2 grep + 1 modify + 2 loglevel), got ${length(local.dotnet_filters)}"
  }
}

# Test: Dotnet filters map is created
run "validate_dotnet_filters_map" {
  command = plan
  assert {
    condition     = contains(keys(local.dotnet_filters_map), "dotnet")
    error_message = "dotnet_filters_map should contain 'dotnet' key"
  }
  assert {
    condition     = length(local.dotnet_filters_map["dotnet"]) == 5
    error_message = "dotnet_filters_map['dotnet'] should contain 5 filters"
  }
}

# Test: Dotnet text parser details
run "validate_dotnet_text_parser" {
  command = plan
  assert {
    condition     = local.dotnet_parsers[0].name == "dotnet_text"
    error_message = "First parser should be dotnet_text"
  }
  assert {
    condition     = local.dotnet_parsers[0].format == "regex"
    error_message = "dotnet_text should use regex format"
  }
}

# Test: Dotnet JSON parser details
run "validate_dotnet_json_parser" {
  command = plan
  assert {
    condition     = local.dotnet_parsers[1].name == "dotnet_json"
    error_message = "Second parser should be dotnet_json"
  }
  assert {
    condition     = local.dotnet_parsers[1].format == "json"
    error_message = "dotnet_json should use json format"
  }
}

# Test: Dotnet Serilog parser details
run "validate_dotnet_serilog_parser" {
  command = plan
  assert {
    condition     = local.dotnet_parsers[2].name == "dotnet_serilog"
    error_message = "Third parser should be dotnet_serilog"
  }
  assert {
    condition     = local.dotnet_parsers[2].format == "json"
    error_message = "dotnet_serilog should use json format"
  }
}

# Test: log_source enrichment filter
run "validate_log_source_enrichment" {
  command = plan
  assert {
    condition     = local.dotnet_filters[2].add_fields.log_source == "dotnet"
    error_message = "Dotnet filter should enrich logs with log_source=dotnet"
  }
}

# Test: Health check/static asset filter
run "validate_health_check_filter" {
  command = plan
  assert {
    condition     = local.dotnet_filters[0].name == "grep"
    error_message = "First dotnet filter should be a grep filter for health checks/static assets"
  }
  assert {
    condition     = local.dotnet_filters[0].exclude == "message .*health.*|.*static.*"
    error_message = "First dotnet filter should exclude health checks and static assets"
  }
}

# Test: Profile image warning filter
run "validate_profile_warning_filter" {
  command = plan
  assert {
    condition     = local.dotnet_filters[1].name == "grep"
    error_message = "Second dotnet filter should be a grep filter for profile image warnings"
  }
  assert {
    condition     = local.dotnet_filters[1].exclude == "message .*Image not found for userId.*"
    error_message = "Second dotnet filter should exclude profile image warnings"
  }
}

# Test: FireLens match pattern (consistent with all other presets)
run "validate_firelens_match_pattern" {
  command = plan
  assert {
    condition     = local.dotnet_filters_map["dotnet"][0].match == "*"
    error_message = "Dotnet filter match pattern should use '*' for FireLens tag format"
  }
}
