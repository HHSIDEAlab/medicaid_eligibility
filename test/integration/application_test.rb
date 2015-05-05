require 'test_helper'

class ApplicationTest < ActionDispatch::IntegrationTest
	Rails.backtrace_cleaner.remove_silencers!

	# load every fixture into an array 
  @jsons = []
  @parsed_jsons = []
  @curls = []
  @parsed_curls = []
  Dir.glob(Rails.root.to_s + '/test/fixtures/*.json') do |file|
    puts 'loading ' + file
    @jsons << File.read(file).to_s
    @parsed_jsons << JSON.parse(File.read(file))
    curl = Curl::Easy.http_post('http://localhost:3000/determinations/eval.json', File.read(file)) do |c|
      c.headers['Content-Type'] = 'application/json;charset=UTF-8'
      c.headers['Accept'] = 'application/json'
    end
    @curls << curl.body_str
    @parsed_curls << JSON.parse(curl.body_str)
  end

	def setup
		@json = JSON.parse(File.read(Rails.root.to_s + '/test/fixtures/4_person_family.json'))
	end

  @curls.each do |curl|
    @i = @i + 1 || 1
    test "the response should contain major fields like determination date and applicants #{@i}" do
    	# determination date is present 
    	assert_match /Determination Date/, curl
    	# determination date is set to today
    	assert_match Time.now.strftime('%Y-%m-%d'), curl
      # has applicants in it
      assert_match /Applicants/, curl
    end
  end

  # @@curl_parsed.
  # test 'the response should contain the correct number of applicants' do 
  	# the return string has 'applicants'
  	# assert_match /Applicants/, @@curl
  	# there are an equal number of people on application and applicants with decision
  	# assert_equal @json['People'].count, @@curl_parsed['Applicants'].count
  # end

  # test 'the response should contain a yes or no determination for medicaid and CHIP' do
  	# @@curl_parsed['Applicants'].each do |applicant|
  		# check for yes-no on medicaid for each applicant
  		# assert ["Y","N"].include? applicant['Medicaid Eligible']
  		# check for yes-no on chip for each applicant
  		# assert ["Y","N"].include? applicant['CHIP Eligible']
  	# end
  # end
end
