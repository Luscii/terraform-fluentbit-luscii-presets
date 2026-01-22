Feature: PHP Monolog Logging Support
  As a Platform Engineer
  I want robust parsing and filtering for PHP Monolog logs
  So that all datetime variants and error logs are correctly processed and noise is filtered

  Background:
    Given the Fluent Bit configuration module uses the parser-filter architecture (ADR-0002)
    And PHP Monolog logs are emitted in JSON format with various datetime formats
    And PHP error logs may be present in standard format

  Scenario: Parse Monolog JSON with timezone colon
    Given a log with datetime "2026-01-15T08:59:58+00:00"
    When the parser_config is generated
    Then the parser "php_monolog_json_tz_colon" is present and matches the log

  Scenario: Parse Monolog JSON with timezone no colon
    Given a log with datetime "2026-01-15T08:59:58+0000"
    When the parser_config is generated
    Then the parser "php_monolog_json_tz" is present and matches the log

  Scenario: Parse Monolog JSON with UTC Z
    Given a log with datetime "2026-01-15T08:59:58Z"
    When the parser_config is generated
    Then the parser "php_monolog_json_utc" is present and matches the log

  Scenario: Parse Monolog JSON with microseconds
    Given a log with datetime "2026-01-15T08:59:58.123456+00:00"
    When the parser_config is generated
    Then the parser "php_monolog_json_micro" is present and matches the log

  Scenario: Parse PHP error log format
    Given a log in format "[22-Jan-2026 08:59:58 UTC] ERROR: Connection failed"
    When the parser_config is generated
    Then the parser "php_error" is present and matches the log

  Scenario: Filter out deprecated warnings
    Given a log containing "PHP Deprecated:"
    When the filters_config is generated
    Then a grep filter excludes this log

  Scenario: Filter out access logs in stderr
    Given a log matching the access log pattern
    When the filters_config is generated
    Then a grep filter excludes this log

  Scenario: Add log_source metadata
    When the filters_config is generated
    Then a modify filter adds the field log_source="php"

  Scenario: Container-specific routing
    Given log_sources includes a container name
    When the filters_config is generated
    Then the match pattern includes the container name
