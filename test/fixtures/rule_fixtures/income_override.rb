##### GENERATED AT 2015-07-06 17:28:06 -0400 ######
class IncomeOverrideFixture < MagiFixture
  attr_accessor :magi, :test_sets

  def initialize
    super
    @magi = 'IncomeOverride'
    @test_sets = [
      {
        test_name: "Income Override - Income Greater Than 100 Perc of FPL",
        inputs: {
          "Applicant Title II Work Quarters Met Indicator" => "X",
          "Calculated Income" => 100,
          "FPL" => 10
        },
        configs: {
          # none
        },
        expected_outputs: {
          "Applicant Work Quarters Override Income Indicator" => "N",
          "Work Quarters Override Income Ineligibility Reason" => 340
        }
      },
      {
        test_name: "Income Override - Income Equal To FPL",
        inputs: {
          "Applicant Title II Work Quarters Met Indicator" => "X",
          "Calculated Income" => 10,
          "FPL" => 10
        },
        configs: {
          # none
        },
        expected_outputs: {
          "Applicant Work Quarters Override Income Indicator" => "N",
          "Work Quarters Override Income Ineligibility Reason" => 340
        }
      },
      {
        test_name: "Income Override - Income Less Than 100 Perc of FPL - Work Quarters Not Met",
        inputs: {
          "Applicant Title II Work Quarters Met Indicator" => "N",
          "Calculated Income" => 8,
          "FPL" => 10
        },
        configs: {
          # none
        },
        expected_outputs: {
          "Applicant Work Quarters Override Income Indicator" => "Y",
          "Work Quarters Override Income Ineligibility Reason" => 999,
          "Applicant Medicaid Indicator" => "N",
          "Medicaid Ineligibility Reason" => 339,
          "Applicant CHIP Indicator" => "N",
          "CHIP Ineligibility Reason" => 340,
          "APTC Referral Indicator" => "Y"
        }
      },
      {
        test_name: "Bad Info - Inputs",
        inputs: {
          "FPL" => 10
        },
        configs: {
          # none
        },
        expected_outputs: {
        }
      }
    ]

    # for work quarters indicator Y or X
    ["X","Y"].each do |ind|
      @test_sets << {
        test_name: "Income Override - Income Less Than 100 Perc of FPL - Work Quarters Met #{ind}",
        inputs: {
          "Applicant Title II Work Quarters Met Indicator" => "X",
          "Calculated Income" => 8,
          "FPL" => 10
        },
        configs: {
          # none
        },
        expected_outputs: {
          "Applicant Work Quarters Override Income Indicator" => "N",
          "Work Quarters Override Income Ineligibility Reason" => 338
        }
      }
    end
  end
end
