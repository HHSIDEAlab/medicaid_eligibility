require 'test_helper'

class ApplicationTest < ActionDispatch::IntegrationTest
	def setup
		@json = JSON.parse(File.read(Rails.root.to_s + '/test/fixtures/individual.json'))
	end

  test "the truth" do
    assert true
  end
end
