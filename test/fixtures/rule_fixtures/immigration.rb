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
			},
			{
				test_name: "Immigration - Seven Year Limit - Applies - Immigration Status 01 and Amerasian Immigrant - Yes",
				inputs: {
					"US Citizen Indicator" => "N",
					"Lawful Presence Attested" => "Y",
					"Immigration Status" => "01",
					"Amerasian Immigrant" => "Y",
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
					"State Applies Seven Year Limit" => "Y",
					"Option Require Work Quarters" => "N"
				},
				expected_outputs: {
					# CHIPRA 214
					"Applicant Seven Year Limit Indicator" => "Y",
					"Seven Year Limit Ineligibility Reason" => 999
				}
			},
			{
				test_name: "Immigration - Seven Year Limit - Applies - Immigration Status 01 and Amerasian Immigrant - No",
				inputs: {
					"US Citizen Indicator" => "N",
					"Lawful Presence Attested" => "Y",
					"Immigration Status" => "01",
					"Amerasian Immigrant" => "Y",
					"Applicant Age" => 25,
					"Applicant Pregnancy Category Indicator" => "N",
					"Victim of Trafficking" => "N",
					"Seven Year Limit Start Date" => 8.years.ago,
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
					"State Applies Seven Year Limit" => "Y",
					"Option Require Work Quarters" => "N"
				},
				expected_outputs: {
					# CHIPRA 214
					"Applicant Seven Year Limit Indicator" => "N",
					"Seven Year Limit Ineligibility Reason" => 111
				}
			},


			{
				test_name: "Immigration - Five Year Bar / T2 Work - Veteran Status - Yes",
				inputs: {
					"US Citizen Indicator" => "N",
					"Lawful Presence Attested" => "Y",
					"Immigration Status" => "01",
					"Amerasian Immigrant" => "N",
					"Applicant Age" => 25,
					"Applicant Pregnancy Category Indicator" => "N",
					"Victim of Trafficking" => "N",
					"Seven Year Limit Start Date" => 8.years.ago,
					"Five Year Bar Applies" => "N",
					"Five Year Bar Met" => "N",
					"Veteran Status" => "Y",
					"Applicant Has 40 Title II Work Quarters" => "N"
				},
				configs: {
					"Option CHIPRA 214 Applicable Program" => "03",
					"Option CHIPRA 214 Child Age Threshold" => 21,
					"Option CHIPRA 214 Applies To" => "03",
					"Option CHIPRA 214 CHIP Applies To" => "03",
					"State Applies Seven Year Limit" => "Y",
					"Option Require Work Quarters" => "N"
				},
				expected_outputs: {
					# CHIPRA 214
					"Applicant Five Year Bar Indicator" => "X",
					"Five Year Bar Ineligibility Reason" => 555,
					"Applicant Title II Work Quarters Met Indicator" => "X",
					"Title II Work Quarters Met Ineligibility Reason" => 555
				}
			},

			{
				test_name: "Immigration - Five Year Bar / T2 Work - Veteran Status No - No Five Year Bar Applies",
				inputs: {
					"US Citizen Indicator" => "N",
					"Lawful Presence Attested" => "Y",
					"Immigration Status" => "01",
					"Amerasian Immigrant" => "N",
					"Applicant Age" => 25,
					"Applicant Pregnancy Category Indicator" => "N",
					"Victim of Trafficking" => "N",
					"Seven Year Limit Start Date" => 8.years.ago,
					"Five Year Bar Applies" => "N",
					"Five Year Bar Met" => "N",
					"Veteran Status" => "Y",
					"Applicant Has 40 Title II Work Quarters" => "N"
				},
				configs: {
					"Option CHIPRA 214 Applicable Program" => "03",
					"Option CHIPRA 214 Child Age Threshold" => 21,
					"Option CHIPRA 214 Applies To" => "03",
					"Option CHIPRA 214 CHIP Applies To" => "03",
					"State Applies Seven Year Limit" => "Y",
					"Option Require Work Quarters" => "N"
				},
				expected_outputs: {
					# CHIPRA 214
					"Applicant Five Year Bar Indicator" => "X",
					"Five Year Bar Ineligibility Reason" => 555
				}
			},
			{
				test_name: "Immigration - Five Year Bar / T2 Work - Veteran Status No - Five Year Bar Applies - Five Year Bar Met",
				inputs: {
					"US Citizen Indicator" => "N",
					"Lawful Presence Attested" => "Y",
					"Immigration Status" => "01",
					"Amerasian Immigrant" => "N",
					"Applicant Age" => 25,
					"Applicant Pregnancy Category Indicator" => "N",
					"Victim of Trafficking" => "N",
					"Seven Year Limit Start Date" => 8.years.ago,
					"Five Year Bar Applies" => "Y",
					"Five Year Bar Met" => "Y",
					"Veteran Status" => "N",
					"Applicant Has 40 Title II Work Quarters" => "N"
				},
				configs: {
					"Option CHIPRA 214 Applicable Program" => "03",
					"Option CHIPRA 214 Child Age Threshold" => 21,
					"Option CHIPRA 214 Applies To" => "03",
					"Option CHIPRA 214 CHIP Applies To" => "03",
					"State Applies Seven Year Limit" => "Y",
					"Option Require Work Quarters" => "N"
				},
				expected_outputs: {
					# CHIPRA 214
					"Applicant Five Year Bar Indicator" => "Y",
					"Five Year Bar Ineligibility Reason" => 999
				}
			},
			{
				test_name: "Immigration - Five Year Bar / T2 Work - Veteran Status No - Five Year Bar Applies - Five Year Bar Not Met",
				inputs: {
					"US Citizen Indicator" => "N",
					"Lawful Presence Attested" => "Y",
					"Immigration Status" => "01",
					"Amerasian Immigrant" => "N",
					"Applicant Age" => 25,
					"Applicant Pregnancy Category Indicator" => "N",
					"Victim of Trafficking" => "N",
					"Seven Year Limit Start Date" => 8.years.ago,
					"Five Year Bar Applies" => "Y",
					"Five Year Bar Met" => "N",
					"Veteran Status" => "N",
					"Applicant Has 40 Title II Work Quarters" => "N"
				},
				configs: {
					"Option CHIPRA 214 Applicable Program" => "03",
					"Option CHIPRA 214 Child Age Threshold" => 21,
					"Option CHIPRA 214 Applies To" => "03",
					"Option CHIPRA 214 CHIP Applies To" => "03",
					"State Applies Seven Year Limit" => "Y",
					"Option Require Work Quarters" => "N"
				},
				expected_outputs: {
					# CHIPRA 214
					"Applicant Five Year Bar Indicator" => "N",
					"Five Year Bar Ineligibility Reason" => 143
				}
			},
			{
				test_name: "Immigration - Five Year Bar / T2 Work - Veteran Status No - Immigration Status 01 And Require Work Quarters Yes - Has Work Quarters",
				inputs: {
					"US Citizen Indicator" => "N",
					"Lawful Presence Attested" => "Y",
					"Immigration Status" => "01",
					"Amerasian Immigrant" => "N",
					"Applicant Age" => 25,
					"Applicant Pregnancy Category Indicator" => "N",
					"Victim of Trafficking" => "N",
					"Seven Year Limit Start Date" => 8.years.ago,
					"Five Year Bar Applies" => "N",
					"Five Year Bar Met" => "N",
					"Veteran Status" => "N",
					"Applicant Has 40 Title II Work Quarters" => "Y"
				},
				configs: {
					"Option CHIPRA 214 Applicable Program" => "03",
					"Option CHIPRA 214 Child Age Threshold" => 21,
					"Option CHIPRA 214 Applies To" => "03",
					"Option CHIPRA 214 CHIP Applies To" => "03",
					"State Applies Seven Year Limit" => "N",
					"Option Require Work Quarters" => "Y"
				},
				expected_outputs: {
					# CHIPRA 214
					"Applicant Title II Work Quarters Met Indicator" => "Y",
					"Title II Work Quarters Met Ineligibility Reason" => 999
				}
			},
			{
				test_name: "Immigration - Five Year Bar / T2 Work - Veteran Status No - Immigration Status 01 And Require Work Quarters Yes - Does Not Have Work Quarters",
				inputs: {
					"US Citizen Indicator" => "N",
					"Lawful Presence Attested" => "Y",
					"Immigration Status" => "01",
					"Amerasian Immigrant" => "N",
					"Applicant Age" => 25,
					"Applicant Pregnancy Category Indicator" => "N",
					"Victim of Trafficking" => "N",
					"Seven Year Limit Start Date" => 8.years.ago,
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
					"Option Require Work Quarters" => "Y"
				},
				expected_outputs: {
					# CHIPRA 214
					"Applicant Title II Work Quarters Met Indicator" => "N",
					"Title II Work Quarters Met Ineligibility Reason" => 104
				}
			},





        # if v("Veteran Status") == 'Y'
        #   determination_na "Five Year Bar"
        #   determination_na "Title II Work Quarters Met"
        # else
        #   if v("Five Year Bar Applies") == 'Y'
        #     if v("Five Year Bar Met") == 'Y'
        #       determination_y "Five Year Bar"
        #     else
        #       determination_n "Five Year Bar", 143
        #     end
        #   else
        #     determination_na "Five Year Bar"
        #   end



			{
				test_name: "Bad Info - Inputs",
				inputs: {
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
				}
			},
			{
				test_name: "Bad Info - Configs",
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
					"Option Require Work Quarters" => "N"
				},
				expected_outputs: {
				}
			}
		]

		# 7 year limit tests
		['02','03','04','09'].each do |im_st|
			@test_sets << {
				test_name: "Immigration - Seven Year Limit - Applies - Immigration Status #{im_st} - Yes",
				inputs: {
					"US Citizen Indicator" => "N",
					"Lawful Presence Attested" => "Y",
					"Immigration Status" => im_st,
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
					"State Applies Seven Year Limit" => "Y",
					"Option Require Work Quarters" => "N"
				},
				expected_outputs: {
					"Applicant Seven Year Limit Indicator" => "Y",
					"Seven Year Limit Ineligibility Reason" => 999
				}
			}
		end

		['02','03','04','09'].each do |im_st|
			@test_sets << {
				test_name: "Immigration - Seven Year Limit - Applies - Immigration Status #{im_st} - No",
				inputs: {
					"US Citizen Indicator" => "N",
					"Lawful Presence Attested" => "Y",
					"Immigration Status" => im_st,
					"Amerasian Immigrant" => "N",
					"Applicant Age" => 25,
					"Applicant Pregnancy Category Indicator" => "N",
					"Victim of Trafficking" => "N",
					"Seven Year Limit Start Date" => 8.years.ago,
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
					"State Applies Seven Year Limit" => "Y",
					"Option Require Work Quarters" => "N"
				},
				expected_outputs: {
					"Applicant Seven Year Limit Indicator" => "N",
					"Seven Year Limit Ineligibility Reason" => 111
				}
			}
		end

		['01', '05', '06', '07', '08', '10', '99'].each do |im_st|
			@test_sets << {
				test_name: "Immigration - Seven Year Limit - Does Not Apply to Immigration Status #{im_st}",
				inputs: {
					"US Citizen Indicator" => "N",
					"Lawful Presence Attested" => "Y",
					"Immigration Status" => im_st,
					"Amerasian Immigrant" => "N",
					"Applicant Age" => 25,
					"Applicant Pregnancy Category Indicator" => "N",
					"Victim of Trafficking" => "N",
					"Seven Year Limit Start Date" => Time.now.tomorrow,
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
					"State Applies Seven Year Limit" => "Y",
					"Option Require Work Quarters" => "N"
				},
				expected_outputs: {
					"Applicant Seven Year Limit Indicator" => "X",
					"Seven Year Limit Ineligibility Reason" => 555
				}
			}
		end

		['02', '03', '04', '05', '06', '07', '08', '09', '10', '99'].each do |im_st|
			@test_sets << {
				test_name: "Immigration - Five Year Bar / T2 Work - Veteran Status No - Immigration Status #{im_st} - Title II Work Quarters NA",
				inputs: {
					"US Citizen Indicator" => "N",
					"Lawful Presence Attested" => "Y",
					"Immigration Status" => im_st,
					"Amerasian Immigrant" => "N",
					"Applicant Age" => 25,
					"Applicant Pregnancy Category Indicator" => "N",
					"Victim of Trafficking" => "N",
					"Seven Year Limit Start Date" => 8.years.ago,
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
					"Option Require Work Quarters" => "Y"
				},
				expected_outputs: {
					# CHIPRA 214
					"Applicant Title II Work Quarters Met Indicator" => "X",
					"Title II Work Quarters Met Ineligibility Reason" => 555
				}
			}
		end
	end
end

# NOTES
# This fixture is way more rigid than it should be but it's an okay first draft. 
# The variety of indicators etc make me think this could really benefit from some code generation. 
# Coming back to this after the rest of them are stubbed. -CF 7/6/2015
