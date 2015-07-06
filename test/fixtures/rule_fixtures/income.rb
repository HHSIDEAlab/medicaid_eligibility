##### GENERATED AT 2015-07-06 17:08:30 -0400 ######
class IncomeFixture < MagiFixture
	attr_accessor :magi, :test_sets

	def initialize
		super
		@magi = 'Income'
		@test_sets = [
			# {
			# 	test_name: "FILL_IN_WITH_TEST_NAME",
			# 	inputs: {
			# 		"Application Year" => 2015,
			# 		"Applicant Adult Group Category Indicator" => "N",
			# 		"Applicant Pregnancy Category Indicator" => "N",
			# 		"Applicant Parent Caretaker Category Indicator" => "N",
			# 		"Applicant Child Category Indicator" => "N",
			# 		"Applicant Optional Targeted Low Income Child Indicator" => "N",
			# 		"Applicant CHIP Targeted Low Income Child Indicator" => "n",
			# 		"Calculated Income" => 0,
			# 		"Medicaid Household" => 1,
			# 		"Applicant Age" => 20
			# 	},
			# 	configs: {
			# 		"Base FPL" => 0,
			# 		"FPL Per Person" => 0,
			# 		"FPL" => {},
			# 		"Option CHIP Pregnancy Category" => "N",
			# 		"Medicaid Thresholds" => {},
			# 		"CHIP Thresholds" => {}
			# 	},
			# 	expected_outputs: {
			# 		"Percentage for Medicaid Category Used" => 0,
			# 		"Percentage for CHIP Category Used" => 0,
			# 		"FPL" => 0,
			# 		"FPL * Percentage Medicaid" => 0,
			# 		"FPL * Percentage CHIP" => 0,
			# 		"Category Used to Calculate Medicaid Income" => 0,
			# 		"Category Used to Calculate CHIP Income" => 0,
			# 		"Applicant Income Medicaid Eligible Indicator" => 0,
			# 		"Income Medicaid Eligible Ineligibility Reason" => 0,
			# 		"Applicant Income CHIP Eligible Indicator" => 0,
			# 		"Income CHIP Eligible Ineligibility Reason" => 0
			# 	}
			# }
		]
	end
end

# NOTES
# Lots of state references here, punting for now. -CF 7/6/2015