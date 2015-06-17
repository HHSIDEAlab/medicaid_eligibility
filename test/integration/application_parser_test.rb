require 'test_helper'

# Application path from initialization is to parse the application into @json_application, then:
# run read_json! (or read_xml!, but there are no plans to test that at this time.)

# read_json! does the following: 
# sets the state
# sets the year; raises an error if there's no valid app year; defaults to the prior year
# loops thru people

class ApplicationParserTest < ActionDispatch::IntegrationTest
	include ApplicationParser 

	@@fixtures.each do |app|
		# doing this to access app in setup -- probably a better way to do this
		@@app = app

		def setup
			@json_application = @@app[:application]
			read_json!
		end

		test "sets state info properly #{app[:name]}" do
			read_json!
			initial_value = @state

		 	assert_equal @state, @json_application['State']

		 	@json_application['State'] = 'MI'
		 	read_json!
		 	assert_equal @state, 'MI'

		 	# TODO: Application side, state might need some validation?
		 	# assert_raises RuntimeError do
		 		# @json_application['State'] = 'Yolo'
	 			# read_json!
	 		# end
		end

	 	test "sets application year properly #{app[:name]}" do 
	 		read_json!
	 		initial_value = @application_year

			# make sure app year works
	 		assert_equal @application_year, @json_application['Application Year']

	 		# should set year to 2013
	 		@json_application['Application Year'] = 2013
	 		read_json!
	 		assert_equal @application_year, 2013

	 		# should throw an error when you give it a bad year -- there 
	 		assert_raises RuntimeError do 
		 		@json_application['Application Year'] = 'Yolo'
		 		read_json!		 		
		 	end

	 		# Reload_fixture refuses to work here so I'm just hard-setting. Let this be a lesson to me about not using class variables
			@json_application['Application Year'] = initial_value 
	 	end

	 	test "handles inputs from applicationvariables model properly #{app[:name]}" do 
	 		read_json!
			# for input in applicationvariables... 
			person_inputs = ApplicationVariables::PERSON_INPUTS
			required_inputs = ApplicationVariables::PERSON_INPUTS.select { |i| i[:required] }
			person_inputs = ApplicationVariables::PERSON_INPUTS.select { |i| i[:group] == :person }
			applicant_inputs = ApplicationVariables::PERSON_INPUTS.select { |i| i[:group] == :applicant }

			@json_application['People'].each do |person|
				# confirm that applications are parsing required inputs properly 
				required_inputs.each do |input|
					# each person should have required inputs
					assert person[input[:name]]
					# TODO inputs should be set properly 

					# TODO required_if inputs should validate also

				end
				# TODO same stuff for person inputs

				# TODO same stuff for applicant inputs
			end
	 	end

	 	test "sets people and applicants properly #{app[:name]}" do 
	 		read_json!
	 		# all people on an app get put in the people array; only applicants get put into the applicant array
	 		# check that everyone makes it to the right array
	 		assert_equal @people.count, @json_application['People'].count
			assert_equal @applicants.count, @json_application['People'].select { |p| p['Is Applicant'] == 'Y'}.count

			# TODO: creates proper object based on applicant status
	 	end

	 	# TODO Relationships, tax returns, physical househoulds

	 	# TODO test get_json_variable / get variable
	end
end
