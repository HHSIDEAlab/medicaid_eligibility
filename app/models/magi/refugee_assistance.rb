# encoding: UTF-8

include IncomeThreshold

module MAGI
  class RefugeeAssistance < Ruleset
    input "Person ID", "Application", "Integer"
    input "Refugee Status", "Application", "Char(1)", %w(Y N)
    input "Refugee Medical Assistance Start Date", "Application", "Date"
    input "Medicaid Residency Indicator", "From Residency Logic", "Char(1)", %w(Y N)
    input "Calculated Income", "From Income rule", "Numeric"
    input "FPL", "From Income rule", "Numeric"

    config "State Offers Refugee Medical Assistance", "State Configuration", "Char(1)", %w(Y N)
    config "Refugee Medical Assistance Income Requirement", "State Configuration", "Char(1)", %w(Y N)
    config "Refugee Medical Assistance Threshold", "State Configuration", "Hash"

    def run(context)
      context.extend IncomeThreshold
      super context
    end

    calculated "Applicant Refugee Medical Assistance End Date" do 
      if v("Refugee Status") == 'Y'
        if v("Refugee Medical Assistance Start Date")
          v("Refugee Medical Assistance Start Date") + 8.months
        else
          raise "Applicant #{v("Person ID")} is missing Refugee Medical Assistance Start Date"
        end
      else
        nil
      end
    end

    # Outputs
    determination "Refugee Medical Assistance", %w(Y N X), %w(999 112 309 373 555)
    output "APTC Referral Indicator", "Char(1)", %w(Y N)
    output "APTC Referral Ineligibility Reason", "Char(3)", %w(407)

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
      elsif c("Refugee Medical Assistance Income Requirement") == 'N' || 
        v("Calculated Income") < get_threshold(c("Refugee Medical Assistance Threshold"))
        determination_y "Refugee Medical Assistance"

        o["APTC Referral Indicator"] = 'N'
        o["APTC Referral Ineligibility Reason"] = 407
      else
        o["Applicant Refugee Medical Assistance Indicator"] = 'N'
        o["Refugee Medical Assistance Determination Date"] = current_date
        o["Refugee Medical Assistance Ineligibility Reason"] = 373

        o["APTC Referral Indicator"] = 'Y'
      end
    end
  end
end
