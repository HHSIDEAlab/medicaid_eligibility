require 'test_helper'

class ApplicationTest < ActionDispatch::IntegrationTest
	Rails.backtrace_cleaner.remove_silencers!
	def setup
		@json = File.read(Rails.root.to_s + '/test/fixtures/4_person_family.json')
	end

  test 'performs a call and gets a response' do
  	# YES I KNOW but I can't get this to work as an httparty call
		curl = Curl::Easy.http_post('http://localhost:3000/determinations/eval.json', @json) do |c|
			c.headers['Content-Type'] = 'application/json;charset=UTF-8'
			c.headers['Accept'] = 'application/json'
		end
		
  	# 
  	assert_match /Determination Date/, curl.body_str

  end

end
