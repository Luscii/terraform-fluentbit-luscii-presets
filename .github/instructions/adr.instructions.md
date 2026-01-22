---
applyTo: "docs/adr/**/*.md"
---

# Architecture Decision Records (ADR) Instructions

## Quick Reference

**When creating ADRs:**
- Use MADR (Markdown Architectural Decision Records) template
- Store in `docs/adr/` directory
- Filename: `NNNN-title-with-dashes.md` (e.g., `0001-use-cloudposse-label-module.md`)
- Required sections: Title, Status/Date, Context, Decision, Consequences
- Optional sections: Decision Drivers, Considered Options, Pros/Cons, More Information
- Link related ADRs with "Supersedes", "Superseded by", "Relates to"

**Cross-references:**
- Implementation planning → [implementation-plan.md](../.github/agents/implementation-plan.md)
- Documentation style → [documentation.instructions.md](./documentation.instructions.md)
- Visual diagrams → Use the **mermaid-diagrams** skill for architecture diagrams and decision visualizations

---

## Overview

Architecture Decision Records (ADRs) document the significant architectural decisions made for a Terraform module. We use the MADR (Markdown Architectural Decision Records) format, which provides a lightweight yet comprehensive template for capturing decisions and their context.

## Why ADRs for Terraform Modules?

ADRs help teams:
- **Understand rationale** - Why specific approaches were chosen
- **Prevent re-litigating** - Decisions are documented with context
- **Onboard new contributors** - Historical context is preserved
- **Track evolution** - See how the module design evolved over time
- **Make informed changes** - Understand implications before modifying

## Directory Structure

### Standard Layout

```
docs/
├── adr/
│   ├── 0001-use-cloudposse-label-module.md
│   ├── 0002-implement-auto-scaling-support.md
│   ├── 0003-add-service-connect-integration.md
│   └── README.md
└── features/
    └── [Gherkin feature files]
```

### Numbering Convention

- **Sequential numbers:** `0001`, `0002`, `0003`, etc.
- **Zero-padded:** Always 4 digits (supports up to 9999 decisions)
- **Continuous sequence:** Don't reuse numbers, even for superseded decisions
- **Index file:** `README.md` in `docs/adr/` lists all ADRs

### Filename Format

**Pattern:** `NNNN-title-with-dashes.md`

**Examples:**
```
✅ Good:
- 0001-use-cloudposse-label-module.md
- 0002-implement-auto-scaling-support.md
- 0003-choose-fargate-over-ec2-launch-type.md

❌ Bad:
- 1-cloudposse.md (not zero-padded)
- use-cloudposse-label-module.md (no number)
- 0001_use_cloudposse.md (underscore instead of dash)
- 0001-Use-CloudPosse-Label-Module.md (not all lowercase)
```

## MADR Template Structure

### Full Template

Use this comprehensive template for significant architectural decisions:

```markdown
# [Short title of decision]

**Status:** [proposed | accepted | rejected | deprecated | superseded by [ADR-0005](0005-example.md)]

**Date:** YYYY-MM-DD

**Deciders:** [List of people involved in the decision]

**Consulted:** [Optional: People consulted for input]

**Informed:** [Optional: People who should be informed]

## Context and Problem Statement

[Describe the context and problem statement, including any business or technical requirements. Use 2-3 paragraphs to explain the situation.]

**Example:**
> The module needs a consistent naming and tagging strategy for all AWS resources. Without standardization, resources become difficult to manage, cost allocation is unclear, and compliance requirements are harder to enforce.

## Decision Drivers

* [Driver 1, e.g., technical requirement, business need, constraint]
* [Driver 2]
* [Driver 3]

**Example:**
* Must support multi-environment deployments (dev, staging, prod)
* Must enable cost allocation tagging
* Must comply with organizational naming standards
* Must work across multiple AWS accounts
* Must be maintained and widely adopted

## Considered Options

* [Option 1]
* [Option 2]
* [Option 3]

**Example:**
* Custom naming module
* CloudPosse label module
* Manual resource naming
* HashiCorp naming module

## Decision Outcome

**Chosen option:** "[Option X]", because [justification].

**Example:**
> **Chosen option:** "CloudPosse label module (v0.25.0)", because it provides comprehensive context propagation, is actively maintained, widely adopted in the Terraform community, and supports all required naming and tagging patterns.

### Consequences

**Positive:**

* [e.g., improvement of quality attribute, follows best practice, ...]
* [...]

**Negative:**

* [e.g., compromising quality attribute, technical debt, ...]
* [...]

**Neutral:**

* [e.g., requires team training, changes existing patterns, ...]
* [...]

**Example:**
**Positive:**
* Standardized naming across all modules
* Automatic tag propagation to all resources
* Context can be passed between modules
* Well-documented and actively maintained

**Negative:**
* External dependency (CloudPosse module)
* Specific version pinning required (0.25.0)
* Learning curve for team members unfamiliar with the pattern

**Neutral:**
* Requires updating all existing modules to adopt the pattern
* `context` variable must always be first in variables.tf

### Confirmation

[Describe how the decision will be validated/confirmed. Optional section.]

**Example:**
> Success will be confirmed when:
> * All resources use `module.label.id` for naming
> * All resources apply `module.label.tags`
> * Terraform plan shows no naming conflicts
> * All tests pass with label integration

## Pros and Cons of the Options

### [Option 1]

[Brief description]

**Pros:**

* [argument a]
* [argument b]

**Cons:**

* [argument c]
* [argument d]

### [Option 2]

[Brief description]

**Pros:**

* [argument a]
* [argument b]

**Cons:**

* [argument c]
* [argument d]

[Repeat for each option]

## More Information

[Optional: Any additional context, references, links, or documentation]

**Example:**
* CloudPosse label module: https://github.com/cloudposse/terraform-null-label
* Module documentation: https://registry.terraform.io/modules/cloudposse/label/null/latest
* Related ADR: [0002-implement-auto-scaling-support.md]
```

### Lightweight Template

For smaller decisions, use this minimal template:

```markdown
# [Short title of decision]

**Status:** [proposed | accepted | rejected | deprecated | superseded]

**Date:** YYYY-MM-DD

## Context and Problem Statement

[2-3 sentences describing the context and problem]

## Decision

[1-2 paragraphs explaining the chosen approach and rationale]

## Consequences

**Positive:**
* [benefit 1]
* [benefit 2]

**Negative:**
* [drawback 1]
* [drawback 2]
```

## Writing ADRs

### When to Create an ADR

Create an ADR for decisions that:
- **Impact module architecture** - Structural choices, patterns, dependencies
- **Affect module users** - Interface changes, required variables, breaking changes
- **Have long-term implications** - Technology choices, provider versions, external dependencies
- **Involve trade-offs** - Performance vs. cost, flexibility vs. simplicity
- **Require justification** - Why one approach over another

**Examples of ADR-worthy decisions:**
- Using CloudPosse label module for naming/tagging
- Implementing auto-scaling support
- Choosing Fargate over EC2 launch type
- Adding Service Connect integration
- Supporting multiple AWS provider versions
- Choosing between count and for_each for resources

**Not ADR-worthy (use code comments instead):**
- Simple implementation details
- Obvious best practices
- Temporary workarounds
- Minor refactoring

### ADR Workflow

**1. Propose Decision:**
```markdown
**Status:** proposed
**Date:** 2026-01-21
```

**2. Discuss and Refine:**
- Share with team
- Gather feedback
- Update considered options
- Document pros/cons

**3. Accept Decision:**
```markdown
**Status:** accepted
**Date:** 2026-01-21
```

**4. Implement:**
- Write code according to decision
- Reference ADR in pull requests
- Update documentation

**5. Validate:**
- Confirm expected consequences
- Document any surprises
- Update ADR if needed

**6. Supersede (if needed):**
```markdown
**Status:** superseded by [ADR-0042](0042-new-approach.md)
**Date:** 2026-03-15
```

### Status Values

- **proposed** - Decision under discussion, not yet accepted
- **accepted** - Decision approved and implemented
- **rejected** - Considered but not chosen (document why)
- **deprecated** - No longer recommended, but not replaced
- **superseded by [ADR-NNNN]** - Replaced by a newer decision

### Linking ADRs

Reference related ADRs using relative links:

```markdown
## More Information

* Supersedes [ADR-0001](0001-manual-naming-strategy.md)
* Superseded by [ADR-0015](0015-enhanced-labeling.md)
* Relates to [ADR-0003](0003-multi-environment-support.md)
* See also [ADR-0007](0007-cost-allocation-tagging.md)
```

## Writing Style

### Clear and Concise

**Good:**
> We need a consistent way to name AWS resources across all environments. Without this, cost allocation becomes impossible and resources are hard to identify.

**Bad:**
> There has been some discussion about potentially implementing some kind of naming strategy which could help with various things like maybe cost tracking and stuff.

### Objective and Factual

**Good:**
> CloudPosse label module provides automated context propagation and is maintained by an active community with 500+ stars on GitHub.

**Bad:**
> CloudPosse is obviously the best choice and everyone should use it.

### Focus on "Why"

**Good:**
> We chose Fargate over EC2 because our workloads are short-lived (avg 15min), making Fargate's per-second billing more cost-effective than maintaining an EC2 cluster.

**Bad:**
> We chose Fargate because it's better.

### Include Context

**Good:**
> At the time of this decision (Jan 2026), ECS Service Connect was recently released (Nov 2022) and provided native service mesh capabilities without requiring additional infrastructure like App Mesh or Consul.

**Bad:**
> Service Connect is new and good.

## Examples

### Example 1: Dependency Decision

```markdown
# Use CloudPosse Label Module for Resource Naming

**Status:** accepted

**Date:** 2026-01-15

**Deciders:** Platform Team, DevOps Team

## Context and Problem Statement

The Terraform module needs a standardized approach for naming and tagging AWS resources. Current manual naming leads to inconsistent resource names across environments, making cost allocation and resource management difficult. We need a solution that works across multiple modules and supports organizational tagging requirements.

## Decision Drivers

* Must generate consistent, predictable resource names
* Must support multi-environment deployments (dev, staging, prod)
* Must enable cost allocation through tags
* Must be reusable across multiple Terraform modules
* Must be actively maintained
* Should follow Terraform best practices

## Considered Options

* Custom naming module (build in-house)
* CloudPosse label module
* Manual resource naming with variables
* HashiCorp naming conventions module

## Decision Outcome

**Chosen option:** "CloudPosse label module (v0.25.0)", because it provides comprehensive context propagation, is actively maintained with broad community adoption, and supports all required naming and tagging patterns without requiring custom development.

### Consequences

**Positive:**
* Standardized naming across all Luscii Terraform modules
* Automatic tag propagation to all resources
* Context can be passed between nested modules
* Well-documented with extensive examples
* Active maintenance and community support
* Enables consistent cost allocation tags

**Negative:**
* External dependency introduces version management requirement
* Requires pinning to specific version (0.25.0)
* Team learning curve for context variable pattern
* All modules must adopt the pattern for consistency

**Neutral:**
* Requires `context` variable to be first in variables.tf (style convention)
* Existing modules need migration to adopt the pattern

### Confirmation

Success will be confirmed when:
* All resources use `module.label.id` for naming
* All resources apply `module.label.tags`
* Terraform plan shows consistent naming across environments
* All tests pass with label integration
* Cost allocation reports can filter by generated tags

## Pros and Cons of the Options

### Custom Naming Module

Build an in-house module for name generation.

**Pros:**
* Full control over implementation
* No external dependencies
* Can customize to exact requirements

**Cons:**
* Requires development and ongoing maintenance effort
* Needs comprehensive testing
* Community knowledge not applicable
* Reinventing the wheel

### CloudPosse Label Module

Use established CloudPosse null-label module.

**Pros:**
* Actively maintained (500+ stars, frequent updates)
* Comprehensive documentation and examples
* Supports complex naming patterns
* Context propagation pattern well-established
* Wide community adoption
* Proven in production

**Cons:**
* External dependency
* Version pinning required
* Some features we may not need
* Learning curve for team

### Manual Resource Naming

Use variables to construct names manually.

**Pros:**
* No dependencies
* Simple to understand
* Full control

**Cons:**
* Inconsistent implementation across modules
* Error-prone (typos in name construction)
* No automatic tag propagation
* Difficult to enforce standards
* Repetitive code in every module

### HashiCorp Naming Module

Use official HashiCorp naming patterns (if available).

**Pros:**
* Official HashiCorp support
* Well-integrated with Terraform ecosystem

**Cons:**
* No comprehensive module exists for this purpose
* Would still need custom development
* Less feature-rich than CloudPosse

## More Information

* CloudPosse label module: https://github.com/cloudposse/terraform-null-label
* Module registry: https://registry.terraform.io/modules/cloudposse/label/null/latest
* Version 0.25.0 release notes: https://github.com/cloudposse/terraform-null-label/releases/tag/0.25.0
* Related: [0002-multi-environment-support.md] (depends on this decision)
```

### Example 2: Technical Choice

```markdown
# Use Fargate Launch Type for ECS Services

**Status:** accepted

**Date:** 2026-01-18

## Context and Problem Statement

The ECS service module needs to choose between EC2 and Fargate launch types. Our workloads are containerized microservices with variable load patterns throughout the day. We need to balance cost, operational overhead, and scalability.

## Decision Drivers

* Cost optimization for variable workloads
* Minimize operational overhead
* Support rapid scaling (0-100 tasks in <5 minutes)
* Avoid cluster management complexity
* Security isolation between services

## Decision Outcome

**Chosen option:** "Fargate launch type", because our workloads are short-lived (average 15 minutes) with highly variable demand, making Fargate's per-second billing more cost-effective than maintaining an EC2 cluster with sufficient capacity for peak loads.

### Consequences

**Positive:**
* No cluster management (no EC2 instances to maintain)
* Per-second billing aligns with actual usage
* Automatic scaling without capacity planning
* Built-in security isolation (task-level ENI)
* Faster deployment pipeline (no AMI updates)

**Negative:**
* Higher per-vCPU cost than EC2 (approximately 20% more)
* Limited instance type choices
* Cannot use Spot instances
* Cold start time slightly higher than warm EC2 instances

**Neutral:**
* Requires awsvpc network mode (beneficial for security)
* Task definitions need Fargate-compatible CPU/memory combinations

## More Information

* AWS Fargate pricing: https://aws.amazon.com/fargate/pricing/
* Cost comparison spreadsheet: [internal-link]
* Related: [0003-implement-auto-scaling.md]
```

## Best Practices

### Do's

✅ **Write ADRs early** - Document decisions as they're made, not after
✅ **Be specific** - Include concrete details, versions, constraints
✅ **Show alternatives** - Document what was considered and why it wasn't chosen
✅ **Update status** - Keep status current (proposed → accepted → superseded)
✅ **Link related ADRs** - Create connections between related decisions
✅ **Include dates** - When was the decision made? Context changes over time
✅ **Document consequences** - Both positive and negative outcomes
✅ **Use examples** - Concrete examples clarify abstract concepts
✅ **Keep it readable** - Write for future team members who weren't there

### Don'ts

❌ **Don't delete ADRs** - Superseded decisions provide historical context
❌ **Don't skip rejected options** - Document why alternatives weren't chosen
❌ **Don't be vague** - "Better performance" → "50% faster processing time"
❌ **Don't hide trade-offs** - Acknowledge negative consequences
❌ **Don't write novels** - Keep it focused and scannable
❌ **Don't skip validation** - Define how success will be measured
❌ **Don't backdated ADRs** - Document decisions when they're made, use actual date
❌ **Don't use jargon** - Explain technical terms, write for broader audience

## Index File

Create a `README.md` in `docs/adr/` to index all ADRs:

```markdown
# Architecture Decision Records

This directory contains Architecture Decision Records (ADRs) for this Terraform module.

## Active Decisions

* [ADR-0001](0001-use-cloudposse-label-module.md) - Use CloudPosse Label Module for Resource Naming
* [ADR-0002](0002-implement-auto-scaling-support.md) - Implement Auto-Scaling Support
* [ADR-0003](0003-choose-fargate-launch-type.md) - Use Fargate Launch Type for ECS Services

## Superseded Decisions

* [ADR-0004](0004-manual-naming-strategy.md) - Manual Naming Strategy (superseded by ADR-0001)

## Template

For new ADRs, see [MADR template](../../instructions/adr.instructions.md).
```

## Integration with Agents

### implementation-plan Agent

The implementation-plan agent creates ADRs for each feature:

```markdown
## Implementation Plan: Feature Name

**ADR:** `docs/adr/0005-feature-name.md`

[ADR content following MADR template]

## Scenarios

[Gherkin scenarios for testing the feature]
```

### Other Agents

Agents reference ADRs when making implementation decisions:

```markdown
<!-- In terraform-module-specialist -->
Implementing auto-scaling as specified in ADR-0002.
Using CloudPosse label module per ADR-0001 for resource naming.
```

## Additional Resources

- [MADR Template Primer](https://www.ozimmer.ch/practices/2022/11/22/MADRTemplatePrimer.html)
- [MADR GitHub Repository](https://github.com/adr/madr)
- [ADR GitHub Organization](https://adr.github.io/)
- [Michael Nygard's ADR Article](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
