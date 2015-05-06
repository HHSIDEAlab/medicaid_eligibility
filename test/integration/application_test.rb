require 'test_helper'

class ApplicationTest < ActionDispatch::IntegrationTest
	# load every fixture into an array and have the test suite loop thru them 
  @fixtures = []
  Dir.glob(Rails.root.to_s + '/test/fixtures/*.json') do |file|
    puts 'loading ' + file
    json = File.read(file).to_s
    parsed_json = JSON.parse(File.read(file))
    curl = Curl::Easy.http_post('http://localhost:3000/determinations/eval.json', File.read(file)) do |c|
      c.headers['Content-Type'] = 'application/json;charset=UTF-8'
      c.headers['Accept'] = 'application/json'
    end
    curl = curl.body_str
    parsed_curl = JSON.parse(curl)
    @fixtures << {name: file.gsub(/\.json/,'').gsub(/#{Rails.root.to_s}\/test\/fixtures\//,''), application: json, application_json: parsed_json, response: curl, response_json: parsed_curl}
  end

	def setup
	end

  @fixtures.each do |app|
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
