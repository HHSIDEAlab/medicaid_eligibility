##### GENERATED AT 2015-07-06 17:08:30 -0400 ######
class IncomeFixture < MagiFixture
  attr_accessor :magi, :test_sets

  def initialize
    super
    @magi = 'Income'
    @test_sets = [
      # ensure that medicaid threshold is making its way down properly
      {
        test_name: 'Income - Set Percentage Used',
        inputs: {
          'Application Year' => 2015,
          'Applicant Adult Group Category Indicator' => 'Y',
          'Applicant Pregnancy Category Indicator' => 'N',
          'Applicant Parent Caretaker Category Indicator' => 'N',
          'Applicant Child Category Indicator' => 'N',
          'Applicant Optional Targeted Low Income Child Indicator' => 'N',
          'Applicant CHIP Targeted Low Income Child Indicator' => 'N',
          'Calculated Income' => 0,
          'Medicaid Household' => MedicaidHousehold.new('house', '', '', '', 3),
          'Applicant Age' => 20
        },
        configs: {
          'FPL' => { '2015' => { 'Base FPL' => 11_770, 'FPL Per Person' => 4160 } },
          'Option CHIP Pregnancy Category' => 'N',
          'Medicaid Thresholds' => { 'Adult Group Category' => { 'percentage' => 'Y', 'method' => 'standard', 'threshold' => 100 } },
          'CHIP Thresholds' => { 'Adult Group Category' => { 'percentage' => 'Y', 'method' => 'standard', 'threshold' => 133 } }
        },
        expected_outputs: {
          'Percentage for Medicaid Category Used' => { 'percentage' => 'Y', 'method' => 'standard', 'threshold' => 100 },
          'Percentage for CHIP Category Used' => { 'percentage' => 'Y', 'method' => 'standard', 'threshold' => 133 }
        }
      },
      {
        test_name: 'Income - Set FPL Percentage',
        inputs: {
          'Application Year' => 2015,
          'Applicant Adult Group Category Indicator' => 'Y',
          'Applicant Pregnancy Category Indicator' => 'Y',
          'Applicant Parent Caretaker Category Indicator' => 'N',
          'Applicant Child Category Indicator' => 'N',
          'Applicant Optional Targeted Low Income Child Indicator' => 'N',
          'Applicant CHIP Targeted Low Income Child Indicator' => 'N',
          'Calculated Income' => 0,
          'Medicaid Household' => MedicaidHousehold.new('house', '', '', '', 3),
          'Applicant Age' => 20
        },
        configs: {
          'FPL' => { '2015' => { 'Base FPL' => 11_770, 'FPL Per Person' => 4160 } },
          'Option CHIP Pregnancy Category' => 'N',
          'Medicaid Thresholds' => { 'Adult Group Category' => { 'percentage' => 'Y', 'method' => 'standard', 'threshold' => 100 } },
          'CHIP Thresholds' => { 'Pregnancy Category' => { 'percentage' => 'Y', 'method' => 'standard', 'threshold' => 133 } }
        },
        expected_outputs: {
          'FPL' => 20_090,
          'FPL * Percentage Medicaid' => 21_094.5,
          'FPL * Percentage CHIP' => 27_724.2,
          'Category Used to Calculate Medicaid Income' => 'Adult Group Category',
          'Category Used to Calculate CHIP Income' => 'Pregnancy Category'
        }
      },
      {
        test_name: 'Income - Set Calculated Income as Percentage of FPL',
        inputs: {
          'Application Year' => 2015,
          'Applicant Adult Group Category Indicator' => 'Y',
          'Applicant Pregnancy Category Indicator' => 'Y',
          'Applicant Parent Caretaker Category Indicator' => 'N',
          'Applicant Child Category Indicator' => 'N',
          'Applicant Optional Targeted Low Income Child Indicator' => 'N',
          'Applicant CHIP Targeted Low Income Child Indicator' => 'N',
          'Calculated Income' => 24_042,
          'Medicaid Household' => MedicaidHousehold.new('house', '', '', '', 3),
          'Applicant Age' => 20
        },
        configs: {
          'FPL' => { '2015' => { 'Base FPL' => 11_770, 'FPL Per Person' => 4160 } },
          'Option CHIP Pregnancy Category' => 'N',
          'Medicaid Thresholds' => { 'Adult Group Category' => { 'percentage' => 'Y', 'method' => 'standard', 'threshold' => 100 } },
          'CHIP Thresholds' => { 'Pregnancy Category' => { 'percentage' => 'Y', 'method' => 'standard', 'threshold' => 133 } }
        },
        expected_outputs: {
          'FPL' => 20_090,
          'Calculated Income as Percentage of FPL' => 119
        }
      },
      {
        test_name: 'Income - Calculate 2016 FPL Correctly',
        inputs: {
          'Application Year' => 2016,
          'Applicant Adult Group Category Indicator' => 'Y',
          'Applicant Pregnancy Category Indicator' => 'Y',
          'Applicant Parent Caretaker Category Indicator' => 'N',
          'Applicant Child Category Indicator' => 'N',
          'Applicant Optional Targeted Low Income Child Indicator' => 'N',
          'Applicant CHIP Targeted Low Income Child Indicator' => 'N',
          'Calculated Income' => 25_000,
          'Medicaid Household' => MedicaidHousehold.new('house', '', '', '', 3),
          'Applicant Age' => 20
        },
        configs: {
          'FPL' => { '2016' => { 'FPL By Age' => [11_880, 16_020, 20_160, 24_300, 28_440, 32_580, 36_730, 40_890], 'FPL Per Extra Person' => 4160 } },
          'Option CHIP Pregnancy Category' => 'N',
          'Medicaid Thresholds' => { 'Adult Group Category' => { 'percentage' => 'Y', 'method' => 'standard', 'threshold' => 100 } },
          'CHIP Thresholds' => { 'Pregnancy Category' => { 'percentage' => 'Y', 'method' => 'standard', 'threshold' => 133 } }
        },
        expected_outputs: {
          'FPL' => 20_160,
          'Calculated Income as Percentage of FPL' => 124
        }
      },

      # determine income eligibility rule - Medicaid
      {
        test_name: 'Determine Medicaid Income Eligibility - Max Eligible Medicaid None',
        inputs: {
          'Application Year' => 2015,
          'Applicant Adult Group Category Indicator' => 'N',
          'Applicant Pregnancy Category Indicator' => 'N',
          'Applicant Parent Caretaker Category Indicator' => 'N',
          'Applicant Child Category Indicator' => 'N',
          'Applicant Optional Targeted Low Income Child Indicator' => 'N',
          'Applicant CHIP Targeted Low Income Child Indicator' => 'N',
          'Calculated Income' => 0,
          'Medicaid Household' => MedicaidHousehold.new('house', '', '', '', 3),
          'Applicant Age' => 20
        },
        configs: {
          'FPL' => { '2015' => { 'Base FPL' => 11_770, 'FPL Per Person' => 4160 } },
          'Option CHIP Pregnancy Category' => 'N',
          'Medicaid Thresholds' => { 'Adult Group Category' => { 'percentage' => 'Y', 'method' => 'standard', 'threshold' => 100 } },
          'CHIP Thresholds' => { 'Pregnancy Category' => { 'percentage' => 'Y', 'method' => 'standard', 'threshold' => 133 } }
        },
        expected_outputs: {
          'Applicant Income Medicaid Eligible Indicator' => 'N',
          'Income Medicaid Eligible Ineligibility Reason' => 401
        }
      },
      {
        test_name: 'Determine Medicaid Income Eligibility - Calculated Income Greater Than Max Eligible',
        inputs: {
          'Application Year' => 2015,
          'Applicant Adult Group Category Indicator' => 'Y',
          'Applicant Pregnancy Category Indicator' => 'N',
          'Applicant Parent Caretaker Category Indicator' => 'N',
          'Applicant Child Category Indicator' => 'N',
          'Applicant Optional Targeted Low Income Child Indicator' => 'N',
          'Applicant CHIP Targeted Low Income Child Indicator' => 'N',
          'Calculated Income' => 22_090, # slightly higher than fpl * percentage medicaid from above
          'Medicaid Household' => MedicaidHousehold.new('house', '', '', '', 3),
          'Applicant Age' => 20
        },
        configs: {
          'FPL' => { '2015' => { 'Base FPL' => 11_770, 'FPL Per Person' => 4160 } },
          'Option CHIP Pregnancy Category' => 'N',
          'Medicaid Thresholds' => { 'Adult Group Category' => { 'percentage' => 'Y', 'method' => 'standard', 'threshold' => 100 } },
          'CHIP Thresholds' => { 'Pregnancy Category' => { 'percentage' => 'Y', 'method' => 'standard', 'threshold' => 133 } }
        },
        expected_outputs: {
          'Applicant Income Medicaid Eligible Indicator' => 'N',
          'Income Medicaid Eligible Ineligibility Reason' => 402
        }
      },
      {
        test_name: 'Determine Medicaid Income Eligibility - Calculated Income Lower Than Max Eligible',
        inputs: {
          'Application Year' => 2015,
          'Applicant Adult Group Category Indicator' => 'Y',
          'Applicant Pregnancy Category Indicator' => 'N',
          'Applicant Parent Caretaker Category Indicator' => 'N',
          'Applicant Child Category Indicator' => 'N',
          'Applicant Optional Targeted Low Income Child Indicator' => 'N',
          'Applicant CHIP Targeted Low Income Child Indicator' => 'N',
          'Calculated Income' => 20_000,
          'Medicaid Household' => MedicaidHousehold.new('house', '', '', '', 3),
          'Applicant Age' => 20
        },
        configs: {
          'FPL' => { '2015' => { 'Base FPL' => 11_770, 'FPL Per Person' => 4160 } },
          'Option CHIP Pregnancy Category' => 'N',
          'Medicaid Thresholds' => { 'Adult Group Category' => { 'percentage' => 'Y', 'method' => 'standard', 'threshold' => 100 } },
          'CHIP Thresholds' => { 'Pregnancy Category' => { 'percentage' => 'Y', 'method' => 'standard', 'threshold' => 133 } }
        },
        expected_outputs: {
          'Applicant Income Medicaid Eligible Indicator' => 'Y',
          'Income Medicaid Eligible Ineligibility Reason' => 999
        }
      },

      # determine income eligibility rule - CHIP - 27724.2
      {
        test_name: 'Determine CHIP Income Eligibility - No CHIP Eligibility',
        inputs: {
          'Application Year' => 2015,
          'Applicant Adult Group Category Indicator' => 'N',
          'Applicant Pregnancy Category Indicator' => 'N',
          'Applicant Parent Caretaker Category Indicator' => 'N',
          'Applicant Child Category Indicator' => 'N',
          'Applicant Optional Targeted Low Income Child Indicator' => 'N',
          'Applicant CHIP Targeted Low Income Child Indicator' => 'N',
          'Calculated Income' => 20_000,
          'Medicaid Household' => MedicaidHousehold.new('house', '', '', '', 3),
          'Applicant Age' => 20
        },
        configs: {
          'FPL' => { '2015' => { 'Base FPL' => 11_770, 'FPL Per Person' => 4160 } },
          'Option CHIP Pregnancy Category' => 'Y',
          'Medicaid Thresholds' => { 'Adult Group Category' => { 'percentage' => 'Y', 'method' => 'standard', 'threshold' => 100 } },
          'CHIP Thresholds' => { 'Pregnancy Category' => { 'percentage' => 'Y', 'method' => 'standard', 'threshold' => 133 } }
        },
        expected_outputs: {
          'Applicant Income CHIP Eligible Indicator' => 'N',
          'Income CHIP Eligible Ineligibility Reason' => 401
        }
      },
      {
        test_name: 'Determine CHIP Income Eligibility - Calculated Income Greater than Max Eligible Income',
        inputs: {
          'Application Year' => 2015,
          'Applicant Adult Group Category Indicator' => 'Y',
          'Applicant Pregnancy Category Indicator' => 'Y',
          'Applicant Parent Caretaker Category Indicator' => 'N',
          'Applicant Child Category Indicator' => 'N',
          'Applicant Optional Targeted Low Income Child Indicator' => 'N',
          'Applicant CHIP Targeted Low Income Child Indicator' => 'N',
          'Calculated Income' => 30_000,
          'Medicaid Household' => MedicaidHousehold.new('house', '', '', '', 3),
          'Applicant Age' => 20
        },
        configs: {
          'FPL' => { '2015' => { 'Base FPL' => 11_770, 'FPL Per Person' => 4160 } },
          'Option CHIP Pregnancy Category' => 'Y',
          'Medicaid Thresholds' => { 'Adult Group Category' => { 'percentage' => 'Y', 'method' => 'standard', 'threshold' => 100 } },
          'CHIP Thresholds' => { 'Pregnancy Category' => { 'percentage' => 'Y', 'method' => 'standard', 'threshold' => 133 } }
        },
        expected_outputs: {
          'Applicant Income CHIP Eligible Indicator' => 'N',
          'Income CHIP Eligible Ineligibility Reason' => 402
        }
      },
      {
        test_name: 'Determine CHIP Income Eligibility - Calculated Income Lower than Max Eligible Income',
        inputs: {
          'Application Year' => 2015,
          'Applicant Adult Group Category Indicator' => 'Y',
          'Applicant Pregnancy Category Indicator' => 'Y',
          'Applicant Parent Caretaker Category Indicator' => 'N',
          'Applicant Child Category Indicator' => 'N',
          'Applicant Optional Targeted Low Income Child Indicator' => 'Y',
          'Applicant CHIP Targeted Low Income Child Indicator' => 'Y',
          'Calculated Income' => 20_000,
          'Medicaid Household' => MedicaidHousehold.new('house', '', '', '', 3),
          'Applicant Age' => 20
        },
        configs: {
          'FPL' => { '2015' => { 'Base FPL' => 11_770, 'FPL Per Person' => 4160 } },
          'Option CHIP Pregnancy Category' => 'Y',
          'Medicaid Thresholds' => { 'Adult Group Category' => { 'percentage' => 'Y', 'method' => 'standard', 'threshold' => 100 } },
          'CHIP Thresholds' => { 'Pregnancy Category' => { 'percentage' => 'Y', 'method' => 'standard', 'threshold' => 133 } }
        },
        expected_outputs: {
          'Applicant Income CHIP Eligible Indicator' => 'Y',
          'Income CHIP Eligible Ineligibility Reason' => 999
        }
      },

      {
        test_name: 'Bad Info - Inputs',
        inputs: {
          'Applicant Age' => 20
        },
        configs: {
          'FPL' => { '2015' => { 'Base FPL' => 11_770, 'FPL Per Person' => 4160 } },
          'Option CHIP Pregnancy Category' => 'N',
          'Medicaid Thresholds' => { 'Adult Group Category' => { 'percentage' => 'Y', 'method' => 'standard', 'threshold' => 100 } },
          'CHIP Thresholds' => { 'Pregnancy Category' => { 'percentage' => 'Y', 'method' => 'standard', 'threshold' => 133 } }
        },
        expected_outputs: {
        }
      },
      {
        test_name: 'Bad Info - Configs',
        inputs: {
          'Application Year' => 2015,
          'Applicant Adult Group Category Indicator' => 'Y',
          'Applicant Pregnancy Category Indicator' => 'N',
          'Applicant Parent Caretaker Category Indicator' => 'N',
          'Applicant Child Category Indicator' => 'N',
          'Applicant Optional Targeted Low Income Child Indicator' => 'N',
          'Applicant CHIP Targeted Low Income Child Indicator' => 'N',
          'Calculated Income' => 0,
          'Medicaid Household' => MedicaidHousehold.new('house', '', '', '', 3),
          'Applicant Age' => 20
        },
        configs: {
          'CHIP Thresholds' => { 'Pregnancy Category' => { 'percentage' => 'Y', 'method' => 'standard', 'threshold' => 133 } }
        },
        expected_outputs: {
        }
      }
    ]
  end
end
