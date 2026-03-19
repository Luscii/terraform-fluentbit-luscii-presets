# Node.js Pino JSON Parser and Logging Support

**Status:** accepted

**Date:** 2026-02-05

**Deciders:** Platform Team

## Context and Problem Statement

Node.js applications using the Pino logging library generate JSON-formatted logs with high-performance characteristics. Pino is one of the most popular logging libraries for Node.js, known for its low overhead and structured logging capabilities. The module currently supports PHP, Nginx, Envoy, .NET, and Datadog logs, but lacks support for Node.js applications that use Pino for structured JSON logging.

Pino outputs JSON logs with specific field names and timestamp formats that need proper parsing and filtering in Fluent Bit. Common Pino log formats include ISO 8601 timestamps in the `time` field (as milliseconds since epoch or ISO string), along with `level`, `msg`, `pid`, `hostname`, and other contextual fields.

We need to add Node.js/Pino support following the established parser-filter architecture (ADR-0002) to enable proper log processing for Node.js workloads in ECS/Fargate environments.

## Decision Drivers

* Pino is a widely-adopted logging library in the Node.js ecosystem
* Pino outputs structured JSON logs by default, making parsing straightforward
* Pino timestamp format can vary (milliseconds epoch or ISO 8601 string)
* Need to support both default Pino configuration and common customizations
* Should filter out common Node.js application noise (health checks, static assets)
* Must follow the established parser-filter architecture (ADR-0002)
* Must support container-specific routing via AWS FireLens tag format
* Should enrich logs with source metadata

## Considered Options

* **Multiple parsers for different Pino timestamp formats** (chosen)
* Single flexible parser with timestamp normalization
* Require applications to use specific Pino configuration
* Use generic JSON parser without time parsing

## Decision Outcome

**Chosen option:** "Multiple parsers for different Pino timestamp formats", because Pino can be configured to output timestamps in different formats (milliseconds epoch or ISO 8601 string), and Fluent Bit's parser filter tries parsers sequentially until one succeeds. This approach provides maximum compatibility without requiring application configuration changes.

### Implementation

**Parsers (3 total):**

1. **nodejs_pino_json_epoch** - Pino default format with milliseconds epoch
   - Format: json
   - Time field: `time` (milliseconds since epoch)
   - Time format: Handled by Fluent Bit's automatic conversion
   - Example: `{"level":30,"time":1738755000000,"msg":"Server started"}`

2. **nodejs_pino_json_iso** - Pino with ISO 8601 timestamp
   - Format: json
   - Time field: `time`
   - Time format: %Y-%m-%dT%H:%M:%S.%LZ
   - Example: `{"level":30,"time":"2026-02-05T10:30:00.000Z","msg":"Server started"}`

3. **nodejs_pino_json_iso_tz** - Pino with ISO 8601 timestamp and timezone
   - Format: json
   - Time field: `time`
   - Time format: %Y-%m-%dT%H:%M:%S.%L%z
   - Example: `{"level":30,"time":"2026-02-05T10:30:00.000+00:00","msg":"Server started"}`

**Filters (5 total):**

Grep filters (4) for noise reduction:
1. Exclude health check endpoints (common patterns: `/health`, `/healthz`, `/ready`, `/alive`)
2. Exclude static asset requests (`.js`, `.css`, `.png`, `.jpg`, `.ico` files)
3. Exclude common debug-level logs in production
4. Exclude successful heartbeat/keepalive messages

Modify filter (1) for enrichment:
5. Add log_source = "nodejs"

### Consequences

**Positive:**

* Supports Pino's default configuration (milliseconds epoch timestamp)
* Supports common Pino customizations (ISO 8601 timestamps)
* No application code changes required
* Follows established parser-filter architecture
* Clear parser names indicate which timestamp format they handle
* Easy to extend with additional parsers if needed
* Noise filtering reduces log volume and costs

**Negative:**

* Multiple parsers means Fluent Bit tries each until success (slight performance overhead)
* Must maintain parser configurations as Pino evolves
* Noise filters may need tuning per application

**Neutral:**

* All parsers attempt to parse the same "log" field
* Parser order doesn't matter (Fluent Bit tries all)
* Filters are applied after parsing succeeds

### Confirmation

Success will be confirmed by:
* ✅ nodejs-config.tftest.hcl passes (all parser and filter tests)
* ✅ All 3 parsers validated with different timestamp formats
* ✅ All 5 filters validated
* ✅ Integration tests pass with container-specific routing
* ✅ Documentation includes Pino configuration examples

## Implementation Plan

### Agent Tasks

**1. scenario-shaper** - Create scenario:
- File: `docs/features/nodejs-logging.feature`
- Scenarios:
  - Parse Pino JSON with milliseconds epoch timestamp
  - Parse Pino JSON with ISO 8601 timestamp (UTC)
  - Parse Pino JSON with ISO 8601 timestamp (timezone)
  - Filter out health check endpoints
  - Filter out static asset requests
  - Filter out debug logs
  - Add log_source metadata
  - Container-specific routing

**2. terraform-tester** - Create tests:
- File: `tests/nodejs-config.tftest.hcl`
- Test parser count and structure
- Test each parser configuration
- Test filter count and types
- Test filter patterns and field additions
- Test parsers_map and filters_map creation
- Test integration with config.tf

**3. terraform-module-specialist** - Implement code:
- File: `nodejs-config.tf`
- Create nodejs_parsers local with 3 parser definitions
- Create nodejs_filters local with 5 filter definitions
- Create nodejs_parsers_map entry
- Create nodejs_filters_map entry
- Update config.tf to merge nodejs maps
- Update variables.tf validation to include "nodejs"

**4. documentation-specialist** - Update docs:
- Update README.md with Node.js/Pino section
- Document supported Pino timestamp formats
- Explain noise filtering strategy
- Provide Pino configuration example
- Document when to use custom filters
- Show minimal and advanced examples

**5. examples-specialist** - Add examples:
- Add Node.js example to examples/complete/main.tf
- Show Pino JSON configuration
- Demonstrate custom filter addition
- Show multi-container Node.js setup

## Pros and Cons of the Options

### Multiple parsers for different Pino timestamp formats

**Pros:**
* Works with default Pino configuration (no app changes needed)
* Works with custom Pino timestamp formats
* Clear separation of concerns (one parser per format)
* Easy to debug which parser matched
* Follows pattern established by PHP parsers (ADR-0004)

**Cons:**
* Multiple parsers have slight performance overhead
* More parser definitions to maintain
* Parser list grows if new formats emerge

### Single flexible parser with timestamp normalization

**Pros:**
* Single parser definition
* No performance overhead from trying multiple parsers

**Cons:**
* Timestamp normalization adds complexity
* May not handle all Pino timestamp variants
* Harder to debug parsing issues

### Require applications to use specific Pino configuration

**Pros:**
* Simplest parser implementation
* Predictable log format

**Cons:**
* Requires application changes
* Breaks existing applications
* Reduces flexibility

### Use generic JSON parser without time parsing

**Pros:**
* Simplest implementation
* Works with any JSON format

**Cons:**
* Loses timestamp information
* Cannot properly order logs
* Doesn't follow best practices

## More Information

**Pino Documentation:**
- [Pino GitHub](https://github.com/pinojs/pino)
- [Pino Timestamp Documentation](https://github.com/pinojs/pino/blob/master/docs/api.md#timestamp-boolean--function)

**Pino Default Log Format:**
```json
{
  "level": 30,
  "time": 1738755000000,
  "pid": 12345,
  "hostname": "server-01",
  "msg": "Server listening on port 3000"
}
```

**Pino Log Levels:**
- 10: trace
- 20: debug
- 30: info
- 40: warn
- 50: error
- 60: fatal

**Pino Timestamp Formats:**

1. Default (milliseconds epoch):
```javascript
const logger = pino();
// Output: {"level":30,"time":1738755000000,"msg":"hello"}
```

2. ISO 8601 with milliseconds:
```javascript
const logger = pino({ timestamp: pino.stdTimeFunctions.isoTime });
// Output: {"level":30,"time":"2026-02-05T10:30:00.000Z","msg":"hello"}
```

3. Custom timestamp function:
```javascript
const logger = pino({ 
  timestamp: () => `,"time":"${new Date().toISOString()}"` 
});
```

**Related ADRs:**
- [ADR-0002](0002-parser-filter-architecture.md) - Parser-Filter Architecture
- [ADR-0004](0004-php-monolog-parsers-filters.md) - Similar approach for PHP Monolog

**Files to Create/Modify:**
- ✅ docs/adr/0007-nodejs-pino-json-parser.md (this file)
- ✅ docs/adr/README.md (update index)
- ✅ docs/features/nodejs-logging.feature (scenario-shaper)
- ✅ tests/nodejs-config.tftest.hcl (terraform-tester)
- ✅ nodejs-config.tf (terraform-module-specialist)
- ✅ config.tf (terraform-module-specialist - merge maps)
- ✅ variables.tf (terraform-module-specialist - add "nodejs" to validation)
- ✅ README.md (documentation-specialist)
- ✅ examples/complete/main.tf (examples-specialist)

**Testing Strategy:**
- Unit tests for parser structure and configuration
- Unit tests for filter structure and patterns
- Integration tests with log_sources
- Container-specific match pattern tests
- Validation with actual Pino log samples
