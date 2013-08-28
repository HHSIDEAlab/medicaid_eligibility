# encoding: UTF-8

module Medicaid::Eligibility::Category
  class ParentCaretakerRelative < Ruleset
    name        "Identify Medicaid Category – Parent or Caretaker Relative"
    mandatory   "Mandatory"
    references  "§435.4 and §435.110"
    applies_to  "Medicaid only"
    purpose     "Identify if an applicant is a caretaker relative or a parent of a dependent child."
    #description "*** Description is very long. Will be handled later ***"

    assumption "States that elect the option to cover parent or caretaker relatives at an FPL% above 133% FPL will set the higher FPL% in their state configuration; the rule is otherwise unchanged to accommodate this option."
    assumption "One of the primary inputs to this rule is a list of children to be evaluated as to whether the applicant assumes primary responsibility for them.  This list is built outside the rule and consists of unique values for 1) children and stepchildren of the applicant and 2) children the applicant has claimed as a tax dependent and 3) any children for whom the applicant has attested to providing primary support.  The child is only added to the list if the applicant lives with the child. Before adding the child to the list because of the parent criteria, the rule will check if child was claimed as a tax dependent by someone other than the parent or if someone other than the parent attests to primary responsibility. If so, the child won’t be added to the list for the parent."
    assumption "A child must satisfy all four conditions (dependent child age, deprived of parental support, relationship and applicant assumes primary responsibility) in order for the applicant to qualify for the Parent Caretaker Relative category."

    input "Applicant List", "Application", "List"
    input "Person ID", "Application", "Integer"
    input "Person List", "Application", "List"
    input "Applicant Relationships", "Application", "List"
    input "Applicant Age", "Application", "Integer"
    input "Physical Household", "Application", "List"
    input "Tax Returns", "Application", "List"
    
    config "Dependent Age Threshold", "System Configuration", "Integer", nil, 18
    config "Option Dependent Student", "State Configuration", "Char(1)", %w(Y N)
    config "Deprivation Requirement Retained", "State Configuration", "Char(1)", %w(Y N)
    config "Option Caretaker Relative Relationship", "State Configuration", "Char(2)", %w(00 01 02 03 04)

    # Get children who (1) the applicant is the parent of, (2) the 
    # applicant attests primary responsibility for, (3) the applicant
    # claims as a dependent on their tax return
    calculated "Applicant Child List" do
      v("Applicant Relationships").select{|relationship|
        [:child, :stepchild].include?(relationship.relationship) ||
        relationship.relationship_attributes["Attest Primary Responsibility"] == 'Y'
      }.map{|relationship|
        relationship.person
      }.concat(
        v("Tax Returns").select{|tr| tr.filers.any?{|f| f.person_id == v("Person ID")}}.map{|tr| tr.dependents}.flatten
      ).uniq.select{|person|
        v("Applicant List").include? person
      }.map{|child|
        {
          "Person ID" => child.person_id,
          "Relationship" => child.relationships.find{|r| r.person.person_id == v("Person ID")}.relationship
        }.merge(child.person_attributes).merge(child.applicant_attributes)
      }
    end

    indicator "Applicant Parent Caretaker Category Indicator", %w(Y N T)
    date      "Parent Caretaker Category Determination Date"
    code      "Parent Caretaker Category Ineligibility Reason", %w(999 146)
    output    "Children List", "List", nil,
      :element => {
        "Person ID" => {
          :type => :string
        },
        "Child of Caretaker Dependent Age Indicator" => {
          :type => :indicator,
          :possible_values => %w(Y N)
        },
        "Child of Caretaker Dependent Age Determination Date" => {
          :type => :date
        },
        "Child of Caretaker Dependent Age Ineligibility Reason" => {
          :type => :code,
          :possible_values => %w(999 137 147)
        },
        "Child of Caretaker Deprived Child Indicator" => {
          :type => :indicator,
          :possible_values => %w(Y N T X)
        },
        "Child of Caretaker Deprived Child Determination Date" => {
          :type => :date
        },
        "Child of Caretaker Deprived Child Ineligibility Reason" => {
          :type => :code,
          :possible_values => %w(999 555)
        },
        "Child of Caretaker Relationship Indicator" => {
          :type => :indicator,
          :possible_values => %w(Y N)
        },
        "Child of Caretaker Relationship Determination Date" => {
          :type => :date
        },
        "Child of Caretaker Relationship Ineligibility Reason" => {
          :type => :code,
          :possible_values => %w(999 130 131 132 389)
        }
      }
    output    "Qualified Children List", "List"
    
    def run(context)
      self.class.calculateds.each do |cvar|
        cvar.run(context)
      end

      children_list = context.v("Applicant Child List").map{|child| {"Person ID" => child["Person ID"]}}
      
      for c_in, c_out in context.v("Applicant Child List").zip(children_list)
        context.input["Current Child"] = c_in
        self.class.rules[0..13].each do |rule|
          rule.run(context)
        end
        c_out.merge!(context.o)

        context.input.delete("Current Child")
        context.o.delete_if{|_| true}
      end

      context.o["Children List"] = children_list
      
      self.class.rules[14..-1].each do |rule|
        rule.run(context)
      end

      context        
    end

    # per-child rules

    rule "Dependent Child Age Logic – Child under dependent age" do
      if v("Current Child")["Applicant Age"] < c("Dependent Age Threshold")
        o["Child of Caretaker Dependent Age Indicator"] = 'Y' 
        o["Child of Caretaker Dependent Age Determination Date"] = current_date
        o["Child of Caretaker Dependent Age Ineligibility Reason"] = 999
      end
    end
    
    rule "Dependent Child Age Logic – Child older than dependent age" do
      if v("Current Child")["Applicant Age"] > c("Dependent Age Threshold")
        o["Child of Caretaker Dependent Age Indicator"] = 'N'
        o["Child of Caretaker Dependent Age Determination Date"] = current_date
        o["Child of Caretaker Dependent Age Ineligibility Reason"] = 147
      end
    end
    
    rule "Dependent Child Age Logic – Child equal to dependent age and a student" do
      if c("Option Dependent Student") == 'Y' && v("Current Child")["Applicant Age"] == c("Dependent Age Threshold") && v("Current Child")["Student Indicator"] == 'Y'
        o["Child of Caretaker Dependent Age Indicator"] = 'Y'
        o["Child of Caretaker Dependent Age Determination Date"] = current_date
        o["Child of Caretaker Dependent Age Ineligibility Reason"] = 999
      end
    end

    rule "Dependent Child Age Logic – Child is equal to dependent age but not a student" do
      if c("Option Dependent Student") == 'Y' && v("Current Child")["Applicant Age"] == c("Dependent Age Threshold") && v("Current Child")["Student Indicator"] == 'N'
        o["Child of Caretaker Dependent Age Indicator"] = 'N'
        o["Child of Caretaker Dependent Age Determination Date"] = current_date
        o["Child of Caretaker Dependent Age Ineligibility Reason"] = 137
      end
    end

    rule "Dependent Deprived of Parental Support – Requirement not retained by state" do
      if c("Deprivation Requirement Retained") == 'N' 
        o["Child of Caretaker Deprived Child Indicator"] = 'X'
        o["Child of Caretaker Deprived Child Determination Date"] = current_date
        o["Child of Caretaker Deprived Child Ineligibility Reason"] = 555
      end
    end

    rule "Dependent Deprived of Parental Support – Requirement retained by state" do
      if c("Deprivation Requirement Retained") == 'Y' 
        o["Child of Caretaker Deprived Child Indicator"] = 'T'
        o["Child of Caretaker Deprived Child Determination Date"] = current_date
        o["Child of Caretaker Deprived Child Ineligibility Reason"] = 999
      end
    end
    
    rule "Caretaker Relationship – Caretaker meets standard definition" do
      if c("Option Caretaker Relative Relationship") == "00" && [:parent, :sibling, :stepparent, :uncle_aunt, :grandparent, :cousin, :sibling_in_law].include?(v("Current Child")["Relationship"])
        o["Child of Caretaker Relationship Indicator"] = 'Y'
        o["Child of Caretaker Relationship Determination Date"] = current_date
        o["Child of Caretaker Relationship Ineligibility Reason"] = 999
      end
    end
    
    rule "Caretaker Relationship – Caretaker does not meet standard definition" do
      if c("Option Caretaker Relative Relationship") == "00" && !([:parent, :sibling, :stepparent, :uncle_aunt, :grandparent, :cousin, :sibling_in_law].include?(v("Current Child")["Relationship"]))
        o["Child of Caretaker Relationship Indicator"] = 'N'
        o["Child of Caretaker Relationship Determination Date"] = current_date
        o["Child of Caretaker Relationship Ineligibility Reason"] = 132
      end
    end
    
    rule "Caretaker Relationship – Caretaker meets any relative definition" do
      if c("Option Caretaker Relative Relationship") == "01" && [:parent, :sibling, :stepparent, :uncle_aunt, :grandparent, :cousin, :sibling_in_law, :former_spouse, :parent_in_law].include?(v("Current Child")["Relationship"])
        o["Child of Caretaker Relationship Indicator"] = 'Y'
        o["Child of Caretaker Relationship Determination Date"] = current_date
        o["Child of Caretaker Relationship Ineligibility Reason"] = 999
      end
    end

    rule "Caretaker Relationship – Caretaker does not meet any relative definition" do
      if c("Option Caretaker Relative Relationship") == "01" && !([:parent, :sibling, :stepparent, :uncle_aunt, :grandparent, :cousin, :sibling_in_law, :former_spouse, :parent_in_law].include?(v("Current Child")["Relationship"]))
        o["Child of Caretaker Relationship Indicator"] = 'N'
        o["Child of Caretaker Relationship Determination Date"] = current_date
        o["Child of Caretaker Relationship Ineligibility Reason"] = 131
      end
    end

    rule "Caretaker Relationship – Any Adult – Caretaker is an adult" do
      if c("Option Caretaker Relative Relationship") == "04" && v("Applicant Age") >= c("Child Age Threshold")
        o["Child of Caretaker Relationship Indicator"] = 'Y'
        o["Child of Caretaker Relationship Determination Date"] = current_date
        o["Child of Caretaker Relationship Ineligibility Reason"] = 999
      end
    end

    rule "Caretaker Relationship – Any Adult – Caretaker is not an Adult" do
      if c("Option Caretaker Relative Relationship") == "04" && v("Applicant Age") < c("Child Age Threshold")
        o["Child of Caretaker Relationship Indicator"] = 'N'
        o["Child of Caretaker Relationship Determination Date"] = current_date
        o["Child of Caretaker Relationship Ineligibility Reason"] = 130
      end
    end
    
    rule "Caretaker Relationship – Domestic Partner – Individual is domestic partner" do
      if c("Option Caretaker Relative Relationship") == "02" && v("Current Child")["Relationship"] == :parents_domestic_partner
        o["Child of Caretaker Relationship Indicator"] = 'Y'
        o["Child of Caretaker Relationship Determination Date"] = current_date
        o["Child of Caretaker Relationship Ineligibility Reason"] = 999
      end
    end

    rule "Caretaker Relationship – Domestic Partner Individual is not the domestic partner" do
      if c("Option Caretaker Relative Relationship") == "02" && v("Current Child")["Relationship"] != :parents_domestic_partner
        o["Child of Caretaker Relationship Indicator"] = 'N'
        o["Child of Caretaker Relationship Determination Date"] = current_date
        o["Child of Caretaker Relationship Ineligibility Reason"] = 389
      end
    end
    
    # rules to set category

    rule "Applicant Child list is empty – no children" do
      if o["Children List"].empty?
        o["Applicant Parent Caretaker Category Indicator"] = 'N'
        o["Parent Caretaker Category Determination Date"] = current_date
        o["Parent Caretaker Category Ineligibility Reason"] = 146
      end
    end

    rule "Child of Caretaker meets all criteria" do 
      o["Qualified Children List"] = o["Children List"].select{|child|
        child["Child of Caretaker Dependent Age Indicator"] == 'Y' &&
        child["Child of Caretaker Relationship Indicator"] == 'Y' &&
        %w(X T).include?(child["Child of Caretaker Deprived Child Indicator"])
      }
    end

    rule "State retains deprivation requirement - awaiting deprivation logic" do
      if o["Qualified Children List"].any? && c("Deprivation Requirement Retained") == 'Y'
        o["Applicant Parent Caretaker Category Indicator"] = 'T'
        o["Parent Caretaker Category Determination Date"] = current_date
        o["Parent Caretaker Category Ineligibility Reason"] = 999
      end
    end

    rule "State does not retain deprivation requirement" do
      if o["Qualified Children List"].any? && c("Deprivation Requirement Retained") == 'N'
        o["Applicant Parent Caretaker Category Indicator"] = 'Y'
        o["Parent Caretaker Category Determination Date"] = current_date
        o["Parent Caretaker Category Ineligibility Reason"] = 999
      end
    end

    rule "No children qualify" do
      if o["Qualified Children List"].empty?
        o["Applicant Parent Caretaker Category Indicator"] = 'N'
        o["Parent Caretaker Category Determination Date"] = current_date
        o["Parent Caretaker Category Ineligibility Reason"] = 146
      end
    end

    special_instruction "The Dependent Age Threshold is set as a variable for system configurability, not to support a state option. The value is set to 18."
  end
end
