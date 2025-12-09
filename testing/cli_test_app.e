note
	description: "Test application for SIMPLE_CLI"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	CLI_TEST_APP

inherit
	TEST_SET_BASE
		redefine
			on_prepare
		end

create
	make

feature {NONE} -- Initialization

	make
			-- Run the tests.
		do
			default_create
			print ("Running SIMPLE_CLI tests...%N%N")

			test_basic_flag
			test_basic_option
			test_short_and_long_names
			test_positional_arguments
			test_command_parsing
			test_help_generation
			test_default_values
			test_required_options
			test_builtin_help_version
			test_integer_options
			test_boolean_options

			print ("%N=== All tests passed ===%N")
		end

	on_prepare
			-- Prepare for tests.
		do
		end

feature -- Tests

	test_basic_flag
			-- Test basic flag parsing.
		local
			cli: SIMPLE_CLI
		do
			print ("test_basic_flag: ")

			create cli.make
			cli.add_flag ("verbose", "Enable verbose output")

			print ("OK%N")
		end

	test_basic_option
			-- Test basic option parsing.
		local
			cli: SIMPLE_CLI
		do
			print ("test_basic_option: ")

			create cli.make
			cli.add_option ("output", "Output file", "FILE")

			print ("OK%N")
		end

	test_short_and_long_names
			-- Test short and long name format.
		local
			cli: SIMPLE_CLI
		do
			print ("test_short_and_long_names: ")

			create cli.make
			cli.add_flag ("v|verbose", "Enable verbose output")
			cli.add_option ("o|output", "Output file", "FILE")

			print ("OK%N")
		end

	test_positional_arguments
			-- Test positional argument access.
		local
			cli: SIMPLE_CLI
		do
			print ("test_positional_arguments: ")

			create cli.make
			cli.parse

			assert_true ("empty args", cli.arguments.is_empty)
			assert_void ("no command", cli.command)

			print ("OK%N")
		end

	test_command_parsing
			-- Test command extraction.
		local
			cli: SIMPLE_CLI
		do
			print ("test_command_parsing: ")

			create cli.make
			cli.parse

			assert_true ("args after command empty", cli.arguments_after_command.is_empty)

			print ("OK%N")
		end

	test_help_generation
			-- Test help text generation.
		local
			cli: SIMPLE_CLI
			l_help: STRING
		do
			print ("test_help_generation: ")

			create cli.make
			cli.set_app_info ("test-app", "A test application", "1.0.0")
			cli.add_flag ("v|verbose", "Enable verbose output")
			cli.add_option ("o|output", "Output file", "FILE")

			l_help := cli.help_text

			assert_string_contains ("has app name", l_help, "test-app")
			assert_string_contains ("has version", l_help, "1.0.0")
			assert_string_contains ("has description", l_help, "test application")
			assert_string_contains ("has verbose flag", l_help, "verbose")
			assert_string_contains ("has output option", l_help, "output")
			assert_string_contains ("has builtin help", l_help, "--help")
			assert_string_contains ("has builtin version", l_help, "--version")

			print ("OK%N")
		end

	test_default_values
			-- Test option default values.
		local
			cli: SIMPLE_CLI
			l_help: STRING
		do
			print ("test_default_values: ")

			create cli.make
			cli.add_option_with_default ("p|port", "Server port", "PORT", "8080")
			cli.parse

			assert_true ("has default", cli.has_option ("port"))
			assert_attached ("default value", cli.option_value ("port"))
			if attached cli.option_value ("port") as v then
				assert_equal ("default value correct", "8080", v)
			end

			l_help := cli.help_text
			assert_string_contains ("help shows default", l_help, "default: 8080")

			print ("OK%N")
		end

	test_required_options
			-- Test required option validation.
		local
			cli: SIMPLE_CLI
		do
			print ("test_required_options: ")

			create cli.make
			cli.add_required_option ("c|config", "Config file", "FILE")
			cli.parse

			assert_true ("has error", cli.has_errors)
			assert_false ("not successful", cli.is_successful)
			assert_string_contains ("error mentions required", cli.errors.first, "Required")
			assert_string_contains ("help shows required", cli.help_text, "[required]")

			print ("OK%N")
		end

	test_builtin_help_version
			-- Test built-in help and version flags.
		local
			cli: SIMPLE_CLI
		do
			print ("test_builtin_help_version: ")

			create cli.make
			cli.set_app_info ("myapp", "My application", "2.0.0")

			assert_string_contains ("version text has name", cli.version_text, "myapp")
			assert_string_contains ("version text has version", cli.version_text, "2.0.0")

			cli.disable_help_flag
			cli.disable_version_flag
			assert_string_not_contains ("disabled flags not in help", cli.help_text, "--help")

			print ("OK%N")
		end

	test_integer_options
			-- Test integer option accessors.
		local
			cli: SIMPLE_CLI
		do
			print ("test_integer_options: ")

			create cli.make
			cli.add_option_with_default ("p|port", "Port number", "PORT", "8080")
			cli.parse

			assert_integers_equal ("integer value", 8080, cli.integer_option ("port"))
			assert_integers_equal ("integer default", 3000, cli.integer_option_or_default ("nonexistent", 3000))

			print ("OK%N")
		end

	test_boolean_options
			-- Test boolean option accessors.
		local
			cli: SIMPLE_CLI
		do
			print ("test_boolean_options: ")

			create cli.make
			cli.add_option_with_default ("debug", "Debug mode", "BOOL", "true")
			cli.add_option_with_default ("quiet", "Quiet mode", "BOOL", "false")
			cli.parse

			assert_true ("true value", cli.boolean_option ("debug"))
			assert_false ("false value", cli.boolean_option ("quiet"))

			print ("OK%N")
		end

note
	copyright: "Copyright (c) 2024-2025, Larry Rix"
	license: "MIT License"

end
