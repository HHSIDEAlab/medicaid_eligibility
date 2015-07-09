#### GENERATED AT 2015-07-06 14:34:35 -0400 ######
class FormerFosterCareFixture < MagiFixture
  attr_accessor :magi, :test_sets

  def initialize
    super
    @magi = 'FormerFosterCare'
    @test_sets = [
      {
        test_name: "Foster Care Eligibility - Not Former Foster Care",
        inputs: {
          "Medicaid Residency Indicator" => "Y",
          "Applicant Medicaid Citizen Or Immigrant Indicator" => "Y",
          "Applicant Age" => 24,
          "Former Foster Care" => "N",
          "Age Left Foster Care" => 21,
          "Had Medicaid During Foster Care" => "Y",
          "Foster Care State" => "TN",
          "State" => "TN"
        },
        configs: {
          "Foster Care Age Threshold" => 18,
          "In-State Foster Care Required" => "Y"
        },
        expected_outputs: {
          "Applicant Former Foster Care Category Indicator" => "N",
          "Former Foster Care Category Ineligibility Reason" => 400
        }
      },
      {
        test_name: "Foster Care Eligibility - Not Medicaid Resident",
        inputs: {
          "Medicaid Residency Indicator" => "N",
          "Applicant Medicaid Citizen Or Immigrant Indicator" => "Y",
          "Applicant Age" => 24,
          "Former Foster Care" => "Y",
          "Age Left Foster Care" => 21,
          "Had Medicaid During Foster Care" => "Y",
          "Foster Care State" => "TN",
          "State" => "TN"
        },
        configs: {
          "Foster Care Age Threshold" => 18,
          "In-State Foster Care Required" => "Y"
        },
        expected_outputs: {
          "Applicant Former Foster Care Category Indicator" => "N",
          "Former Foster Care Category Ineligibility Reason" => 101
        }
      },
      {
        test_name: "Foster Care Eligibility - Not Medicaid Citizen or Immigrant",
        inputs: {
          "Medicaid Residency Indicator" => "Y",
          "Applicant Medicaid Citizen Or Immigrant Indicator" => "N",
          "Applicant Age" => 24,
          "Former Foster Care" => "Y",
          "Age Left Foster Care" => 21,
          "Had Medicaid During Foster Care" => "Y",
          "Foster Care State" => "TN",
          "State" => "TN"
        },
        configs: {
          "Foster Care Age Threshold" => 18,
          "In-State Foster Care Required" => "Y"
        },
        expected_outputs: {
          "Applicant Former Foster Care Category Indicator" => "N",
          "Former Foster Care Category Ineligibility Reason" => 101
        }
      },
      {
        test_name: "Foster Care Eligibility - Aged Out of Coverage",
        inputs: {
          "Medicaid Residency Indicator" => "Y",
          "Applicant Medicaid Citizen Or Immigrant Indicator" => "Y",
          "Applicant Age" => 29,
          "Former Foster Care" => "Y",
          "Age Left Foster Care" => 21,
          "Had Medicaid During Foster Care" => "Y",
          "Foster Care State" => "TN",
          "State" => "TN"
        },
        configs: {
          "Foster Care Age Threshold" => 18,
          "In-State Foster Care Required" => "Y"
        },
        expected_outputs: {
          "Applicant Former Foster Care Category Indicator" => "N",
          "Former Foster Care Category Ineligibility Reason" => 126
        }
      },
      {
        test_name: "Foster Care Eligibility - Different State Foster Care",
        inputs: {
          "Medicaid Residency Indicator" => "Y",
          "Applicant Medicaid Citizen Or Immigrant Indicator" => "Y",
          "Applicant Age" => 22,
          "Former Foster Care" => "Y",
          "Age Left Foster Care" => 21,
          "Had Medicaid During Foster Care" => "Y",
          "Foster Care State" => "TN",
          "State" => "MI"
        },
        configs: {
          "Foster Care Age Threshold" => 18,
          "In-State Foster Care Required" => "Y"
        },
        expected_outputs: {
          "Applicant Former Foster Care Category Indicator" => "N",
          "Former Foster Care Category Ineligibility Reason" => 102
        }
      },
      {
        test_name: "Foster Care Eligibility - Left Care Before Age Threshold",
        inputs: {
          "Medicaid Residency Indicator" => "Y",
          "Applicant Medicaid Citizen Or Immigrant Indicator" => "Y",
          "Applicant Age" => 22,
          "Former Foster Care" => "Y",
          "Age Left Foster Care" => 15,
          "Had Medicaid During Foster Care" => "Y",
          "Foster Care State" => "TN",
          "State" => "TN"
        },
        configs: {
          "Foster Care Age Threshold" => 18,
          "In-State Foster Care Required" => "Y"
        },
        expected_outputs: {
          "Applicant Former Foster Care Category Indicator" => "N",
          "Former Foster Care Category Ineligibility Reason" => 125
        }
      },
      {
        test_name: "Foster Care Eligibility - Didn't Have Medicaid During Foster Care",
        inputs: {
          "Medicaid Residency Indicator" => "Y",
          "Applicant Medicaid Citizen Or Immigrant Indicator" => "Y",
          "Applicant Age" => 22,
          "Former Foster Care" => "Y",
          "Age Left Foster Care" => 19,
          "Had Medicaid During Foster Care" => "N",
          "Foster Care State" => "TN",
          "State" => "TN"
        },
        configs: {
          "Foster Care Age Threshold" => 18,
          "In-State Foster Care Required" => "Y"
        },
        expected_outputs: {
          "Applicant Former Foster Care Category Indicator" => "N",
          "Former Foster Care Category Ineligibility Reason" => 103
        }
      },
      {
        test_name: "Foster Care Eligibility - Fallback",
        inputs: {
          "Medicaid Residency Indicator" => "Y",
          "Applicant Medicaid Citizen Or Immigrant Indicator" => "Y",
          "Applicant Age" => 22,
          "Former Foster Care" => "Y",
          "Age Left Foster Care" => 19,
          "Had Medicaid During Foster Care" => "Y",
          "Foster Care State" => "TN",
          "State" => "TN"
        },
        configs: {
          "Foster Care Age Threshold" => 18,
          "In-State Foster Care Required" => "Y"
        },
        expected_outputs: {
          "Applicant Former Foster Care Category Indicator" => "Y",
          "Former Foster Care Category Ineligibility Reason" => 999,
          "Applicant Medicaid Prelim Indicator" => "Y",
          "Medicaid Prelim Ineligibility Reason" => 999,
          "Applicant CHIP Prelim Indicator" => "N",
          "CHIP Prelim Ineligibility Reason" => 380
        }
      },
      {
        test_name: "Bad Info - Inputs",
        inputs: {
          "State" => "TN"
        },
        configs: {
          "Foster Care Age Threshold" => 18,
          "In-State Foster Care Required" => "Y"
        },
        expected_outputs: {
        }
      },
      {
        test_name: "Bad Info - Configs",
        inputs: {
          "Medicaid Residency Indicator" => "Y",
          "Applicant Medicaid Citizen Or Immigrant Indicator" => "Y",
          "Applicant Age" => 22,
          "Former Foster Care" => "Y",
          "Age Left Foster Care" => 19,
          "Had Medicaid During Foster Care" => "N",
          "Foster Care State" => "TN",
          "State" => "TN"
        },
        configs: {
          "In-State Foster Care Required" => "Y"
        },
        expected_outputs: {
        }
      }
    ]
  end
end
