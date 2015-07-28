##### GENERATED AT 2015-07-07 11:06:11 -0400 ######
class ParentCaretakerRelativeFixture < MagiFixture
  attr_accessor :magi, :test_sets

  def initialize
    super
    @magi = 'ParentCaretakerRelative'

    # set 1: One kid, qualifies
    @parent = Applicant.new("Parent", {'Applicant Age' => 25, 'Hours Worked Per Week' => 40},'','','')
    @parent.relationships = [Relationship.new(@parent, :self, ''), Relationship.new(@child, :child, '')]
    @child = Applicant.new("Child", {'Applicant Age' => 6 },'','','')
    @child.relationships = [Relationship.new(@child, :self, ''), Relationship.new(@parent, :parent, '')]
    @household = Household.new('Household', [ @parent, @child ] )
    @tax_return = TaxReturn.new( [@parent], [@child], {} )
    
    # set 2: Two kids, both qualify
    @parent_2 = Applicant.new("Parent", {'Applicant Age' => 25, 'Hours Worked Per Week' => 40},'','','')
    @parent_2.relationships = [Relationship.new(@parent_2, :self, ''), Relationship.new(@child_2a, :child, ''), Relationship.new(@child_2b, :child, '')]
    @child_2a = Applicant.new("Child 1", {'Applicant Age' => 6 },'','','')
    @child_2a.relationships = [Relationship.new(@child_2a, :self, ''), Relationship.new(@parent_2, :parent, ''), Relationship.new(@child_2b, :sibling, '')]
    @child_2b = Applicant.new("Child 2", {'Applicant Age' => 6 },'','','')
    @child_2b.relationships = [Relationship.new(@child_2b, :self, ''), Relationship.new(@parent_2, :parent, ''), Relationship.new(@child_2a, :sibling, '')]
    @household_2 = Household.new('Household', [ @parent_2, @child_2a, @child_2b ] )
    @tax_return_2 = TaxReturn.new( [@parent_2], [@child_2a, @child_2b], {} )

    # set 3: Two kids, one qualifies
    @parent_3 = Applicant.new("Parent", {'Applicant Age' => 40, 'Hours Worked Per Week' => 40},'','','')
    @parent_3.relationships = [Relationship.new(@parent_3, :self, ''), Relationship.new(@child_3a, :child, ''), Relationship.new(@child_3b, :child, '')]
    @child_3a = Applicant.new("Child 1", {'Applicant Age' => 6 },'','','')
    @child_3a.relationships = [Relationship.new(@child_3a, :self, ''), Relationship.new(@parent_3, :parent, ''), Relationship.new(@child_3b, :sibling, '')]
    @child_3b = Applicant.new("Child 2", {'Applicant Age' => 20 },'','','')
    @child_3b.relationships = [Relationship.new(@child_3b, :self, ''), Relationship.new(@parent_3, :parent, ''), Relationship.new(@child_3a, :sibling, '')]
    @household_3 = Household.new('Household', [ @parent_3, @child_3a, @child_3b ] )
    @tax_return_3 = TaxReturn.new( [@parent_3], [@child_3a, @child_3b], {} )

    # set 4: Two kids, neither qualify
    @parent_4 = Applicant.new("Parent", {'Applicant Age' => 40, 'Hours Worked Per Week' => 40},'','','')
    @parent_4.relationships = [Relationship.new(@parent_4, :self, ''), Relationship.new(@child_4a, :child, ''), Relationship.new(@child_4b, :child, '')]
    @child_4a = Applicant.new("Child 1", {'Applicant Age' => 26 },'','','')
    @child_4a.relationships = [Relationship.new(@child_4a, :self, ''), Relationship.new(@parent_4, :parent, ''), Relationship.new(@child_4b, :sibling, '')]
    @child_4b = Applicant.new("Child 2", {'Applicant Age' => 20 },'','','')
    @child_4b.relationships = [Relationship.new(@child_4b, :self, ''), Relationship.new(@parent_4, :parent, ''), Relationship.new(@child_4a, :sibling, '')]
    @household_4 = Household.new('Household', [ @parent_4, @child_4a, @child_4b ] )
    @tax_return_4 = TaxReturn.new( [@parent_4], [@child_4a, @child_4b], {} )

    # set 5: Stepchildren, both qualify
    @parent_5 = Applicant.new("Parent", {'Applicant Age' => 25, 'Hours Worked Per Week' => 40},'','','')
    @parent_5.relationships = [Relationship.new(@parent_5, :self, ''), Relationship.new(@child_5a, :stepchild, ''), Relationship.new(@child_5b, :child, '')]
    @child_5a = Applicant.new("Child 1", {'Applicant Age' => 6 },'','','')
    @child_5a.relationships = [Relationship.new(@child_5a, :self, ''), Relationship.new(@parent_5, :parent, ''), Relationship.new(@child_5b, :sibling, '')]
    @child_5b = Applicant.new("Child 2", {'Applicant Age' => 6 },'','','')
    @child_5b.relationships = [Relationship.new(@child_5b, :self, ''), Relationship.new(@parent_5, :parent, ''), Relationship.new(@child_5a, :sibling, '')]
    @household_5 = Household.new('Household', [ @parent_5, @child_5a, @child_5b ] )
    @tax_return_5 = TaxReturn.new( [@parent_5], [@child_5a, @child_5b], {} )

    # set 6: Parent is other relative instead of blood relative, neither qualify
    @parent_6 = Applicant.new("Parent", {'Applicant Age' => 25, 'Hours Worked Per Week' => 40},'','','')
    @parent_6.relationships = [Relationship.new(@parent_6, :self, ''), Relationship.new(@child_6a, :other, ''), Relationship.new(@child_6b, :other, '')]
    @child_6a = Applicant.new("Child 1", {'Applicant Age' => 6 },'','','')
    @child_6a.relationships = [Relationship.new(@child_6a, :self, ''), Relationship.new(@parent_6, :other_relative, ''), Relationship.new(@child_6b, :sibling, '')]
    @child_6b = Applicant.new("Child 2", {'Applicant Age' => 6 },'','','')
    @child_6b.relationships = [Relationship.new(@child_6b, :self, ''), Relationship.new(@parent_6, :other_relative, ''), Relationship.new(@child_6a, :sibling, '')]
    @household_6 = Household.new('Household', [ @parent_6, @child_6a, @child_6b ] )
    @tax_return_6 = TaxReturn.new( [@parent_6], [@child_6a, @child_6b], {} )


    @test_sets = [
      {
        test_name: "Parent Caretaker - Applicant Child List is Empty", 
        inputs: {
          "Person ID" => "Parent",
          "Person List" => [@parent],
          "Physical Household" => Household.new('Solo Household', [@parent]),
          "Tax Returns" => [TaxReturn.new([@parent], [],nil) ],
          "Applicant Age" => 25,
          "Applicant Relationships" => [Relationship.new(@parent, :self, '')]
        },
        configs: {
          "Child Age Threshold" => 19,
          "Dependent Age Threshold" => 19,
          "Option Dependent Student" => "N",
          "Deprivation Requirement Retained" => "N",
          "Option Caretaker Relative Relationship" => "00",
          "State Unemployed Standard" => 100
        },
        expected_outputs: {
          "Applicant Parent Caretaker Category Indicator" => "N",
          "Parent Caretaker Category Ineligibility Reason" => 146,
          "Qualified Children List" => []
        }
      },
      {
        test_name: "Parent Caretaker - Set 1 - Child Qualifies ",
        inputs: {
          "Person ID" => "Parent",
          "Person List" => [@parent, @child],
          "Physical Household" => @household,
          "Tax Returns" => [ @tax_return ],
          "Applicant Age" => 25,
          "Applicant Relationships" => [Relationship.new(@parent, :self, ''), Relationship.new(@child, :child, '')]
        },
        configs: {
          "Child Age Threshold" => 19,
          "Dependent Age Threshold" => 19,
          "Option Dependent Student" => "N",
          "Deprivation Requirement Retained" => "N",
          "Option Caretaker Relative Relationship" => "00",
          "State Unemployed Standard" => 100
        },
        expected_outputs: {
          "Applicant Parent Caretaker Category Indicator" => "Y",
          "Parent Caretaker Category Ineligibility Reason" => 999,
          "Qualified Children List" => [ 'Child' ]
        }
      },
      {
        test_name: "Parent Caretaker - Set 2 -  Two Kids Both Qualify",
        inputs: {
          "Person ID" => "Parent",
          "Person List" => [@parent_2, @child_2a, @child_2b],
          "Physical Household" => @household_2,
          "Tax Returns" => [ @tax_return_2 ],
          "Applicant Age" => 25,
          "Applicant Relationships" => [Relationship.new(@parent_2, :self, ''), Relationship.new(@child_2a, :child, ''), Relationship.new(@child_2b, :child, '')]
        },
        configs: {
          "Child Age Threshold" => 19,
          "Dependent Age Threshold" => 19,
          "Option Dependent Student" => "N",
          "Deprivation Requirement Retained" => "N",
          "Option Caretaker Relative Relationship" => "00",
          "State Unemployed Standard" => 100
        },
        expected_outputs: {
          "Applicant Parent Caretaker Category Indicator" => "Y",
          "Parent Caretaker Category Ineligibility Reason" => 999,
          "Qualified Children List" => [ 'Child 1', 'Child 2' ]
        }
      },
      {
        test_name: "Parent Caretaker - Set 3 - Two Kids One Qualifies",
        inputs: {
          "Person ID" => "Parent",
          "Person List" => [@parent_3, @child_3a, @child_3b],
          "Physical Household" => @household_3,
          "Tax Returns" => [ @tax_return_3 ],
          "Applicant Age" => 25,
          "Applicant Relationships" => [Relationship.new(@parent_3, :self, ''), Relationship.new(@child_3a, :child, ''), Relationship.new(@child_3b, :child, '')]
        },
        configs: {
          "Child Age Threshold" => 19,
          "Dependent Age Threshold" => 19,
          "Option Dependent Student" => "N",
          "Deprivation Requirement Retained" => "N",
          "Option Caretaker Relative Relationship" => "00",
          "State Unemployed Standard" => 100
        },
        expected_outputs: {
          "Applicant Parent Caretaker Category Indicator" => "Y",
          "Parent Caretaker Category Ineligibility Reason" => 999,
          "Qualified Children List" => [ 'Child 1' ]
        }
      },
      {
        test_name: "Parent Caretaker - Set 4 - Two Kids Neither Qualifies",
        inputs: {
          "Person ID" => "Parent",
          "Person List" => [@parent_4, @child_4a, @child_4b],
          "Physical Household" => @household_4,
          "Tax Returns" => [ @tax_return_4 ],
          "Applicant Age" => 25,
          "Applicant Relationships" => [Relationship.new(@parent_4, :self, ''), Relationship.new(@child_4a, :child, ''), Relationship.new(@child_4b, :child, '')]
        },
        configs: {
          "Child Age Threshold" => 19,
          "Dependent Age Threshold" => 19,
          "Option Dependent Student" => "N",
          "Deprivation Requirement Retained" => "N",
          "Option Caretaker Relative Relationship" => "00",
          "State Unemployed Standard" => 100
        },
        expected_outputs: {
          "Applicant Parent Caretaker Category Indicator" => "N",
          "Parent Caretaker Category Ineligibility Reason" => 146,
          "Qualified Children List" => []
        }
      },
      {
        test_name: "Parent Caretaker - Set 5 - Stepchildren, Both Qualify",
        inputs: {
          "Person ID" => "Parent",
          "Person List" => [@parent_5, @child_5a, @child_5b],
          "Physical Household" => @household_5,
          "Tax Returns" => [ @tax_return_5 ],
          "Applicant Age" => 25,
          "Applicant Relationships" => [Relationship.new(@parent_5, :self, ''), Relationship.new(@child_5a, :stepchild, ''), Relationship.new(@child_5b, :stepchild, '')]
        },
        configs: {
          "Child Age Threshold" => 19,
          "Dependent Age Threshold" => 19,
          "Option Dependent Student" => "N",
          "Deprivation Requirement Retained" => "N",
          "Option Caretaker Relative Relationship" => "00",
          "State Unemployed Standard" => 100
        },
        expected_outputs: {
          "Applicant Parent Caretaker Category Indicator" => "Y",
          "Parent Caretaker Category Ineligibility Reason" => 999,
          "Qualified Children List" => [ 'Child 1', 'Child 2']
        }
      },
      {
        test_name: "Parent Caretaker - Set 6 - Parent is Other Relative",
        inputs: {
          "Person ID" => "Parent",
          "Person List" => [@parent_6, @child_6a, @child_6b],
          "Physical Household" => @household_6,
          "Tax Returns" => [ @tax_return_6 ],
          "Applicant Age" => 25,
          "Applicant Relationships" => [Relationship.new(@parent_6, :self, ''), Relationship.new(@child_6a, :other, ''), Relationship.new(@child_6b, :other, '')]
        },
        configs: {
          "Child Age Threshold" => 19,
          "Dependent Age Threshold" => 19,
          "Option Dependent Student" => "N",
          "Deprivation Requirement Retained" => "N",
          "Option Caretaker Relative Relationship" => "00",
          "State Unemployed Standard" => 100
        },
        expected_outputs: {
          "Applicant Parent Caretaker Category Indicator" => "N",
          "Parent Caretaker Category Ineligibility Reason" => 146,
          "Qualified Children List" => []
        }
      },
      {
        test_name: "Bad Info - Inputs",
        inputs: {
          "Applicant Relationships" => []
        },
        configs: {
          "Child Age Threshold" => 19,
          "Dependent Age Threshold" => 19,
          "Option Dependent Student" => "N",
          "Deprivation Requirement Retained" => "N",
          "Option Caretaker Relative Relationship" => "00",
          "State Unemployed Standard" => 100
        },
        expected_outputs: {
        }
      },
      {
        test_name: "Bad Info - Configs",
        inputs: {
          "Person ID" => 1,
          "Person List" => [],
          "Physical Household" => [],
          "Tax Returns" => [],
          "Applicant Age" => 25,
          "Applicant Relationships" => []
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
