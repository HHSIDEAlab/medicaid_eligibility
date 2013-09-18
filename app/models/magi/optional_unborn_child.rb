# encoding: UTF-8

module MAGI
  class OptionalUnbornChild < Ruleset
    name        "Optional CHIP Category - Unborn Child Category"
    mandatory   "Optional"
    references  "§457.10"
    applies_to  "CHIP Only"
    purpose     "Determine if unborn child is eligible for CHIP."
    description "States can elect to provide CHIP coverage to unborn children of pregnant women who are not eligible for Medicaid or CHIP, as specified in 42 CFR 457.10.  There is no requirement that the mother be a citizen or in an eligible immigration status for an unborn child to be eligible for coverage under this option.  But an unborn child is not eligible for coverage under this option if the mother is incarcerated or has access to coverage under a state employee health benefits plan."
    
    assumption "If the mother’s residency status is flagged as “inconsistent” due to the student residency rule, logic in this rule overrides her residency status so the unborn child is not precluded from CHIP eligibility."
    
    input "Applicant Pregnant Indicator", "Application", "Char(1)", %w(Y N)
    input "Applicant Medicaid Prelim Indicator", "Output from Prelim Medicaid Eligible Rule", "Char(1)", %w(Y N)
    input "Applicant CHIP Prelim Indicator", "Output from Prelim Medicaid Eligible Rule", "Char(1)", %w(Y N)
    input "Calculated Income", "From Income Logic", "Number"
    input "FPL", "From Income logic", "Number"
    
    config "Option Cover Unborn Child", "State Configuration", "Char(1)", %w(Y N)
    config "Percent CHIP FPL Unborn Child", "State Configuration", "Number"

    # Outputs
    determination "Unborn Child", %w(Y N X), %w(999 151 555)

    rule "State does not elect this option" do 
      if c("Option Cover Unborn Child") == 'N' || v("Applicant Pregnant Indicator") == 'N'
        determination_na "Unborn Child"
      elsif v("Applicant Medicaid Prelim Indicator") == 'Y' || v("Applicant CHIP Prelim Indicator") == 'Y'
        o["Applicant Unborn Child Indicator"] = 'N'
        o["Unborn Child Determination Date"] = current_date
        o["Unborn Child Ineligibility Reason"] = 151
      elsif v("Calculated Income") < c("Category-Percentage Mapping")["Unborn Child Category"] * v("FPL")
        determination_y "Unborn Child"

        o["Percentage for Category Used"] = c("Category-Percentage Mapping")["Unborn Child Category"]
        o["FPL * Percentage"] = v("FPL") * c("Category-Percentage Mapping")["Unborn Child Category"] * 0.01
      end
    end
  end
end
