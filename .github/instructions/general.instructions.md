---
applyTo: "**"
---

# General Repository Instructions

## Language

**All code, comments, and documentation in this repository must be in English.**

✅ **DO:**
- Write code comments in English
- Write commit messages in English
- Write documentation in English
- Use English variable and function names
- Write issue descriptions and PR descriptions in English

❌ **DON'T:**
- Use Dutch or other languages in code
- Mix languages within the same file
- Use language-specific characters in identifiers

**Rationale:** English ensures:
- International collaboration
- Consistency across the codebase
- Compatibility with tools and AI assistants
- Wider community understanding

## File Encoding

✅ **ALWAYS:**
- Use UTF-8 encoding
- Use LF (Unix) line endings
- Include final newline at end of file

❌ **NEVER:**
- Use CRLF (Windows) line endings in commits
- Mix line ending styles

## General Code Quality

✅ **DO:**
- Write clear, self-documenting code
- Keep functions and files focused on single responsibility
- Remove unused code and commented-out code before committing
- Use descriptive names for variables, functions, and files

❌ **DON'T:**
- Commit commented-out code (use git history instead)
- Leave TODO comments without creating issues
- Hardcode sensitive values (credentials, tokens, secrets)

## Pre-Commit Requirements

**Before every commit:**
- [ ] Code is in English
- [ ] All tests pass
- [ ] Code is properly formatted
- [ ] No sensitive data is included
- [ ] Commit message follows conventional commits format

## Cross-References

- **Commit messages** → See [conventional-commits.instructions.md](./conventional-commits.instructions.md)
- **Terraform code** → See [terraform.instructions.md](./terraform.instructions.md)
- **Documentation** → See [documentation.instructions.md](./documentation.instructions.md)
- **Architecture decisions** → See [adr.instructions.md](./adr.instructions.md)
