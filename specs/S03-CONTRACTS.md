# S03 - Contracts: simple_cli

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23

---

## 1. SIMPLE_CLI Contracts

### Configuration Contracts

```eiffel
set_app_info (a_name, a_description, a_version: STRING)
    require
        name_not_empty: not a_name.is_empty
    ensure
        name_set: app_name = a_name
        description_set: app_description = a_description
        version_set: app_version = a_version

add_flag (a_names, a_description: STRING)
    require
        names_not_empty: not a_names.is_empty

add_option (a_names, a_description, a_arg_name: STRING)
    require
        names_not_empty: not a_names.is_empty

add_option_with_default (a_names, a_description, a_arg_name, a_default: STRING)
    require
        names_not_empty: not a_names.is_empty

add_required_option (a_names, a_description, a_arg_name: STRING)
    require
        names_not_empty: not a_names.is_empty
```

### Parsing Contracts

```eiffel
parse
    ensure
        parsed: has_parsed
```

### Access Contracts

```eiffel
has_flag (a_name: STRING): BOOLEAN
    require
        parsed: has_parsed

option_value (a_name: STRING): detachable STRING
    require
        parsed: has_parsed

option_value_or_default (a_name, a_default: STRING): STRING
    require
        parsed: has_parsed

has_option (a_name: STRING): BOOLEAN
    require
        parsed: has_parsed

integer_option (a_name: STRING): INTEGER
    require
        parsed: has_parsed

integer_option_or_default (a_name: STRING; a_default: INTEGER): INTEGER
    require
        parsed: has_parsed

boolean_option (a_name: STRING): BOOLEAN
    require
        parsed: has_parsed

command: detachable STRING
    require
        parsed: has_parsed

arguments: LIST [STRING]
    require
        parsed: has_parsed

arguments_after_command: LIST [STRING]
    require
        parsed: has_parsed
```

---

## 2. Contract Summary

| Category | Preconditions | Postconditions |
|----------|---------------|----------------|
| Configuration | 5 | 3 |
| Parsing | 0 | 1 |
| Access | 11 | 0 |
| **Total** | **16** | **4** |

---

## 3. Key Contract Patterns

### Parse-Before-Access Pattern

All access features require `parsed: has_parsed`. This ensures:
- Configuration is complete before parsing
- Parsing happens exactly once before value access
- Clear error if client forgets to parse

### Non-Empty Names Pattern

All add_* features require `names_not_empty: not a_names.is_empty`. This ensures:
- No empty flag/option names
- Meaningful identifiers for all options

---

## 4. Implicit Contracts (Behavioral)

### Flag Name Format

```
"v|verbose"  -- short|long format
"verbose"    -- long only format
```

### Option Value Access

```eiffel
-- Returns Void if option not set and no default
option_value (a_name): detachable STRING

-- Returns a_default if option not set
option_value_or_default (a_name, a_default): STRING
```

### Error Accumulation

```eiffel
-- Errors are accumulated during parse
errors: LIST [STRING]

-- is_successful = errors.is_empty and not help_requested and not version_requested
```
