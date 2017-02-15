# encoding: UTF-8

module MAGI
  class ReferralType < Ruleset
    input 'Applicant Age', 'From Child Category Rule', 'Number'
    input 'Applicant Attest Blind or Disabled', 'From application', 'Char(1)', %w(Y N)
    input 'Applicant Attest Long Term Care', 'From application', 'Char(1)', %w(Y N)
    input 'Medicare Entitlement Indicator', 'From SSA via Hub', 'Char(1)', %w(Y N)
    input 'Receives SSI', 'From application', 'Char(1)', %w(Y N)

    # Outputs
    indicator 'Applicant Medicaid Non-MAGI Referral Indicator', %w(Y N)
    date      'Medicaid Non-MAGI Referral Determination Date'
    code      'Medicaid Non-MAGI Referral Ineligibility Reason', %w(999 108)

    rule "Applicant's account should be referred for Non-MAGI eligibility determination" do
      if v('Applicant Age') >= 65 || v('Applicant Attest Blind or Disabled') == 'Y' || v('Applicant Attest Long Term Care') == 'Y' || v('Medicare Entitlement Indicator') == 'Y' || v('Receives SSI') == 'Y'
        o['Applicant Medicaid Non-MAGI Referral Indicator'] = 'Y'
        o['Medicaid Non-MAGI Referral Determination Date'] = current_date
        o['Medicaid Non-MAGI Referral Ineligibility Reason'] = 999
      else
        o['Applicant Medicaid Non-MAGI Referral Indicator'] = 'N'
        o['Medicaid Non-MAGI Referral Determination Date'] = current_date
        o['Medicaid Non-MAGI Referral Ineligibility Reason'] = 108
      end
    end
  end
end
