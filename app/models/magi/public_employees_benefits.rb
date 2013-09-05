# encoding: UTF-8

module MAGI
  class PublicEmployeesBenefits < Ruleset
    name        "State Health Benefits through Public Employees "
    mandatory   "Optional"
    references  "§SHO#11-002\nACA # 15\n§457.310"
    applies_to  "CHIP only"
    purpose     "This rule checks to see if the applicant has access to coverage under a state health benefits plan and, for applicants that do, determines whether the state option extends them CHIP coverage."
    description "Children historically have not been eligible for CHIP if the child has access to coverage under a state health benefits plan by virtue of a family member’s employment with a public agency and the state contributes at least $10 to the cost of dependent coverage under the state health benefits plan. The same rule applies to pregnant women with access to such coverage (through their own employment) in states that cover pregnant women under CHIP.  However, CHIPRA provides states with the option to choose to cover all children, a subset of children (for example, those with income below a certain threshold) as well as pregnant women with access to a state health benefits plan."
    
    assumption "States can opt to cover applicants with access to state health benefits that cover all such applicants under CHIP (provided that other eligibility criteria are met) or may extend coverage only to defined subsets of applicants. The Exchange will support the following state options:\n- Deny CHIP eligibility to all applicants with access to state health benefit plan (these are states that have not exercised the option to cover any such applicants under CHIP);\nCover all applicants with access to a state health benefit plan;\nCover applicants with access to a state health benefits plan if their income is below a specific level.\nIf the state has opted to cover a subset of applicants based on criteria not listed above, the Exchange will not determine whether or not the applicant falls into the subset covered.  The account information will be transferred to the state as eligible. The state may apply additional logic if necessary to confirm eligibility."
    assumption "Note that a state which contributes less than $10 to dependent coverage under the state health benefit plan will be included in the configuration table as a state which covers all applicants with access to such coverage."
      
    input "State Health Benefits Through Public Employee", "Application", "Char(1)", %w(Y N)
    input "Calculated Income", "Income logic", "Numeric"
    input "FPL", "Income logic", "Numeric"
    input "Applicant Medicaid Prelim Indicator", "Char(1)", %w(Y N)

    config "CHIP for State Health Benefits", "State Configuration", "Char(2)", %w(01 02 03 04)
    config "State Health Benefits FPL Standard", "State Configuration", "Numeric"

    determination "State Health Benefits CHIP", %w(Y N X), %w(999 555 138 155)

    rule "Applicant is Medicaid eligible  - rule does not apply" do
      if v("Applicant Medicaid Prelim Indicator") == 'Y' || v("State Health Benefits Through Public Employee") == 'N'
        determination_na "State Health Benefits CHIP"
      elsif c("CHIP for State Health Benefits") == "01"
        o["Applicant State Health Benefits CHIP Indicator"] = 'N'
        o["State Health Benefits CHIP Determination Date"] = current_date
        o["State Health Benefits CHIP Ineligibility Reason"] = 155
      elsif c("CHIP for State Health Benefits") == "02"
        determination_y "State Health Benefits CHIP"
      elsif c("CHIP for State Health Benefits") == "03"
        if v("Calculated Income") < v("FPL") * c("State Health Benefits FPL Standard")
          determination_y "State Health Benefits CHIP"
        else
          o["Applicant State Health Benefits CHIP Indicator"] = 'N'
          o["State Health Benefits CHIP Determination Date"] = current_date
          o["State Health Benefits CHIP Ineligibility Reason"] = 138
        end
      elsif c("CHIP for State Health Benefits") == "04"
        determination_y "State Health Benefits CHIP"
      else
        raise "Invalid value for config CHIP For State Health Benefits"
      end      
    end
  end
end

