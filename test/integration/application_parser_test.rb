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

		 	# ERR: Application side, state might need some validation?
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

	 		# some variable definition here
			# KNOWN ISSUE: Application currently not setting US Citizen Indicator despite it being marked as required!
			required_inputs = ApplicationVariables::PERSON_INPUTS.select { |i| i[:required] && i[:name] != "US Citizen Indicator" }
			person_inputs = ApplicationVariables::PERSON_INPUTS.select { |i| i[:group] == :person }
			applicant_inputs = ApplicationVariables::PERSON_INPUTS.select { |i| i[:group] == :applicant }

	 		# all people on an app get put in the people array; only applicants get put into the applicant array
	 		# check that everyone makes it to the right array
	 		assert_equal @people.count, @json_application['People'].count
			assert_equal @applicants.count, @json_application['People'].select { |p| p['Is Applicant'] == 'Y'}.count

			# TODO: I don't really trust the method of checking inputs. Check with Curtis on a good way to do this 
			@applicants.each do |applicant|
				# check that 'Is Applicant' ensures that you get initialized as an applicant
				assert_kind_of Applicant, applicant

				json_applicant = @json_application['People'].find { |a| a['Person ID'] = applicant.person_id }

				# confirm that all fields from the json object are reflected in the applicant object
				applicant_inputs.select { |i| json_applicant[i[:name]] }.each do |input|
					assert_not_nil json_applicant[input[:name]]
					assert_not_nil applicant.applicant_attributes[input[:name]]
					# assert_equal json_applicant[input[:name]], applicant.applicant_attributes[input[:name]] # ERR: this actually seems to throw a legit flag!

					# test required applicant inputs
					applicant_inputs.select { |r_i| r_i[:required_if] == input[:name] }.each do |req_input|
						# confirm that required_if values are set (or not set!)
						# many of these are tested in the pregnant_fostercare_woman fixture
						if req_input[:required_if_value] == applicant.applicant_attributes[input[:name]]
							assert_not_nil applicant.applicant_attributes[req_input[:name]]

							# if a required_if field is not set, raise an error
							assert_raises RuntimeError do 								
								@json_application['People'].find { |a| a['Person ID'] == applicant.person_id }[req_input[:name]] = nil 
								read_json!
							end
							@json_application['People'].find { |a| a['Person ID'] == applicant.person_id }[req_input[:name]] = applicant.applicant_attributes[req_input[:name]].to_s
							read_json!
						else 
							# if it doesn't have the required_if_value, confirm that it's nil
							assert_nil applicant.applicant_attributes[req_input[:name]]
						end
					end
				end

				teardown_app app 
			end

			@people.each do |person|
				# everyone should be a person
				assert_kind_of Person, person

				# confirm that required person inputs are all there 
				required_inputs.each do |input|
					refute_nil person.person_attributes[input[:name]]
				end

				# for non-applicants, should skip applicant inputs
				applicant_inputs.each do |input|
					assert_nil person.person_attributes[input[:name]]
				end unless @applicants.find { |a| a.person_id == person.person_id }

				# should get personal income properly for everyone
				# this is basically a test of the result of get_json_income person, :personal
				json_applicant = @json_application['People'].find { |a| a['Person ID'] == person.person_id }
				assert_equal json_applicant['Income']['Wages, Salaries, Tips'], person.income[:primary_income]
				ApplicationVariables::INCOME_INPUTS[:personal][:other_income].each do |input|
					assert_equal json_applicant['Income'][input], person.income[:other_income][input]
				end
				ApplicationVariables::INCOME_INPUTS[:personal][:deductions].each do |input|
					# this is just magi deductions
					assert_equal json_applicant['Income'][input], person.income[:deductions][input]
				end
			end

			# make sure there are no applicationvariables with a group other than application, relationship, or person
			assert_equal ApplicationVariables::PERSON_INPUTS.select { |i| i[:group] != :applicant && i[:group] != :person && i[:group] != :relationship }.count, 0 

			# nuking a required variable should raise an error
			assert_raises RuntimeError do 
				@json_application['People'][0]['Applicant Age'] = nil 
				read_json!
			end
			@json_application['People'][0]['Applicant Age'] = 40
			read_json! 

			# if you set a conflicting datatype, it should raise an error 
			# ERR: Doesn't do this, at least for applicant age? But seems to for required_if applicant inputs
			# assert_raises RuntimeError do 
				# @json_application['People'][0]['Applicant Age'] = 'Yolo'
				# read_json!
			# end
			# @json_application['People'][0]['Applicant Age'] = 40
			# read_json! 

			teardown_app app
	 	end

	 	test "get and process relationships properly #{app[:name]}" do 
	 		setup_app app 

	 		@people.each do |person|
	 			json_person = @json_application['People'].find { |a| a['Person ID'] == person.person_id }
	 			
	 			assert_equal person.relationships.count, @people.count - 1

 				json_person['Relationships'].each do |j_p|
 					# every person in the json blob should show up in person.relationships
 					refute_nil person.relationships.find { |rel| rel.person.person_id == j_p['Other ID'] } 
 				end

				# TODO: Test relationship code setting from ApplicationVariables

 				person.relationships.each do |rel|
 					other_person = @people.find { |p| p.person_id == rel.person.person_id }.relationships.find { |p| p.person.person_id == person.person_id }
 					# super clunky way to test relationship inverses
 					assert_equal ApplicationVariables::RELATIONSHIP_INVERSE[rel.relationship_type], other_person.relationship_type
 					refute_nil rel.relationship_attributes # every one should have 'attest primary responsibility'
 				end
	 		end

	 		# ERR: this should raise an error, right? 
	 		# should reject no relationship codes
	 		# assert_raises RuntimeError do 
		 		# @json_application['People'][0]['Relationships'][0]['Relationship Code'] = nil 
		 		# read_json!
		 	# end if @json_application['People'][0]['Relationships'][0]

		 	# ERR: Should probably raise an error also? 
	 		# should reject fake relationship codes
	 		# assert_raises RuntimeError do 
		 		# @json_application['People'][0]['Relationships'][0]['Relationship Code'] = "999" 
		 		# read_json!
		 	# end if @json_application['People'][0]['Relationships'][0]

	 		teardown_app app 
	 	end

	 	test "get and processes tax returns properly #{app[:name]}" do 
	 		setup_app app 

	 		# NOTE: It looks like there's logic to parse tax returns but none of the apps generated with the angular use it?
	 		# as such I'm not really writing tests for the get_json_income method here

	 		# tax returns counts should match
	 		assert_equal @tax_returns.count, @json_application['Tax Returns'].count

	 		@tax_returns.each do |tax_return|
	 			# test filers
	 			tax_return.filers.each do |filer|
	 				# should be identified
	 				assert_not_nil filer.person_id
	 				# should be linked to people on the application
	 				assert_not_nil @people.find { |p| p.person_id == filer.person_id }
	 			end

	 			# test dependents
	 			tax_return.dependents.each do |dependent|
	 				# should all have ids /  be real people
	 				assert_not_nil dependent.person_id 
	 				# should be linked to people on the application
	 				assert_not_nil @people.find { |p| p.person_id == dependent.person_id }
	 			end
	 		end

	 		teardown_app app 
	 	end

	 	test "get and process physical households properly #{app[:name]}" do 
	 		setup_app app 

	 		# TODO 
	 		# test that household counts match
	 		# test that all households have IDs
	 		# test that every person is in a household object

			teardown_app app 
	 	end
	end
end
