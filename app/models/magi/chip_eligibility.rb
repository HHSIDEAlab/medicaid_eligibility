# encoding: UTF-8

module MAGI
  class CHIPEligibility < Ruleset
    input 'Incarceration Status', 'Application', 'Char(1)', %w(Y N)
    input 'Applicant CHIP Prelim Indicator', 'Determine Preliminary Medicaid and CHIP Eligibility rule', 'Char(1)', %w(Y N)
    input 'Applicant Unborn Child Indicator', 'Unborn Child rule', 'Char(1)', %w(Y N X)
    input 'Applicant State Health Benefits CHIP Indicator', 'State Health Benefits Through Public Employees rule', 'Char(1)', %w(Y N X)
    input 'Applicant CHIP Waiting Period Satisfied Indicator', 'CHIP Waiting Period rule', 'Char(1)', %w(Y N X)
    input 'Applicant CHIP Targeted Low Income Child Indicator', 'CHIP Targeted Low-Income Children rule', 'Char(1)', %w(Y N X)

    # Outputs
    determination 'CHIP', %w(Y N), %w(999 107 405)
    output 'APTC Referral Indicator', 'Char(1)', %w(Y N)

    rule 'Determine final CHIP eligibility' do
      if v('Incarceration Status') == 'Y'
        o['Applicant CHIP Indicator'] = 'N'
        o['CHIP Determination Date'] = current_date
        o['CHIP Ineligibility Reason'] = 405
      elsif (v('Applicant CHIP Prelim Indicator') == 'Y' &&
          %w(Y X).include?(v('Applicant State Health Benefits CHIP Indicator')) &&
          %w(Y X).include?(v('Applicant CHIP Waiting Period Satisfied Indicator'))) ||
            v('Applicant Unborn Child Indicator') == 'Y'
        determination_y 'CHIP'
      else
        o['Applicant CHIP Indicator'] = 'N'
        o['CHIP Determination Date'] = current_date
        o['CHIP Ineligibility Reason'] = 107

        o['APTC Referral Indicator'] = 'Y'
      end
    end
  end
end
