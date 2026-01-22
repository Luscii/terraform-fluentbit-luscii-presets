Feature: Fluent Bit Parser-Filter Architecture
  As a Platform Engineer
  I want a modular parser/filter setup per technology
  So that log processing is maintainable, extensible, and testable

  Background:
    Given the module uses technology-specific config files (ADR-0002)
    And config.tf aggregates all technology parser/filter maps
    And custom parsers/filters can be added via variables

  Scenario: Technology lookup in merged maps
    Given log_sources includes multiple technologies
    When the parser_config and filters_config are generated
    Then each technology's parsers and filters are included

  Scenario: Container-specific match patterns
    Given log_sources specifies a container name
    When the filters_config is generated
    Then the match pattern includes the container name

  Scenario: Custom parser addition
    Given custom_parsers is set
    When the parser_config is generated
    Then the custom parser is included in the output

  Scenario: Custom filter addition
    Given custom_filters is set
    When the filters_config is generated
    Then the custom filter is included in the output

  Scenario: Integration with consumer module
    Given the output is used in terraform-aws-ecs-fargate-datadog-container-definitions
    When the module is applied
    Then the log configuration is compatible and complete
