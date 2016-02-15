# encoding: UTF-8

module MAGI
  class AdultGroup < Ruleset
    input "Medicare Entitlement Indicator", "From the Hub", "Char(1)", %w(Y N) 
    input "Applicant Pregnancy Category Indicator", "Output from the Pregnant Women Category Rule", "Char(1)", %w(Y N)
    input "Applicant Age", "From Child Category Rule", "Number"
    input "Applicant Dependent Child Covered Indicator", "From Dependent Child Covered Rule", "Char(1)", %w(Y N X)

    config "Option Adult Group", "State Configuration", "Char(1)", %w(Y N)

    # Outputs
    indicator "Applicant Adult Group Category Indicator", %w(Y N)
    date      "Adult Group Category Determination Date"  
    code      "Adult Group Category Ineligibility Reason", %w(999 117 122 123)

    rule "Adult Group Category determination" do
      if c("Option Adult Group") == 'N'
        o["Applicant Adult Group Category Indicator"] = 'X' 
        o["Adult Group Category Determination Date"] = current_date
        o["Adult Group Category Ineligibility Reason"] = 555 
      elsif v("Applicant Age") < 19 || v("Applicant Age") >= 65
        o["Applicant Adult Group Category Indicator"] = 'N' 
        o["Adult Group Category Determination Date"] = current_date
        o["Adult Group Category Ineligibility Reason"] = 123 
      elsif v("Applicant Pregnancy Category Indicator") == 'Y'
        o["Applicant Adult Group Category Indicator"] = 'N'
        o["Adult Group Category Determination Date"] = current_date
        o["Adult Group Category Ineligibility Reason"] = 122
      elsif v("Medicare Entitlement Indicator") == 'Y' 
        o["Applicant Adult Group Category Indicator"] = 'N'
        o["Adult Group Category Determination Date"] = current_date
        o["Adult Group Category Ineligibility Reason"] = 117
      elsif v("Applicant Dependent Child Covered Indicator") == 'N'
        o["Applicant Adult Group Category Indicator"] = 'N'
        o["Adult Group Category Determination Date"] = current_date
        o["Adult Group Category Ineligibility Reason"] = 411
      else
        o["Applicant Adult Group Category Indicator"] = 'Y'
        o["Adult Group Category Determination Date"] = current_date
        o["Adult Group Category Ineligibility Reason"] = 999
      end
    end
  end
end
