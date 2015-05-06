require 'test_helper'

class ApplicationTest < ActionDispatch::IntegrationTest
	def setup
	end

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
end
