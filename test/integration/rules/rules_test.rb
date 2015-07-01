require 'test_helper'

# The sole purpose of this test is to confirm that the test suite is running properly

class MagiRulesTest < ActionDispatch::IntegrationTest
	include ApplicationProcessor
	include ApplicationParser

	test 'adult_group' do 
		@json = JSON.parse(File.read(Rails.root + 'test/fixtures/rule_fixtures/test_fixture.json')).to_hash

		# set configs
		@state = @json["State"]
		read_configs!

		context = RuleContext.new @config, @json['Inputs'], Time.now.yesterday

		# do it via applicant object instead of just raw json
		# @applicant = Applicant.new 'Fixture', @json['Inputs'], 'Fixture', @json['Inputs'], 10
		# context = RuleContext.new @config, @applicant.applicant_attributes, Time.now.yesterday # also works with this 

		@result = MAGI::AdultGroup.new.run context

		@json['Expected Outputs'].each_key do |out|
			assert_equal @result.output[out], @json['Expected Outputs'][out]
		end

		# assert_equal @result.output['Thing'], @json['Expected Outputs']['Thing']

		# p @result.output

	end
end
