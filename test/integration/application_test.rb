require 'test_helper'

class ApplicationTest < ActionDispatch::IntegrationTest
	def setup
	end

  # for each fixture, check this stuff
  @@fixtures.each do |app|
    test "the response should contain major fields like determination date and applicants #{app[:name]}" do
    	# determination date is set to today
      assert_equal Time.now.strftime('%Y-%m-%d'), app[:response]["Determination Date"]
    end

    test "the response should contain the correct number of applicants #{app[:name]}" do 
      # there are an equal number of applicants on application and applicants with decision
      assert_equal app[:application]['People'].select{|p| p["Is Applicant"] == 'Y'}.count, app[:response]['Applicants'].count
    end

    test "the response should contain a yes or no determination for medicaid and CHIP #{app[:name]}" do
      app[:response]['Applicants'].each do |applicant|
    		# check for yes-no on medicaid for each applicant
        assert %w(Y N).include? applicant['Medicaid Eligible']
    		# check for yes-no on chip for each applicant
        assert %w(Y N).include? applicant['CHIP Eligible']
      end
    end
  end

  # just for a single -- no need to run for all possible, and it slows 
  test 'an application should initialize properly from the POST' do 
    new_app = Application.new(@@fixtures[0][:application_raw], 'application/json')
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
    new_app = Application.new('yolo goat', 'application/json')
    refute_nil new_app.error
    assert_match /yolo goat/, new_app.error.to_s
    assert_kind_of JSON::ParserError, new_app.error

    # TODO: test that it's properly going to read_json or read_xml
  end
end
