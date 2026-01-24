# S05 - Constraints: simple_cli

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23

---

## 1. Name Format Constraints

### Flag/Option Names

| Constraint | Format | Example |
|------------|--------|---------|
| Short only | Single character | "v" |
| Long only | Multiple characters | "verbose" |
| Short and long | "short\|long" | "v\|verbose" |

### Name Validation

| Rule | Description |
|------|-------------|
| Non-empty | Names cannot be empty |
| Case insensitive | Stored and matched as lowercase |
| No spaces | Implicit in string splitting |

### Reserved Names

| Name | Purpose |
|------|---------|
| h / help | Built-in help flag |
| V / version | Built-in version flag |

**Note:** -v (lowercase) is NOT reserved for version; can be used for verbose.

---

## 2. Argument Format Constraints

### Long Options

| Format | Example |
|--------|---------|
| --option=value | --output=file.txt |
| --option value | --output file.txt |
| --flag | --verbose |

### Short Options

| Format | Example |
|--------|---------|
| -f | -v (flag) |
| -ovalue | -ofile.txt |
| -o value | -o file.txt |
| -abc | -vxf (combined flags) |

---

## 3. State Constraints

### Parse State Machine

```
[Initial] --add_flag/add_option--> [Configuring]
[Configuring] --parse--> [Parsed]
[Parsed] --access queries--> [Parsed]
```

### State Requirements

| Operation | Required State |
|-----------|----------------|
| add_flag, add_option, set_app_info | Before parse |
| parse | Once only |
| has_flag, option_value, etc. | After parse |

### Postcondition Guarantee

```eiffel
parse
    ensure
        parsed: has_parsed
```

---

## 4. Value Type Constraints

### String Options

| Constraint | Handling |
|------------|----------|
| Any string | Accepted as-is |
| Empty string | Valid value |
| Quoted strings | Handled by shell before Eiffel |

### Integer Options

| Input | Result |
|-------|--------|
| Valid integer | Parsed value |
| Non-integer | 0 |
| Empty | 0 |

### Boolean Options

| Input | Result |
|-------|--------|
| "true", "yes", "1" | True |
| "false", "no", "0" | False |
| Other | False |

---

## 5. Default Value Constraints

| Constraint | Description |
|------------|-------------|
| Optional | Not required for options |
| Shown in help | Displayed as "(default: value)" |
| Applied on access | If option not set, default returned |
| Satisfies required | Default value satisfies required check |

---

## 6. Required Option Constraints

| Constraint | Description |
|------------|-------------|
| Must be provided | Error if missing |
| Shown in help | Displayed as "[required]" |
| Default overrides | If default set, not required |
| Validated in parse | Checked after all arguments processed |

---

## 7. Error Accumulation Constraints

| Constraint | Description |
|------------|-------------|
| Non-fatal | Parsing continues after error |
| Collected | All errors stored in errors_list |
| Accessible | Via errors query |
| Affects is_successful | is_successful = errors.is_empty |

---

## 8. Built-in Flag Behavior

### Help Flag (-h, --help)

| Behavior | Description |
|----------|-------------|
| Sets help_requested | True when used |
| Stops normal flow | is_successful = False |
| Can be disabled | disable_help_flag |

### Version Flag (-V, --version)

| Behavior | Description |
|----------|-------------|
| Sets version_requested | True when used |
| Stops normal flow | is_successful = False |
| Can be disabled | disable_version_flag |
| Note | Uppercase V, not lowercase |

---

## 9. Thread Safety

| Constraint | Value |
|------------|-------|
| Thread safety | Not thread-safe |
| Concurrent use | Not supported |
| Recommendation | Create per-thread instances |
