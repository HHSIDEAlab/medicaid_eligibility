require 'test_helper'
require_relative Rails.root + 'test/fixtures/rule_fixtures/adult_group.rb'

class MagiRulesTest < ActionDispatch::IntegrationTest
	include ApplicationProcessor
	include ApplicationParser

	@fixture = AdultGroupFixture.new

	@fixture.test_sets.each do |set|
		test "#{@fixture.magi} - #{set[:test_name]}" do 
			if set[:test_name] =~ /Bad Info/
				assert_raises RuleContext::MissingVariableError do 
					context = RuleContext.new set[:configs], set[:inputs], Time.now.yesterday
					@result = MAGI::AdultGroup.new.run context

					set[:expected_outputs].each_key do |out|
						assert_equal @result.output[out], set[:expected_outputs][out]
					end
				end
			else
				context = RuleContext.new set[:configs], set[:inputs], Time.now.yesterday
				@result = MAGI::AdultGroup.new.run context

				set[:expected_outputs].each_key do |out|
					assert_equal @result.output[out], set[:expected_outputs][out]
				end
			end
		end
	end
end
