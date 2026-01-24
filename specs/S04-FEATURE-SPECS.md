# S04 - Feature Specifications: simple_cli

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23

---

## 1. Configuration Features

### set_app_info

| Attribute | Value |
|-----------|-------|
| Signature | `set_app_info (a_name, a_description, a_version: STRING)` |
| Purpose | Set application metadata for help output |
| Parameters | a_name: app name; a_description: one-line description; a_version: version string |
| Effect | Updates help and version text generation |

### add_flag

| Attribute | Value |
|-----------|-------|
| Signature | `add_flag (a_names, a_description: STRING)` |
| Purpose | Define a boolean flag |
| Parameters | a_names: "v\|verbose" format; a_description: help text |
| Algorithm | Parse short\|long format, store in flag_descriptions and flag_short_to_long |
| Example | `cli.add_flag ("v\|verbose", "Enable verbose output")` |

### add_option

| Attribute | Value |
|-----------|-------|
| Signature | `add_option (a_names, a_description, a_arg_name: STRING)` |
| Purpose | Define an option that takes a value |
| Parameters | a_names: "o\|output" format; a_description: help text; a_arg_name: placeholder (e.g., "FILE") |
| Example | `cli.add_option ("o\|output", "Output file", "FILE")` |

### add_option_with_default

| Attribute | Value |
|-----------|-------|
| Signature | `add_option_with_default (a_names, a_description, a_arg_name, a_default: STRING)` |
| Purpose | Define option with default value |
| Effect | Default shown in help, used if option not provided |
| Example | `cli.add_option_with_default ("p\|port", "Server port", "PORT", "8080")` |

### add_required_option

| Attribute | Value |
|-----------|-------|
| Signature | `add_required_option (a_names, a_description, a_arg_name: STRING)` |
| Purpose | Define mandatory option |
| Effect | Error if not provided, shown as [required] in help |
| Example | `cli.add_required_option ("c\|config", "Config file", "FILE")` |

---

## 2. Parsing Features

### parse

| Attribute | Value |
|-----------|-------|
| Signature | `parse` |
| Purpose | Parse command-line arguments |
| Algorithm | 1. Reset state; 2. Iterate arguments; 3. Handle -- prefixed as long; 4. Handle - prefixed as short; 5. Collect positional args; 6. Validate required options |
| State Changes | Sets has_parsed, help_requested, version_requested, is_successful |

### Argument Handling Algorithm

```
For each argument:
  if starts with "--":
    if contains "=":
      extract name=value
    else:
      treat next arg as value (for options)
    check built-in (--help, --version)
    check user flags/options
  elif starts with "-":
    for each character after "-":
      check built-in (-h, -V)
      check user flags
      if option, consume rest of arg or next arg as value
  else:
    add to positional arguments
```

---

## 3. Access Features

### option_value

| Attribute | Value |
|-----------|-------|
| Signature | `option_value (a_name: STRING): detachable STRING` |
| Purpose | Get option value |
| Algorithm | Check option_values, then option_defaults |
| Return | Value string or Void |

### integer_option

| Attribute | Value |
|-----------|-------|
| Signature | `integer_option (a_name: STRING): INTEGER` |
| Purpose | Get option as integer |
| Algorithm | Get option_value, check is_integer, convert |
| Return | Integer value or 0 |

### boolean_option

| Attribute | Value |
|-----------|-------|
| Signature | `boolean_option (a_name: STRING): BOOLEAN` |
| Purpose | Get option as boolean |
| Algorithm | Recognize "true", "yes", "1" as True |
| Return | Boolean value |

### command

| Attribute | Value |
|-----------|-------|
| Signature | `command: detachable STRING` |
| Purpose | Get first positional argument |
| Algorithm | Return arguments_list.first if not empty |
| Use Case | Subcommand-style CLIs |

---

## 4. Help Generation

### help_text

| Attribute | Value |
|-----------|-------|
| Signature | `help_text: STRING` |
| Purpose | Generate help message |
| Format | See below |

### Help Text Format

```
appname v1.0.0
Description text

Usage: appname [OPTIONS] [COMMAND] [ARGS...]

Options:
  -h, --help         Show this help message
  -V, --version      Show version information
  -v, --verbose      Enable verbose output
  -o, --output=FILE  Output file (default: out.txt)
  -c, --config=FILE  Config file [required]
```

---

## 5. Error Handling

### Error Cases

| Case | Error Message |
|------|---------------|
| Unknown option | "Unknown option: --foo" |
| Missing value | "Option --output requires a value" |
| Required missing | "Required option missing: --config" |

### Error Flow

```
parse()
  |
  v
Collect errors in errors_list
  |
  v
is_successful = errors_list.is_empty and not help_requested and not version_requested
  |
  v
Client checks is_successful or has_errors
  |
  v
print_errors if needed
```
