# encoding: UTF-8

module MAGI
  class AdultGroup < Ruleset
    name        "Identify Medicaid Category – Adult Group"
    references  "§435.119, 435.218 and §1902(a)(10)(A)(i)(VIII) & 1902(a)(10)(A)(ii)(XX) of the Social Security Act"
    applies_to  "Medicaid Only"
    purpose     "Determine if the new adult group category applies."
    description "Applicants whose age >= 19 and <65 who are not entitled to or enrolled in Medicare and not pregnant may be eligible for Medicaid under the adult group category (VIII group). States also have the option to cover individuals under age 65 with income above 133 percent FPL (optional XX group).  This rule sets an indicator for both the Adult Group and Adult XX Group, based on the age, pregnancy status and Medicare eligibility or entitlement of the applicant. The Exchange calls the Hub to ascertain whether the applicant is entitled to or enrolled in Medicare.\nAlthough pregnant applicants and applicants under age 19 are not precluded from eligibility under the optional Adult XX group, in this rule the Adult XX Group category is limited to applicants who are between ages 19 and 64 who are entitled to or enrolled in Medicare and who are not pregnant. This is because coverage under the XX group of pregnant women, children under 19 and adults between 19 and 64 who are not entitled to or enrolled in Medicare is implemented through adjusting the applicable income standards associated with the Child, Pregnant Women and Adult Group categories.\nThe FPL % will be set to 0 for those states who choose not to apply Medicaid expansion to the new adult group."

    assumption  "Whether the State opts to cover the adult group at the higher FPL% (i.e., the Adult Group XX) will be handled by the applicable MAGI standard logic." 

    input "Medicare Entitlement Indicator", "From the Hub", "Char(1)", %w(Y N) 
    input "Applicant Pregnancy Category Indicator", "Output from the Pregnant Women Category Rule", "Char(1)", %w(Y N)
    input "Applicant Age", "From Child Category Rule", "Number"  

    config "Option Adult Group XX", "State Configuration", "Char(1)", %w(Y N)

    # Outputs
    indicator "Applicant Adult Group Category Indicator", %w(Y N)
    date      "Adult Group Category Determination Date"  
    code      "Adult Group Category Ineligibility Reason", %w(999 117 122 123)
    indicator "Applicant Adult Group XX Category Indicator", %w(Y N X)
    date      "Adult Group XX Category Determination Date"
    code      "Adult Group XX Category Ineligibility Reason", %w(999 122 123)

    rule "Adult Group Category-Applicant not the right age" do  
      if v("Applicant Age") < 19 || v("Applicant Age") >= 65 
        o["Applicant Adult Group Category Indicator"] = 'N' 
        o["Adult Group Category Determination Date"] = current_date
        o["Adult Group Category Ineligibility Reason"] = 123 
      end
    end

    rule "Adult Group Category -Applicant is in pregnant women category" do
      if v("Applicant Pregnancy Category Indicator") == 'Y'
        o["Applicant Adult Group Category Indicator"] = 'N'
        o["Adult Group Category Determination Date"] = current_date
        o["Adult Group Category Ineligibility Reason"] = 122
      end
    end

    rule "Applicant is entitled to or enrolled in Medicare" do
      if v("Medicare Entitlement Indicator") == 'Y' 
        o["Applicant Adult Group Category Indicator"] = 'N'
        o["Adult Group Category Determination Date"] = current_date
        o["Adult Group Category Ineligibility Reason"] = 117 
      end
    end

    rule "Applicant is not entitled to or enrolled in Medicare" do
      if v("Medicare Entitlement Indicator") == 'N'
        o["Applicant Adult Group Category Indicator"] = 'Y'
        o["Adult Group Category Determination Date"] = current_date
        o["Adult Group Category Ineligibility Reason"] = 999
      end
    end

    rule "Adult XX Group: State does not elect this option" do
      if c("Option Adult Group XX") == 'N'
        o["Applicant Adult Group XX Category Indicator"] = 'X'
        o["Adult Group XX Category Determination Date"] = current_date
        o["Adult Group XX Category Ineligibility Reason"] = 555
      end
    end

    rule "Adult Group XX Category- applicant meets all criteria for Adult XX Group" do
      if c("Option Adult Group XX") == 'Y' && o["Applicant Adult Group Category Indicator"] == 'Y'
        o["Applicant Adult Group XX Category Indicator"] = 'Y'
        o["Adult Group XX Category Determination Date"] = current_date
        o["Adult Group XX Category Ineligibility Reason"] = 999
      end
    end

    rule "Adult Group XX Category - applicant meets all criteria for Adult XX  Group" do
      if c("Option Adult Group XX") == 'Y' && o["Applicant Adult Group Category Indicator"] == 'N' && v("Medicare Entitlement Indicator") == 'Y'
        o["Applicant Adult Group XX Category Indicator"] = 'Y'
        o["Adult Group XX Category Determination Date"] = current_date
        o["Adult Group XX Category Ineligibility Reason"] = 999
      end
    end

    special_instruction "If ineligible for the Adult Group, the applicable MAGI standard logic will need to check the State configuration table for the Adult Group XX FPL%."
  end
end
