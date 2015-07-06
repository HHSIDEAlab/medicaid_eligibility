class AdultGroupFixture < MagiFixture 
	attr_accessor :magi, :test_sets

	def initialize 
		super 
		@magi = "Adult Group"
		@test_sets = [
			{
				test_name: "No Option Adult Group",
				inputs: {
					"Medicare Entitlement Indicator" => "Y", 
					"Applicant Pregnancy Category Indicator" => "N", 
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
				test_name: "Bad Info - Inputs",
				inputs: {
					# "Medicare Entitlement Indicator" => "N", 
					# "Applicant Pregnancy Category Indicator" => "N", 
					"Applicant Age" => 25
				}, 
				configs: {
					"Option Adult Group" => "Y"
				},
				expected_outputs: {
					# "Applicant Adult Group Category Indicator" => "Y",
					# "Adult Group Category Ineligibility Reason" => 999
				}
			},
			{
				test_name: "Bad Info - Configs",
				inputs: {
					"Medicare Entitlement Indicator" => "N", 
					"Applicant Pregnancy Category Indicator" => "N", 
					"Applicant Age" => 25
				}, 
				configs: {
					# "Option Adult Group" => "Y"
				},
				expected_outputs: {
					# "Applicant Adult Group Category Indicator" => "Y",
					# "Adult Group Category Ineligibility Reason" => 999
				}
			}
		] 
	end
end

