require 'test_helper'

class ApplicationTest < ActionDispatch::IntegrationTest
	Rails.backtrace_cleaner.remove_silencers!

	# load the json to beat on it; doing this on the class lvl because setup reruns before each test
	# result: two accessible class variables, one json and one a plain string
	@json = File.read(Rails.root.to_s + '/test/fixtures/4_person_family.json')
	curl = Curl::Easy.http_post('http://localhost:3000/determinations/eval.json', @json) do |c|
		c.headers['Content-Type'] = 'application/json;charset=UTF-8'
		c.headers['Accept'] = 'application/json'
	end
	@@curl = curl.body_str
	@@curl_parsed = JSON.parse(curl.body_str)

	def setup
		@json = JSON.parse(File.read(Rails.root.to_s + '/test/fixtures/4_person_family.json'))
	end

  test 'the response should contain the determination date' do
  	# determination date is present 
  	assert_match /Determination Date/, @@curl
  	# determination date is set to today
  	assert_match Time.now.strftime('%Y-%m-%d'), @@curl
  end

  test 'the response should contain the correct number of applicants' do 
  	# the return string has 'applicants'
  	assert_match /Applicants/, @@curl
  	# there are an equal number of people on application and applicants with decision
  	assert_equal @json['People'].count, @@curl_parsed['Applicants'].count
  end



end
