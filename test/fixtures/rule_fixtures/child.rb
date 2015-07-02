class ChildFixture < MagiFixture 
	attr_accessor :magi, :test_sets, :output_codes

	def initialize 
		super 
		@magi = "Child"
		@output_codes = %w(999 115 394)
		@test_sets = [
			{
				test_name: "Child is Under 19 Years Old",
				inputs: {
					"Applicant Age" => 13
				}, 
				configs: {
					"Child Age Threshold" => 19,
					"Option Young Adults" => "Y",
					"Young Adult Age Threshold" => 19
				},
				expected_outputs: {
					"Applicant Child Category Indicator" => "Y",
					"#{@magi} Category Ineligibility Reason" => 999
				}
			}, 
			{
				test_name: "State does not cover young adults- Child is over 18",
				inputs: {
					"Applicant Age" => 30
				}, 
				configs: {
					"Child Age Threshold" => 19,
					"Option Young Adults" => "N",
					"Young Adult Age Threshold" => 19
				},
				expected_outputs: {
					"Applicant Child Category Indicator" => "N",
					"#{@magi} Category Ineligibility Reason" => 115
				}
			}, 		
			{
				test_name: "State covers young adults- Child is less than age limit for young adults",
				inputs: {
					"Applicant Age" => 20
				}, 
				configs: {
					"Child Age Threshold" => 19,
					"Option Young Adults" => "Y",
					"Young Adult Age Threshold" => 21
				},
				expected_outputs: {
					"Applicant Child Category Indicator" => "Y",
					"#{@magi} Category Ineligibility Reason" => 999
				}
			}, 
			{
				test_name: "State covers young adults- Child is older than age limit for young adults",
				inputs: {
					"Applicant Age" => 22
				}, 
				configs: {
					"Child Age Threshold" => 19,
					"Option Young Adults" => "Y",
					"Young Adult Age Threshold" => 21
				},
				expected_outputs: {
					"Applicant Child Category Indicator" => "N",
					"#{@magi} Category Ineligibility Reason" => 394
				}
			},
			{
				test_name: "Bad Info",
				inputs: {
					"People" => "Billy Everyteen"

					# "Applicant Age" => 22
				}, 
				configs: {
					"Child Age Threshold" => 19,
					"Option Young Adults" => "Y",
					"Young Adult Age Threshold" => 21
				},
				expected_outputs: {
					"Applicant Child Category Indicator" => "N",
					"#{@magi} Category Ineligibility Reason" => 394
				}
			},
		]
	end
end

