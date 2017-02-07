##### GENERATED AT 2015-07-07 12:06:44 -0400 ######
class QualifiedChildFixture < MagiFixture
  attr_accessor :magi, :test_sets

  def initialize
    super
    @magi = 'QualifiedChild'

    @parent = Person.new('Parent', { 'Hours Worked Per Week' => 40 }, '', '', '')
    @parent_2 = Person.new('Parent 2', { 'Hours Worked Per Week' => 40 }, '', '', '')
    @parent_underemployed = Person.new('Parent', { 'Hours Worked Per Week' => 10 }, '', '', '')
    @parent_underemployed_2 = Person.new('Parent 2', { 'Hours Worked Per Week' => 10 }, '', '', '')
    @child = Person.new('Child', '', '', '', '')

    @test_sets = [
      # dependent child age logic tests
      {
        test_name: 'Child Under Dependent Age',
        inputs: {
          'Caretaker Age' => 40,
          'Child Age' => 15,
          'Child Parents' => [@parent],
          'Physical Household' => Household.new('Household A', [@parent, @child]),
          'Relationship Type' => :parent,
          'Student Indicator' => 'Y'
        },
        configs: {
          'Child Age Threshold' => 19,
          'Dependent Age Threshold' => 18,
          'Option Dependent Student' => 'Y',
          'Deprivation Requirement Retained' => 'N',
          'Option Caretaker Relative Relationship' => '00',
          'State Unemployed Standard' => 100
        },
        expected_outputs: {
          'Child of Caretaker Dependent Age Indicator' => 'Y',
          'Child of Caretaker Dependent Age Ineligibility Reason' => 999
        }
      },
      {
        test_name: 'Child Over Dependent Age',
        inputs: {
          'Caretaker Age' => 40,
          'Child Age' => 40,
          'Child Parents' => [@parent],
          'Physical Household' => Household.new('Household A', [@parent, @child]),
          'Relationship Type' => :parent,
          'Student Indicator' => 'Y'
        },
        configs: {
          'Child Age Threshold' => 19,
          'Dependent Age Threshold' => 18,
          'Option Dependent Student' => 'Y',
          'Deprivation Requirement Retained' => 'N',
          'Option Caretaker Relative Relationship' => '00',
          'State Unemployed Standard' => 100
        },
        expected_outputs: {
          'Child of Caretaker Dependent Age Indicator' => 'N',
          'Child of Caretaker Dependent Age Ineligibility Reason' => 147
        }
      },
      {
        test_name: 'Child Equal to Dependent Age and a Student',
        inputs: {
          'Caretaker Age' => 40,
          'Child Age' => 18,
          'Child Parents' => [@parent],
          'Physical Household' => Household.new('Household A', [@parent, @child]),
          'Relationship Type' => :parent,
          'Student Indicator' => 'Y'
        },
        configs: {
          'Child Age Threshold' => 19,
          'Dependent Age Threshold' => 18,
          'Option Dependent Student' => 'Y',
          'Deprivation Requirement Retained' => 'N',
          'Option Caretaker Relative Relationship' => '00',
          'State Unemployed Standard' => 100
        },
        expected_outputs: {
          'Child of Caretaker Dependent Age Indicator' => 'Y',
          'Child of Caretaker Dependent Age Ineligibility Reason' => 999
        }
      },
      {
        test_name: 'Child Equal to Dependent Age but Not a Student',
        inputs: {
          'Caretaker Age' => 40,
          'Child Age' => 18,
          'Child Parents' => [@parent],
          'Physical Household' => Household.new('Household A', [@parent, @child]),
          'Relationship Type' => :parent,
          'Student Indicator' => 'N'
        },
        configs: {
          'Child Age Threshold' => 19,
          'Dependent Age Threshold' => 18,
          'Option Dependent Student' => 'Y',
          'Deprivation Requirement Retained' => 'N',
          'Option Caretaker Relative Relationship' => '00',
          'State Unemployed Standard' => 100
        },
        expected_outputs: {
          'Child of Caretaker Dependent Age Indicator' => 'N',
          'Child of Caretaker Dependent Age Ineligibility Reason' => 137
        }
      },

      # dependent deprived of parental support tests
      {
        test_name: 'Dependent Deprived of Parental Support - Deprivation Req N',
        inputs: {
          'Caretaker Age' => 40,
          'Child Age' => 15,
          'Child Parents' => [@parent],
          'Physical Household' => Household.new('Household A', [@parent, @child]),
          'Relationship Type' => :parent,
          'Student Indicator' => 'Y'
        },
        configs: {
          'Child Age Threshold' => 19,
          'Dependent Age Threshold' => 18,
          'Option Dependent Student' => 'Y',
          'Deprivation Requirement Retained' => 'N',
          'Option Caretaker Relative Relationship' => '00',
          'State Unemployed Standard' => 100
        },
        expected_outputs: {
          'Child of Caretaker Deprived Child Indicator' => 'X',
          'Child of Caretaker Deprived Child Ineligibility Reason' => 555
        }
      },
      {
        test_name: 'Dependent Deprived of Parental Support - Deprivation Req Y - Single Parent',
        inputs: {
          'Caretaker Age' => 40,
          'Child Age' => 15,
          'Child Parents' => [@parent],
          'Physical Household' => Household.new('Household A', [@parent, @child]),
          'Relationship Type' => :parent,
          'Student Indicator' => 'Y'
        },
        configs: {
          'Child Age Threshold' => 19,
          'Dependent Age Threshold' => 18,
          'Option Dependent Student' => 'Y',
          'Deprivation Requirement Retained' => 'Y',
          'Option Caretaker Relative Relationship' => '00',
          'State Unemployed Standard' => 100
        },
        expected_outputs: {
          'Child of Caretaker Deprived Child Indicator' => 'Y',
          'Child of Caretaker Deprived Child Ineligibility Reason' => 999
        }
      },
      {
        test_name: 'Dependent Deprived of Parental Support - Deprivation Req Y - Underemployed Parents',
        inputs: {
          'Caretaker Age' => 18,
          'Child Age' => 15,
          'Child Parents' => [@parent_underemployed, @parent_underemployed_2],
          'Physical Household' => Household.new('Household A', [@parent_underemployed, @parent_underemployed_2, @child]),
          'Relationship Type' => :parent,
          'Student Indicator' => 'Y'
        },
        configs: {
          'Child Age Threshold' => 18,
          'Dependent Age Threshold' => 18,
          'Option Dependent Student' => 'Y',
          'Deprivation Requirement Retained' => 'Y',
          'Option Caretaker Relative Relationship' => '00',
          'State Unemployed Standard' => 100
        },
        expected_outputs: {
          'Child of Caretaker Deprived Child Indicator' => 'Y',
          'Child of Caretaker Deprived Child Ineligibility Reason' => 999
        }
      },
      {
        test_name: 'Dependent Deprived of Parental Support - Deprivation Req Y - Fallback',
        inputs: {
          'Caretaker Age' => 40,
          'Child Age' => 15,
          'Child Parents' => [@parent, @parent_2],
          'Physical Household' => Household.new('Household A', [@parent, @parent_2, @child]),
          'Relationship Type' => :parent,
          'Student Indicator' => 'Y'
        },
        configs: {
          'Child Age Threshold' => 18,
          'Dependent Age Threshold' => 18,
          'Option Dependent Student' => 'Y',
          'Deprivation Requirement Retained' => 'Y',
          'Option Caretaker Relative Relationship' => '00',
          'State Unemployed Standard' => 100
        },
        expected_outputs: {
          'Child of Caretaker Deprived Child Indicator' => 'N',
          'Child of Caretaker Deprived Child Ineligibility Reason' => 129
        }
      },

      # relationship rule
      {
        test_name: 'Relationship Requirements - Caretaker Relationship 04 - Caretaker Over Threshold',
        inputs: {
          'Caretaker Age' => 40,
          'Child Age' => 15,
          'Child Parents' => [@parent, @parent_2],
          'Physical Household' => Household.new('Household A', [@parent, @parent_2, @child]),
          'Relationship Type' => :parent,
          'Student Indicator' => 'Y'
        },
        configs: {
          'Child Age Threshold' => 19,
          'Dependent Age Threshold' => 11,
          'Option Dependent Student' => 'Y',
          'Deprivation Requirement Retained' => 'Y',
          'Option Caretaker Relative Relationship' => '04',
          'State Unemployed Standard' => 100
        },
        expected_outputs: {
          'Child of Caretaker Relationship Indicator' => 'Y',
          'Child of Caretaker Relationship Ineligibility Reason' => 999
        }
      },
      {
        test_name: 'Relationship Requirements - Caretaker Relationship 04 - Caretaker Under Threshold',
        inputs: {
          'Caretaker Age' => 17,
          'Child Age' => 4,
          'Child Parents' => [@parent, @parent_2],
          'Physical Household' => Household.new('Household A', [@parent, @parent_2, @child]),
          'Relationship Type' => :parent,
          'Student Indicator' => 'Y'
        },
        configs: {
          'Child Age Threshold' => 19,
          'Dependent Age Threshold' => 18,
          'Option Dependent Student' => 'Y',
          'Deprivation Requirement Retained' => 'Y',
          'Option Caretaker Relative Relationship' => '04',
          'State Unemployed Standard' => 100
        },
        expected_outputs: {
          'Child of Caretaker Relationship Indicator' => 'N',
          'Child of Caretaker Relationship Ineligibility Reason' => 130
        }
      },
      {
        test_name: 'Relationship Requirements - Valid Relationship - Scenario 1',
        inputs: {
          'Caretaker Age' => 40,
          'Child Age' => 11,
          'Child Parents' => [@parent, @parent_2],
          'Physical Household' => Household.new('Household A', [@parent, @parent_2, @child]),
          'Relationship Type' => :parent,
          'Student Indicator' => 'Y'
        },
        configs: {
          'Child Age Threshold' => 19,
          'Dependent Age Threshold' => 18,
          'Option Dependent Student' => 'Y',
          'Deprivation Requirement Retained' => 'Y',
          'Option Caretaker Relative Relationship' => '02',
          'State Unemployed Standard' => 100
        },
        expected_outputs: {
          'Child of Caretaker Relationship Indicator' => 'Y',
          'Child of Caretaker Relationship Ineligibility Reason' => 999
        }
      },
      {
        test_name: 'Relationship Requirements - Valid Relationship - Scenario 2',
        inputs: {
          'Caretaker Age' => 40,
          'Child Age' => 11,
          'Child Parents' => [@parent, @parent_2],
          'Physical Household' => Household.new('Household A', [@parent, @parent_2, @child]),
          'Relationship Type' => :former_spouse,
          'Student Indicator' => 'Y'
        },
        configs: {
          'Child Age Threshold' => 19,
          'Dependent Age Threshold' => 18,
          'Option Dependent Student' => 'Y',
          'Deprivation Requirement Retained' => 'Y',
          'Option Caretaker Relative Relationship' => '01',
          'State Unemployed Standard' => 100
        },
        expected_outputs: {
          'Child of Caretaker Relationship Indicator' => 'Y',
          'Child of Caretaker Relationship Ineligibility Reason' => 999
        }
      },
      {
        test_name: 'Relationship Requirements - Valid Relationship - Scenario 3',
        inputs: {
          'Caretaker Age' => 40,
          'Child Age' => 11,
          'Child Parents' => [@parent, @parent_2],
          'Physical Household' => Household.new('Household A', [@parent, @parent_2, @child]),
          'Relationship Type' => :parents_domestic_partner,
          'Student Indicator' => 'Y'
        },
        configs: {
          'Child Age Threshold' => 19,
          'Dependent Age Threshold' => 18,
          'Option Dependent Student' => 'Y',
          'Deprivation Requirement Retained' => 'Y',
          'Option Caretaker Relative Relationship' => '03',
          'State Unemployed Standard' => 100
        },
        expected_outputs: {
          'Child of Caretaker Relationship Indicator' => 'Y',
          'Child of Caretaker Relationship Ineligibility Reason' => 999
        }
      },
      {
        test_name: 'Relationship Requirements - Invalid Relationship - Caretaker Relationship 00',
        inputs: {
          'Caretaker Age' => 40,
          'Child Age' => 11,
          'Child Parents' => [@parent, @parent_2],
          'Physical Household' => Household.new('Household A', [@parent, @parent_2, @child]),
          'Relationship Type' => :parents_domestic_partner,
          'Student Indicator' => 'Y'
        },
        configs: {
          'Child Age Threshold' => 19,
          'Dependent Age Threshold' => 18,
          'Option Dependent Student' => 'Y',
          'Deprivation Requirement Retained' => 'Y',
          'Option Caretaker Relative Relationship' => '00',
          'State Unemployed Standard' => 100
        },
        expected_outputs: {
          'Child of Caretaker Relationship Indicator' => 'N',
          'Child of Caretaker Relationship Ineligibility Reason' => 132
        }
      },
      {
        test_name: 'Relationship Requirements - Invalid Relationship - Caretaker Relationship 01',
        inputs: {
          'Caretaker Age' => 40,
          'Child Age' => 11,
          'Child Parents' => [@parent, @parent_2],
          'Physical Household' => Household.new('Household A', [@parent, @parent_2, @child]),
          'Relationship Type' => :other,
          'Student Indicator' => 'Y'
        },
        configs: {
          'Child Age Threshold' => 19,
          'Dependent Age Threshold' => 18,
          'Option Dependent Student' => 'Y',
          'Deprivation Requirement Retained' => 'Y',
          'Option Caretaker Relative Relationship' => '01',
          'State Unemployed Standard' => 100
        },
        expected_outputs: {
          'Child of Caretaker Relationship Indicator' => 'N',
          'Child of Caretaker Relationship Ineligibility Reason' => 131
        }
      },
      {
        test_name: 'Relationship Requirements - Invalid Relationship - Fallback',
        inputs: {
          'Caretaker Age' => 40,
          'Child Age' => 11,
          'Child Parents' => [@parent, @parent_2],
          'Physical Household' => Household.new('Household A', [@parent, @parent_2, @child]),
          'Relationship Type' => :other,
          'Student Indicator' => 'Y'
        },
        configs: {
          'Child Age Threshold' => 19,
          'Dependent Age Threshold' => 18,
          'Option Dependent Student' => 'Y',
          'Deprivation Requirement Retained' => 'Y',
          'Option Caretaker Relative Relationship' => '02',
          'State Unemployed Standard' => 100
        },
        expected_outputs: {
          'Child of Caretaker Relationship Indicator' => 'N',
          'Child of Caretaker Relationship Ineligibility Reason' => 389
        }
      },

      # fallbacks
      {
        test_name: 'Bad Info - Inputs',
        inputs: {
          'Student Indicator' => 'N'
        },
        configs: {
          'Child Age Threshold' => 19,
          'Dependent Age Threshold' => 18,
          'Option Dependent Student' => 'N',
          'Deprivation Requirement Retained' => 'N',
          'Option Caretaker Relative Relationship' => 0o0,
          'State Unemployed Standard' => 100
        },
        expected_outputs: {
        }
      },
      {
        test_name: 'Bad Info - Configs',
        inputs: {
          'Caretaker Age' => 23,
          'Child Age' => 19,
          'Child Parents' => [],
          'Physical Household' => Household.new('', ''),
          'Relationship Type' => :child,
          'Student Indicator' => 'N'
        },
        configs: {
          'State Unemployed Standard' => 100
        },
        expected_outputs: {
        }
      }
    ]
  end
end
