##### GENERATED AT 2015-07-07 11:18:20 -0400 ######
class PreliminaryCHIPFixture < MagiFixture
	attr_accessor :magi, :test_sets

	def initialize
		super
		@magi = 'PreliminaryCHIP'
		@test_sets = [
			{
				test_name: "Prelim CHIP - CHIP Eligible No Insurance",
				inputs: {
					"Medicaid Residency Indicator" => "Y",
					"Applicant CHIP Citizen Or Immigrant Indicator" => "Y",
					"Applicant Income CHIP Eligible Indicator" => "Y",
					"Has Insurance" => "N"
				},
				configs: {
					# none
				},
				expected_outputs: {
					"Applicant CHIP Prelim Indicator" => "Y",
					"CHIP Prelim Ineligibility Reason" => 999
				}
			},
			{
				test_name: "Prelim CHIP - Not Prelim Eligible Scenario 1",
				inputs: {
					"Medicaid Residency Indicator" => "N",
					"Applicant CHIP Citizen Or Immigrant Indicator" => "N",
					"Applicant Income CHIP Eligible Indicator" => "Y",
					"Has Insurance" => "N"
				},
				configs: {
					# none
				},
				expected_outputs: {
					"Applicant CHIP Prelim Indicator" => "N",
					"CHIP Prelim Ineligibility Reason" => 107
				}
			},
			{
				test_name: "Prelim CHIP - Not Prelim Eligible Scenario 2",
				inputs: {
					"Medicaid Residency Indicator" => "Y",
					"Applicant CHIP Citizen Or Immigrant Indicator" => "Y",
					"Applicant Income CHIP Eligible Indicator" => "N",
					"Has Insurance" => "N"
				},
				configs: {
					# none
				},
				expected_outputs: {
					"Applicant CHIP Prelim Indicator" => "N",
					"CHIP Prelim Ineligibility Reason" => 107
				}
			},
			{
				test_name: "Prelim CHIP - Not Prelim Eligible Scenario 3",
				inputs: {
					"Medicaid Residency Indicator" => "Y",
					"Applicant CHIP Citizen Or Immigrant Indicator" => "Y",
					"Applicant Income CHIP Eligible Indicator" => "Y",
					"Has Insurance" => "Y"
				},
				configs: {
					# none
				},
				expected_outputs: {
					"Applicant CHIP Prelim Indicator" => "N",
					"CHIP Prelim Ineligibility Reason" => 107
				}
			}
		]
	end
end
