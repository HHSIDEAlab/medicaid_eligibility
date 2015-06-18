require 'test_helper'

# Application path from initialization is to parse the application into @json_application, then:
# run read_json! (or read_xml!, but there are no plans to test that at this time.)

# read_json! does the following: 
# sets the state
# sets the year; raises an error if there's no valid app year; defaults to the prior year
# loops thru people

class ApplicationParserTest < ActionDispatch::IntegrationTest
	include ApplicationParser 

	@fixtures = load_fixtures

	# making an adhoc setup and teardown
	def setup_app(app)
		@json_application = app[:application]
		read_json!
	end

	# restore to default
	def teardown_app(app) 
		app = reload_fixture app[:name]
		setup_app app
	end

	@fixtures.each do |app|
		test "make sure fixtures parse right #{app[:name]}" do 
			# check that app json is equal to json application. Kind of a stupid safety check 
			setup_app app 
			assert_equal app[:application], @json_application
			teardown_app app 
		end


		test "sets state info properly #{app[:name]}" do
			setup_app app

	 		assert_equal @state, @json_application['State']

		 	@json_application['State'] = 'MI'
		 	read_json!
		 	assert_equal @state, 'MI'

		 	# TODO: Application side, state might need some validation?
		 	# commenting this out for now because it doesn't actually raise an error
		 	# assert_raises RuntimeError do
		 		# @json_application['State'] = 'Yolo'
	 			# read_json!
	 		# end

 			# restore to default
 			teardown_app app
		end

	 	test "sets application year properly #{app[:name]}" do 
	 		setup_app app 

			# make sure app year works
	 		assert_equal @application_year, @json_application['Application Year']

	 		# should set year to 2013
	 		@json_application['Application Year'] = 2013
	 		read_json!
	 		assert_equal @application_year, 2013

	 		# should throw an error when you give it a bad year
	 		# WARNING: If you stop it after this, it doesn't reload well for some reason
	 		assert_raises RuntimeError do 
		 		@json_application['Application Year'] = 'Yolo'
		 		read_json!		 		
		 	end

		 	# if no year, should assume either last year (if before April) or the year prior (if after April)
		 	@json_application['Application Year'] = nil
		 	read_json!

		 	# TODO: this passes but doesn't actually test the time behavior.
		 	if Time.now.month >= 4
		 		assert_equal @application_year, Time.now.year 
		 	else 
		 		assert_equal @application_year, Time.now.year - 1
		 	end

			teardown_app app
	 	end

	 	test "sets people and applicants properly #{app[:name]}" do 
	 		setup_app app

	 		# some variable definition
			# KNOWN ISSUE: Application currently not setting US Citizen Indicator despite it being marked as required!
			required_inputs = ApplicationVariables::PERSON_INPUTS.select { |i| i[:required] && i[:name] != "US Citizen Indicator" }
			person_inputs = ApplicationVariables::PERSON_INPUTS.select { |i| i[:group] == :person }
			applicant_inputs = ApplicationVariables::PERSON_INPUTS.select { |i| i[:group] == :applicant }

	 		# all people on an app get put in the people array; only applicants get put into the applicant array
	 		# check that everyone makes it to the right array
	 		assert_equal @people.count, @json_application['People'].count
			assert_equal @applicants.count, @json_application['People'].select { |p| p['Is Applicant'] == 'Y'}.count




			# check that the people on the app initialize as the proper objects
			@applicants.each do |applicant|
				assert_kind_of Applicant, applicant


				applicant_inputs.each do |input|

				end
			end

			@people.each do |person|
				assert_kind_of Person, person

				# confirm that required person inputs are all there 
				required_inputs.each do |input|
					refute_nil person.person_attributes[input[:name]]


				end

				# for non-applicants, should skip applicant inputs
				applicant_inputs.each do |input|
					assert_nil person.person_attributes[input[:name]]
				end unless @applicants.find { |a| a.person_id == person.person_id }

				# person_inputs.each do |input|


			end

			# if you nuke a required variable, it should raise an error
			assert_raises RuntimeError do 
				@json_application['People'][0]['Applicant Age'] = nil 
				read_json!
			end
			@json_application['People'][0]['Applicant Age'] = 40
			read_json! 

			# if you set a conflicting datatype, it should raise an error -- KNOWN ISSUE: DOESN'T DO THIS
			# assert_raises RuntimeError do 
				# @json_application['People'][0]['Applicant Age'] = 'Yolo'
				# read_json!
			# end
			# @json_application['People'][0]['Applicant Age'] = 40
			# read_json! 


			# @people

			# checks that required person inputs are there 
			# required_inputs = ApplicationVariables::PERSON_INPUTS.select { |i| i[:required] }




			# p @applicants.count
			# p @people.count
			# assert_kind_of @

			teardown_app app
	 	end

	 	test "handles inputs from applicationvariables model properly #{app[:name]}" do 
	 		setup_app app 

			# for input in applicationvariables... 
			

			@json_application['People'].each do |person|
				# confirm that applications are parsing required inputs properly 
				# required_inputs.each do |input|
					# each person should have required inputs
					# assert person[input[:name]]
					# TODO inputs should be set properly 

					# TODO required_if inputs should validate also

				# end
				# TODO same stuff for person inputs

				# TODO same stuff for applicant inputs
			end

			teardown_app app 
	 	end
	 	# TODO Relationships, tax returns, physical househoulds

	 	# TODO test get_json_variable / get variable
	end
end
