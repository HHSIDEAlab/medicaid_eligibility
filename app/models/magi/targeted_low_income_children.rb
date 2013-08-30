# encoding: UTF-8

module MAGI
  class TargetedLowIncomeChildren < Ruleset
    name        "CHIP Targeted Low-Income Children"
    mandatory   "Optional"
    references  "§457.310"
    applies_to  "CHIP Only"
    purpose     "Determine if the applicant is in the CHIP targeted low-income child category."
    description "Per 42 CFR 457.310, states can cover under CHIP, children who are under age 19, not eligible for Medicaid and not enrolled in other health insurance coverage.  States can cover all children under age 19 meeting these criteria, or specify a range of ages, including a range low to high (e.g., 6-18) or under a specified age (e.g., < 1).\nThis rule addresses only whether a child is the required age range; information regarding enrollment in other health insurance coverage has not yet been obtained from the applicant."
    
    assumption  "A child can be in the main child category, the optional, targeted low-income category, and the targeted low-income category."
    assumption  "The low and high thresholds are inclusive of children who meet the requirements for this category."
    assumption  "This rule can only set a temporary indicator for inclusion in this group as the question regarding whether the child has other health insurance coverage is not asked until after this logic is run.  In MAGI Part 3, a rule is run to check whether the child has other coverage and reset this indicator to yes or no.  If the child is not eligible for this category and it was used as the basis for the applicant’s applicable FPL standard, the applicable standard is re-determined and the income eligibility logic is re-run."

    input "Applicant Age", "From Child Category Rule", "Number"  

    config "CHIP Targeted Low Income Child Group", "State configuration table", "Char(1)", %w(Y N)
    config "CHIP Targeted Low Income Child Age Low Threshold", "State configuration table", "Numeric", nil, 0
    config "CHIP Targeted Low Income Child Age High Threshold", "State configuration table", "Numeric", nil, 19

    # Outputs 
    indicator "Applicant CHIP Targeted Low Income Child Indicator", %w(Y N T X)
    date      "CHIP Targeted Low Income Child Determination Date"
    code      "CHIP Targeted Low Income Child Ineligibility Reason", %w(999 555 127)

    rule "State does not elect this option" do
      if c("CHIP Targeted Low Income Child Group") == 'N'
        o["Applicant CHIP Targeted Low Income Child Indicator"] = 'X'
        o["CHIP Targeted Low Income Child Determination Date"] = current_date
        o["CHIP Targeted Low Income Child Ineligibility Reason"] = 555
      end
    end
    
    rule "Child right age for this category" do
      if c("CHIP Targeted Low Income Child Group") == 'Y' && v("Applicant Age") >= c("CHIP Targeted Low Income Child Age Low Threshold") && v("Applicant Age") <= c("CHIP Targeted Low Income Child Age High Threshold")
        o["Applicant CHIP Targeted Low Income Child Indicator"] = 'T'
        o["CHIP Targeted Low Income Child Determination Date"] = current_date
        o["CHIP Targeted Low Income Child Ineligibility Reason"] = 999
      end
    end
    
    rule "Else - Child not the right age for this category" do 
      if c("CHIP Targeted Low Income Child Group") == 'Y' && (v("Applicant Age") < c("CHIP Targeted Low Income Child Age Low Threshold") || v("Applicant Age") > c("CHIP Targeted Low Income Child Age High Threshold"))
        o["Applicant CHIP Targeted Low Income Child Indicator"] = 'N'
        o["CHIP Targeted Low Income Child Determination Date"] = current_date 
        o["CHIP Targeted Low Income Child Ineligibility Reason"] = 127
      end
    end
  end
end
