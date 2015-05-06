ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/reporters'
require 'minitest/spec'
Minitest::Reporters.use!
require 'curb' 
ActiveRecord::Base.logger.level = 1

class ActiveSupport::TestCase
	Rails.backtrace_cleaner.remove_silencers! # for messier errors

	# make fixtures available as a class variable so it's available in integration tests for looping thru
  @@fixtures = []
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
    @@fixtures << {name: file.gsub(/\.json/,'').gsub(/#{Rails.root.to_s}\/test\/fixtures\//,''), application: json, application_json: parsed_json, response: curl, response_json: parsed_curl}
  end
end

class Request
	attr_accessor :raw_post, :content_type, :query_parameters
	def initialize(curl)
		@raw_post = curl[:payload]
		@content_type = curl[:headers]['Content-Type'].split(';')[0]
		@query_parameters = {return_application: 'true'}
	end
end

def post_request(payload)
	curl = Curl::Easy.http_post('http://localhost:3000/determinations/eval.json', payload) do |c|
		c.headers['Content-Type'] = 'application/json;charset=UTF-8'
		c.headers['Accept'] = 'application/json'
	end
	return {payload: payload, headers: curl.headers, query_parameters: 'true'}
end
