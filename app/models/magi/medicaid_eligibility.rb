# encoding: UTF-8

module MAGI
  class MedicaidEligibility < Ruleset
    input "Applicant Medicaid Prelim Indicator", "From Determine Preliminary Medicaid & CHIP Eligibility Rule", "Char(1)", %w(Y N)
    input "Applicant Dependent Child Covered Indicator", "From Dependent Child Covered Rule", "Char(1)", %w(Y N)
    input "Medicaid Residency Indicator", "From Residency Logic", "Char(1)", %w(Y N)
    input "Applicant Income Medicaid Eligible Indicator", "From Verify Household Income Rule", "Char(1)", %w(Y N)

    # Outputs 
    determination "Medicaid", %w(Y N), %w(999 128 106)
    output "APTC Referral Indicator", "Char(1)", %w(Y N)
    output "APTC Referral Ineligibility Reason", "Char(3)", %w(406)

    rule "Determine final Medicaid eligibility" do
      if v("Applicant Medicaid Prelim Indicator") == 'Y' && 
         v("Applicant Dependent Child Covered Indicator") == 'N'
        o["Applicant Medicaid Indicator"] = 'N'
        o["Medicaid Determination Date"] = current_date
        o["Medicaid Ineligibility Reason"] = 128

        o["APTC Referral Indicator"] = 'Y'
      elsif v("Applicant Medicaid Prelim Indicator") == 'Y' && 
            %w(Y X).include?(v("Applicant Dependent Child Covered Indicator"))
        determination_y "Medicaid"

        o["APTC Referral Indicator"] = 'N'
        o["APTC Referral Ineligibility Reason"] = 406
      else
        o["Applicant Medicaid Indicator"] = 'N'
        o["Medicaid Determination Date"] = current_date
        o["Medicaid Ineligibility Reason"] = 106

        o["APTC Referral Indicator"] = 'Y'
      end
    end
  end
end
