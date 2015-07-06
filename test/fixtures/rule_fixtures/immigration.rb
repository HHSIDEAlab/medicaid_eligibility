##### GENERATED AT 2015-07-06 15:11:52 -0400 ######
class ImmigrationFixture < MagiFixture
	attr_accessor :magi, :test_sets

	def initialize
		super
		@magi = 'Immigration'
		@test_sets = [
			{
				test_name: "Immigration",
				inputs: {
					"US Citizen Indicator" => "Y",
					"Lawful Presence Attested" => "N",
					"Immigration Status" => "99",
					"Amerasian Immigrant" => "N",
					"Applicant Age" => 21,
					"Applicant Pregnancy Category Indicator" => "N",
					"Victim of Trafficking" => "N",
					"Seven Year Limit Start Date" => Time.now.yesterday,
					"Five Year Bar Applies" => "N",
					"Five Year Bar Met" => "N",
					"Veteran Status" => "N",
					"Applicant Has 40 Title II Work Quarters" => "N"
				},
				configs: {
					"Option CHIPRA 214 Applicable Program" => "01",
					"Option CHIPRA 214 Child Age Threshold" => 21,
					"Option CHIPRA 214 Applies To" => "03",
					"Option CHIPRA 214 CHIP Applies To" => "03",
					"State Applies Seven Year Limit" => "N",
					"Option Require Work Quarters" => "N"
				},
				expected_outputs: {
					# "Applicant Trafficking Victim Indicator" => ?,
					# "Applicant Seven Year Limit Indicator" => ?
				}
			}
		]
	end
end
