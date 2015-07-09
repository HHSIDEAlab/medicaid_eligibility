##### GENERATED AT 2015-07-07 12:06:44 -0400 ######
class QualifiedChildFixture < MagiFixture
  attr_accessor :magi, :test_sets

  def initialize
    super
    @magi = 'QualifiedChild'
    @test_sets = [
      
      # {
      #   test_name: "FILL_IN_WITH_TEST_NAME",
      #   inputs: {
      #     "Caretaker Age" => 40,
      #     "Child Age" => 15,
      #     "Child Parents" => [],
      #     "Physical Household" => Household.new('Household A', [Applicant.new('Parent','','','',''), Applicant.new('Child','','','','')] ),
      #     "Relationship Type" => :parent,
      #     "Student Indicator" => "Y"
      #   },
      #   configs: {
      #     "Child Age Threshold" => 19,
      #     "Dependent Age Threshold" => 18,
      #     "Option Dependent Student" => "Y",
      #     "Deprivation Requirement Retained" => "N",
      #     "Option Caretaker Relative Relationship" => "N",
      #     "State Unemployed Standard" => 100
      #   },
      #   expected_outputs: {
      #     "Child of Caretaker Dependent Age Indicator" => "Y",
      #     "Child of Caretaker Dependent Age Ineligibility Reason" => 999,
      #     "Child of Caretaker Deprived Child Indicator" => "Y",
      #     "Child of Caretaker Deprived Child Ineligibility Reason" => 999,
      #     "Child of Caretaker Relationship Indicator" => "Y",
      #     "Child of Caretaker Relationship Ineligibility Reason" => 999
      #   }
      # },


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
