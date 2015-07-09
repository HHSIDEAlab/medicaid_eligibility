##### GENERATED AT 2015-07-06 13:05:54 -0400 ######
class EmergencyMedicaidFixture < MagiFixture
  attr_accessor :magi, :test_sets

  def initialize
    super
    @magi = 'EmergencyMedicaid'
    @test_sets = [
      {
        test_name: "Determine Medicaid Eligbility - Regular Medicaid",
        inputs: {
          "Medicaid Residency Indicator" => "Y",
          "Applicant Medicaid Citizen Or Immigrant Indicator" => "Y",
          "Applicant Income Medicaid Eligible Indicator" => "Y",
          "Applicant Former Foster Care Category Indicator" => "Y"
        },
        configs: {
          # none
        },
        expected_outputs: {
          "APTC Referral Indicator" => "N",
          "APTC Referral Ineligibility Reason" => 406,
          "Prelim APTC Referral Indicator" => "N",
          "Applicant Medicaid Indicator" => "Y",
          "Medicaid Ineligibility Reason" => 999
        }
      },
      {
        test_name: "Determine Medicaid Eligbility - Emergency Medicaid",
        inputs: {
          "Medicaid Residency Indicator" => "Y",
          "Applicant Medicaid Citizen Or Immigrant Indicator" => "N",
          "Applicant Income Medicaid Eligible Indicator" => "Y",
          "Applicant Former Foster Care Category Indicator" => "Y"
        },
        configs: {
          # none
        },
        expected_outputs: {
          "APTC Referral Indicator" => "Y",
          "Applicant Emergency Medicaid Indicator" => "Y",
          "Emergency Medicaid Ineligibility Reason" => 999
        }
      },
      {
        test_name: "Determine Medicaid Eligbility - Fallback 1",
        inputs: {
          "Medicaid Residency Indicator" => "N",
          "Applicant Medicaid Citizen Or Immigrant Indicator" => "N",
          "Applicant Income Medicaid Eligible Indicator" => "Y",
          "Applicant Former Foster Care Category Indicator" => "Y"
        },
        configs: {
          # none
        },
        expected_outputs: {
          "Applicant Emergency Medicaid Indicator" => "N",
          "Emergency Medicaid Ineligibility Reason" => 109
        }
      },
      {
        test_name: "Determine Medicaid Eligbility - Fallback 2",
        inputs: {
          "Medicaid Residency Indicator" => "Y",
          "Applicant Medicaid Citizen Or Immigrant Indicator" => "N",
          "Applicant Income Medicaid Eligible Indicator" => "N",
          "Applicant Former Foster Care Category Indicator" => "Y"
        },
        configs: {
          # none
        },
        expected_outputs: {
          "Applicant Emergency Medicaid Indicator" => "N",
          "Emergency Medicaid Ineligibility Reason" => 109
        }
      },
      {
        test_name: "Bad Info - Inputs",
        inputs: {
          "Applicant Former Foster Care Category Indicator" => "N"
        },
        configs: {
          # none
        },
        expected_outputs: {
        }
      }
    ]
  end
end
