##### GENERATED AT 2015-07-06 18:13:59 -0400 ######
class OptionalTargetedLowIncomeChildrenFixture < MagiFixture
	attr_accessor :magi, :test_sets

	def initialize
		super
		@magi = 'OptionalTargetedLowIncomeChildren'
		@test_sets = [
			{
				test_name: "Low Income Child Eligibility - No group",
				inputs: {
					"Applicant Age" => 18,
					"Has Insurance" => "N"
				},
				configs: {
					"Optional Targeted Low Income Child Group" => "N",
					"Optional Targeted Low Income Child Age Low Threshold" => 10,
					"Optional Targeted Low Income Child Age High Threshold" => 19
				},
				expected_outputs: {
					"Applicant Optional Targeted Low Income Child Indicator" => "X",
					"Optional Targeted Low Income Child Ineligibility Reason" => 555
				}
			},
			{
				test_name: "Low Income Child Eligibility - Yes group - Applicant Has Insurance",
				inputs: {
					"Applicant Age" => 18,
					"Has Insurance" => "Y"
				},
				configs: {
					"Optional Targeted Low Income Child Group" => "Y",
					"Optional Targeted Low Income Child Age Low Threshold" => 10,
					"Optional Targeted Low Income Child Age High Threshold" => 19
				},
				expected_outputs: {
					"Applicant Optional Targeted Low Income Child Indicator" => "N",
					"Optional Targeted Low Income Child Ineligibility Reason" => 114
				}
			},
			{
				test_name: "Low Income Child Eligibility - Yes group - Applicant Doesn't Have Insurance",
				inputs: {
					"Applicant Age" => 18,
					"Has Insurance" => "N"
				},
				configs: {
					"Optional Targeted Low Income Child Group" => "Y",
					"Optional Targeted Low Income Child Age Low Threshold" => 10,
					"Optional Targeted Low Income Child Age High Threshold" => 19
				},
				expected_outputs: {
					"Applicant Optional Targeted Low Income Child Indicator" => "Y",
					"Optional Targeted Low Income Child Ineligibility Reason" => 999
				}
			},
			{
				test_name: "Bad Info - Inputs",
				inputs: {
					"Has Insurance" => "N"
				},
				configs: {
					"Optional Targeted Low Income Child Group" => "Y",
					"Optional Targeted Low Income Child Age Low Threshold" => 10,
					"Optional Targeted Low Income Child Age High Threshold" => 19
				},
				expected_outputs: {
				}
			},
			{
				test_name: "Bad Info - Configs",
				inputs: {
					"Applicant Age" => 18,
					"Has Insurance" => "N"
				},
				configs: {
					"Optional Targeted Low Income Child Age High Threshold" => 19
				},
				expected_outputs: {
				}
			}
		]

		[{ name: "below", age: 9 }, { name: "above", age: 40 }].each do |app|
			@test_sets << {
				test_name: "Low Income Child Eligibility - Yes group - Applicant Age #{app[:name]} Thresholds",
				inputs: {
					"Applicant Age" => app[:age],
					"Has Insurance" => "N"
				},
				configs: {
					"Optional Targeted Low Income Child Group" => "Y",
					"Optional Targeted Low Income Child Age Low Threshold" => 10,
					"Optional Targeted Low Income Child Age High Threshold" => 19
				},
				expected_outputs: {
					"Applicant Optional Targeted Low Income Child Indicator" => "N",
					"Optional Targeted Low Income Child Ineligibility Reason" => 127
				}
			}
		end
	end
end
