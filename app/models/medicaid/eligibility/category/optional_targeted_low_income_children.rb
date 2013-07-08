# encoding: UTF-8

module Medicaid::Eligibility::Category
  class OptionalTargetedLowIncomeChildren < Ruleset
    name        "Optional Targeted Low-Income Children"
    mandatory   "Optional"
    references  "§435.229"
    applies_to  "Medicaid Only"
    purpose     "Determine if the applicant is in the optional, targeted low-income child category."
    description "Optional, targeted low-income children is a Medicaid group only for uninsured children under age 19 with household income exceeding the limit for the child’s age under §435.118 and no more than the limit established by the State for this optional group.  Generally, Medicaid does not deny eligibility to individuals with other coverage.  However, this optional group only applies if the child is not covered by other insurance (creditable coverage). This rule addresses only whether a child is the required age range; information regarding enrollment in other health insurance coverage has not yet been obtained from the applicant.\nStates can cover all children under age 19 under this optional group or specify an age range to which the optional targeted low-income child category applies, including a range low to high (e.g., 6-18) or under a specified age (e.g., < 1)(435.229)."
    
    assumption "A child can be in both the main Medicaid child category, the optional, targeted low-income category and the CHIP targeted low-income category."  
    assumption "The low and high age thresholds are inclusive of children who meet the requirements for this category."
    assumption "This rule can only set a temporary indicator for inclusion in this group as the question regarding whether the child has other coverage is not asked until after this logic is run.  In MAGI Part 3, a rule is run to check whether the child has other health insurance coverage and reset this indicator to yes or no.  If the child is not eligible for this category and it was used as the basis for the applicant’s applicable FPL standard, the applicable standard is re-determined and the income eligibility logic is re-run."

    input "Applicant Age", "From Child Category Rule", "Number"  

    config "Optional Targeted Low Income Child Group", "State configuration table", "Char(1)", %w(Y N)
    config "Optional Targeted Low Income Child Age Low Threshold", "State configuration table", "Numeric", "Default 0"
    config "Optional Targeted Low Income Child Age High Threshold", "State configuration table", "Numeric", "Default 19"

    # Outputs 
    indicator "Applicant Optional Targeted Low Income Child Category Indicator", %w(Y N T X)
    date      "Optional Targeted Low Income Child Determination Date"
    code      "Optional Targeted Low Income Child Ineligibility Reason", %w(999 555 127)

    rule "State does not elect this option" do
      if c("Optional Targeted Low Income Child Group") == 'N'
        o["Applicant Optional Targeted Low Income Child Category Indicator"] = 'X'
        o["Optional Targeted Low Income Child Determination Date"] = current_date
        o["Optional Targeted Low Income Child Ineligibility Reason"] = 555
      end
    end

    rule "Child right age for this category" do
      if c("Optional Targeted Low Income Child Group") == 'Y' && v("Applicant Age") >= c("Optional Targeted Low Income Child Age Low Threshold") && v("Applicant Age") <= c("Optional Targeted Low Income Child Age High Threshold")
        o["Applicant Optional Targeted Low Income Child Category Indicator"] = 'T'
        o["Optional Targeted Low Income Child Determination Date"] = current_date
        o["Optional Targeted Low Income Child Ineligibility Reason"] = 999
      end
    end

    rule "Child not the right age for this category" do
      if c("Optional Targeted Low Income Child Group") == 'Y' && (v("Applicant Age") < c("Optional Targeted Low Income Child Age Low Threshold") || v("Applicant Age") > c("Optional Targeted Low Income Child Age High Threshold"))
        o["Applicant Optional Targeted Low Income Child Category Indicator"] = 'N'
        o["Optional Targeted Low Income Child Determination Date"] = current_date
        o["Optional Targeted Low Income Child Ineligibility Reason"] = 127
      end
    end
  end
end
