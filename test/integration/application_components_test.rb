require 'test_helper'
include ApplicationComponents

class ApplicationComponentsTest < ActionDispatch::IntegrationTest
	def setup
		app = @@fixtures[0][:application]
	end

	# basic object tests to make sure everything initializes properly 
	test 'person initializes properly' do 
		# person = Person.new app['People'][0]
		
		# person = Person.new 
	end



end
