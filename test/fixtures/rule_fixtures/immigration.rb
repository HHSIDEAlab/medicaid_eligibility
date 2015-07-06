##### GENERATED AT 2015-07-06 15:11:52 -0400 ######
class ImmigrationFixture < MagiFixture
	attr_accessor :magi, :test_sets

	def initialize
		super
		@magi = 'Immigration'
		@test_sets = [
			{
				test_name: "Immigration - US Citizen",
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
					"Applicant Medicaid Citizen Or Immigrant Indicator" => "Y",
					"Medicaid Citizen Or Immigrant Ineligibility Reason" => 999,
					"Applicant CHIP Citizen Or Immigrant Indicator" => "Y",
					"CHIP Citizen Or Immigrant Ineligibility Reason" => 999,
					"Applicant Medicaid CHIPRA 214 Indicator" => "X",
					"Medicaid CHIPRA 214 Ineligibility Reason" => 555,
					"Applicant CHIP CHIPRA 214 Indicator" => "X",
					"CHIP CHIPRA 214 Ineligibility Reason" => 555,
					"Applicant Trafficking Victim Indicator" => "X",
					"Trafficking Victim Ineligibility Reason" => 555,
					"Applicant Seven Year Limit Indicator" => "X",
					"Seven Year Limit Ineligibility Reason" => 555,
					"Applicant Five Year Bar Indicator" => "X",
					"Five Year Bar Ineligibility Reason" => 555,
					"Applicant Title II Work Quarters Met Indicator" => "X",
					"Title II Work Quarters Met Ineligibility Reason" => 555
				}
			}, 
			{
				test_name: "Immigration - No Lawful Presence Attested",
				inputs: {
					"US Citizen Indicator" => "N",
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
					"Applicant Medicaid Citizen Or Immigrant Indicator" => "N",
					"Medicaid Citizen Or Immigrant Ineligibility Reason" => 409,
					"Applicant CHIP Citizen Or Immigrant Indicator" => "N",
					"CHIP Citizen Or Immigrant Ineligibility Reason" => 409,
					"Applicant Medicaid CHIPRA 214 Indicator" => "X",
					"Medicaid CHIPRA 214 Ineligibility Reason" => 555,
					"Applicant CHIP CHIPRA 214 Indicator" => "X",
					"CHIP CHIPRA 214 Ineligibility Reason" => 555,
					"Applicant Trafficking Victim Indicator" => "X",
					"Trafficking Victim Ineligibility Reason" => 555,
					"Applicant Seven Year Limit Indicator" => "X",
					"Seven Year Limit Ineligibility Reason" => 555,
					"Applicant Five Year Bar Indicator" => "X",
					"Five Year Bar Ineligibility Reason" => 555,
					"Applicant Title II Work Quarters Met Indicator" => "X",
					"Title II Work Quarters Met Ineligibility Reason" => 555
				}
			},
			{
				test_name: "Immigration - Not A Qualified Non-Citizen",
				inputs: {
					"US Citizen Indicator" => "N",
					"Lawful Presence Attested" => "Y",
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
					"Applicant Medicaid Citizen Or Immigrant Indicator" => "N",
					"Medicaid Citizen Or Immigrant Ineligibility Reason" => 409,
					"Applicant CHIP Citizen Or Immigrant Indicator" => "N",
					"CHIP Citizen Or Immigrant Ineligibility Reason" => 409,
					"Applicant Medicaid CHIPRA 214 Indicator" => "X",
					"Medicaid CHIPRA 214 Ineligibility Reason" => 555,
					"Applicant CHIP CHIPRA 214 Indicator" => "X",
					"CHIP CHIPRA 214 Ineligibility Reason" => 555,
					"Applicant Trafficking Victim Indicator" => "X",
					"Trafficking Victim Ineligibility Reason" => 555,
					"Applicant Seven Year Limit Indicator" => "X",
					"Seven Year Limit Ineligibility Reason" => 555,
					"Applicant Five Year Bar Indicator" => "X",
					"Five Year Bar Ineligibility Reason" => 555,
					"Applicant Title II Work Quarters Met Indicator" => "X",
					"Title II Work Quarters Met Ineligibility Reason" => 555
				}
			},
			{
				test_name: "Immigration - CHIPRA Applicable - Applicant Age Under Threshold",
				inputs: {
					"US Citizen Indicator" => "N",
					"Lawful Presence Attested" => "Y",
					"Immigration Status" => "01",
					"Amerasian Immigrant" => "N",
					"Applicant Age" => 18,
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
					"Option CHIPRA 214 Applies To" => "01",
					"Option CHIPRA 214 CHIP Applies To" => "03",
					"State Applies Seven Year Limit" => "N",
					"Option Require Work Quarters" => "N"
				},
				expected_outputs: {
					# CHIPRA 214
					"Applicant Medicaid CHIPRA 214 Indicator" => "Y",
					"Medicaid CHIPRA 214 Ineligibility Reason" => 999,
				}
			},
			{
				test_name: "Immigration - CHIPRA Applicable - Applicant Pregnant",
				inputs: {
					"US Citizen Indicator" => "N",
					"Lawful Presence Attested" => "Y",
					"Immigration Status" => "01",
					"Amerasian Immigrant" => "N",
					"Applicant Age" => 25,
					"Applicant Pregnancy Category Indicator" => "Y",
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
					"Option CHIPRA 214 Applies To" => "01",
					"Option CHIPRA 214 CHIP Applies To" => "03",
					"State Applies Seven Year Limit" => "N",
					"Option Require Work Quarters" => "N"
				},
				expected_outputs: {
					# CHIPRA 214
					"Applicant Medicaid CHIPRA 214 Indicator" => "Y",
					"Medicaid CHIPRA 214 Ineligibility Reason" => 999,
				}
			},
			{
				test_name: "Immigration - CHIPRA Applicable - Option CHIPRA 214 Applies to 01",
				inputs: {
					"US Citizen Indicator" => "N",
					"Lawful Presence Attested" => "Y",
					"Immigration Status" => "01",
					"Amerasian Immigrant" => "N",
					"Applicant Age" => 25,
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
					"Option CHIPRA 214 Applies To" => "01",
					"Option CHIPRA 214 CHIP Applies To" => "03",
					"State Applies Seven Year Limit" => "N",
					"Option Require Work Quarters" => "N"
				},
				expected_outputs: {
					# CHIPRA 214
					"Applicant Medicaid CHIPRA 214 Indicator" => "N",
					"Medicaid CHIPRA 214 Ineligibility Reason" => 119,
				}
			},
			{
				test_name: "Immigration - CHIPRA Applicable - Option CHIPRA 214 Applies to 02",
				inputs: {
					"US Citizen Indicator" => "N",
					"Lawful Presence Attested" => "Y",
					"Immigration Status" => "01",
					"Amerasian Immigrant" => "N",
					"Applicant Age" => 25,
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
					"Option CHIPRA 214 Applies To" => "02",
					"Option CHIPRA 214 CHIP Applies To" => "03",
					"State Applies Seven Year Limit" => "N",
					"Option Require Work Quarters" => "N"
				},
				expected_outputs: {
					# CHIPRA 214
					"Applicant Medicaid CHIPRA 214 Indicator" => "N",
					"Medicaid CHIPRA 214 Ineligibility Reason" => 118,
				}
			},
			{
				test_name: "Immigration - CHIPRA Applicable - Option CHIPRA 214 Applies to 03",
				inputs: {
					"US Citizen Indicator" => "N",
					"Lawful Presence Attested" => "Y",
					"Immigration Status" => "01",
					"Amerasian Immigrant" => "N",
					"Applicant Age" => 25,
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
					# CHIPRA 214
					"Applicant Medicaid CHIPRA 214 Indicator" => "N",
					"Medicaid CHIPRA 214 Ineligibility Reason" => 120,
				}
			},
			{
				test_name: "Immigration - CHIPRA Applicable - Program Not 01",
				inputs: {
					"US Citizen Indicator" => "N",
					"Lawful Presence Attested" => "Y",
					"Immigration Status" => "01",
					"Amerasian Immigrant" => "N",
					"Applicant Age" => 25,
					"Applicant Pregnancy Category Indicator" => "N",
					"Victim of Trafficking" => "N",
					"Seven Year Limit Start Date" => Time.now.yesterday,
					"Five Year Bar Applies" => "N",
					"Five Year Bar Met" => "N",
					"Veteran Status" => "N",
					"Applicant Has 40 Title II Work Quarters" => "N"
				},
				configs: {
					"Option CHIPRA 214 Applicable Program" => "03",
					"Option CHIPRA 214 Child Age Threshold" => 21,
					"Option CHIPRA 214 Applies To" => "03",
					"Option CHIPRA 214 CHIP Applies To" => "03",
					"State Applies Seven Year Limit" => "N",
					"Option Require Work Quarters" => "N"
				},
				expected_outputs: {
					# CHIPRA 214
					"Applicant CHIP CHIPRA 214 Indicator" => "X",
					"CHIP CHIPRA 214 Ineligibility Reason" => 555,
				}
			},
			{
				test_name: "Immigration - CHIPRA - Applicable Program 03",
				inputs: {
					"US Citizen Indicator" => "N",
					"Lawful Presence Attested" => "Y",
					"Immigration Status" => "01",
					"Amerasian Immigrant" => "N",
					"Applicant Age" => 25,
					"Applicant Pregnancy Category Indicator" => "N",
					"Victim of Trafficking" => "N",
					"Seven Year Limit Start Date" => Time.now.yesterday,
					"Five Year Bar Applies" => "N",
					"Five Year Bar Met" => "N",
					"Veteran Status" => "N",
					"Applicant Has 40 Title II Work Quarters" => "N"
				},
				configs: {
					"Option CHIPRA 214 Applicable Program" => "03",
					"Option CHIPRA 214 Child Age Threshold" => 21,
					"Option CHIPRA 214 Applies To" => "03",
					"Option CHIPRA 214 CHIP Applies To" => "03",
					"State Applies Seven Year Limit" => "N",
					"Option Require Work Quarters" => "N"
				},
				expected_outputs: {
					# CHIPRA 214
					"Applicant Medicaid CHIPRA 214 Indicator" => "X", 
					"Medicaid CHIPRA 214 Ineligibility Reason" => 555,
					"Applicant CHIP CHIPRA 214 Indicator" => "X",
					"CHIP CHIPRA 214 Ineligibility Reason" => 555
				}
			},
			{
				test_name: "Immigration - Victim of Trafficking - Yes",
				inputs: {
					"US Citizen Indicator" => "N",
					"Lawful Presence Attested" => "Y",
					"Immigration Status" => "01",
					"Amerasian Immigrant" => "N",
					"Applicant Age" => 25,
					"Applicant Pregnancy Category Indicator" => "N",
					"Victim of Trafficking" => "Y",
					"Seven Year Limit Start Date" => Time.now.yesterday,
					"Five Year Bar Applies" => "N",
					"Five Year Bar Met" => "N",
					"Veteran Status" => "N",
					"Applicant Has 40 Title II Work Quarters" => "N"
				},
				configs: {
					"Option CHIPRA 214 Applicable Program" => "03",
					"Option CHIPRA 214 Child Age Threshold" => 21,
					"Option CHIPRA 214 Applies To" => "03",
					"Option CHIPRA 214 CHIP Applies To" => "03",
					"State Applies Seven Year Limit" => "N",
					"Option Require Work Quarters" => "N"
				},
				expected_outputs: {
					# CHIPRA 214
					"Applicant Trafficking Victim Indicator" => "Y",
					"Trafficking Victim Ineligibility Reason" => 999
				}
			},
			{
				test_name: "Immigration - Victim of Trafficking - No",
				inputs: {
					"US Citizen Indicator" => "N",
					"Lawful Presence Attested" => "Y",
					"Immigration Status" => "01",
					"Amerasian Immigrant" => "N",
					"Applicant Age" => 25,
					"Applicant Pregnancy Category Indicator" => "N",
					"Victim of Trafficking" => "N",
					"Seven Year Limit Start Date" => Time.now.yesterday,
					"Five Year Bar Applies" => "N",
					"Five Year Bar Met" => "N",
					"Veteran Status" => "N",
					"Applicant Has 40 Title II Work Quarters" => "N"
				},
				configs: {
					"Option CHIPRA 214 Applicable Program" => "03",
					"Option CHIPRA 214 Child Age Threshold" => 21,
					"Option CHIPRA 214 Applies To" => "03",
					"Option CHIPRA 214 CHIP Applies To" => "03",
					"State Applies Seven Year Limit" => "N",
					"Option Require Work Quarters" => "N"
				},
				expected_outputs: {
					# CHIPRA 214
					"Applicant Trafficking Victim Indicator" => "N",
					"Trafficking Victim Ineligibility Reason" => 410
				}
			}

			# next was: immigration - seven year limit

		]
	end
end

# NOTES
# This fixture is way more rigid than it should be but it's an okay first draft. 
# The variety of indicators etc make me think this could really benefit from some code generation. 
# Coming back to this after the rest of them are stubbed. -CF 7/6/2015
