# encoding: UTF-8

module MAGI
  class OptionalTargetedLowIncomeChildrenOtherCoverage < Ruleset
    name        "Optional, Targeted Low-Income Children- Other Coverage"
    mandatory   "Optional"
    references  "§435.229"
    applies_to  "Medicaid Only"
    purpose     "Determine if the applicant is in the optional targeted low-income child category."
    description "A child can be eligible under his optional eligibility group only if the child is not covered by other insurance. This rule checks for an Optional Targeted Low-Income category indicator equal to “T” (Temporary) as set in MAGI Part 1.  The category indicator is reset in this rule based on whether or not the child is enrolled in other creditable coverage.\nStates can specify the age range to which the optional targeted, low-income children option applies, including a range low to high (e.g., 6-18) or under a specified age (e.g., < 1). (§435.229)  This rule addresses whether the child has other insurance."
    
    assumption "A child can be in both the main child category and the optional, targeted low-income category."
    assumption "The applicant is flagged for this category in the MAGI Part 1 logic.  The requirement that the child not be covered by other insurance could not be evaluated at that time as the information from the application was not yet available."

    input "Applicant Age", "Child Category Rule", "Number"  
    input "Is Enrolled", "Application", "Char(1)", %w(Y N)
    input "Applicable Medicaid Standard Basis", "Applicable Standard Rule", "Char(2)", %w(01 02 03 04 05 06)
    input "Applicant Optional Targeted Low Income Child Category Indicator", "Char(1)", %w(Y N T X)

    config "Optional Targeted Low Income Child Group", "State configuration table", "Char(1)", %w(Y N)
    config "Optional Targeted Low Income Child Age Low Threshold", "State configuration table", "Numeric", nil, 0
    config "Optional Targeted Low Income Child Age High Threshold", "State configuration table", "Numeric", nil, 19

    # Outputs 
    indicator "Applicant Optional Targeted Low Income Child Category Indicator", %w(Y N T X)
    date      "Optional Targeted Low Income Child Determination Date"
    code      "Optional Targeted Low Income Child Ineligibility Reason", %w(999 114 555)
    output    "Redetermine Applicable Standard", "Char(1)", %w(Y N)
    output    "Applicant Optional Targeted Low-Income Child Medicaid Standard", "Number"
    output    "Applicable Medicaid Standard Basis", "Char(2)", %w(01 02 03 04 05 06)

    rule "Rule does not apply" do 
      if v("Applicant Optional Targeted Low Income Child Category Indicator") != 'T'
      end
    end

    rule "Applicant does not have other coverage" do
      if v("Is Enrolled") == 'N' 
        o["Applicant Optional Targeted Low Income Child Category Indicator"] = 'Y'
        o["Optional Targeted Low Income Child Determination Date"] = current_date
        o["Optional Targeted Low Income Child Ineligibility Reason"] = 999
        o["Redetermine Applicable Standard"] = 'N'
      end
    end

    rule "Applicant has other coverage and applicable MAGI standard was optional, targeted low-income child" do
      if v("Is Enrolled") == 'Y' && v("Applicable Medicaid Standard Basis") == '05' 
        o["Applicant Optional Targeted Low Income Child Category Indicator"] = 'N'
        o["Optional Targeted Low Income Child Determination Date"] = current_date
        o["Optional Targeted Low Income Child Ineligibility Reason"] = 114
        o["Redetermine Applicable Standard"] = 'Y'
        o["Applicant Optional Targeted Low-Income Child Medicaid Standard"] = 0
        o["Applicable Medicaid Standard Basis"] = nil
      end
    end

    rule "Applicant has other coverage, applicable MAGI standard was not optional, targeted low-income child" do
      if v("Is Enrolled") == 'Y' && v("Applicable Medicaid Standard Basis") != '05'
        o["Applicant Optional Targeted Low Income Child Category Indicator"] = 'N'
        o["Optional Targeted Low Income Child Determination Date"] = current_date
        o["Optional Targeted Low Income Child Ineligibility Reason"] = 114
        o["Redetermine Applicable Standard"] = 'N'
        o["Applicant Optional Targeted Low-Income Child Medicaid Standard"] = 0
      end
    end

    special_instruction "When Redetermine Applicable Standard = Y, reset the applicable standard and rerun the income eligibility."
  end
end
