# encoding: UTF-8

module MAGI
  class MedicaidEligibility < Ruleset
    input "Applicant Medicaid Prelim Indicator", "From Determine Preliminary Medicaid & CHIP Eligibility Rule", "Char(1)", %w(Y N)

    # Outputs 
    determination "Medicaid", %w(Y N), %w(999 128 106)
    output "APTC Referral Indicator", "Char(1)", %w(Y N)
    output "APTC Referral Ineligibility Reason", "Char(3)", %w(406)

    rule "Determine final Medicaid eligibility" do
      if v("Applicant Medicaid Prelim Indicator") == 'Y'
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
