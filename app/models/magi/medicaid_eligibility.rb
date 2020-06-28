# encoding: UTF-8

module MAGI
  class MedicaidEligibility < Ruleset
    input "Applicant Medicaid Prelim Indicator", "From Determine Preliminary Medicaid & CHIP Eligibility Rule", "Char(1)", %w(Y N)
    input "Previously Denied", "Char(1)", %w(Y N)

    # Outputs
    determination "Medicaid", %w(Y N), %w(999 128 106)
    output "APTC Referral Indicator", "Char(1)", %w(Y N)
    output "APTC Referral Ineligibility Reason", "Char(3)", %w(406)

    rule "Determine final Medicaid eligibility" do
      # Note: we use input directly here because we want to allow that Previously Denied might be unset
      if @input["Previously Denied"] == 'Y'
        o["Applicant Medicaid Indicator"] = 'N'
        o["Medicaid Determination Date"] = current_date
        o["Medicaid Ineligibility Reason"] = 123
      elsif v("Applicant Medicaid Prelim Indicator") == 'Y'
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
