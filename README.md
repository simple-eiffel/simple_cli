<p align="center">
  <img src="https://raw.githubusercontent.com/simple-eiffel/claude_eiffel_op_docs/main/artwork/LOGO.png" alt="simple_ library logo" width="400">
</p>

# simple_cli

**[Documentation](https://simple-eiffel.github.io/simple_cli/)** | **[GitHub](https://github.com/simple-eiffel/simple_cli)**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Eiffel](https://img.shields.io/badge/Eiffel-25.02-blue.svg)](https://www.eiffel.org/)
[![Design by Contract](https://img.shields.io/badge/DbC-enforced-orange.svg)]()

Command-line argument parsing for Eiffel applications.

Part of the [Simple Eiffel](https://github.com/simple-eiffel) ecosystem.

## Status

**Production**

## Overview

SIMPLE_CLI provides a fluent API for parsing command-line arguments. Supports flags, options with values, positional arguments, subcommands, and automatic help generation.

```eiffel
local
    cli: SIMPLE_CLI
do
    create cli.make
    cli.set_app_info ("myapp", "My Application", "1.0.0")
    cli.add_flag ("v|verbose", "Enable verbose output")
    cli.add_option ("o|output", "Output file", "FILE")
    cli.parse

    if cli.has_flag ("verbose") then
        print ("Verbose mode%N")
    end
end
```

## Features

- **Fluent API** - Chain configuration calls cleanly
- **Flags & Options** - Boolean flags, string options with defaults
- **Short & Long Names** - "v|verbose" gives -v and --verbose
- **Auto Help** - Generates formatted help from definitions
- **Subcommands** - Git-style command parsing
- **Typed Access** - Get values as strings, integers, or booleans

## Installation

1. Set environment variable (one-time setup for all simple_* libraries):
```bash
export SIMPLE_EIFFEL=D:\prod
```

2. Add to ECF:
```xml
<library name="simple_cli" location="$SIMPLE_EIFFEL/simple_cli/simple_cli.ecf"/>
```

## License

MIT License
