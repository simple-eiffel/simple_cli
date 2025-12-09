note
	description: "Simple CLI argument parsing library"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_CLI

inherit
	ARGUMENTS_32

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize CLI parser.
		do
			create flag_descriptions.make (10)
			create flag_short_to_long.make (10)
			create option_descriptions.make (10)
			create option_short_to_long.make (10)
			create option_arg_names.make (10)
			create option_defaults.make (10)
			create required_options.make (10)
			create flag_values.make (10)
			create option_values.make (10)
			create arguments_list.make (10)
			create errors_list.make (5)
			create all_flag_names.make (20)
			create all_option_names.make (20)
			app_name := "app"
			app_description := ""
			app_version := "1.0.0"
			enable_help_flag := True
			enable_version_flag := True
		end

feature -- Configuration

	set_app_info (a_name, a_description, a_version: STRING)
			-- Set application info for help output.
		require
			name_not_empty: not a_name.is_empty
		do
			app_name := a_name
			app_description := a_description
			app_version := a_version
		ensure
			name_set: app_name = a_name
			description_set: app_description = a_description
			version_set: app_version = a_version
		end

	add_flag (a_names, a_description: STRING)
			-- Add a boolean flag.
			-- `a_names' can be "v|verbose" for short and long forms.
		require
			names_not_empty: not a_names.is_empty
		local
			l_parts: LIST [STRING]
			l_short, l_long: STRING
		do
			l_parts := a_names.split ('|')
			if l_parts.count >= 2 then
				l_short := l_parts.first
				l_long := l_parts.i_th (2)
				flag_short_to_long.force (l_long.as_lower, l_short.as_lower)
			else
				l_long := a_names
			end
			flag_descriptions.force (a_description, l_long.as_lower)
			all_flag_names.extend (l_long.as_lower)
		end

	add_option (a_names, a_description, a_arg_name: STRING)
			-- Add an option with a value.
			-- `a_names' can be "o|output" for short and long forms.
		require
			names_not_empty: not a_names.is_empty
		do
			add_option_internal (a_names, a_description, a_arg_name, Void, False)
		end

	add_option_with_default (a_names, a_description, a_arg_name, a_default: STRING)
			-- Add an option with a default value.
		require
			names_not_empty: not a_names.is_empty
		do
			add_option_internal (a_names, a_description, a_arg_name, a_default, False)
		end

	add_required_option (a_names, a_description, a_arg_name: STRING)
			-- Add a required option (must be provided).
		require
			names_not_empty: not a_names.is_empty
		do
			add_option_internal (a_names, a_description, a_arg_name, Void, True)
		end

	disable_help_flag
			-- Disable built-in -h/--help handling.
		do
			enable_help_flag := False
		end

	disable_version_flag
			-- Disable built-in -V/--version handling.
		do
			enable_version_flag := False
		end

feature -- Parsing

	parse
			-- Parse command-line arguments.
			-- Sets `help_requested' or `version_requested' if those flags are used.
		local
			i: INTEGER
			l_arg: STRING_32
		do
			has_parsed := True
			help_requested := False
			version_requested := False
			arguments_list.wipe_out
			errors_list.wipe_out
			flag_values.wipe_out
			option_values.wipe_out

			from
				i := 1
			until
				i > argument_count
			loop
				l_arg := argument (i)

				if l_arg.starts_with ("--") then
					i := handle_long_argument (l_arg, i)
				elseif l_arg.starts_with ("-") and l_arg.count > 1 then
					i := handle_short_argument (l_arg, i)
				else
					arguments_list.extend (l_arg.to_string_8)
				end

				i := i + 1
			end

			-- Validate required options
			validate_required_options

			is_successful := errors_list.is_empty and not help_requested and not version_requested
		ensure
			parsed: has_parsed
		end

feature -- Access: Flags

	has_flag (a_name: STRING): BOOLEAN
			-- Is the flag `a_name' set?
		require
			parsed: has_parsed
		do
			Result := flag_values.has (a_name.as_lower)
		end

feature -- Access: String Options

	option_value (a_name: STRING): detachable STRING
			-- Get value for option `a_name' (or default if set).
		require
			parsed: has_parsed
		local
			l_lower: STRING
		do
			l_lower := a_name.as_lower
			if option_values.has (l_lower) then
				Result := option_values.item (l_lower)
			elseif option_defaults.has (l_lower) then
				Result := option_defaults.item (l_lower)
			end
		end

	option_value_or_default (a_name, a_default: STRING): STRING
			-- Get value for option `a_name', or `a_default' if not found.
		require
			parsed: has_parsed
		do
			if attached option_value (a_name) as l_val then
				Result := l_val
			else
				Result := a_default
			end
		end

	has_option (a_name: STRING): BOOLEAN
			-- Is the option `a_name' set (or has default)?
		require
			parsed: has_parsed
		local
			l_lower: STRING
		do
			l_lower := a_name.as_lower
			Result := option_values.has (l_lower) or option_defaults.has (l_lower)
		end

feature -- Access: Integer Options

	integer_option (a_name: STRING): INTEGER
			-- Get integer value for option `a_name' (0 if not found or not integer).
		require
			parsed: has_parsed
		do
			if attached option_value (a_name) as l_val and then l_val.is_integer then
				Result := l_val.to_integer
			end
		end

	integer_option_or_default (a_name: STRING; a_default: INTEGER): INTEGER
			-- Get integer value for option `a_name', or `a_default'.
		require
			parsed: has_parsed
		do
			if attached option_value (a_name) as l_val and then l_val.is_integer then
				Result := l_val.to_integer
			else
				Result := a_default
			end
		end

feature -- Access: Boolean Options

	boolean_option (a_name: STRING): BOOLEAN
			-- Get boolean value for option `a_name'.
			-- Recognizes: "true", "false", "yes", "no", "1", "0"
		require
			parsed: has_parsed
		local
			l_val: STRING
		do
			if attached option_value (a_name) as v then
				l_val := v.as_lower
				Result := l_val.is_equal ("true") or l_val.is_equal ("yes") or l_val.is_equal ("1")
			end
		end

feature -- Access: Arguments

	command: detachable STRING
			-- First positional argument (the command).
		require
			parsed: has_parsed
		do
			if not arguments_list.is_empty then
				Result := arguments_list.first
			end
		end

	arguments: LIST [STRING]
			-- All positional arguments.
		require
			parsed: has_parsed
		do
			Result := arguments_list
		end

	arguments_after_command: LIST [STRING]
			-- Arguments after the command.
		require
			parsed: has_parsed
		local
			l_result: ARRAYED_LIST [STRING]
			i: INTEGER
		do
			create l_result.make (arguments_list.count)
			from
				i := 2
			until
				i > arguments_list.count
			loop
				l_result.extend (arguments_list.i_th (i))
				i := i + 1
			end
			Result := l_result
		end

feature -- Status

	has_parsed: BOOLEAN
			-- Has `parse' been called?

	is_successful: BOOLEAN
			-- Did parsing succeed without errors?

	help_requested: BOOLEAN
			-- Was -h or --help specified?

	version_requested: BOOLEAN
			-- Was -V or --version specified?

	errors: LIST [STRING]
			-- List of parsing errors.
		do
			Result := errors_list
		end

	has_errors: BOOLEAN
			-- Are there any errors?
		do
			Result := not errors_list.is_empty
		end

feature -- Help

	help_text: STRING
			-- Generate help text.
		local
			l_name, l_default: STRING
			i: INTEGER
		do
			create Result.make (500)
			Result.append (app_name)
			if not app_version.is_empty then
				Result.append (" v")
				Result.append (app_version)
			end
			Result.append ("%N")

			if not app_description.is_empty then
				Result.append (app_description)
				Result.append ("%N")
			end

			Result.append ("%NUsage: ")
			Result.append (app_name)
			Result.append (" [OPTIONS] [COMMAND] [ARGS...]%N")

			Result.append ("%NOptions:%N")

			-- Built-in flags
			if enable_help_flag then
				Result.append ("  -h, --help%TShow this help message%N")
			end
			if enable_version_flag then
				Result.append ("  -V, --version%TShow version information%N")
			end

			-- User flags
			from
				i := 1
			until
				i > all_flag_names.count
			loop
				l_name := all_flag_names.i_th (i)
				Result.append ("  ")
				if attached short_for_long_flag (l_name) as l_short then
					Result.append ("-")
					Result.append (l_short)
					Result.append (", ")
				else
					Result.append ("    ")
				end
				Result.append ("--")
				Result.append (l_name)
				if attached flag_descriptions.item (l_name) as l_flag_desc then
					Result.append ("%T")
					Result.append (l_flag_desc)
				end
				Result.append ("%N")
				i := i + 1
			end

			-- User options
			from
				i := 1
			until
				i > all_option_names.count
			loop
				l_name := all_option_names.i_th (i)
				Result.append ("  ")
				if attached short_for_long_option (l_name) as l_short then
					Result.append ("-")
					Result.append (l_short)
					Result.append (", ")
				else
					Result.append ("    ")
				end
				Result.append ("--")
				Result.append (l_name)
				Result.append ("=")
				if attached option_arg_names.item (l_name) as l_arg then
					Result.append (l_arg)
				else
					Result.append ("VALUE")
				end
				if attached option_descriptions.item (l_name) as l_opt_desc then
					Result.append ("%T")
					Result.append (l_opt_desc)
				end
				-- Show default value
				if option_defaults.has (l_name) then
					if attached option_defaults.item (l_name) as def then
						l_default := def
						Result.append (" (default: ")
						Result.append (l_default)
						Result.append (")")
					end
				end
				-- Show required marker
				if required_options.has (l_name) then
					Result.append (" [required]")
				end
				Result.append ("%N")
				i := i + 1
			end
		end

	version_text: STRING
			-- Generate version text.
		do
			create Result.make (50)
			Result.append (app_name)
			Result.append (" v")
			Result.append (app_version)
			Result.append ("%N")
		end

	print_help
			-- Print help text to stdout.
		do
			print (help_text)
		end

	print_version
			-- Print version text to stdout.
		do
			print (version_text)
		end

	print_errors
			-- Print errors to stdout.
		local
			i: INTEGER
		do
			from
				i := 1
			until
				i > errors_list.count
			loop
				print ("Error: " + errors_list.i_th (i) + "%N")
				i := i + 1
			end
		end

feature {NONE} -- Implementation

	app_name: STRING
	app_description: STRING
	app_version: STRING
	enable_help_flag: BOOLEAN
	enable_version_flag: BOOLEAN

	flag_descriptions: HASH_TABLE [STRING, STRING]
	flag_short_to_long: HASH_TABLE [STRING, STRING]
	option_descriptions: HASH_TABLE [STRING, STRING]
	option_short_to_long: HASH_TABLE [STRING, STRING]
	option_arg_names: HASH_TABLE [STRING, STRING]
	option_defaults: HASH_TABLE [STRING, STRING]
	required_options: HASH_TABLE [BOOLEAN, STRING]

	all_flag_names: ARRAYED_LIST [STRING]
	all_option_names: ARRAYED_LIST [STRING]

	flag_values: HASH_TABLE [BOOLEAN, STRING]
	option_values: HASH_TABLE [STRING, STRING]
	arguments_list: ARRAYED_LIST [STRING]
	errors_list: ARRAYED_LIST [STRING]

	add_option_internal (a_names, a_description, a_arg_name: STRING; a_default: detachable STRING; a_required: BOOLEAN)
			-- Internal: add option with all parameters.
		local
			l_parts: LIST [STRING]
			l_short, l_long: STRING
		do
			l_parts := a_names.split ('|')
			if l_parts.count >= 2 then
				l_short := l_parts.first
				l_long := l_parts.i_th (2)
				option_short_to_long.force (l_long.as_lower, l_short.as_lower)
			else
				l_long := a_names
			end
			l_long := l_long.as_lower
			option_descriptions.force (a_description, l_long)
			option_arg_names.force (a_arg_name, l_long)
			all_option_names.extend (l_long)
			if attached a_default as def then
				option_defaults.force (def, l_long)
			end
			if a_required then
				required_options.force (True, l_long)
			end
		end

	handle_long_argument (a_arg: STRING_32; a_index: INTEGER): INTEGER
			-- Handle --option or --flag argument.
		local
			l_name, l_value: STRING
			l_eq_pos: INTEGER
		do
			Result := a_index
			l_eq_pos := a_arg.index_of ('=', 1)
			if l_eq_pos > 0 then
				l_name := a_arg.substring (3, l_eq_pos - 1).to_string_8.as_lower
				l_value := a_arg.substring (l_eq_pos + 1, a_arg.count).to_string_8
				if option_descriptions.has (l_name) then
					option_values.force (l_value, l_name)
				else
					errors_list.extend ("Unknown option: --" + l_name)
				end
			else
				l_name := a_arg.substring (3, a_arg.count).to_string_8.as_lower
				-- Check built-in flags
				if enable_help_flag and l_name.is_equal ("help") then
					help_requested := True
				elseif enable_version_flag and l_name.is_equal ("version") then
					version_requested := True
				elseif flag_descriptions.has (l_name) then
					flag_values.force (True, l_name)
				elseif option_descriptions.has (l_name) then
					if a_index < argument_count then
						l_value := argument (a_index + 1).to_string_8
						option_values.force (l_value, l_name)
						Result := a_index + 1
					else
						errors_list.extend ("Option --" + l_name + " requires a value")
					end
				else
					errors_list.extend ("Unknown option: --" + l_name)
				end
			end
		end

	handle_short_argument (a_arg: STRING_32; a_index: INTEGER): INTEGER
			-- Handle -v or -ofile argument.
		local
			l_char: CHARACTER_32
			l_short: STRING
			l_value: STRING
			i: INTEGER
		do
			Result := a_index
			from
				i := 2
			until
				i > a_arg.count
			loop
				l_char := a_arg.item (i)
				l_short := l_char.out.as_lower

				-- Check built-in flags
				if enable_help_flag and l_short.is_equal ("h") then
					help_requested := True
				elseif enable_version_flag and l_short.is_equal ("v") and l_short.same_string (l_char.out) then
					-- Only -V (uppercase) for version, not -v
					if l_char = 'V' then
						version_requested := True
					else
						-- Check if it's a user-defined flag
						if attached flag_short_to_long.item (l_short) as l_flag_long then
							flag_values.force (True, l_flag_long)
						elseif attached option_short_to_long.item (l_short) as l_opt_long then
							if i < a_arg.count then
								l_value := a_arg.substring (i + 1, a_arg.count).to_string_8
								option_values.force (l_value, l_opt_long)
								i := a_arg.count
							elseif a_index < argument_count then
								l_value := argument (a_index + 1).to_string_8
								option_values.force (l_value, l_opt_long)
								Result := a_index + 1
							else
								errors_list.extend ("Option -" + l_short + " requires a value")
							end
						else
							errors_list.extend ("Unknown option: -" + l_short)
						end
					end
				elseif attached flag_short_to_long.item (l_short) as l_flag_long then
					flag_values.force (True, l_flag_long)
				elseif attached option_short_to_long.item (l_short) as l_opt_long then
					if i < a_arg.count then
						l_value := a_arg.substring (i + 1, a_arg.count).to_string_8
						option_values.force (l_value, l_opt_long)
						i := a_arg.count
					elseif a_index < argument_count then
						l_value := argument (a_index + 1).to_string_8
						option_values.force (l_value, l_opt_long)
						Result := a_index + 1
					else
						errors_list.extend ("Option -" + l_short + " requires a value")
					end
				else
					errors_list.extend ("Unknown option: -" + l_short)
				end
				i := i + 1
			end
		end

	validate_required_options
			-- Check that all required options have values.
		do
			from
				required_options.start
			until
				required_options.after
			loop
				if not option_values.has (required_options.key_for_iteration) then
					if not option_defaults.has (required_options.key_for_iteration) then
						errors_list.extend ("Required option missing: --" + required_options.key_for_iteration)
					end
				end
				required_options.forth
			end
		end

	short_for_long_flag (a_long: STRING): detachable STRING
			-- Get short name for long flag name, if any.
		do
			from
				flag_short_to_long.start
			until
				flag_short_to_long.after or Result /= Void
			loop
				if attached flag_short_to_long.item_for_iteration as l_val and then l_val.is_case_insensitive_equal (a_long) then
					Result := flag_short_to_long.key_for_iteration
				end
				flag_short_to_long.forth
			end
		end

	short_for_long_option (a_long: STRING): detachable STRING
			-- Get short name for long option name, if any.
		do
			from
				option_short_to_long.start
			until
				option_short_to_long.after or Result /= Void
			loop
				if attached option_short_to_long.item_for_iteration as l_val and then l_val.is_case_insensitive_equal (a_long) then
					Result := option_short_to_long.key_for_iteration
				end
				option_short_to_long.forth
			end
		end

note
	copyright: "Copyright (c) 2024-2025, Larry Rix"
	license: "MIT License"

end
