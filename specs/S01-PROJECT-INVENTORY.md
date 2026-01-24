# S01 - Project Inventory: simple_cli

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23
**Library Version:** 1.0.0

---

## 1. Project Identity

| Attribute | Value |
|-----------|-------|
| Name | simple_cli |
| Purpose | Command-line argument parsing library |
| Domain | CLI / Developer Tools |
| Facade Class | SIMPLE_CLI |
| ECF File | simple_cli.ecf |

## 2. File Inventory

### Source Files (src/)

| File | Class | Purpose |
|------|-------|---------|
| simple_cli.e | SIMPLE_CLI | Complete CLI parser - flags, options, arguments |

### Test Files (testing/)

| File | Purpose |
|------|---------|
| test_app.e | Test application entry point |
| lib_tests.e | Library test suite |
| test_set_base.e | Base test set class |

## 3. Dependencies

### ISE Libraries

| Library | Purpose |
|---------|---------|
| base | Core Eiffel classes |
| argument_parser | ARGUMENTS_32 inheritance |

### simple_* Libraries

None required.

## 4. Platform Requirements

| Requirement | Value |
|-------------|-------|
| OS | Cross-platform (Windows, Linux, macOS) |
| Compiler | EiffelStudio 25.02+ |

## 5. Documentation Assets

| File | Status |
|------|--------|
| README.md | Present |
| CHANGELOG.md | Present |
| research/SIMPLE_CLI_RESEARCH.md | Present (comprehensive) |
| docs/index.html | Present |

## 6. Known Limitations

1. No subcommand support (like `git add`, `docker run`)
2. No environment variable fallback
3. No shell completion generation
4. No mutual exclusion groups
5. No value validation (one-of, range)
