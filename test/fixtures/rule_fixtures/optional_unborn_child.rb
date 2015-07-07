##### GENERATED AT 2015-07-07 10:31:46 -0400 ######
class OptionalUnbornChildFixture < MagiFixture
	attr_accessor :magi, :test_sets

	def initialize
		super
		@magi = 'OptionalUnbornChild'
		@test_sets = [
			{
				test_name: "Unborn Child Eligibility - Calculated Income Under Limit",
				inputs: {
					"Applicant Pregnant Indicator" => "Y",
					"Applicant Medicaid Prelim Indicator" => "N",
					"Applicant CHIP Prelim Indicator" => "N",
					"Calculated Income" => 0,
					"FPL" => 10
				},
				configs: {
					"Percent FPL Unborn Child" => 10,
					"Option Cover Unborn Child" => "Y"
				},
				expected_outputs: {
					"Applicant Unborn Child Indicator" => "Y",
					"Unborn Child Ineligibility Reason" => 999,
					"Percentage for CHIP Category Used" => 10,
					"FPL * Percentage CHIP" => (10 * 15 * 0.01) 
				}
			},
			{
				test_name: "Unborn Child Eligibility - Calculated Income Over Limit",
				inputs: {
					"Applicant Pregnant Indicator" => "Y",
					"Applicant Medicaid Prelim Indicator" => "N",
					"Applicant CHIP Prelim Indicator" => "N",
					"Calculated Income" => 1000000,
					"FPL" => 10
				},
				configs: {
					"Percent FPL Unborn Child" => 10,
					"Option Cover Unborn Child" => "Y"
				},
				expected_outputs: {
					"Applicant Unborn Child Indicator" => "N",
					"Unborn Child Ineligibility Reason" => 408
				}
			}
		]

		[{preg: "N", cover: "N"}, {preg: "Y", cover: "N"}, {preg: "N", cover: "Y"}].each do |ind|
			@test_sets << {
				test_name: "Unborn Child Eligibility - Not Pregnant or Unborn Child Covered - Preg #{ind[:preg]} Cover #{ind[:cover]}",
				inputs: {
					"Applicant Pregnant Indicator" => ind[:preg],
					"Applicant Medicaid Prelim Indicator" => "N",
					"Applicant CHIP Prelim Indicator" => "N",
					"Calculated Income" => 10,
					"FPL" => 10
				},
				configs: {
					"Percent FPL Unborn Child" => 10,
					"Option Cover Unborn Child" => ind[:cover]
				},
				expected_outputs: {
					"Applicant Unborn Child Indicator" => "X",
					"Unborn Child Ineligibility Reason" => 555
				}
			}
		end

		[{medicaid_prelim: "Y", chip_prelim: "Y"}, {medicaid_prelim: "Y", chip_prelim: "N"}, {medicaid_prelim: "N", chip_prelim: "Y"}].each do |ind|
			@test_sets << {
				test_name: "Unborn Child Eligibility - Has Prelim Medicaid or CHIP Indicator - Medicaid #{ind[:medicaid_prelim]} CHIP #{ind[:chip_prelim]}",
				inputs: {
					"Applicant Pregnant Indicator" => "Y",
					"Applicant Medicaid Prelim Indicator" => ind[:medicaid_prelim],
					"Applicant CHIP Prelim Indicator" => ind[:chip_prelim],
					"Calculated Income" => 10,
					"FPL" => 10
				},
				configs: {
					"Percent FPL Unborn Child" => 10,
					"Option Cover Unborn Child" => "Y"
				},
				expected_outputs: {
					"Applicant Unborn Child Indicator" => "N",
					"Unborn Child Ineligibility Reason" => 151
				}
			}
		end
		


	end
end


# NOTES 
# may want a more intense test for income over / under limits. - CF 7/7/2015
