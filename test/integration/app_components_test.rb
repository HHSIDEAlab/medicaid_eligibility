require 'test_helper'

# mostly just object safety check testing of Applicant, Relationship, MedicaidHousehold, and TaxReturn

class AppComponentsTest < ActionDispatch::IntegrationTest
	include ApplicationComponents

	def setup
		# @billy = Applicant.new 1, "handsome", "Billy Everyteen", "Not Important", 40000
		# @johnny = Applicant.new 2, "tightlipped", "Johnny Tightlips", "Not Important", 40000
	end

	# @a = Request.new post_request(@@fixtures[1][:application])
	# @app = Application.new @a

	test 'applicants should be able to get relationships' do
		# assert @billy.respond_to? :get_relationships
		# assert @billy.respond_to? :get_relationship
	end
end
