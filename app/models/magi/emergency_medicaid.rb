# encoding: UTF-8

module MAGI
  class EmergencyMedicaid < Ruleset
    input 'Medicaid Residency Indicator', 'From Residency Logic', 'Char(1)', %w(Y N)
    input 'Applicant Medicaid Citizen Or Immigrant Indicator', 'From Immigration Status rule', 'Char(1)', %w(Y N)
    input 'Applicant Income Medicaid Eligible Indicator', 'From Verify Household Income Rule', 'Char(1)', %w(Y N)
    input 'Applicant Former Foster Care Category Indicator', 'From Former Foster Care Children Rule', 'Char(1)', %w(Y N)

    # Outputs
    determination 'Medicaid', %w(Y N), %w(999)
    determination 'Emergency Medicaid', %w(Y N), %w(999 109)
    output 'APTC Referral Indicator', 'Char(1)', %w(Y N)
    output 'Prelim APTC Referral Indicator', 'Char(1)', %w(Y N)

    rule 'Determine Emergency Medicaid eligibility' do
      if v('Medicaid Residency Indicator') == 'Y' &&
         v('Applicant Medicaid Citizen Or Immigrant Indicator') == 'Y' &&
         v('Applicant Former Foster Care Category Indicator') == 'Y'
        determination_y 'Medicaid'

        o['APTC Referral Indicator'] = 'N'
        o['APTC Referral Ineligibility Reason'] = 406
        o['Prelim APTC Referral Indicator'] = 'N'
      elsif v('Medicaid Residency Indicator') == 'Y' &&
            v('Applicant Income Medicaid Eligible Indicator') == 'Y' &&
            v('Applicant Medicaid Citizen Or Immigrant Indicator') == 'N'
        determination_y 'Emergency Medicaid'

        o['APTC Referral Indicator'] = 'Y'
      else
        o['Applicant Emergency Medicaid Indicator'] = 'N'
        o['Emergency Medicaid Determination Date'] = current_date
        o['Emergency Medicaid Ineligibility Reason'] = 109
      end
    end
  end
end
