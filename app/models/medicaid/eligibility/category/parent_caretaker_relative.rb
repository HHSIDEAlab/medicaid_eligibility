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

    # input "Applicant Child List", "System Logic", "List", nil, 
    #   :element => {
    #     "Person Birth Date" => {
    #       :source => "Application",
    #       :type => "Date"
    #     },
    #     "Student Indicator" => {
    #       :source => "Application", 
    #       :type => "Char(1)", 
    #       :possible_values => %w(Y N)
    #     },
    #     "Relationship Code (Caretaker to Dependent Child)" => {
    #       :source => "Application",
    #       :type => "Char(2)",
    #       :possible_values => %w(01 02 03 04 05 06 07 08 12 13 14 15 16 17 23 26 27 30)
    #     },
    #     "Lives With Child" => {
    #       :source => "Application",
    #       :type => "Char(1)",
    #       :possible_values => %w(Y N)
    #     }
    #   }
    input "Person List", "Application", "List"
    input "Applicant Relationships", "Application", "List"
    input "Applicant Age", "Application", "Integer"
    input "Student Indicator", "Application", "Char(1)", %w(Y N)
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
        relationship.relationship_code == "03" ||
        relationship.relationship_attributes["Attest Primary Responsibility"] == 'Y'
      }.map{|relationship|
        relationship.person
      }.concat(
        v("Tax Returns").select{|tr| tr.filers.any?{|f| f.person.person_id == v("Person ID")}}.map{|tr| tr.dependents}.flatten
      ).uniq
    end

    indicator "Applicant Parent Caretaker Category Indicator", %w(Y N T)
    date      "Parent Caretaker Category Determination Date"
    code      "Parent Caretaker Category Ineligibility Reason", %w(999 146)
    output    "Qualified Children List", "List", nil,
      :element => {
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
    
    def run(context)
      self.class.calculateds.each do |cvar|
        cvar.run(context)
      end

      context.o["Qualified Children List"] = Array.new(context.v("Applicant Child List").length, {})
      
      self.class.rules.each do |rule|
        rule.run(context)
      end

      context        
    end

    # rule "Dependent Child Age Logic – Child under dependent age" do
    #   for c_in, c_out in v("Applicant Child List").zip o["Qualified Children List"]
    #     if c_in["Dependent Child Age"] < c("Dependent Age Threshold")
    #       c_out["Child of Caretaker Dependent Age Indicator"] = 'Y' 
    #       c_out["Child of Caretaker Dependent Age Determination Date"] = current_date
    #       c_out["Child of Caretaker Dependent Age Ineligibility Reason"] = 999
    #     end
    #   end
    # end
    
    # rule "Dependent Child Age Logic – Child older than dependent age" do
    #   for c_in, c_out in v("Applicant Child List").zip o["Qualified Children List"]
    #     if c_in["Dependent Child Age"] > c("Dependent Age Threshold")
    #       c_out["Child of Caretaker Dependent Age Indicator"] = 'N'
    #       c_out["Child of Caretaker Dependent Age Determination Date"] = current_date
    #       c_out["Child of Caretaker Dependent Age Ineligibility Reason"] = 147
    #     end
    #   end
    # end
    
    # rule "Dependent Child Age Logic – Child equal to dependent age and a student" do
    #   for c_in, c_out in v("Applicant Child List").zip o["Qualified Children List"]
    #     if c("Option Dependent Student") == 'Y' && c_in["Dependent Child Age"] == c("Dependent Age Threshold") && c_in["Student Indicator"] == 'Y'
    #       c_out["Child of Caretaker Dependent Age Indicator"] = 'Y'
    #       c_out["Child of Caretaker Dependent Age Determination Date"] = current_date
    #       c_out["Child of Caretaker Dependent Age Ineligibility Reason"] = 999
    #     end
    #   end
    # end

    # 4.  Dependent Child Age Logic – Child is equal to dependent age but not a student When Option Dependent Student = Y and Dependent Child Age = Dependent Age Threshold and Student Indicator = N
    # Then Child of Caretaker Dependent Age Indicator= N and Child of Caretaker Dependent Age Determination Date = current date and Child of Caretaker Dependent Age Ineligibility Reason = 137
    # Continue to the Deprivation logic below with the current child record
    # 5.  Dependent Deprived of Parental Support – Requirement not retained by state  When Deprivation Requirement Retained = N 
    # Then Child of Caretaker Deprived Child Indicator =X and Child of Caretaker Deprived Child Determination Date = current date and  Child of Caretaker Deprived Child Ineligibility Reason = 555
    # Continue to the Relationship logic below with the current child record

    # 6.  Dependent Deprived of Parental Support – Requirement retained by state  When Deprivation Requirement Retained = Y 
    # Then Child of Caretaker Deprived Child Indicator =T and Child of Caretaker Deprived Child Determination Date = current date and  Child of Caretaker Deprived Child Ineligibility Reason = 999
    # Continue to the Relationship logic below with the current child record
    # 7.  Caretaker Relationship – Caretaker meets standard definition  When Option Caretaker Relative Relationship = 00 and Relationship Code(caretaker to dependent child) = (03, 07, 12, 13, 14, 15, 16, 23)
    # Then Child of Caretaker Relationship Indicator= Y and Child of Caretaker Relationship Determination Date = current date and Child of Caretaker Relationship Ineligibility Reason = 999
    # Get next record from Applicant Children list and begin at Dependent Age logic.
    # 8.  Caretaker Relationship – Caretaker does not meet standard definition  When Option Caretaker Relative Relationship = 00 and Relationship Code(caretaker to dependent child) <> (03, 07, 12, 13, 14, 15, 16, 23)
    # Then Child of Caretaker Relationship Indicator= N and Child of Caretaker Relationship Determination Date = current date and Child of Caretaker Relationship Ineligibility Reason = 132
    # Get next record from Applicant Children list and begin at Dependent Age logic.
    # 9.  Caretaker Relationship – Caretaker meets any relative definition  When Option Caretaker Relative Relationship = 01 and Relationship Code(caretaker to dependent child) = (03, 07, 12, 13, 14, 15, 16, 23, 27, 30)
    # Then Child of Caretaker Relationship Indicator= Y and Child of Caretaker Relationship Determination Date = current date and Child of Caretaker Relationship Ineligibility Reason = 999
    # Get next record from Applicant Children list and begin at Dependent Age logic.
    # 10. Caretaker Relationship – Caretaker does not meet any relative definition  When Option Caretaker Relative Relationship = 01 and Relationship Code(caretaker to dependent child) <>(03, 07, 12, 13, 14, 15, 16, 23, 27, 30)
    # Then Child of Caretaker Relationship Indicator= N and Child of Caretaker Relationship Determination Date = current date and Child of Caretaker Relationship Ineligibility Reason = 131
    # Get next record from Applicant Children list and begin at Dependent Age logic.
    # 11. Caretaker Relationship – Any Adult – Caretaker is an adult  When Option Caretaker Relative Relationship = 04 and Applicant Age >= Child Age Threshold
    # Then Child of Caretaker Relationship Indicator= Y and Child of Caretaker Relationship Determination Date = current date and Child of Caretaker Relationship Ineligibility Reason = 999
    # Get next record from Applicant Children list and begin at Dependent Age logic.
    # 12. Caretaker Relationship – Any Adult – Caretaker is not an Adult  When Option Caretaker Relative Relationship = 04 and Applicant Age < Child Age Threshold
    # Then Child of Caretaker Relationship Indicator= N and Child of Caretaker Relationship Determination Date = current date and Child of Caretaker Relationship Ineligibility Reason = 130
    # Get next record from Applicant Children list and begin at Dependent Age logic.
    # 13. Caretaker Relationship – Domestic Partner – Individual is domestic partner  When Option Caretaker Relative Relationship = 02 and Relationship Code(to child) = 17
    # Then Child of Caretaker Relationship Indicator= Y and Child of Caretaker Relationship Determination Date = current date and Child of Caretaker Relationship Ineligibility Reason = 999
    # Get next record from Applicant Children list and begin at Dependent Age logic.
    # 14. Caretaker Relationship – Domestic Partner Individual is not the domestic partner  When Option Caretaker Relative Relationship = 02 and Relationship Code(to child) <> 17
    # Then Child of Caretaker Relationship Indicator= N and Child of Caretaker Relationship Determination Date = current date and Child of Caretaker Relationship Ineligibility Reason = 389
    # Get next record from Applicant Children list and begin at Dependent Age logic.

    # Business Rule Logic: Set Parent Caretaker Category
    # 1.  Applicant Child list is empty – no children   When Applicant Children List is empty
    # Then Applicant Parent Caretaker Category Indicator = N and Parent Caretaker Category Determination Date = current date and Parent Caretaker Category Ineligibility Reason = 146
    # 2.  Child of Caretaker meets all criteria When Child of Caretaker Dependent Age Indicator= Y and Child of Caretaker Relationship Indicator= Y and Child of Caretaker Deprived Child Indicator = (X or T) 
    # Add child record to the Qualified Children list and get next child record
    # 3.  Child of Caretaker does not meet all criteria When Child of Caretaker Dependent Age Indicator= N or Child of Caretaker Deprived Child Indicator= N or Child of Caretaker Relationship Indicator= N
    # Then get next child record 
    # 4.  No more child records When Child of Caretaker Deprived Child Indicator=  T (for all records in Qualified Children list)
    # Then Applicant Parent Caretaker Category Indicator = T and Parent Caretaker Category Determination Date = current date and Parent Caretaker Category Ineligibility Reason = 999 
    # 5.  No more child records When Child of Caretaker Deprived Child Indicator <>  T (for all records in Qualified Children list)
    # Then Applicant Parent Caretaker Category Indicator = Y and Parent Caretaker Category Determination Date = current date and Parent Caretaker Category Ineligibility Reason = 999 
    # 6.  No more child records When Qualified Children List is empty
    # Then Applicant Parent Caretaker Category Indicator = N and Parent Caretaker Category Determination Date = current date and Parent Caretaker Category Ineligibility Reason = 146

    # Business Rule Logic: Spouse or Domestic Partner of Caretaker Relative
    # 1.  Caretaker Relationship – Spouse meets criteria  When Applicant Parent Caretaker Category Indicator = Y and Relationship Code(applicant to any other applicant) = 02 and (Spouse)Lives With (Applicant) = Y 
    # Then Applicant Parent Caretaker Category Indicator (for Spouse) = Y and Parent Caretaker Category Determination Date = current date and Parent Caretaker Category Ineligibility Reason = 999

    # 2.  Caretaker Relationship – Domestic Partner meets criteria  When Applicant Parent Caretaker Category Indicator = Y and Option Caretaker Relative Relationship = 02 or 03 and Relationship Code(applicant to any other applicant) = 08 and (Domestic Partner)Lives With (Applicant) = Y
    # Then Applicant Parent Caretaker Category Indicator (for Spouse) = Y and Parent Caretaker Category Determination Date = current date and Parent Caretaker Category Ineligibility Reason = 999


    # Constraints/ Special Instructions
    # 1.  The Dependent Age Threshold is set as a variable for system configurability, not to support a state option. The value is set to 18.

  end
end
