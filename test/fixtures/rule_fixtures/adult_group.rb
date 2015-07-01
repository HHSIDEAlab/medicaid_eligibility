class AdultGroupFixture < MagiFixture 
	attr_accessor :magi, :test_sets

	def initialize 
		super 
		@magi = "AdultGroup"
		@test_sets = [
			{
				test_name: "No Option Adult Group",
				inputs: {
					"Application Year" => 2015,
					"Name" => "Demo 1",
					"People" => "Billy Everyteen",
		
					"Medicare Entitlement Indicator" => "Y", 
					"rake tApplicant Pregnancy Category Indicator" => "N", 
					"Applicant Age" => 13
				}, 
				configs: {
					"Option Adult Group" => "N"
				},
				expected_outputs: {
					"Applicant Adult Group Category Indicator" => "X",
					"Adult Group Category Ineligibility Reason" => 555
				}
			}, 
			{
				test_name: "Applicant Age Under 19 or Above 65",
				inputs: {
					"Application Year" => 2015,
					"Name" => "Demo 1",
					"People" => "Billy Everyteen",
		
					"Medicare Entitlement Indicator" => "Y", 
					"Applicant Pregnancy Category Indicator" => "N", 
					"Applicant Age" => 13
				}, 
				configs: {
					"Option Adult Group" => "Y"
				},
				expected_outputs: {
					"Applicant Adult Group Category Indicator" => "N",
					"Adult Group Category Ineligibility Reason" => 123
				}
			},
			{
				test_name: "Application Pregnancy Category Indicator is Yes",
				inputs: {
					"Application Year" => 2015,
					"Name" => "Demo 1",
					"People" => "Billy Everyteen",
		
					"Medicare Entitlement Indicator" => "Y", 
					"Applicant Pregnancy Category Indicator" => "Y", 
					"Applicant Age" => 25
				}, 
				configs: {
					"Option Adult Group" => "Y"
				},
				expected_outputs: {
					"Applicant Adult Group Category Indicator" => "N",
					"Adult Group Category Ineligibility Reason" => 122
				}
			},
			{
				test_name: "Medicare Entitlement Indicator is Yes",
				inputs: {
					"Application Year" => 2015,
					"Name" => "Demo 1",
					"People" => "Billy Everyteen",
		
					"Medicare Entitlement Indicator" => "Y", 
					"Applicant Pregnancy Category Indicator" => "N", 
					"Applicant Age" => 25
				}, 
				configs: {
					"Option Adult Group" => "Y"
				},
				expected_outputs: {
					"Applicant Adult Group Category Indicator" => "N",
					"Adult Group Category Ineligibility Reason" => 117
				}
			},
			{
				test_name: "Fallback Determination",
				inputs: {
					"Application Year" => 2015,
					"Name" => "Demo 1",
					"People" => "Billy Everyteen",
		
					"Medicare Entitlement Indicator" => "N", 
					"Applicant Pregnancy Category Indicator" => "N", 
					"Applicant Age" => 25
				}, 
				configs: {
					"Option Adult Group" => "Y"
				},
				expected_outputs: {
					"Applicant Adult Group Category Indicator" => "Y",
					"Adult Group Category Ineligibility Reason" => 999
				}
			},
			{
				test_name: "Bad Info",
				inputs: {
					"Application Year" => 2015,
					"Name" => "Demo 1",
					"People" => "Billy Everyteen",
		
					# "Medicare Entitlement Indicator" => "N", 
					# "Applicant Pregnancy Category Indicator" => "N", 
					"Applicant Age" => 25
				}, 
				configs: {
					"Option Adult Group" => "Y"
				},
				expected_outputs: {
					"Applicant Adult Group Category Indicator" => "Y",
					"Adult Group Category Ineligibility Reason" => 999
				}
			}
		]
	end



		# 	"State": "TX", 
		# 	"Inputs": {
		# 		"Application Year": 2015,
		# 		"Name": "Demo 1",
		# 		"People": "Billy Everyteen",

		# 		"Medicare Entitlement Indicator": "Y", 
		# 		"Applicant Pregnancy Category Indicator": "N", 
		# 		"Applicant Age": 13
		# 	}, 
		# 	"Configs": {
		# 		"Option Adult Group": "N"
		# 	},
		# 	"Expected Outputs": {
		# 		"Applicant Adult Group Category Indicator": "X",
		# 		"Adult Group Category Ineligibility Reason": 555
		# 	}
		# }

end

