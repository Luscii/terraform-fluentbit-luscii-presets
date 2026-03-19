# Architecture Decision Records

This directory contains Architecture Decision Records (ADRs) for the terraform-fluentbit-configuration module.


## Active Decisions

* [ADR-0001](0001-single-envoy-technology-for-appmesh-and-serviceconnect.md) - Use Single Envoy Technology for Both AppMesh and ServiceConnect
* [ADR-0002](0002-parser-filter-architecture.md) - Parser-Filter Architecture for Technology-Specific Log Processing
* [ADR-0003](0003-nginx-parsers-filters.md) - Nginx JSON Access Log Parser and Error Log Support
* [ADR-0004](0004-php-monolog-parsers-filters.md) - PHP Monolog JSON Parser with Multiple Datetime Formats
* [ADR-0005](0005-datadog-apm-filtering.md) - Datadog APM Trace Log Filtering
* [ADR-0006](0006-dotnet-pending-implementation.md) - .NET Logging Support - Implemented
* [ADR-0007](0007-nodejs-pino-json-parser.md) - Node.js Pino JSON Parser and Logging Support

## About ADRs

Architecture Decision Records document significant architectural decisions made for this module, including:
- The context and problem being addressed
- Alternatives considered
- The chosen solution and rationale
- Consequences (positive, negative, and neutral)

For more information about ADRs, see [MADR (Markdown Architectural Decision Records)](https://adr.github.io/madr/).

## Creating New ADRs

When creating a new ADR:
1. Follow the MADR template in [.github/instructions/adr.instructions.md](../../.github/instructions/adr.instructions.md)
2. Use sequential numbering: `NNNN-title-with-dashes.md`
3. Start with status "proposed", change to "accepted" when implemented
4. Link related ADRs using relative paths
5. Update this README index
