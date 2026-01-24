# S07 - Specification Summary: simple_cli

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23

---

## 1. Library Overview

**simple_cli** is a command-line argument parsing library for Eiffel, providing a fluent API for defining and accessing flags, options, and positional arguments.

### Key Capabilities

| Capability | Description |
|------------|-------------|
| Flags | Boolean options (-v, --verbose) |
| Options | Value options (-o file, --output=file) |
| Defaults | Default values for options |
| Required | Mandatory options with validation |
| Short/Long | Support for both short and long forms |
| Help Generation | Automatic help text |
| Version | Built-in version flag |
| Error Handling | Collected errors with messages |

---

## 2. Architecture Summary

### Component Count

| Component | Count |
|-----------|-------|
| Classes | 1 |
| Public Features | 35+ |
| Preconditions | 16 |
| Postconditions | 4 |

### Design Pattern

| Pattern | Application |
|---------|-------------|
| Fluent API | Method chaining for configuration |
| Builder | Build up option definitions before parse |
| Facade | Single class handles all functionality |

---

## 3. API Quick Reference

### Basic Usage

```eiffel
cli: SIMPLE_CLI
create cli.make

-- Configure
cli.set_app_info ("myapp", "My application", "1.0.0")
cli.add_flag ("v|verbose", "Enable verbose output")
cli.add_option ("o|output", "Output file", "FILE")
cli.add_option_with_default ("p|port", "Server port", "PORT", "8080")

-- Parse
cli.parse

-- Handle results
if cli.help_requested then
    cli.print_help
elseif cli.version_requested then
    cli.print_version
elseif cli.is_successful then
    if cli.has_flag ("verbose") then
        -- verbose mode
    end
    if attached cli.option_value ("output") as out then
        -- use output file
    end
    port := cli.integer_option_or_default ("port", 8080)
else
    cli.print_errors
end
```

### Help Output Example

```
myapp v1.0.0
My application

Usage: myapp [OPTIONS] [COMMAND] [ARGS...]

Options:
  -h, --help           Show this help message
  -V, --version        Show version information
  -v, --verbose        Enable verbose output
  -o, --output=FILE    Output file
  -p, --port=PORT      Server port (default: 8080)
```

---

## 4. Constraint Summary

### Name Format

| Format | Example | Description |
|--------|---------|-------------|
| Short | "v" | Single character |
| Long | "verbose" | Multiple characters |
| Both | "v\|verbose" | Short and long |

### Value Types

| Type | Access Method | Default |
|------|---------------|---------|
| String | option_value | Void |
| Integer | integer_option | 0 |
| Boolean | boolean_option | False |

---

## 5. Dependencies

### Required

| Dependency | Purpose |
|------------|---------|
| ISE base library | Core Eiffel classes |
| ISE argument_parser | ARGUMENTS_32 base class |

---

## 6. Platform Support

| Platform | Status |
|----------|--------|
| Windows | Supported |
| Linux | Supported |
| macOS | Supported |

**Note:** Pure Eiffel, cross-platform.

---

## 7. Performance Characteristics

| Operation | Complexity |
|-----------|------------|
| add_flag/option | O(1) |
| parse | O(n) where n = argument count |
| has_flag | O(1) hash lookup |
| option_value | O(1) hash lookup |

---

## 8. Completeness Assessment

### Implemented Features

- [x] Boolean flags
- [x] Value options
- [x] Short and long names
- [x] Default values
- [x] Required options
- [x] Help text generation
- [x] Version text generation
- [x] Error collection
- [x] Integer conversion
- [x] Boolean conversion
- [x] Positional arguments
- [x] First argument as command

### Not Implemented (Future)

- [ ] Subcommand support
- [ ] Environment variable fallback
- [ ] Shell completion generation
- [ ] Mutual exclusion groups
- [ ] Value validation (one-of, range)
- [ ] File/directory validation
- [ ] Man page generation

---

## 9. Usage Recommendations

### Best Practices

1. **Call parse exactly once** after all configuration
2. **Check is_successful** before accessing values
3. **Handle help_requested and version_requested** first
4. **Use option_value_or_default** for optional values
5. **Use integer_option_or_default** for typed access

### Common Pitfalls

| Pitfall | Solution |
|---------|----------|
| Access before parse | Check has_parsed or always parse first |
| Forgetting error check | Always check is_successful |
| Case sensitivity | Names are case-insensitive |
| -v for version | Use -V (uppercase) for version |
