require 'test_helper'

class ApplicationTest < ActionDispatch::IntegrationTest
	def setup
	end

  # for each fixture, check this stuff
  @@fixtures.each do |app|
    test "the response should contain major fields like determination date and applicants #{app[:name]}" do
    	# determination date is present 
    	assert_match /Determination Date/, app[:response]
    	# determination date is set to today
    	assert_match Time.now.strftime('%Y-%m-%d'), app[:response]
    end

    test "the response should contain the correct number of applicants #{app[:name]}" do 
    	# the return string has 'applicants'
    	assert_match /Applicants/, app[:response]
    	# there are an equal number of people on application and applicants with decision
    	assert_equal app[:application_json]['People'].count, app[:response_json]['Applicants'].count
    end

    test "the response should contain a yes or no determination for medicaid and CHIP #{app[:name]}" do
      app[:response_json]['Applicants'].each do |applicant|
    		# check for yes-no on medicaid for each applicant
    		assert ["Y","N"].include? applicant['Medicaid Eligible']
    		# check for yes-no on chip for each applicant
    		assert ["Y","N"].include? applicant['CHIP Eligible']
      end
    end
  end

  # just for a single -- no need to run for all possible, and it slows 
  test 'an application should initialize properly from the POST' do 
    new_app = Application.new(Request.new(post_request(@@fixtures[0][:application])))
    # app is an Application object
    assert_kind_of Application, new_app
    # app should be able to read errors, json!, read configs!, compute values!, and process rules!
    assert new_app.respond_to? :error
    assert new_app.respond_to? :read_json!
    assert new_app.respond_to? :read_configs!
    assert new_app.respond_to? :compute_values!
    assert new_app.respond_to? :process_rules!
    # app errors should be empty on a valid app submit
    assert_nil new_app.error
  end

  test 'an application should reject malformed data' do 
    # try with bad json / post body
    new_app = Application.new(Request.new(post_request('yolo goat')))
    refute_nil new_app.error
    assert_match /yolo goat/, new_app.error.to_s
    assert_kind_of JSON::ParserError, new_app.error

    # TODO: test that it's properly going to read_json or read_xml
  end


end
