---
applyTo: ".github/agents/**,.github/skills/**,.github/instructions/**"
---

# GitHub Copilot Architecture Instructions

## Purpose

Define when to use **Agent**, **Instructions**, or **Skills** for GitHub Copilot capabilities.

---

## The Three Pillars

### 1. Custom Agents (Specialized Workflows)

**What:** Custom Agents are `.agent.md` files that create specialized workflows with tailored expertise

**Location:** `.github/agents/{name}.agent.md`

**Capabilities:**
- Define specialized behavior for specific tasks
- Configure which tools the agent can use
- Set AI model preferences
- Create focused workflows (testing, planning, refactoring, etc.)
- Can be assigned to GitHub issues or selected in Copilot Chat

**Examples:** test-specialist, implementation-planner, security-reviewer

**Analogy:** Specialist team members with specific expertise

**When to create:** When you need a specialized workflow for a specific task type

**Note:** Different from "the Agent" (GitHub Copilot AI itself which executes everything)

---

### 2. Instructions (Prescriptive Rules)

**Location:** `.github/instructions/{name}.instructions.md`

**What:** Always-active prescriptive rules automatically loaded for specific file types

**Characteristics:**
- ✅ **Always active** for matching file patterns (`applyTo`)
- ✅ **Prescriptive** - DO's and DON'Ts, mandatory patterns
- ✅ **Context-driven** - loaded based on current file type
- ✅ **Short, focused rules** - what to do and what not to do
- ✅ **100-800 lines maximum** - keep concise

**Required Format:**
```yaml
---
applyTo: "file/pattern/**/*.ext"
---

# Instruction Name

## Rules

- ✅ DO: Use this pattern
- ❌ DON'T: Avoid this anti-pattern
- ⚠️ ALWAYS: Follow this standard
```

**Analogy:** Your team's coding standards and style guide

**When to create an Instruction:**
- ✅ You have mandatory rules for specific file types
- ✅ Rules apply automatically based on file extension/path
- ✅ Content is prescriptive (MUST/NEVER/ALWAYS)
- ✅ You can keep it under 800 lines
- ✅ It's enforcement-focused, not educational

**When NOT to create an Instruction:**
- ❌ Content is descriptive/educational (use Skill instead)
- ❌ Content exceeds 800 lines (use Skill instead)
- ❌ Activation should be query-based, not file-based (use Skill)
- ❌ Contains extensive examples/tutorials (use Skill)

---

### 3. Skills (Descriptive Knowledge Base)

**Location:** `.github/skills/{skill-name}/SKILL.md`

**What:** On-demand knowledge base loaded when agent thinks it's relevant

**Characteristics:**
- ⚡ **On-demand loaded** - only when agent deems relevant
- 📚 **Descriptive** - reference material, explanations, examples
- 🎯 **Specialized** - deep knowledge on specific topic
- 🔍 **Query-driven** - activated by keywords in description
- 📏 **500-1,500 lines ideal** - comprehensive but focused

**Required Format:**
```yaml
---
name: skill-name
description: 'What it does and when to use it. Include keywords: "specific", "triggers", "user might say".'
---

# Skill Title

## When to Use This Skill

- User asks about "topic"
- Questions about "keyword"
- "Specific phrases users might say"

## Content

[Comprehensive explanations, examples, best practices]
```

**Analogy:** A library of reference materials you look up for specific information

**When to create a Skill:**
- ✅ Content is descriptive/educational
- ✅ Contains comprehensive examples and explanations
- ✅ Should be loaded on-demand (query-based)
- ✅ Size: 500-1,500 lines
- ✅ Deep dive into specific topic

**When NOT to create a Skill:**
- ❌ Content is purely prescriptive rules (use Instruction)
- ❌ Should always be active for file types (use Instruction)
- ❌ Content is too small (<200 lines, add to existing skill)
- ❌ Content is too large (>2,000 lines, split into multiple skills)

---

## Decision Matrix

| Question | Answer | Use |
|----------|--------|-----|
| Need specialized workflow? | Yes | **Custom Agent** |
| Is it prescriptive rules? | Yes | **Instruction** |
| Should it auto-load for file types? | Yes | **Instruction** |
| Is it >800 lines? | Yes | **Skill** (not Instruction) |
| Is it descriptive/educational? | Yes | **Skill** |
| Should it load on-demand? | Yes | **Skill** |
| Is it <200 lines? | Yes | Add to existing Instruction/Skill |

## Size Limits

### Instructions
- **Minimum:** 50 lines (below this, add to existing instruction)
- **Target:** 100-500 lines (sweet spot)
- **Maximum:** 800 lines (above this, convert to skill)
- **Critical:** 1,000+ lines (MUST refactor)

**Rationale:** Instructions are always loaded - keep them lightweight!

### Skills
- **Minimum:** 200 lines (below this, add to existing skill)
- **Target:** 500-1,000 lines (sweet spot)
- **Maximum:** 1,500 lines (above this, consider splitting)
- **Critical:** 2,000+ lines (MUST split into focused skills)

**Rationale:** Skills load on-demand - can be larger, but focused

---

## File Type Patterns

### Instructions: applyTo Examples

```yaml
# Terraform files
applyTo: "**/*.tf"

# Test files
applyTo: "**/*.tftest.hcl,tests/**/*.tf"

# Documentation
applyTo: "**/*.md,variables.tf,outputs.tf"

# Examples
applyTo: "examples/**/*,README.md"

# Specific directory
applyTo: "docs/adr/**/*.md"

# Global (use sparingly!)
applyTo: "**"
```

### Skills: Description Triggers

```yaml
# Good - specific triggers
description: 'Configure Terraform resources including naming patterns,
dynamic blocks, conditional creation. Use when asked about "resource
configuration", "dynamic blocks", "count/for_each", "lifecycle blocks".'

# Bad - too vague
description: 'Terraform resources.'
```

---

## Common Patterns

### Pattern 1: Compact Instruction + Deep Skill

**Use when:** Topic needs both rules AND detailed explanations

```
terraform.instructions.md (600 lines)
- DO's and DON'Ts
- Quick reference
- Cross-reference to terraform-resources skill

terraform-resources skill (1,400 lines)
- Comprehensive examples
- Deep explanations
- Best practices
```

### Pattern 2: Standalone Instruction

**Use when:** Pure rules, no deep explanations needed

```
conventional-commits.instructions.md (150 lines)
- Commit message format rules
- DO's and DON'Ts
- No skill needed
```

### Pattern 3: Standalone Skill

**Use when:** On-demand knowledge, not file-type specific

```
terraform-functions skill (600 lines)
- Quick reference for 100+ functions
- Loaded when asked about functions
- No instruction counterpart needed
```

---

## Anti-Patterns to Avoid

### ❌ Anti-Pattern 1: Instruction Too Large

```
# BAD: terraform-tests.instructions.md (2,206 lines)
# Problem: This is actually a skill!
# Solution: Keep instruction compact (200 lines), move details to skill
```

### ❌ Anti-Pattern 2: Missing applyTo

```yaml
# BAD: No applyTo pattern
---
# No activation pattern!
---
```

**Fix:** Always include applyTo for instructions

### ❌ Anti-Pattern 3: Vague Skill Description

```yaml
# BAD
description: 'Terraform helpers.'

# GOOD
description: 'Terraform resource configuration including naming, dynamic
blocks, lifecycle. Use when asked about "resources", "count", "for_each".'
```

### ❌ Anti-Pattern 4: Duplicate Content

```
# BAD: Same content in instruction AND skill
instruction: 2,000 lines
skill:       900 lines
overlap:     70%

# GOOD: Clear separation
instruction: 200 lines (rules only)
skill:       1,200 lines (detailed explanations)
overlap:     0%
```

---

## Cross-Referencing Strategy

### Instruction → Skill

```markdown
## Dynamic Blocks

**Quick Reference:**
- Use `dynamic` blocks for repeating nested blocks
- Syntax: `dynamic "block_name" { for_each = ... }`

**For comprehensive examples, see the **terraform-resources** skill.**
```

### Skill → Skill

```markdown
## Dynamic Blocks

Dynamic blocks generate nested blocks. **For HCL syntax details,
see the **terraform-syntax** skill.**

[Comprehensive examples here...]
```

### Skill → Instruction

```markdown
## Best Practices

For mandatory code style rules, refer to terraform.instructions.md
```

---

## Quality Checklist

### For Instructions
- [ ] Has `applyTo` pattern in frontmatter
- [ ] File name ends with `.instructions.md`
- [ ] Content is prescriptive (DO's/DON'Ts)
- [ ] Length: 100-800 lines
- [ ] Cross-references skills for details
- [ ] No extensive examples (those go in skills)

### For Skills
- [ ] Has YAML frontmatter with `name` and `description`
- [ ] Name matches folder name
- [ ] Description includes specific triggers/keywords
- [ ] Has "When to Use This Skill" section
- [ ] Length: 500-1,500 lines
- [ ] Comprehensive examples included
- [ ] Cross-references other skills where relevant

---

## When in Doubt

**Ask these questions:**

1. **"Do I need a specialized workflow for a specific task?"**
   - Yes → Custom Agent
   - No → Continue below

2. **"Would I want this loaded for EVERY file of this type?"**
   - Yes → Instruction
   - No → Skill

3. **"Is this about RULES or KNOWLEDGE?"**
   - Rules → Instruction
   - Knowledge → Skill

4. **"How many lines?"**
   - <800 lines + file-specific → Instruction
   - >500 lines + on-demand → Skill

5. **"Is it prescriptive or descriptive?"**
   - Prescriptive (MUST/DON'T) → Instruction
   - Descriptive (HOW/WHY) → Skill

---

## Tools for Creation

Use these skills to create new components:

- **make-agent** skill - Scaffold custom agent (.agent.md) files
- **make-instruction** skill - Scaffold new instruction files
- **make-skill-template** skill - Create new skills
- This instruction file - Decide which to create

---

## Examples from This Repository

### ✅ Good Instructions (Compact, Prescriptive)

| File | Lines | Why It's Good |
|------|-------|---------------|
| terraform.instructions.md | 814 | Prescriptive rules for .tf files |
| documentation.instructions.md | 418 | DO's/DON'Ts for docs |
| conventional-commits.instructions.md | 142 | Pure rules, no tutorial |

### ✅ Good Skills (Focused, Descriptive)

| Skill | Lines | Why It's Good |
|-------|-------|---------------|
| terraform-resources | 1,411 | Deep dive with examples |
| terraform-syntax | 1,118 | Comprehensive HCL reference |
| terraform-functions | 581 | Quick reference table |

### ❌ Anti-Pattern Example

| File | Lines | Problem | Solution |
|------|-------|---------|----------|
| terraform-tests.instructions.md | 2,206 | Too large, descriptive content | Keep 200 lines of rules, move rest to skill |

---

## References

- **make-instruction** skill - Create new instructions
- **make-skill-template** skill - Create new skills
- See ARCHITECTURE_REVIEW.md for detailed analysis
