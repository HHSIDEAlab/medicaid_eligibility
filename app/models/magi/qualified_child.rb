# encoding: UTF-8

module MAGI
  class QualifiedChild < Ruleset
    name        "Identify Medicaid Category – Parent or Caretaker Relative, Qualified Child"
    mandatory   "Mandatory"
    references  "§435.4 and §435.110"
    applies_to  "Medicaid only"
    
    assumption "A child must satisfy all four conditions (dependent child age, deprived of parental support, relationship and applicant assumes primary responsibility) in order for the applicant to qualify for the Parent Caretaker Relative category."

    input "Caretaker Age", "Application", "Integer"
    input "Child Age", "Application", "Integer"
    input "Child Parents", "Application", "List"
    input "Physical Household", "Application", "Household Object"
    input "Relationship Type", "Application", "Symbol"
    input "Student Indicator", "Application", "Char(1)", %w(Y N)
    
    config "Child Age Threshold", "System Configuration", "Integer", nil, 19
    config "Dependent Age Threshold", "System Configuration", "Integer", nil, 18
    config "Option Dependent Student", "State Configuration", "Char(1)", %w(Y N)
    config "Deprivation Requirement Retained", "State Configuration", "Char(1)", %w(Y N)
    config "Option Caretaker Relative Relationship", "State Configuration", "Char(2)", %w(00 01 02 03 04)
    config "State Unemployed Standard", "State Configuration", "Integer", (100..744), 100

    # outputs
    indicator "Child of Caretaker Dependent Age Indicator", %w(Y N)
    date      "Child of Caretaker Dependent Age Determination Date"
    code      "Child of Caretaker Dependent Age Ineligibility Reason", %w(999 137 147)
    indicator "Child of Caretaker Deprived Child Indicator", %w(Y N X)
    date      "Child of Caretaker Deprived Child Determination Date"
    code      "Child of Caretaker Deprived Child Ineligibility Reason", %w(999 555)
    indicator "Child of Caretaker Relationship Indicator", %w(Y N)
    date      "Child of Caretaker Relationship Determination Date"
    code      "Child of Caretaker Relationship Ineligibility Reason", %w(999 130 131 132 389)

    calculated "Number of Parents Living With" do
      v("Child Parents").select{|parent| v("Physical Household").people.include?(parent)}.length
    end

    calculated "Parents Work 100 Hours Per Month" do
      if v("Child Parents").all?{|parent| parent.person_attributes["Hours Worked Per Week"] >= c("State Unemployed Standard")}
        'Y'
      else
        'N'
      end
    end

    calculated "Valid Relationships" do
      standard_relationships = [:parent, :sibling, :stepparent, :uncle_aunt, :grandparent, :cousin, :sibling_in_law]
      relative_relationships = [:parent, :sibling, :stepparent, :uncle_aunt, :grandparent, :cousin, :sibling_in_law, :former_spouse, :parent_in_law]

      if c("Option Caretaker Relative Relationship") == '00'
        standard_relationships
      elsif c("Option Caretaker Relative Relationship") == '01'
        relative_relationships
      elsif c("Option Caretaker Relative Relationship") == '02'
        standard_relationships << :parents_domestic_partner
      elsif c("Option Caretaker Relative Relationship") == '03'
        relative_relationships << :parents_domestic_partner
      elsif c("Option Caretaker Relative Relationship") == '04'
        ApplicationVariables::RELATIONSHIP_CODES.values
      end
    end

    rule "Dependent Child Age Logic – Child under dependent age" do
      if v("Child Age") < c("Dependent Age Threshold")
        o["Child of Caretaker Dependent Age Indicator"] = 'Y' 
        o["Child of Caretaker Dependent Age Determination Date"] = current_date
        o["Child of Caretaker Dependent Age Ineligibility Reason"] = 999
      end
    end
    
    rule "Dependent Child Age Logic – Child older than dependent age" do
      if v("Child Age") > c("Dependent Age Threshold")
        o["Child of Caretaker Dependent Age Indicator"] = 'N'
        o["Child of Caretaker Dependent Age Determination Date"] = current_date
        o["Child of Caretaker Dependent Age Ineligibility Reason"] = 147
      end
    end
    
    rule "Dependent Child Age Logic – Child equal to dependent age and a student" do
      if c("Option Dependent Student") == 'Y' && v("Child Age") == c("Dependent Age Threshold") && v("Student Indicator") == 'Y'
        o["Child of Caretaker Dependent Age Indicator"] = 'Y'
        o["Child of Caretaker Dependent Age Determination Date"] = current_date
        o["Child of Caretaker Dependent Age Ineligibility Reason"] = 999
      end
    end

    rule "Dependent Child Age Logic – Child is equal to dependent age but not a student" do
      if c("Option Dependent Student") == 'Y' && v("Child Age") == c("Dependent Age Threshold") && v("Student Indicator") == 'N'
        o["Child of Caretaker Dependent Age Indicator"] = 'N'
        o["Child of Caretaker Dependent Age Determination Date"] = current_date
        o["Child of Caretaker Dependent Age Ineligibility Reason"] = 137
      end
    end

    rule "Dependent Deprived of Parental Support" do
      if c("Deprivation Requirement Retained") == 'N' 
        o["Child of Caretaker Deprived Child Indicator"] = 'X'
        o["Child of Caretaker Deprived Child Determination Date"] = current_date
        o["Child of Caretaker Deprived Child Ineligibility Reason"] = 555
      elsif v("Number of Parents Living With") < 2 || v("Parents Work 100 Hours Per Month") == 'N'
        o["Child of Caretaker Deprived Child Indicator"] = 'Y'
        o["Child of Caretaker Deprived Child Determination Date"] = current_date
        o["Child of Caretaker Deprived Child Ineligibility Reason"] = 999
      else
        o["Child of Caretaker Deprived Child Indicator"] = 'N'
        o["Child of Caretaker Deprived Child Determination Date"] = current_date
        o["Child of Caretaker Deprived Child Ineligibility Reason"] = 129
      end
    end

    rule "Determine whether caretaker meets relationship requirements" do
      if c("Option Caretaker Relative Relationship") == "04"
        if v("Caretaker Age") >= c("Child Age Threshold")
          o["Child of Caretaker Relationship Indicator"] = 'Y'
          o["Child of Caretaker Relationship Determination Date"] = current_date
          o["Child of Caretaker Relationship Ineligibility Reason"] = 999
        else
          o["Child of Caretaker Relationship Indicator"] = 'N'
          o["Child of Caretaker Relationship Determination Date"] = current_date
          o["Child of Caretaker Relationship Ineligibility Reason"] = 130
        end
      elsif v("Valid Relationships").include?(v("Relationship Type"))
        o["Child of Caretaker Relationship Indicator"] = 'Y'
        o["Child of Caretaker Relationship Determination Date"] = current_date
        o["Child of Caretaker Relationship Ineligibility Reason"] = 999
      elsif c("Option Caretaker Relative Relationship") == "00"
        o["Child of Caretaker Relationship Indicator"] = 'N'
        o["Child of Caretaker Relationship Determination Date"] = current_date
        o["Child of Caretaker Relationship Ineligibility Reason"] = 132
      elsif c("Option Caretaker Relative Relationship") == "01"
        o["Child of Caretaker Relationship Indicator"] = 'N'
        o["Child of Caretaker Relationship Determination Date"] = current_date
        o["Child of Caretaker Relationship Ineligibility Reason"] = 131
      else
        o["Child of Caretaker Relationship Indicator"] = 'N'
        o["Child of Caretaker Relationship Determination Date"] = current_date
        o["Child of Caretaker Relationship Ineligibility Reason"] = 389
      end
    end
  end
end
