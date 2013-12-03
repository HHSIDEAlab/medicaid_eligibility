# encoding: UTF-8

module MAGI
  class OptionalUnbornChild < Ruleset
    input "Applicant Pregnant Indicator", "Application", "Char(1)", %w(Y N)
    input "Applicant Medicaid Prelim Indicator", "Output from Prelim Medicaid Eligible Rule", "Char(1)", %w(Y N)
    input "Applicant CHIP Prelim Indicator", "Output from Prelim Medicaid Eligible Rule", "Char(1)", %w(Y N)
    input "Calculated Income", "From Income Logic", "Number"
    input "FPL", "From Income logic", "Number"
    
    config "Percent FPL Unborn Child", "State Configuration", "Integer"
    config "Option Cover Unborn Child", "State Configuration", "Char(1)", %w(Y N)
    
    # Outputs
    determination "Unborn Child", %w(Y N X), %w(999 151 555)

    rule "Determine Unborn Child eligibility" do 
      if c("Option Cover Unborn Child") == 'N' || v("Applicant Pregnant Indicator") == 'N'
        determination_na "Unborn Child"
      elsif v("Applicant Medicaid Prelim Indicator") == 'Y' || v("Applicant CHIP Prelim Indicator") == 'Y'
        o["Applicant Unborn Child Indicator"] = 'N'
        o["Unborn Child Determination Date"] = current_date
        o["Unborn Child Ineligibility Reason"] = 151
      elsif v("Calculated Income") < (c("Percent FPL Unborn Child") + 5) * v("FPL") * 0.01
        determination_y "Unborn Child"

        o["Percentage for CHIP Category Used"] = c("Percent FPL Unborn Child")
        o["FPL * Percentage CHIP"] = v("FPL") * (c("Percent FPL Unborn Child") + 5) * 0.01
      else
        o["Applicant Unborn Child Indicator"] = 'N'
        o["Unborn Child Determination Date"] = current_date
        o["Unborn Child Ineligibility Reason"] = 408
      end
    end
  end
end
