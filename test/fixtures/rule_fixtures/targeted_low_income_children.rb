##### GENERATED AT 2015-07-07 12:27:12 -0400 ######
class TargetedLowIncomeChildrenFixture < MagiFixture
	attr_accessor :magi, :test_sets

	def initialize
		super
		@magi = 'TargetedLowIncomeChildren'
		@test_sets = [
			{
				test_name: "CHIP Targeted Low Income - Not In LIC Group",
				inputs: {
					"Applicant Age" => 5,
					"Has Insurance" => "N"
				},
				configs: {
					"CHIP Targeted Low Income Child Group" => "N",
					"CHIP Targeted Low Income Child Age Low Threshold" => 10,
					"CHIP Targeted Low Income Child Age High Threshold" => 19
				},
				expected_outputs: {
					"Applicant CHIP Targeted Low Income Child Indicator" => "X",
					"CHIP Targeted Low Income Child Ineligibility Reason" => 555
				}
			},
			{
				test_name: "CHIP Targeted Low Income - Under Age Threshold",
				inputs: {
					"Applicant Age" => 5,
					"Has Insurance" => "N"
				},
				configs: {
					"CHIP Targeted Low Income Child Group" => "Y",
					"CHIP Targeted Low Income Child Age Low Threshold" => 10,
					"CHIP Targeted Low Income Child Age High Threshold" => 19
				},
				expected_outputs: {
					"Applicant CHIP Targeted Low Income Child Indicator" => "N",
					"CHIP Targeted Low Income Child Ineligibility Reason" => 127
				}
			},
			{
				test_name: "CHIP Targeted Low Income - Over Age Threshold",
				inputs: {
					"Applicant Age" => 50,
					"Has Insurance" => "N"
				},
				configs: {
					"CHIP Targeted Low Income Child Group" => "Y",
					"CHIP Targeted Low Income Child Age Low Threshold" => 10,
					"CHIP Targeted Low Income Child Age High Threshold" => 19
				},
				expected_outputs: {
					"Applicant CHIP Targeted Low Income Child Indicator" => "N",
					"CHIP Targeted Low Income Child Ineligibility Reason" => 127
				}
			},
			{
				test_name: "CHIP Targeted Low Income - Already Has Insurance",
				inputs: {
					"Applicant Age" => 12,
					"Has Insurance" => "Y"
				},
				configs: {
					"CHIP Targeted Low Income Child Group" => "Y",
					"CHIP Targeted Low Income Child Age Low Threshold" => 10,
					"CHIP Targeted Low Income Child Age High Threshold" => 19
				},
				expected_outputs: {
					"Applicant CHIP Targeted Low Income Child Indicator" => "N",
					"CHIP Targeted Low Income Child Ineligibility Reason" => 114
				}
			},
			{
				test_name: "CHIP Targeted Low Income - Fallback - Eligible",
				inputs: {
					"Applicant Age" => 12,
					"Has Insurance" => "N"
				},
				configs: {
					"CHIP Targeted Low Income Child Group" => "Y",
					"CHIP Targeted Low Income Child Age Low Threshold" => 10,
					"CHIP Targeted Low Income Child Age High Threshold" => 19
				},
				expected_outputs: {
					"Applicant CHIP Targeted Low Income Child Indicator" => "Y",
					"CHIP Targeted Low Income Child Ineligibility Reason" => 999
				}
			}
		]
	end
end
