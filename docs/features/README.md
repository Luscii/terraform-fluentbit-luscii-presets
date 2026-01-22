# Feature Scenarios for terraform-fluentbit-configuration

This directory contains Gherkin scenarios for all supported technologies and the overall module architecture. Each feature file describes testable requirements for the existing code, based on ADRs and the implementation plan.

## Available Features

- [php-logging.feature](php-logging.feature): PHP Monolog log parsing and filtering
- [nginx-logging.feature](nginx-logging.feature): Nginx access and error log parsing
- [datadog-logging.feature](datadog-logging.feature): Datadog APM trace log filtering
- [module-architecture.feature](module-architecture.feature): Parser-filter architecture and integration

## How to Use

- Each scenario describes expected behavior for the current implementation
- No code changes are required; scenarios validate existing logic
- Use these scenarios to guide test creation and documentation
- Scenarios are aligned with ADRs and the IMPLEMENTATION_PLAN

## Next Steps

- terraform-tester: Implement missing tests for Nginx and Datadog
- documentation-specialist: Update README.md and technology docs
- examples-specialist: Add missing examples for PHP, Nginx, Datadog
- scenario-shaper: Add .NET scenarios when .NET support is implemented
