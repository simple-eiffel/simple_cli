note
	description: "Test application for SIMPLE_CLI"
	author: "Larry Rix"

class
	TEST_APP

create
	make

feature {NONE} -- Initialization

	make
			-- Run the tests.
		do
			create tests
			print ("Running SIMPLE_CLI tests...%N%N")

			passed := 0
			failed := 0

			run_test (agent tests.test_basic_flag, "test_basic_flag")
			run_test (agent tests.test_basic_option, "test_basic_option")
			run_test (agent tests.test_short_and_long_names, "test_short_and_long_names")
			run_test (agent tests.test_positional_arguments, "test_positional_arguments")
			run_test (agent tests.test_command_parsing, "test_command_parsing")
			run_test (agent tests.test_help_generation, "test_help_generation")
			run_test (agent tests.test_default_values, "test_default_values")
			run_test (agent tests.test_required_options, "test_required_options")
			run_test (agent tests.test_builtin_help_version, "test_builtin_help_version")
			run_test (agent tests.test_integer_options, "test_integer_options")
			run_test (agent tests.test_boolean_options, "test_boolean_options")

			print ("%N========================%N")
			print ("Results: " + passed.out + " passed, " + failed.out + " failed%N")

			if failed > 0 then
				print ("TESTS FAILED%N")
			else
				print ("ALL TESTS PASSED%N")
			end
		end

feature {NONE} -- Implementation

	tests: LIB_TESTS

	passed: INTEGER
	failed: INTEGER

	run_test (a_test: PROCEDURE; a_name: STRING)
			-- Run a single test and update counters.
		local
			l_retried: BOOLEAN
		do
			if not l_retried then
				a_test.call (Void)
				print ("  PASS: " + a_name + "%N")
				passed := passed + 1
			end
		rescue
			print ("  FAIL: " + a_name + "%N")
			failed := failed + 1
			l_retried := True
			retry
		end

end
