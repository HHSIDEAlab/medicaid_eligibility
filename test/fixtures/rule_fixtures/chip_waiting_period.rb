##### NOT CONFIRMED ######
class CHIPWaitingPeriodFixture < MagiFixture
	attr_accessor :magi, :test_sets

	def initialize
		super
		@magi = 'CHIPWaitingPeriod'
		@test_sets = [
			{
				test_name: "Determine CHIP Waiting Period - Waiting Period Satisfied",
				inputs: { 
					"Applicant CHIP Prelim Indicator" => "Y",
					"Prior Insurance" => "Y",
					"Prior Insurance End Date" => 2.months.ago
				},
				configs: {
					"State CHIP Waiting Period" => 1
					# should calculate a state chip wedding period end date of: 1 month ago
				},
				expected_outputs: {
					"Applicant CHIP Waiting Period Satisfied Indicator" => "Y",
					"CHIP Waiting Period Satisfied Ineligibility Reason" => 999
				}
			},
			{
				test_name: "Determine CHIP Waiting Period - Waiting Period Not Satisfied - Prior Insurance End Date",
				inputs: { 
					"Applicant CHIP Prelim Indicator" => "Y",
					"Prior Insurance" => "Y",
					"Prior Insurance End Date" => 2.months.ago
				},
				configs: {
					"State CHIP Waiting Period" => 5
					# should calculate a state chip wedding period end date of: 3 months from now
				},
				expected_outputs: {
					"Applicant CHIP Waiting Period Satisfied Indicator" => "N",
					"CHIP Waiting Period Satisfied Ineligibility Reason" => 139
				}
			},
			{
				test_name: "Determine CHIP Waiting Period - No Waiting Period - Required Input is 0",
				inputs: { 
					"Applicant CHIP Prelim Indicator" => "N",
					"Prior Insurance" => "Y",
					"Prior Insurance End Date" => 2.months.ago
				},
				configs: {
					"State CHIP Waiting Period" => 0
				},
				expected_outputs: {
					"Applicant CHIP Waiting Period Satisfied Indicator" => "X",
					"CHIP Waiting Period Satisfied Ineligibility Reason" => 555
				}
			},
			{
				test_name: "Determine CHIP Waiting Period - No Waiting Period - No Prior Insurance",
				inputs: { 
					"Applicant CHIP Prelim Indicator" => "N",
					"Prior Insurance" => "N",
					"Prior Insurance End Date" => nil
				},
				configs: {
					"State CHIP Waiting Period" => 0
				},
				expected_outputs: {
					"Applicant CHIP Waiting Period Satisfied Indicator" => "X",
					"CHIP Waiting Period Satisfied Ineligibility Reason" => 555
				}
			},
			{
				test_name: "Bad Info - Inputs",
				inputs: { 
					# "Applicant CHIP Prelim Indicator" => "N",
					# "Prior Insurance" => "N",
					"Prior Insurance End Date" => nil
				},
				configs: {
					"State CHIP Waiting Period" => 0
				},
				expected_outputs: {
					"Applicant CHIP Waiting Period Satisfied Indicator" => "X",
					"CHIP Waiting Period Satisfied Ineligibility Reason" => 555
				}
			}#,			
			# {
			# 	test_name: "Bad Info - Configs",
			# 	inputs: { 
			# 		"Applicant CHIP Prelim Indicator" => "N",
			# 		"Prior Insurance" => "N",
			# 		"Prior Insurance End Date" => nil
			# 	},
			# 	configs: {
			# 		# "State CHIP Waiting Period" => 0
			# 	},
			# 	expected_outputs: {
			# 		"Applicant CHIP Waiting Period Satisfied Indicator" => "X",
			# 		"CHIP Waiting Period Satisfied Ineligibility Reason" => 555
			# 	}
			# }
		]
	end
end

# NOTES
# Config error here doesn't seem to be raising an error properly, not sure why. - CF, 7/6/2015
