# encoding: UTF-8

module MAGI
  class ParentCaretakerRelative < Ruleset
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
          (rel.person.person_attributes["Applicant Age"] < c("Dependent Age Threshold") ||
            (c("Option Dependent Student") == "Y" &&
              rel.person.person_attributes["Student Indicator"] == "Y" &&
              rel.person.person_attributes["Applicant Age"] < c("Dependent Age Threshold")))
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
  end
end
