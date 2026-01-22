Feature: Datadog APM Trace Log Filtering
  As a Platform Engineer
  I want to filter and enrich Datadog APM trace logs
  So that only trace logs are sent to Datadog and regular logs are excluded

  Background:
    Given the Fluent Bit configuration module uses the parser-filter architecture (ADR-0002)
    And Datadog APM trace logs contain the identifier "Luscii APM"

  Scenario: Parse Datadog APM JSON logs
    Given a log in JSON format with datetime field and "Luscii APM" in message
    When the parser_config is generated
    Then the parser "datadog_json" is present and matches the log

  Scenario: Filter for "Luscii APM" identifier
    Given a log containing "Luscii APM"
    When the filters_config is generated
    Then a grep filter includes only logs with this identifier

  Scenario: Exclude non-APM logs
    Given a log not containing "Luscii APM"
    When the filters_config is generated
    Then the grep filter excludes this log

  Scenario: Add log_source metadata
    When the filters_config is generated
    Then a modify filter adds the field log_source="datadog"

  Scenario: Multi-technology setup (PHP + Datadog)
    Given log_sources includes both "php" and "datadog" for the same container
    When the parser_config and filters_config are generated
    Then regular logs are processed by PHP parsers and APM logs by Datadog parser

  Scenario: Verify timestamp extraction
    Given a Datadog APM log with datetime field
    When the parser_config is generated
    Then the time_format is set to "%Y-%m-%dT%H:%M:%S%z"
