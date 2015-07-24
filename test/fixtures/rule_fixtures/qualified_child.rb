##### GENERATED AT 2015-07-07 12:06:44 -0400 ######
class QualifiedChildFixture < MagiFixture
  attr_accessor :magi, :test_sets

  def initialize
    super
    @magi = 'QualifiedChild'

    @parent = Applicant.new('Parent',{'Hours Worked Per Week' => 40 },'','','')
    @parent_2 = Applicant.new('Parent 2',{'Hours Worked Per Week' => 40 },'','','')
    @parent_underemployed = Applicant.new('Parent',{'Hours Worked Per Week' => 10 },'','','')
    @parent_underemployed_2 = Applicant.new('Parent 2',{'Hours Worked Per Week' => 10 },'','','')
    @child = Applicant.new('Child','','','','')

    @test_sets = [
      # dependent child age logic tests
      {
        test_name: "Child Under Dependent Age",
        inputs: {
          "Caretaker Age" => 40,
          "Child Age" => 15,
          "Child Parents" => [@parent],
          "Physical Household" => Household.new( 'Household A', [@parent, @child] ),
          "Relationship Type" => :parent,
          "Student Indicator" => "Y"
        },
        configs: {
          "Child Age Threshold" => 19,
          "Dependent Age Threshold" => 18,
          "Option Dependent Student" => "Y",
          "Deprivation Requirement Retained" => "N",
          "Option Caretaker Relative Relationship" => "00",
          "State Unemployed Standard" => 100
        },
        expected_outputs: {
          "Child of Caretaker Dependent Age Indicator" => "Y",
          "Child of Caretaker Dependent Age Ineligibility Reason" => 999
        }
      },
      {
        test_name: "Child Over Dependent Age",
        inputs: {
          "Caretaker Age" => 40,
          "Child Age" => 40,
          "Child Parents" => [@parent],
          "Physical Household" => Household.new( 'Household A', [@parent, @child] ),
          "Relationship Type" => :parent,
          "Student Indicator" => "Y"
        },
        configs: {
          "Child Age Threshold" => 19,
          "Dependent Age Threshold" => 18,
          "Option Dependent Student" => "Y",
          "Deprivation Requirement Retained" => "N",
          "Option Caretaker Relative Relationship" => "00",
          "State Unemployed Standard" => 100
        },
        expected_outputs: {
          "Child of Caretaker Dependent Age Indicator" => "N",
          "Child of Caretaker Dependent Age Ineligibility Reason" => 147
        }
      },
      {
        test_name: "Child Equal to Dependent Age and a Student",
        inputs: {
          "Caretaker Age" => 40,
          "Child Age" => 18,
          "Child Parents" => [@parent],
          "Physical Household" => Household.new( 'Household A', [@parent, @child] ),
          "Relationship Type" => :parent,
          "Student Indicator" => "Y"
        },
        configs: {
          "Child Age Threshold" => 18,
          "Dependent Age Threshold" => 18,
          "Option Dependent Student" => "Y",
          "Deprivation Requirement Retained" => "N",
          "Option Caretaker Relative Relationship" => "00",
          "State Unemployed Standard" => 100
        },
        expected_outputs: {
          "Child of Caretaker Dependent Age Indicator" => "Y",
          "Child of Caretaker Dependent Age Ineligibility Reason" => 999
        }
      },
      {
        test_name: "Child Equal to Dependent Age but Not a Student",
        inputs: {
          "Caretaker Age" => 40,
          "Child Age" => 18,
          "Child Parents" => [@parent],
          "Physical Household" => Household.new( 'Household A', [@parent, @child] ),
          "Relationship Type" => :parent,
          "Student Indicator" => "N"
        },
        configs: {
          "Child Age Threshold" => 18,
          "Dependent Age Threshold" => 18,
          "Option Dependent Student" => "Y",
          "Deprivation Requirement Retained" => "N",
          "Option Caretaker Relative Relationship" => "00",
          "State Unemployed Standard" => 100
        },
        expected_outputs: {
          "Child of Caretaker Dependent Age Indicator" => "N",
          "Child of Caretaker Dependent Age Ineligibility Reason" => 137
        }
      },

      # dependent deprived of parental support tests
      {
        test_name: "Dependent Deprived of Parental Support - Deprivation Req N",
        inputs: {
          "Caretaker Age" => 40,
          "Child Age" => 15,
          "Child Parents" => [@parent],
          "Physical Household" => Household.new( 'Household A', [@parent, @child] ),
          "Relationship Type" => :parent,
          "Student Indicator" => "Y"
        },
        configs: {
          "Child Age Threshold" => 18,
          "Dependent Age Threshold" => 18,
          "Option Dependent Student" => "Y",
          "Deprivation Requirement Retained" => "N",
          "Option Caretaker Relative Relationship" => "00",
          "State Unemployed Standard" => 100
        },
        expected_outputs: {
          "Child of Caretaker Deprived Child Indicator" => "X",
          "Child of Caretaker Deprived Child Ineligibility Reason" => 555
        }
      },
      {
        test_name: "Dependent Deprived of Parental Support - Deprivation Req Y - Single Parent",
        inputs: {
          "Caretaker Age" => 40,
          "Child Age" => 15,
          "Child Parents" => [@parent],
          "Physical Household" => Household.new( 'Household A', [@parent, @child] ),
          "Relationship Type" => :parent,
          "Student Indicator" => "Y"
        },
        configs: {
          "Child Age Threshold" => 18,
          "Dependent Age Threshold" => 18,
          "Option Dependent Student" => "Y",
          "Deprivation Requirement Retained" => "Y",
          "Option Caretaker Relative Relationship" => "00",
          "State Unemployed Standard" => 100
        },
        expected_outputs: {
          "Child of Caretaker Deprived Child Indicator" => "Y",
          "Child of Caretaker Deprived Child Ineligibility Reason" => 999
        }
      },
      {
        test_name: "Dependent Deprived of Parental Support - Deprivation Req Y - Underemployed Parents",
        inputs: {
          "Caretaker Age" => 40,
          "Child Age" => 15,
          "Child Parents" => [@parent_underemployed, @parent_underemployed_2],
          "Physical Household" => Household.new( 'Household A', [@parent_underemployed, @parent_underemployed_2, @child] ),
          "Relationship Type" => :parent,
          "Student Indicator" => "Y"
        },
        configs: {
          "Child Age Threshold" => 18,
          "Dependent Age Threshold" => 18,
          "Option Dependent Student" => "Y",
          "Deprivation Requirement Retained" => "Y",
          "Option Caretaker Relative Relationship" => "00",
          "State Unemployed Standard" => 100
        },
        expected_outputs: {
          "Child of Caretaker Deprived Child Indicator" => "Y",
          "Child of Caretaker Deprived Child Ineligibility Reason" => 999
        }
      },
      {
        test_name: "Dependent Deprived of Parental Support - Deprivation Req Y - Fallback",
        inputs: {
          "Caretaker Age" => 40,
          "Child Age" => 15,
          "Child Parents" => [@parent, @parent_2],
          "Physical Household" => Household.new( 'Household A', [@parent, @parent_2, @child] ),
          "Relationship Type" => :parent,
          "Student Indicator" => "Y"
        },
        configs: {
          "Child Age Threshold" => 18,
          "Dependent Age Threshold" => 18,
          "Option Dependent Student" => "Y",
          "Deprivation Requirement Retained" => "Y",
          "Option Caretaker Relative Relationship" => "00",
          "State Unemployed Standard" => 100
        },
        expected_outputs: {
          "Child of Caretaker Deprived Child Indicator" => "N",
          "Child of Caretaker Deprived Child Ineligibility Reason" => 129
        }
      },



      {
        test_name: "Bad Info - Inputs",
        inputs: {
          "Student Indicator" => "N"
        },
        configs: {
          "Child Age Threshold" => 19,
          "Dependent Age Threshold" => 18,
          "Option Dependent Student" => "N",
          "Deprivation Requirement Retained" => "N",
          "Option Caretaker Relative Relationship" => 00,
          "State Unemployed Standard" => 100
        },
        expected_outputs: {
        }
      },
      {
        test_name: "Bad Info - Configs",
        inputs: {
          "Caretaker Age" => 23,
          "Child Age" => 19,
          "Child Parents" => [],
          "Physical Household" => Household.new('',''),
          "Relationship Type" => :child,
          "Student Indicator" => "N"
        },
        configs: {
          "State Unemployed Standard" => 100
        },
        expected_outputs: {
        }
      }
    ]
  end
end

# NOTES
# no. -CF 7/7/2015

      ### STUB THAT GETS TO THE END
      # {
      #   test_name: "Child Under Dependent Age",
      #   inputs: {
      #     "Caretaker Age" => 40,
      #     "Child Age" => 15,
      #     "Child Parents" => [@parent],
      #     "Physical Household" => Household.new( 'Household A', [@parent, @child] ),
      #     "Relationship Type" => :parent,
      #     "Student Indicator" => "Y"
      #   },
      #   configs: {
      #     "Child Age Threshold" => 19,
      #     "Dependent Age Threshold" => 18,
      #     "Option Dependent Student" => "Y",
      #     "Deprivation Requirement Retained" => "N",
      #     "Option Caretaker Relative Relationship" => "00",
      #     "State Unemployed Standard" => 100
      #   },
      #   expected_outputs: {
      #     "Child of Caretaker Dependent Age Indicator" => "Y",
      #     "Child of Caretaker Dependent Age Ineligibility Reason" => 999
      #     # "Child of Caretaker Deprived Child Indicator" => "Y",
      #     # "Child of Caretaker Deprived Child Ineligibility Reason" => 999,
      #     # "Child of Caretaker Relationship Indicator" => "Y",
      #     # "Child of Caretaker Relationship Ineligibility Reason" => 999
      #   }
      # },