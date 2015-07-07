##### GENERATED AT 2015-07-07 12:15:52 -0400 ######
class RefugeeAssistanceFixture < MagiFixture
	attr_accessor :magi, :test_sets

	def initialize
		super
		@magi = 'RefugeeAssistance'
		@test_sets = [
			# {
			# 	test_name: "FILL_IN_WITH_TEST_NAME",
			# 	inputs: {
			# 		"Refugee Status" => ?,
			# 		"Refugee Medical Assistance Start Date" => ?,
			# 		"Medicaid Residency Indicator" => ?,
			# 		"Calculated Income" => ?,
			# 		"FPL" => ?
			# 	},
			# 	configs: {
			# 		"State Offers Refugee Medical Assistance" => ?,
			# 		"Refugee Medical Assistance Income Requirement" => ?,
			# 		"Refugee Medical Assistance Threshold" => ?
			# 	},
			# 	expected_outputs: {
			# 		"Applicant Refugee Medical Assistance Indicator" => ?,
			# 		"Refugee Medical Assistance Determination Date" => ?,
			# 		"Refugee Medical Assistance Ineligibility Reason" => ?,
			# 		"APTC Referral Indicator" => ?,
			# 		"APTC Referral Ineligibility Reason" => ?
			# 	}
			# }
		]
	end
end

# NOTES
# Weird that run is in here, probably means there's an x-factor, coming back to this later -CF 7/7/2015
