# simple_cli

Easy command-line argument parsing for Eiffel applications.

## Features

- Simple, fluent API for defining CLI options
- Support for flags (boolean switches) and options with values
- Short and long name formats (`-v`, `--verbose`)
- Automatic help text generation
- Command-based parsing (git-style subcommands)

## Installation

Add to your ECF file:

```xml
<library name="simple_cli" location="$SIMPLE_CLI\simple_cli.ecf"/>
```

## Quick Start

```eiffel
create cli.make
cli.set_app_info ("myapp", "My Application", "1.0.0")
cli.add_flag ("v|verbose", "Enable verbose output")
cli.add_option ("o|output", "Output file", "FILE")
cli.parse

if cli.has_flag ("verbose") then
    print ("Verbose mode enabled%N")
end

if attached cli.option_value ("output") as l_file then
    print ("Output: " + l_file + "%N")
end
```

## Documentation

See [docs/index.html](docs/index.html) for full API documentation.

## License

MIT License - see LICENSE file for details.
