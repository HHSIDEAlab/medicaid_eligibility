##### GENERATED AT 2015-07-07 11:53:31 -0400 ######
class PublicEmployeesBenefitsFixture < MagiFixture
  attr_accessor :magi, :test_sets

  def initialize
    super
    @magi = 'PublicEmployeesBenefits'
    @test_sets = [
      {
        test_name: "Public Employee - No State Benefit Eligibility Scenario 1",
        inputs: {
          "State Health Benefits Through Public Employee" => "N",
          "Calculated Income" => 0,
          "FPL" => 10,
          "Applicant Medicaid Prelim Indicator" => "N"
        },
        configs: {
          "CHIP for State Health Benefits" => "01",
          "State Health Benefits FPL Standard" => 10
        },
        expected_outputs: {
          "Applicant State Health Benefits CHIP Indicator" => "X",
          "State Health Benefits CHIP Ineligibility Reason" => 555
        }
      },
      {
        test_name: "Public Employee - No State Benefit Eligibility Scenario 2",
        inputs: {
          "State Health Benefits Through Public Employee" => "Y",
          "Calculated Income" => 0,
          "FPL" => 10,
          "Applicant Medicaid Prelim Indicator" => "Y"
        },
        configs: {
          "CHIP for State Health Benefits" => "01",
          "State Health Benefits FPL Standard" => 10
        },
        expected_outputs: {
          "Applicant State Health Benefits CHIP Indicator" => "X",
          "State Health Benefits CHIP Ineligibility Reason" => 555
        }
      },
      {
        test_name: "Public Employee - CHIP 01",
        inputs: {
          "State Health Benefits Through Public Employee" => "Y",
          "Calculated Income" => 0,
          "FPL" => 10,
          "Applicant Medicaid Prelim Indicator" => "N"
        },
        configs: {
          "CHIP for State Health Benefits" => "01",
          "State Health Benefits FPL Standard" => 10
        },
        expected_outputs: {
          "Applicant State Health Benefits CHIP Indicator" => "N",
          "State Health Benefits CHIP Ineligibility Reason" => 155
        }
      },
      {
        test_name: "Public Employee - CHIP 02",
        inputs: {
          "State Health Benefits Through Public Employee" => "Y",
          "Calculated Income" => 0,
          "FPL" => 10,
          "Applicant Medicaid Prelim Indicator" => "N"
        },
        configs: {
          "CHIP for State Health Benefits" => "02",
          "State Health Benefits FPL Standard" => 10
        },
        expected_outputs: {
          "Applicant State Health Benefits CHIP Indicator" => "Y",
          "State Health Benefits CHIP Ineligibility Reason" => 999
        }
      },
      {
        test_name: "Public Employee - CHIP 03 - Income Under Line",
        inputs: {
          "State Health Benefits Through Public Employee" => "Y",
          "Calculated Income" => 0,
          "FPL" => 10,
          "Applicant Medicaid Prelim Indicator" => "N"
        },
        configs: {
          "CHIP for State Health Benefits" => "03",
          "State Health Benefits FPL Standard" => 10
        },
        expected_outputs: {
          "Applicant State Health Benefits CHIP Indicator" => "Y",
          "State Health Benefits CHIP Ineligibility Reason" => 999
        }
      },
      {
        test_name: "Public Employee - CHIP 03 - Income Over Line",
        inputs: {
          "State Health Benefits Through Public Employee" => "Y",
          "Calculated Income" => 10000000,
          "FPL" => 10,
          "Applicant Medicaid Prelim Indicator" => "N"
        },
        configs: {
          "CHIP for State Health Benefits" => "03",
          "State Health Benefits FPL Standard" => 10
        },
        expected_outputs: {
          "Applicant State Health Benefits CHIP Indicator" => "N",
          "State Health Benefits CHIP Ineligibility Reason" => 138
        }
      },
      {
        test_name: "Public Employee - CHIP 04",
        inputs: {
          "State Health Benefits Through Public Employee" => "Y",
          "Calculated Income" => 0,
          "FPL" => 10,
          "Applicant Medicaid Prelim Indicator" => "N"
        },
        configs: {
          "CHIP for State Health Benefits" => "04",
          "State Health Benefits FPL Standard" => 10
        },
        expected_outputs: {
          "Applicant State Health Benefits CHIP Indicator" => "Y",
          "State Health Benefits CHIP Ineligibility Reason" => 999
        }
      },
      {
        test_name: "Bad Info - Inputs",
        inputs: {
          "Applicant Medicaid Prelim Indicator" => "N"
        },
        configs: {
          "CHIP for State Health Benefits" => "04",
          "State Health Benefits FPL Standard" => 10
        },
        expected_outputs: {
        }
      },
      {
        test_name: "Bad Info - Configs",
        inputs: {
          "State Health Benefits Through Public Employee" => "Y",
          "Calculated Income" => 0,
          "FPL" => 10,
          "Applicant Medicaid Prelim Indicator" => "N"
        },
        configs: {
          "State Health Benefits FPL Standard" => 10
        },
        expected_outputs: {
          "Applicant State Health Benefits CHIP Indicator" => "Y",
          "State Health Benefits CHIP Ineligibility Reason" => 999
        }
      }
      # {
      #   test_name: "Public Employee - Invalid CHIP Value - Should raise error",
      #   inputs: {
      #     "State Health Benefits Through Public Employee" => "Y",
      #     "Calculated Income" => 0,
      #     "FPL" => 10,
      #     "Applicant Medicaid Prelim Indicator" => "N"
      #   },
      #   configs: {
      #     "CHIP for State Health Benefits" => "04",
      #     "State Health Benefits FPL Standard" => 10
      #   },
      #   expected_outputs: {
      #     "Applicant State Health Benefits CHIP Indicator" => "4",
      #     "State Health Benefits CHIP Ineligibility Reason" => 999
      #   }
      # }
    ]
  end
end



# NOTES
# Need to make a way to test the error raising here. Skipping for now. 
# Also it looks like config arrays aren't enforced in general? Initial test passed with "N" set for the chip config instead of 01. -CF 7/7/2015
