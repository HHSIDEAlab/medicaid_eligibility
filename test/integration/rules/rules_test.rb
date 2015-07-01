require 'test_helper'

class MagiRulesTest < ActionDispatch::IntegrationTest
	include ApplicationProcessor
	include ApplicationParser

	# test 'adult_group' do 
	@json = JSON.parse(File.read(Rails.root + 'test/fixtures/rule_fixtures/test_fixture.json'))

	@json['Test Sets'].each do |fixture|
		test "#{@json['Magi']} - #{fixture["Test Name"]}" do 
			if fixture['Test Name'] =~ /Bad Info/
				assert_raises RuleContext::MissingVariableError do 
					# should throw an error when trying to run the inputs through the rule
					@state = fixture['State']
					read_configs!
					context = RuleContext.new @config, fixture['Inputs'], Time.now.yesterday

					@result = MAGI::AdultGroup.new.run context
				end
			else
				# set configs
				@state = fixture['State']
				read_configs!

				context = RuleContext.new @config, fixture['Inputs'], Time.now.yesterday

				# do it via applicant object instead of just raw json
				# @applicant = Applicant.new 'Fixture', fixture['Inputs'], 'Fixture', fixture['Inputs'], 10
				# context = RuleContext.new @config, @applicant.applicant_attributes, Time.now.yesterday # also works with this 

				@result = MAGI::AdultGroup.new.run context

				fixture['Expected Outputs'].each_key do |out|
					assert_equal @result.output[out], fixture['Expected Outputs'][out]
				end
			end
		end
	end
end
