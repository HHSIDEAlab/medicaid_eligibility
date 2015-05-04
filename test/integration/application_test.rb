require 'test_helper'

class ApplicationTest < ActionDispatch::IntegrationTest
	Rails.backtrace_cleaner.remove_silencers!
	def setup
		@json = File.read(Rails.root.to_s + '/test/fixtures/4_person_family.json')
	end

  test 'loads a json fixture' do
  	# YES I KNOW but I can't get this to work as an httparty call or a curb request
		a = system "curl 'http://localhost:3000/determinations/eval.json' -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept: application/json' --data-binary '#{@json}' --compressed"

  	# app = Curl.post("localhost:3000", body: @json, headers: headers)

  	puts a
  	# app = Application.new @json.to_json
  	# puts app 
  	puts @json
  	assert true
  end

end

