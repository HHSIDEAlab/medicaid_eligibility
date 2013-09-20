# encoding: UTF-8

module MAGI
  class RefugeeAssistance < Ruleset
    name        "Identify Medicaid Category – Refugee Medical Assistance"
    mandatory   "Optional"
    references  "Refugee Act of 1980\nINA §412."
    applies_to  "Medicaid Only"
    purpose     "Determine if the applicant is entitled to Refugee Medical Assistance (RMA) based on refugee status."
    description "*** TBD ***" 

    input "Refugee Status", "Application", "Char(1)", %w(Y N)
    input "Refugee Medical Assistance Start Date", "Application", "Date"
    input "Medicaid Residency Indicator", "From Residency Logic", "Char(1)", %w(Y N)
    input "Calculated Income", "From Income rule", "Numeric"
    input "FPL", "From Income rule", "Numeric"

    config "State Offers Refugee Medical Assistance", "State Configuration", "Char(1)", %w(Y N)
    config "Percent FPL Refugee Medical Assistance", "State Configuration", "Number"

    calculated "Applicant Refugee Medical Assistance End Date" do 
      if v("Refugee Status") == 'Y'
        v("Refugee Medical Assistance Start Date") + 8.months
      else
        nil
      end
    end

    # Outputs
    determination "Refugee Medical Assistance", %w(Y N X), %w(999 112 309 373 555)
    output "APTC Referral Indicator", "Char(1)", %w(Y N)

    rule "Determine Refugee Medical Assistance eligibility" do 
      if c("State Offers Refugee Medical Assistance") == 'N' || v("Refugee Status") == 'N'
        determination_na "Refugee Medical Assistance"
      elsif v("Applicant Refugee Medical Assistance End Date") <= current_date
        o["Applicant Refugee Medical Assistance Indicator"] = 'N'
        o["Refugee Medical Assistance Determination Date"] = current_date
        o["Refugee Medical Assistance Ineligibility Reason"] = 112

        o["APTC Referral Indicator"] = 'Y'
      elsif v("Medicaid Residency Indicator") == 'N'
        o["Applicant Refugee Medical Assistance Indicator"] = 'N'
        o["Refugee Medical Assistance Determination Date"] = current_date
        o["Refugee Medical Assistance Ineligibility Reason"] = 309

        o["APTC Referral Indicator"] = 'Y'
      elsif v("Calculated Income") >= v("FPL") * c("Percent FPL Refugee Medical Assistance") * 0.01
        o["Applicant Refugee Medical Assistance Indicator"] = 'N'
        o["Refugee Medical Assistance Determination Date"] = current_date
        o["Refugee Medical Assistance Ineligibility Reason"] = 373

        o["APTC Referral Indicator"] = 'Y'
      else
        determination_y "Refugee Medical Assistance"

        o["APTC Referral Indicator"] = 'N'
      end
    end
  end
end
