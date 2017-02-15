##### GENERATED AT 2015-07-07 12:19:08 -0400 ######
class ResidencyFixture < MagiFixture
  attr_accessor :magi, :test_sets

  def initialize
    super
    @magi = 'Residency'
    @test_sets = [
      {
        test_name: 'Lives in State, Denies Residency to Students',
        inputs: {
          'Lives In State' => 'Y',
          'No Fixed Address' => 'N',
          'Temporarily Out of State' => 'N',
          'Medicaid Household' => MedicaidHousehold.new('something', [Person.new('guy', '', '')], '', '', 1),
          'Claimed as Dependent by Person Not on Application' => 'Y',
          'Claimer Is Out of State' => 'Y',
          'Student Indicator' => 'Y',
          'Person ID' => 'guy',
          'Tax Returns' => []
        },
        configs: {
          'Option Deny Residency to Temporary Resident Students' => 'Y'
        },
        expected_outputs: {
          'Medicaid Residency Indicator' => 'N',
          'Medicaid Residency Indicator Ineligibility Reason' => 403
        }
      },
      {
        test_name: 'Lives in State, Cool With Students',
        inputs: {
          'Lives In State' => 'Y',
          'No Fixed Address' => 'N',
          'Temporarily Out of State' => 'N',
          'Medicaid Household' => MedicaidHousehold.new('something', [Person.new('guy', '', '')], '', '', 1),
          'Claimed as Dependent by Person Not on Application' => 'Y',
          'Claimer Is Out of State' => 'Y',
          'Student Indicator' => 'Y',
          'Person ID' => 'guy',
          'Tax Returns' => []
        },
        configs: {
          'Option Deny Residency to Temporary Resident Students' => 'N'
        },
        expected_outputs: {
          'Medicaid Residency Indicator' => 'Y',
          'Medicaid Residency Indicator Ineligibility Reason' => 999
        }
      },
      {
        test_name: 'Does Not Live in State',
        inputs: {
          'Lives In State' => 'N',
          'No Fixed Address' => 'N',
          'Temporarily Out of State' => 'N',
          'Medicaid Household' => MedicaidHousehold.new('something', [Person.new('guy', '', '')], '', '', 1),
          'Claimed as Dependent by Person Not on Application' => 'Y',
          'Claimer Is Out of State' => 'Y',
          'Student Indicator' => 'Y',
          'Person ID' => 'guy',
          'Tax Returns' => []
        },
        configs: {
          'Option Deny Residency to Temporary Resident Students' => 'N'
        },
        expected_outputs: {
          'Medicaid Residency Indicator' => 'N',
          'Medicaid Residency Indicator Ineligibility Reason' => 404
        }
      },
      {
        test_name: 'Bad Info - Inputs',
        inputs: {
          'Tax Returns' => []
        },
        configs: {
          'Option Deny Residency to Temporary Resident Students' => 'N'
        },
        expected_outputs: {
        }
      },
      {
        test_name: 'Bad Info - Configs',
        inputs: {
          'Lives In State' => 'Y',
          'No Fixed Address' => 'N',
          'Temporarily Out of State' => 'N',
          'Medicaid Household' => 'N',
          'Claimed as Dependent by Person Not on Application' => 'N',
          'Claimer Is Out of State' => 'N',
          'Student Indicator' => 'N',
          'Person ID' => 'N',
          'Tax Returns' => []
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
