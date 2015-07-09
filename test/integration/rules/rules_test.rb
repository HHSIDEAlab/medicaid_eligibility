require 'test_helper'
Dir.glob(Rails.root + 'test/fixtures/rule_fixtures/*.rb').each do |fixture|
  require_relative fixture
end

class MagiRulesTest < ActionDispatch::IntegrationTest
  include ApplicationProcessor
  include ApplicationParser

  # dynamically load and transform names of everything in fixtures/rule_fixtures
  @all_fixtures = Dir.entries(Rails.root + 'test/fixtures/rule_fixtures').select { |file| file.to_s.length > 2 }.map do |file|
    file.gsub('.rb','').split('_').map { |x| /chip/i.match(x) ? x.upcase : x.capitalize }.join('')
  end

  @all_fixtures.each do |fixture| 
    # generate objects from all_fixtures 
    magi_fixture = eval "#{fixture}Fixture.new"

    # generate tests based on fixture.test_sets
    magi_fixture.test_sets.each do |set|
      test "#{magi_fixture.magi} - #{set[:test_name]}" do 
        # p "#{magi_fixture.magi} - #{set[:test_name]}" # debug line

        # should raise a MissingVariableError if it's missing an input
        if set[:test_name] =~ /Bad Info - Inputs/
          exception = assert_raises RuleContext::MissingVariableError do 
            context = RuleContext.new set[:configs], set[:inputs], Time.now.yesterday
            result = eval "MAGI::#{fixture}.new.run context"
          end
          assert_match /missing input variable/, exception.to_s

        # should also raise a MissingVariableError if it's missing a config variable
        elsif set[:test_name] =~ /Bad Info - Configs/
          exception = assert_raises RuleContext::MissingVariableError do 
            context = RuleContext.new set[:configs], set[:inputs], Time.now.yesterday
            result = eval "MAGI::#{fixture}.new.run context"
          end
          assert_match /missing config variable/, exception.to_s

        # should run clean
        else
          context = RuleContext.new set[:configs], set[:inputs], Time.now.yesterday
          result = eval "MAGI::#{fixture}.new.run context"

          set[:expected_outputs].each_key do |out|
            assert_equal set[:expected_outputs][out], result.output[out]
          end

          # skip this test for immigration since it has so many moving parts
          unless ["Immigration", "Income"].include? fixture 
            assert_equal set[:expected_outputs].count, result.output.keys.reject { |o| /Determination Date$/i.match o }.count
          end
        end
      end
    end
  end
end