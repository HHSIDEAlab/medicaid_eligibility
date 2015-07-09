##### GENERATED AT 2015-07-07 12:19:08 -0400 ######
class ResidencyFixture < MagiFixture
  attr_accessor :magi, :test_sets

  def initialize
    super
    @magi = 'Residency'
    @test_sets = [
      # {
      #   test_name: "FILL_IN_WITH_TEST_NAME",
      #   inputs: {
      #     "Lives In State" => "Y",
      #     "No Fixed Address" => "N",
      #     "Temporarily Out of State" => "N",
      #     "Medicaid Household" => "N",
      #     "Claimed as Dependent by Person Not on Application" => "N",
      #     "Claimer Is Out of State" => "N",
      #     "Student Indicator" => "N",
      #     "Person ID" => "N",
      #     "Tax Returns" => []
      #   },
      #   configs: {
      #     "Option Deny Residency to Temporary Resident Students" => ?
      #   },
      #   expected_outputs: {
      #     "Medicaid Residency Indicator" => ?,
      #     "Medicaid Residency Indicator Determination Date" => ?,
      #     "Medicaid Residency Indicator Ineligibility Reason" => ?
      #   }
      # }

      {
        test_name: "Bad Info - Inputs",
        inputs: {
          "Tax Returns" => []
        },
        configs: {
          "Option Deny Residency to Temporary Resident Students" => "N"
        },
        expected_outputs: {
        }
      },
      {
        test_name: "Bad Info - Configs",
        inputs: {
          "Lives In State" => "Y",
          "No Fixed Address" => "N",
          "Temporarily Out of State" => "N",
          "Medicaid Household" => "N",
          "Claimed as Dependent by Person Not on Application" => "N",
          "Claimer Is Out of State" => "N",
          "Student Indicator" => "N",
          "Person ID" => "N",
          "Tax Returns" => []
        },
        configs: {
        },
        expected_outputs: {
        }
      }
    ]
  end
end

# tax return object, coming back later

# def initialize(filers, dependents, income) tax return