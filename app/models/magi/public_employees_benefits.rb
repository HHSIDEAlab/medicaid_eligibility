# encoding: UTF-8

module MAGI
  class PublicEmployeesBenefits < Ruleset
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
        if v("Calculated Income") < v("FPL") * c("State Health Benefits FPL Standard") * 0.01
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

