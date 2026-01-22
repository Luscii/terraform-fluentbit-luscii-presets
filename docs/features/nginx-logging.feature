Feature: Nginx Access and Error Log Parsing
  As a Platform Engineer
  I want to parse both JSON and standard Nginx logs
  So that access and error logs are correctly processed and enriched

  Background:
    Given the Fluent Bit configuration module uses the parser-filter architecture (ADR-0002)
    And Nginx logs may be in JSON format or standard access/error format

  Scenario: Parse JSON access log
    Given a log in JSON format with time_local field
    When the parser_config is generated
    Then the parser "nginx_json" is present and matches the log

  Scenario: Parse standard access log (regex)
    Given a log in standard Nginx access log format
    When the parser_config is generated
    Then the parser "nginx_access" is present and matches the log

  Scenario: Parse error log
    Given a log in standard Nginx error log format
    When the parser_config is generated
    Then the parser "nginx_error" is present and matches the log

  Scenario: Add log_source metadata
    When the filters_config is generated
    Then a modify filter adds the field log_source="nginx"

  Scenario: Container-specific routing
    Given log_sources includes a container name
    When the filters_config is generated
    Then the match pattern includes the container name
