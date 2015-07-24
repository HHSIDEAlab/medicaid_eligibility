##### GENERATED AT 2015-07-07 12:06:44 -0400 ######
class QualifiedChildFixture < MagiFixture
  attr_accessor :magi, :test_sets

  def initialize
    super
    @magi = 'QualifiedChild'

    @parent = Applicant.new('Parent',{'Hours Worked Per Week' => 40 },'','','')
    @child = Applicant.new('Child','','','','')

    @test_sets = [
      
      {
        test_name: "GETS TO THE END",
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
          "Child of Caretaker Dependent Age Ineligibility Reason" => 999,
          "Child of Caretaker Deprived Child Indicator" => "Y",
          "Child of Caretaker Deprived Child Ineligibility Reason" => 999,
          "Child of Caretaker Relationship Indicator" => "Y",
          "Child of Caretaker Relationship Ineligibility Reason" => 999
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
