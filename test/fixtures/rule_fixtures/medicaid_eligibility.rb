##### GENERATED AT 2015-07-06 18:00:51 -0400 ######
class MedicaidEligibilityFixture < MagiFixture
	attr_accessor :magi, :test_sets

	def initialize
		super
		@magi = 'MedicaidEligibility'
		@test_sets = [
			{
				test_name: "Final Eligibility - Prelim Yes, Dependent Child Covered No",
				inputs: {
					"Applicant Medicaid Prelim Indicator" => "Y",
					"Applicant Dependent Child Covered Indicator" => "N",
					"Medicaid Residency Indicator" => "N",
					"Applicant Income Medicaid Eligible Indicator" => "N"
				},
				configs: {
					# none
				},
				expected_outputs: {
					"Applicant Medicaid Indicator" => "N",
					"Medicaid Ineligibility Reason" => 128,
					"APTC Referral Indicator" => "Y"
				}
			},
			{
				test_name: "Final Eligibility - Prelim No",
				inputs: {
					"Applicant Medicaid Prelim Indicator" => "N",
					"Applicant Dependent Child Covered Indicator" => "N",
					"Medicaid Residency Indicator" => "N",
					"Applicant Income Medicaid Eligible Indicator" => "N"
				},
				configs: {
					# none
				},
				expected_outputs: {
					"Applicant Medicaid Indicator" => "N",
					"Medicaid Ineligibility Reason" => 106,
					"APTC Referral Indicator" => "Y"
				}
			},
			{
				test_name: "Bad Info - Inputs",
				inputs: {
					"Applicant Income Medicaid Eligible Indicator" => "N"
				},
				configs: {
					# none
				},
				expected_outputs: {
				}
			}
		]

		["Y","X"].each do |ind|
			@test_sets << {
				test_name: "Final Eligibility - Prelim Yes, Dependent Child Covered #{ind}",
				inputs: {
					"Applicant Medicaid Prelim Indicator" => "Y",
					"Applicant Dependent Child Covered Indicator" => "Y",
					"Medicaid Residency Indicator" => "N",
					"Applicant Income Medicaid Eligible Indicator" => "N"
				},
				configs: {
					# none
				},
				expected_outputs: {
					"Applicant Medicaid Indicator" => "Y",
					"Medicaid Ineligibility Reason" => 999,
					"APTC Referral Indicator" => "N",
					"APTC Referral Ineligibility Reason" => 406
				}
			}
		end
	end
end

# NOTES
# No 999 on aptc referral ineligibility reason here when aptc referral is yes? -CF 7/6/2015