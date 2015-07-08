##### GENERATED AT 2015-07-06 17:08:30 -0400 ######
class IncomeFixture < MagiFixture
	attr_accessor :magi, :test_sets

	def initialize
		super
		@magi = 'Income'
		@test_sets = [
			# {
			# 	test_name: "Income - Set Percentage Used - Adult Group",
			# 	inputs: {
			# 		"Application Year" => 2015,
			# 		"Applicant Adult Group Category Indicator" => "Y",
			# 		"Applicant Pregnancy Category Indicator" => "N",
			# 		"Applicant Parent Caretaker Category Indicator" => "N",
			# 		"Applicant Child Category Indicator" => "N",
			# 		"Applicant Optional Targeted Low Income Child Indicator" => "N",
			# 		"Applicant CHIP Targeted Low Income Child Indicator" => "N",
			# 		"Calculated Income" => 0,
			# 		"Medicaid Household" => MedicaidHousehold.new("house", '', '', '', 3),
			# 		"Applicant Age" => 20
			# 	},
			# 	configs: {
			# 		"Base FPL" => 10,
			# 		"FPL Per Person" => 10,
			# 		"FPL" => { "2015" => { "Base FPL" => 11770, "FPL Per Person" => 4160 } },
			# 		"Option CHIP Pregnancy Category" => "N",
			# 		"Medicaid Thresholds" => { "Adult Group Category" => { "percentage" => "Y", "method" => "standard", "threshold" => 100 } },
			# 		"CHIP Thresholds" => { "Pregnancy Category" => { "percentage" => "Y", "method" => "standard", "threshold" => 133 } }
			# 	},
			# 	expected_outputs: {
			# 		"Percentage for Medicaid Category Used" => 100,
			# 		"Percentage for CHIP Category Used" => 0
			# 	}
			# }


			{
				test_name: "Bad Info - Inputs",
				inputs: {
					"Applicant Age" => 20
				},
				configs: {
					"Base FPL" => 10,
					"FPL Per Person" => 10,
					"FPL" => { "2015" => { "Base FPL" => 11770, "FPL Per Person" => 4160 } },
					"Option CHIP Pregnancy Category" => "N",
					"Medicaid Thresholds" => { "Adult Group Category" => { "percentage" => "Y", "method" => "standard", "threshold" => 100 } },
					"CHIP Thresholds" => { "Pregnancy Category" => { "percentage" => "Y", "method" => "standard", "threshold" => 133 } }
				},
				expected_outputs: {
				}
			},
			{
				test_name: "Bad Info - Configs",
				inputs: {
					"Application Year" => 2015,
					"Applicant Adult Group Category Indicator" => "Y",
					"Applicant Pregnancy Category Indicator" => "N",
					"Applicant Parent Caretaker Category Indicator" => "N",
					"Applicant Child Category Indicator" => "N",
					"Applicant Optional Targeted Low Income Child Indicator" => "N",
					"Applicant CHIP Targeted Low Income Child Indicator" => "N",
					"Calculated Income" => 0,
					"Medicaid Household" => MedicaidHousehold.new("house", '', '', '', 3),
					"Applicant Age" => 20
				},
				configs: {
					"CHIP Thresholds" => { "Pregnancy Category" => { "percentage" => "Y", "method" => "standard", "threshold" => 133 } }
				},
				expected_outputs: {
				}
			}			
		]
	end
end

# NOTES
# This is very deeply confusing due to max eligible medicaid category. Punting. -CF 7/6/2015



# expected_outputs: {
# 	"Percentage for Medicaid Category Used" => 0,
# 	"Percentage for CHIP Category Used" => 0,
# 	"FPL" => 0,
# 	"FPL * Percentage Medicaid" => 0,
# 	"FPL * Percentage CHIP" => 0,
# 	"Category Used to Calculate Medicaid Income" => 0,
# 	"Category Used to Calculate CHIP Income" => 0,
# 	"Applicant Income Medicaid Eligible Indicator" => 0,
# 	"Income Medicaid Eligible Ineligibility Reason" => 0,
# 	"Applicant Income CHIP Eligible Indicator" => 0,
# 	"Income CHIP Eligible Ineligibility Reason" => 0
# }


# config thresholds; 
# "Medicaid Thresholds": { "Adult Group Category": { "percentage": "Y", "method": "standard", "threshold": 100 }
#   "Parent Caretaker Category": {
#     "percentage": "Y",
#     "method": "standard",
#     "threshold": 100
#   },
#   "Pregnancy Category": {
#     "percentage": "Y",
#     "method": "standard",
#     "threshold": 100
#   },
#   "Child Category": {
#     "percentage": "Y",
#     "method": "standard",
#     "threshold": 100
#   },
#   "Optional Targeted Low Income Child": {
#     "percentage": "Y",
#     "method": "standard",
#     "threshold": 100
#   }
# },

# "CHIP Thresholds": {
# "Pregnancy Category": { "percentage": "Y", "method": "standard", "threshold": 133 },
#   "Child Category": {
#     "percentage": "Y",
#     "method": "standard",
#     "threshold": 100
#   },
#   "CHIP Targeted Low Income Child": {
#     "percentage": "Y",
#     "method": "standard",
#     "threshold": 100
#   }
# }