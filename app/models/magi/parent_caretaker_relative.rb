# encoding: UTF-8

module MAGI
  class ParentCaretakerRelative < Ruleset
    name        "Identify Medicaid Category – Parent or Caretaker Relative"
    mandatory   "Mandatory"
    references  "§435.4 and §435.110"
    applies_to  "Medicaid only"
    purpose     "Identify if an applicant is a caretaker relative or a parent of a dependent child."
    #description "*** Description is very long. Will be handled later ***"

    assumption "States that elect the option to cover parent or caretaker relatives at an FPL% above 133% FPL will set the higher FPL% in their state configuration; the rule is otherwise unchanged to accommodate this option."
    assumption "One of the primary inputs to this rule is a list of children to be evaluated as to whether the applicant assumes primary responsibility for them.  This list is built outside the rule and consists of unique values for 1) children and stepchildren of the applicant and 2) children the applicant has claimed as a tax dependent and 3) any children for whom the applicant has attested to providing primary support.  The child is only added to the list if the applicant lives with the child. Before adding the child to the list because of the parent criteria, the rule will check if child was claimed as a tax dependent by someone other than the parent or if someone other than the parent attests to primary responsibility. If so, the child won’t be added to the list for the parent."

    input "Person ID", "Application", "Integer"
    input "Person List", "Application", "List"
    input "Physical Household", "Application", "Household Object"
    input "Tax Returns", "Application", "List"
    input "Applicant Age", "Application", "Integer"
    input "Applicant Relationships", "Application", "List"
    
    config "Child Age Threshold", "System Configuration", "Integer", nil, 19
    config "Dependent Age Threshold", "System Configuration", "Integer", nil, 18
    config "Option Dependent Student", "State Configuration", "Char(1)", %w(Y N)
    config "Deprivation Requirement Retained", "State Configuration", "Char(1)", %w(Y N)
    config "Option Caretaker Relative Relationship", "State Configuration", "Char(2)", %w(00 01 02 03 04)
    config "State Unemployed Standard", "State Configuration", "Integer", (100..744), 100

    calculated "Applicant Child List" do
      tax_return = v("Tax Returns").find{|tr| tr.filers.any?{|filer| filer.person_id == v("Person ID")}}

      # Case 1: Parent who lives with child
      children = v("Applicant Relationships").select{|rel|
        [:child, :stepchild].include?(rel.relationship_type)}.map{|rel| rel.person}
      children.select!{|child| v("Physical Household").people.include?(child)}

      # Case 1 exception 1: Exclude if an adult person in the household 
      # claims the child as a tax dependent (other than this applicant's
      # tax return)
      children.delete_if{|child| v("Tax Returns").any?{|tr| tr.dependents.include?(child) && tr != tax_return && tr.filers.any?{|filer| filer.person_attributes["Applicant Age"] >= c("Child Age Threshold") && v("Physical Household").people.include?(filer)}}}

      # Case 1 exception 2: Exclude if an adult person claims primary
      # responsibility for the child (other than this applicant)
      children.delete_if{|child| v("Person List").any?{|p| p.person_id != v("Person ID") && p.person_attributes["Applicant Age"] >= c("Child Age Threshold") && p.relationships.any?{|rel| rel.person == child && rel.relationship_attributes["Attest Primary Responsibility"] == 'Y'}}}

      # Case 2: Tax filer claims child as dependent and lives with child
      if tax_return
        dependents = tax_return.dependents
        children += dependents.select{|child| v("Physical Household").people.include?(child)}
      end

      # Case 3: Adult applicant attests to primary responsibility for child # under the primary responsibility age limit
      if v("Applicant Age") >= c("Child Age Threshold")
        responsible_children = v("Applicant Relationships").select{|rel| 
          rel.relationship_attributes["Attest Primary Responsibility"] == 'Y' && 
          (rel.person.person_attributes("Applicant Age") < c("Dependent Age Threshold") ||
            (c("Option Dependent Student") == "Y" &&
              rel.person.person_attributes("Student Indicator") == "Y" &&
              rel.person.person_attributes("Applicant Age") < c("Dependent Age Threshold")))
          }.map{|rel| rel.person}

        # Exception: Exclude if someone else (adult or not) claims the 
        # child on a tax return
        responsible_children.delete_if{|child| v("Tax Returns").any?{|tr| tr.dependents.include?(child) && tr != tax_return && tr.filers.any?{|filer| v("Physical Household").people.include?(filer)}}}

        children += responsible_children
      end

      children.uniq!

      # Run all children through the QualifiedChild rule
      qualified_child_rule = MAGI::QualifiedChild.new()
      child_list = []
      for child in children
        child_input = {
          "Caretaker Age"      => v("Applicant Age"),
          "Child Age"          => child.person_attributes["Applicant Age"],
          "Child Parents"      => child.relationships.select{|r| r.relationship_type == :parent}.map{|r| r.person},
          "Physical Household" => v("Physical Household"),
          "Relationship Type"  => child.relationships.find{|r| r.person.person_id == v("Person ID")}.relationship_type,
          "Student Indicator"  => child.person_attributes["Applicant Age"]
        }
        
        context = RuleContext.new(config, child_input, current_date)
        qualified_child_rule.run(context)
        
        child_list << {"Person ID" => child.person_id}.merge(context.output)
      end

      child_list
    end

    indicator "Applicant Parent Caretaker Category Indicator", %w(Y N)
    date      "Parent Caretaker Category Determination Date"
    code      "Parent Caretaker Category Ineligibility Reason", %w(999 146)
    output    "Qualified Children List", "List"

    rule "Applicant Child list is empty – no children" do
      if v("Applicant Child List").empty?
        o["Applicant Parent Caretaker Category Indicator"] = 'N'
        o["Parent Caretaker Category Determination Date"] = current_date
        o["Parent Caretaker Category Ineligibility Reason"] = 146
      end
    end

    rule "Child of Caretaker meets all criteria" do
      o["Qualified Children List"] = v("Applicant Child List").select{|child|
        child["Child of Caretaker Dependent Age Indicator"] == 'Y' &&
        child["Child of Caretaker Relationship Indicator"] == 'Y' &&
        %w(Y X).include?(child["Child of Caretaker Deprived Child Indicator"])
      }
    end

    rule "Some children qualify" do
      if o["Qualified Children List"].any?
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
