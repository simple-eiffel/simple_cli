# S06 - Boundaries: simple_cli

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23

---

## 1. External Boundaries

### System Interface

```
Operating System
     | (command line)
     v
Shell (bash, cmd, PowerShell)
     | (parsed ARGV)
     v
Eiffel Runtime
     | (ARGUMENTS_32)
     v
SIMPLE_CLI
     |
     v
Application
```

### Inheritance Boundary

```
ISE Runtime
     |
     v
ARGUMENTS_32
     | (argument_count, argument(i))
     v
SIMPLE_CLI (extends)
```

---

## 2. API Boundary

### Public Interface

| Category | Features |
|----------|----------|
| Configuration | set_app_info, add_flag, add_option, add_option_with_default, add_required_option, disable_help_flag, disable_version_flag |
| Parsing | parse |
| Flag Access | has_flag |
| Option Access | option_value, option_value_or_default, has_option, integer_option, integer_option_or_default, boolean_option |
| Argument Access | command, arguments, arguments_after_command |
| Status | has_parsed, is_successful, help_requested, version_requested, errors, has_errors |
| Output | help_text, version_text, print_help, print_version, print_errors |

### Internal Features

| Feature | Visibility |
|---------|------------|
| add_option_internal | {NONE} |
| handle_long_argument | {NONE} |
| handle_short_argument | {NONE} |
| validate_required_options | {NONE} |
| short_for_long_flag | {NONE} |
| short_for_long_option | {NONE} |

---

## 3. Data Flow Boundaries

### Configuration Flow

```
Client Code
     |
     | add_flag("v|verbose", "Enable verbose output")
     v
+-------------------+
|   SIMPLE_CLI      |
|                   |
| flag_descriptions |
| flag_short_to_long|
+-------------------+
```

### Parse Flow

```
Command Line: myapp -v --output=file.txt input.txt

     |
     v (inherited from ARGUMENTS_32)
argument(1) = "-v"
argument(2) = "--output=file.txt"
argument(3) = "input.txt"
     |
     v (parse)
+-------------------+
| flag_values       | <- verbose = True
| option_values     | <- output = "file.txt"
| arguments_list    | <- ["input.txt"]
+-------------------+
```

### Access Flow

```
Client Code
     |
     | cli.has_flag("verbose")
     v
+-------------------+
| flag_values.has   |
| ("verbose")       |
+-------------------+
     |
     v
True/False
```

---

## 4. Error Boundaries

### Error Sources

| Source | Error Type |
|--------|------------|
| Unknown option | "Unknown option: --foo" |
| Missing value | "Option --bar requires a value" |
| Required missing | "Required option missing: --config" |

### Error Flow

```
parse()
     |
     v
errors_list.extend(error_message)
     |
     v
is_successful = False
     |
     v
Client checks is_successful
     |
     v
Client calls print_errors or accesses errors
```

---

## 5. Output Boundaries

### Help Output Structure

```
+------------------+
| App name + ver   |
+------------------+
| Description      |
+------------------+
| Usage line       |
+------------------+
| Options section  |
| - Built-in flags |
| - User flags     |
| - User options   |
+------------------+
```

### Version Output Structure

```
appname v1.0.0
```

---

## 6. Scope Boundaries

### In Scope

- Boolean flags (-v, --verbose)
- Value options (-o file, --output=file)
- Short/long name mapping
- Default values
- Required options
- Positional arguments
- Help text generation
- Version text generation
- Error collection
- Integer/boolean conversion

### Out of Scope

- Subcommand support
- Environment variable fallback
- Shell completion generation
- Mutual exclusion groups
- Value validation (one-of, range)
- File/directory validation
- Man page generation
- Configuration file integration
- Interactive prompts

### Future Extensions

| Feature | Potential Approach |
|---------|-------------------|
| Subcommands | SIMPLE_CLI_COMMAND class |
| Environment fallback | add_option_with_env |
| Value validation | add_option_with_validator |
| Mutual exclusion | option_group |
