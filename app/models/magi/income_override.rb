# encoding: UTF-8

module MAGI
  class IncomeOverride < Ruleset
    name        "Income Override Rule"
    mandatory   "Mandatory"
    applies_to  "Medicaid Only"
    purpose     "Determine if the work quarters income override applies."
    description "Applicants who attest to income less than 100% FPL but greater than the applicable MAGI standard and who are not eligible for Medicaid because they have not met the Title II work quarters requirement (if applicable) or the five year waiting period (if applicable) may be eligible for APTC/CSR even though their income is less than 100% FPL. The income override rule for applicants not eligible for Medicaid due to the five year waiting period will be discussed elsewhere in the verification of household income rules.  The MAGI 3 logic sets a work quarters income override indicator and the income verification logic sets a five year bar override indicator for these applicants.  When one of these override indicators is set, the APTC Referral Indicator is set to “yes” so the applicant can be evaluated for APTC/CSR eligibility."
      
    input "Applicant Title II Work Quarters Met Indicator", "From 40 Title II Work Quarters logic", "Char(1)", %w(Y N X)
    input "Calculated Income", "From Income logic", "Number"
    input "FPL", "From Income logic", "Number"
    
    # Outputs
    determination "Work Quarters Override Income", %w(Y N), %w(999 338 339 340)
    indicator "APTC Referral Indicator", %w(Y N)
    
    rule "Income is greater than or equal to 100% FPL" do
      if v("Calculated Income") >= v("FPL")
        o["Applicant Work Quarters Override Income Indicator"] = 'N'
        o["Work Quarters Override Income Determination Date"] = current_date
        o["Work Quarters Override Income Ineligibility Reason"] = 340
      end
    end

    rule "Applicant met Title II Work Quarters requirement or rule did not apply" do
      if v("Calculated Income") < v("FPL") && v("Applicant Title II Work Quarters Met Indicator") != 'N'
        o["Applicant Work Quarters Override Income Indicator"] = 'N'
        o["Work Quarters Override Income Determination Date"] = current_date
        o["Work Quarters Override Income Ineligibility Reason"] = 338
      end
    end

    rule "Applicant did not meet Title II Work Quarters requirement" do
      if v("Calculated Income") < v("FPL") && v("Applicant Title II Work Quarters Met Indicator") == 'N'
        determination_y "Work Quarters Override Income"

        o["Applicant Medicaid Indicator"] = 'N'
        o["Medicaid Determination Date"] = current_date
        o["Medicaid Ineligibility Reason"] = 339
        o["Applicant CHIP Indicator"] = 'N'
        o["CHIP Determination Date"] = current_date
        o["CHIP Ineligibility Reason"] = 340
        o["APTC Referral Indicator"] = 'Y'
      end
    end
  end
end
