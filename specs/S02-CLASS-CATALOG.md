# S02 - Class Catalog: simple_cli

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23

---

## 1. Class Hierarchy

```
ARGUMENTS_32 (ISE base)
     |
     v
SIMPLE_CLI (facade + implementation)
```

## 2. Class Description

### SIMPLE_CLI

| Attribute | Value |
|-----------|-------|
| Role | Complete CLI argument parser |
| Responsibility | Define, parse, and access command-line arguments |
| Creatable | Yes (via `make`) |
| Inherits | ARGUMENTS_32 |

**Key Responsibilities:**
- Define flags (boolean options)
- Define options (with values)
- Parse command-line arguments
- Provide typed access to values
- Generate help text
- Handle errors

## 3. Feature Groupings

### Configuration Features

| Feature | Purpose |
|---------|---------|
| set_app_info | Set application name, description, version |
| add_flag / define_flag / flag | Add boolean flag |
| add_option / define_option / option_def | Add value option |
| add_option_with_default | Add option with default value |
| add_required_option | Add mandatory option |
| disable_help_flag | Turn off -h/--help handling |
| disable_version_flag | Turn off -V/--version handling |

### Parsing Features

| Feature | Purpose |
|---------|---------|
| parse / run / process_args | Parse command-line arguments |

### Flag Access Features

| Feature | Purpose |
|---------|---------|
| has_flag / flag_set / is_flag / flag_exists | Check if flag is set |

### Option Access Features

| Feature | Purpose |
|---------|---------|
| option_value / get_option / value_of | Get string option value |
| option_value_or_default | Get value with fallback |
| has_option / option_set / option_exists | Check if option is set |
| integer_option | Get integer value |
| integer_option_or_default | Get integer with fallback |
| boolean_option | Get boolean value |

### Argument Access Features

| Feature | Purpose |
|---------|---------|
| command / subcommand / first_arg | Get first positional argument |
| arguments / args / positional_args | Get all positional arguments |
| arguments_after_command | Get arguments after first |

### Status Features

| Feature | Purpose |
|---------|---------|
| has_parsed | Check if parsing done |
| is_successful | Check if no errors |
| help_requested | Check if help flag used |
| version_requested | Check if version flag used |
| errors | Get error list |
| has_errors | Check for errors |

### Output Features

| Feature | Purpose |
|---------|---------|
| help_text / usage / help_message | Generate help text |
| version_text | Generate version text |
| print_help | Print help to stdout |
| print_version | Print version to stdout |
| print_errors | Print errors to stdout |

## 4. Internal Data Structures

| Attribute | Type | Purpose |
|-----------|------|---------|
| flag_descriptions | HASH_TABLE [STRING, STRING] | Flag help text |
| flag_short_to_long | HASH_TABLE [STRING, STRING] | Short to long name mapping |
| option_descriptions | HASH_TABLE [STRING, STRING] | Option help text |
| option_short_to_long | HASH_TABLE [STRING, STRING] | Short to long name mapping |
| option_arg_names | HASH_TABLE [STRING, STRING] | Argument placeholder names |
| option_defaults | HASH_TABLE [STRING, STRING] | Default values |
| required_options | HASH_TABLE [BOOLEAN, STRING] | Required flag |
| flag_values | HASH_TABLE [BOOLEAN, STRING] | Parsed flag values |
| option_values | HASH_TABLE [STRING, STRING] | Parsed option values |
| arguments_list | ARRAYED_LIST [STRING] | Positional arguments |
| errors_list | ARRAYED_LIST [STRING] | Parse errors |

## 5. Alias Patterns

The class provides multiple aliases for common operations to support different naming preferences:

| Primary | Aliases | Purpose |
|---------|---------|---------|
| add_flag | define_flag, flag | Define boolean flag |
| add_option | define_option, option_def | Define value option |
| parse | run, process_args, process_arguments | Parse arguments |
| has_flag | flag_set, is_flag, flag_exists | Check flag |
| option_value | get_option, value_of | Get option value |
| has_option | option_set, option_exists | Check option |
| command | subcommand, first_arg | First argument |
| arguments | args, positional_args | All arguments |
| help_text | usage, help_message | Help string |
