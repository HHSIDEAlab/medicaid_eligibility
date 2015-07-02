##### NOT CONFIRMED ######
class CHIPEligibilityFixture < MagiFixture
	attr_accessor :magi, :test_sets

	def initialize
		super
		@magi = 'CHIP Eligibility'
		@test_sets = [
			{
				test_name: "Determine final CHIP Eligibility Incarcerated",
				inputs: {
					"Incarceration Status" => "Y",
					"Applicant CHIP Prelim Indicator" => "Y",
					"Applicant Unborn Child Indicator" => "Y",
					"Applicant State Health Benefits CHIP Indicator" => "N",
					"Applicant CHIP Waiting Period Satisfied Indicator" => "N",
					"Applicant CHIP Targeted Low Income Child Indicator" => "N"
				},
				configs: {
					# none
				},
				expected_outputs: {
					"Applicant CHIP Indicator" => "N",
					"CHIP Ineligibility Reason" => 405,
					"APTC Referral Indicator" => nil
				}
			},
			{
				test_name: "Determine final CHIP Eligibility CHIP Prelim",
				inputs: {
					"Incarceration Status" => "N",
					"Applicant CHIP Prelim Indicator" => "Y",
					"Applicant Unborn Child Indicator" => "N",
					"Applicant State Health Benefits CHIP Indicator" => "Y",
					"Applicant CHIP Waiting Period Satisfied Indicator" => "X",
					"Applicant CHIP Targeted Low Income Child Indicator" => "N" 
				},
				configs: {
					# none
				},
				expected_outputs: {
					"Applicant CHIP Indicator" => "Y",
					"CHIP Ineligibility Reason" => 999,
					"APTC Referral Indicator" => nil
				}
			},
			{
				test_name: "Determine final CHIP Eligibility Unborn Child Indicator",
				inputs: {
					"Incarceration Status" => "N",
					"Applicant CHIP Prelim Indicator" => "N",
					"Applicant Unborn Child Indicator" => "Y",
					"Applicant State Health Benefits CHIP Indicator" => "N",
					"Applicant CHIP Waiting Period Satisfied Indicator" => "X",
					"Applicant CHIP Targeted Low Income Child Indicator" => "N" 
				},
				configs: {
					# none
				},
				expected_outputs: {
					"Applicant CHIP Indicator" => "Y",
					"CHIP Ineligibility Reason" => 999,
					"APTC Referral Indicator" => nil
				}
			}, 
			{
				test_name: "Fallback Determination - All N",
				inputs: {
					"Incarceration Status" => "N",
					"Applicant CHIP Prelim Indicator" => "N",
					"Applicant Unborn Child Indicator" => "N",
					"Applicant State Health Benefits CHIP Indicator" => "N",
					"Applicant CHIP Waiting Period Satisfied Indicator" => "N",
					"Applicant CHIP Targeted Low Income Child Indicator" => "N" 
				},
				configs: {
					# none
				},
				expected_outputs: {
					"Applicant CHIP Indicator" => "N",
					"CHIP Ineligibility Reason" => 107,
					"APTC Referral Indicator" => "Y"
				}
			},
			{
				test_name: "Fallback Determination - Not All Applicant Indicators",
				inputs: {
					"Incarceration Status" => "N",
					"Applicant CHIP Prelim Indicator" => "Y",
					"Applicant Unborn Child Indicator" => "N",
					"Applicant State Health Benefits CHIP Indicator" => "N",
					"Applicant CHIP Waiting Period Satisfied Indicator" => "N",
					"Applicant CHIP Targeted Low Income Child Indicator" => "N" 
				},
				configs: {
					# none
				},
				expected_outputs: {
					"Applicant CHIP Indicator" => "N",
					"CHIP Ineligibility Reason" => 107,
					"APTC Referral Indicator" => "Y"
				}
			},
			{
				test_name: "Bad Info - Inputs",
				inputs: {
					# "Incarceration Status" => "N",
					# "Applicant CHIP Prelim Indicator" => "Y",
					# "Applicant Unborn Child Indicator" => "N",
					# "Applicant State Health Benefits CHIP Indicator" => "N",
					# "Applicant CHIP Waiting Period Satisfied Indicator" => "N",
					"Applicant CHIP Targeted Low Income Child Indicator" => "N" 
				},
				configs: {
					# none
				},
				expected_outputs: {
					"Applicant CHIP Indicator" => "N",
					"CHIP Ineligibility Reason" => 107,
					"APTC Referral Indicator" => "Y"
				}
			}
		]
	end
end
