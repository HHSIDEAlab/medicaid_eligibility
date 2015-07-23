##### GENERATED AT 2015-07-07 11:34:20 -0400 ######
class PreliminaryMedicaidFixture < MagiFixture
  attr_accessor :magi, :test_sets

  def initialize
    super
    @magi = 'PreliminaryMedicaid'
    @test_sets = [
      {
        test_name: "Prelim Medicaid - Eligible for Medicaid",
        inputs: {
          "Medicaid Residency Indicator" => "Y",
          "Applicant Medicaid Citizen Or Immigrant Indicator" => "Y",
          "Applicant Income Medicaid Eligible Indicator" => "Y"
        },
        configs: {
          # none
        },
        expected_outputs: {
          "Applicant Medicaid Prelim Indicator" => "Y",
          "Medicaid Prelim Ineligibility Reason" => 999
        }
      },
      {
        test_name: "Prelim Medicaid - Not Eligible for Medicaid Scenario 1",
        inputs: {
          "Medicaid Residency Indicator" => "N",
          "Applicant Medicaid Citizen Or Immigrant Indicator" => "Y",
          "Applicant Income Medicaid Eligible Indicator" => "Y"
        },
        configs: {
          # none
        },
        expected_outputs: {
          "Applicant Medicaid Prelim Indicator" => "N",
          "Medicaid Prelim Ineligibility Reason" => 106
        }
      },
      {
        test_name: "Prelim Medicaid - Not Eligible for Medicaid Scenario 2",
        inputs: {
          "Medicaid Residency Indicator" => "N",
          "Applicant Medicaid Citizen Or Immigrant Indicator" => "Y",
          "Applicant Income Medicaid Eligible Indicator" => "N"
        },
        configs: {
          # none
        },
        expected_outputs: {
          "Applicant Medicaid Prelim Indicator" => "N",
          "Medicaid Prelim Ineligibility Reason" => 106
        }
      },
      {
        test_name: "Prelim Medicaid - Emergency Medicaid",
        inputs: {
          "Medicaid Residency Indicator" => "Y",
          "Applicant Medicaid Citizen Or Immigrant Indicator" => "N",
          "Applicant Income Medicaid Eligible Indicator" => "Y"
        },
        configs: {
          # none
        },
        expected_outputs: {
          "Applicant Medicaid Prelim Indicator" => "N",
          "Medicaid Prelim Ineligibility Reason" => 106,
          "Applicant Emergency Medicaid Indicator" => "Y", 
          "Emergency Medicaid Ineligibility Reason" => 999
        }
      },
      {
        test_name: "Bad Info - Inputs",
        inputs: {
          "Applicant Income Medicaid Eligible Indicator" => "Y"
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
