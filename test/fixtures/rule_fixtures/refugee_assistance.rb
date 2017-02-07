##### GENERATED AT 2015-07-07 12:15:52 -0400 ######
class RefugeeAssistanceFixture < MagiFixture
  attr_accessor :magi, :test_sets

  def initialize
    super
    @magi = 'RefugeeAssistance'
    @test_sets = [
      {
        test_name: 'Not a refugee',
        inputs: {
          'Refugee Status' => 'N',
          'Refugee Medical Assistance Start Date' => 2.months.ago,
          'Medicaid Residency Indicator' => 'N',
          'Calculated Income' => 1000,
          'FPL' => 20
        },
        configs: {
          'State Offers Refugee Medical Assistance' => 'Y',
          'Refugee Medical Assistance Income Requirement' => 'N',
          'Refugee Medical Assistance Threshold' => { 'percentage' => 'Y', 'method' => 'standard', 'threshold' => 100 }
        },
        expected_outputs: {
          'Applicant Refugee Medical Assistance Indicator' => 'X',
          'Refugee Medical Assistance Ineligibility Reason' => 555
        }
      },
      {
        test_name: 'State does not offer refugee assistance',
        inputs: {
          'Refugee Status' => 'Y',
          'Refugee Medical Assistance Start Date' => 2.months.ago,
          'Medicaid Residency Indicator' => 'N',
          'Calculated Income' => 1000,
          'FPL' => 20
        },
        configs: {
          'State Offers Refugee Medical Assistance' => 'N',
          'Refugee Medical Assistance Income Requirement' => 'N',
          'Refugee Medical Assistance Threshold' => { 'percentage' => 'Y', 'method' => 'standard', 'threshold' => 100 }
        },
        expected_outputs: {
          'Applicant Refugee Medical Assistance Indicator' => 'X',
          'Refugee Medical Assistance Ineligibility Reason' => 555
        }
      },
      {
        test_name: 'Refugee Assistance End Date has Passed',
        inputs: {
          'Refugee Status' => 'Y',
          'Refugee Medical Assistance Start Date' => 2.years.ago,
          'Medicaid Residency Indicator' => 'N',
          'Calculated Income' => 1000,
          'FPL' => 20
        },
        configs: {
          'State Offers Refugee Medical Assistance' => 'Y',
          'Refugee Medical Assistance Income Requirement' => 'N',
          'Refugee Medical Assistance Threshold' => { 'percentage' => 'Y', 'method' => 'standard', 'threshold' => 100 }
        },
        expected_outputs: {
          'Applicant Refugee Medical Assistance Indicator' => 'N',
          'Refugee Medical Assistance Ineligibility Reason' => 112,
          'APTC Referral Indicator' => 'Y'
          # "APTC Referral Ineligibility Reason" => ?
        }
      },
      {
        test_name: 'Is Not Medicaid Resident',
        inputs: {
          'Refugee Status' => 'Y',
          'Refugee Medical Assistance Start Date' => 2.months.ago,
          'Medicaid Residency Indicator' => 'N',
          'Calculated Income' => 1000,
          'FPL' => 20
        },
        configs: {
          'State Offers Refugee Medical Assistance' => 'Y',
          'Refugee Medical Assistance Income Requirement' => 'N',
          'Refugee Medical Assistance Threshold' => { 'percentage' => 'Y', 'method' => 'standard', 'threshold' => 100 }
        },
        expected_outputs: {
          'Applicant Refugee Medical Assistance Indicator' => 'N',
          'Refugee Medical Assistance Ineligibility Reason' => 309,
          'APTC Referral Indicator' => 'Y'
        }
      },
      {
        test_name: 'No Refugee Assistance Income Requirement',
        inputs: {
          'Refugee Status' => 'Y',
          'Refugee Medical Assistance Start Date' => 2.months.ago,
          'Medicaid Residency Indicator' => 'Y',
          'Calculated Income' => 1000,
          'FPL' => 20
        },
        configs: {
          'State Offers Refugee Medical Assistance' => 'Y',
          'Refugee Medical Assistance Income Requirement' => 'N',
          'Refugee Medical Assistance Threshold' => { 'percentage' => 'Y', 'method' => 'standard', 'threshold' => 100 }
        },
        expected_outputs: {
          'Applicant Refugee Medical Assistance Indicator' => 'Y',
          'Refugee Medical Assistance Ineligibility Reason' => 999,
          'APTC Referral Indicator' => 'N',
          'APTC Referral Ineligibility Reason' => 407
        }
      },
      {
        test_name: 'Refugee Assistance Income Requirement, Calculated Income Below Threshold',
        inputs: {
          'Refugee Status' => 'Y',
          'Refugee Medical Assistance Start Date' => 2.months.ago,
          'Medicaid Residency Indicator' => 'Y',
          'Calculated Income' => 1000,
          'FPL' => 20_000
        },
        configs: {
          'State Offers Refugee Medical Assistance' => 'Y',
          'Refugee Medical Assistance Income Requirement' => 'Y',
          'Refugee Medical Assistance Threshold' => { 'percentage' => 'Y', 'method' => 'standard', 'threshold' => 100 }
        },
        expected_outputs: {
          'Applicant Refugee Medical Assistance Indicator' => 'Y',
          'Refugee Medical Assistance Ineligibility Reason' => 999,
          'APTC Referral Indicator' => 'N',
          'APTC Referral Ineligibility Reason' => 407
        }
      },
      {
        test_name: 'Fallback',
        inputs: {
          'Refugee Status' => 'Y',
          'Refugee Medical Assistance Start Date' => 2.months.ago,
          'Medicaid Residency Indicator' => 'Y',
          'Calculated Income' => 1000,
          'FPL' => 700
        },
        configs: {
          'State Offers Refugee Medical Assistance' => 'Y',
          'Refugee Medical Assistance Income Requirement' => 'Y',
          'Refugee Medical Assistance Threshold' => { 'percentage' => 'Y', 'method' => 'standard', 'threshold' => 100 }
        },
        expected_outputs: {
          'Applicant Refugee Medical Assistance Indicator' => 'N',
          'Refugee Medical Assistance Ineligibility Reason' => 373,
          'APTC Referral Indicator' => 'Y'
        }
      },
      {
        test_name: 'Bad Info - Inputs',
        inputs: {
          'FPL' => 0
        },
        configs: {
          'State Offers Refugee Medical Assistance' => 'N',
          'Refugee Medical Assistance Income Requirement' => 100,
          'Refugee Medical Assistance Threshold' => 100
        },
        expected_outputs: {
        }
      },
      {
        test_name: 'Bad Info - Configs',
        inputs: {
          'Refugee Status' => 'N',
          'Refugee Medical Assistance Start Date' => Time.now.yesterday,
          'Medicaid Residency Indicator' => 'N',
          'Calculated Income' => 0,
          'FPL' => 10
        },
        configs: {
          'Refugee Medical Assistance Threshold' => 10
        },
        expected_outputs: {
        }
      }

    ]
  end
end

# NOTES
# Weird that run is in here, probably means there's an x-factor, coming back to this later -CF 7/7/2015
