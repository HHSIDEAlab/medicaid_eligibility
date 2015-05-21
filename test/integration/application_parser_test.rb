require 'test_helper'

# Application path from initialization is to parse the application into @json_application, then:
# run read_json! (or read_xml!, but there are no plans to test that at this time.)

# read_json! does the following: 
# sets the state
# sets the year; raises an error if there's no valid app year; defaults to the prior year
# loops thru people

class ApplicationParserTest < ActionDispatch::IntegrationTest
	include ApplicationParser 

	def setup
		@json_application = @@fixtures[0][:application]
		read_json!
	end

	test 'check' do 
	end

	test 'sets state info properly' do
	 	assert_equal @state, @json_application['State']

	 	@json_application['State'] = 'MI'
	 	read_json!
	 	assert_equal @state, 'MI'

	 	# TODO: Application side, state might need some validation?
 		# @json_application['State'] = 'Yolo'
 		# read_json!
 		# assert_match /Invalid application year/, @error.to_s
	end

 	test 'sets application year properly' do 
 		assert_equal @application_year, @json_application['Application Year']

 		# should set year to 2013
 		@json_application['Application Year'] = '2013'
 		read_json!
 		assert_equal @application_year, '2013'
 		
 		# should throw an error when you give it a bad year
 		@json_application['Application Year'] = 'Yolo'
 		read_json!
 		assert_match /Invalid application year/, @error.to_s
 		ApplicationParserTest.reload_fixtures
 	end


 	test 'sets people and applicants properly' do 
 		# p @people.count
 		# p @applicants.count

 		# because of the runtime error 
 		assert_equal @applicants.count, @json_application['People'].count
 		# p @people.count
 		# p @applicants.count
 		# p @error.to_s
 	end

end
