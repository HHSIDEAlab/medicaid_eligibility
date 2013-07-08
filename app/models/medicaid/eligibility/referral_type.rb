# encoding: UTF-8

module Medicaid::Eligibility
  class ReferralType < Ruleset
    name        "Determine Non-MAGI Referral Type"
    mandatory   "Mandatory"
    references  "§435.603(j)"
    applies_to  "Medicaid"
    purpose     "Determine if this applicant may be referred based on non-MAGI factors."
    description "If the applicant attests to being disabled or in need of long-term services and supports, is age 65 or older or the Hub service returns information from SSA indicating that the applicant is entitled to or enrolled in Medicare or receives Title II benefits due to disability, the applicant’s account is referred to the Medicaid agency for a non-MAGI eligibility determination. The applicant’s account is referred to the state’s Medicaid agency for a non-MAGI eligibility determination regardless of the applicant’s Medicaid or CHIP MAGI eligibility or eligibility for APTC/CSR. "

    input "Applicant Age", "From Child Category Rule", "Number"
    input "Applicant Attest Disabled", "From application", "Char(1)", %(Y N)
    input "Applicant Attest Long Term Care", "From application", "Char(1)", %(Y N)
    input "Person Disabled Indicator", "From SSA via Hub", "Char(1)", %(Y N)
    input "Medicare Entitlement Indicator", "From SSA via Hub", "Char(1)", %(Y N)

    # Outputs 
    indicator "Applicant Medicaid Non-MAGI Referral Indicator", %(Y N)
    date      "Medicaid Non-MAGI Referral Determination Date"
    code      "Medicaid Non-MAGI Referral Ineligibility Reason", %(999 108)

    rule "Applicant's account should be referred for Non-MAGI eligibility determination" do
      if v("Person Disabled Indicator") == 'Y' || v("Applicant Age") >= 65 || v("Applicant Attest Disabled") == 'Y' || v("Applicant Attest Long Term Care") == 'Y' || v("Medicare Entitlement Indicator") == 'Y'
        o["Applicant Medicaid Non-MAGI Referral Indicator"] = 'Y'
        o["Medicaid Non-MAGI Referral Determination Date"] = current_date
        o["Medicaid Non-Magi Referral Ineligibility Reason"] = 999
      end
    end

    rule "Applicant's account should not be referred for Non-MAGI eligibility determination" do
      if v("Person Disabled Indicator") == 'N' && v("Applicant Age") < 65 && v("Applicant Attest Disabled") == 'N' && v("Applicant Attest Long Term Care") == 'N' && v("Medicare Entitlement Indicator") == 'N'
        o["Applicant Medicaid Non-MAGI Referral Indicator"] = 'N'
        o["Medicaid Non-MAGI Referral Determination Date"] = current_date
        o["Medicaid Non-MAGI Referral Ineligibility Reason"] = 108
      end
    end
  end
end
