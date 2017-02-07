# encoding: UTF-8

module MAGI
  class TargetedLowIncomeChildren < Ruleset
    input 'Applicant Age', 'From Child Category Rule', 'Number'
    input 'Has Insurance', 'Application', 'Char(1)', %w(Y N)

    config 'CHIP Targeted Low Income Child Group', 'State configuration table', 'Char(1)', %w(Y N)
    config 'CHIP Targeted Low Income Child Age Low Threshold', 'State configuration table', 'Numeric', nil, 0
    config 'CHIP Targeted Low Income Child Age High Threshold', 'State configuration table', 'Numeric', nil, 19

    # Outputs
    indicator 'Applicant CHIP Targeted Low Income Child Indicator', %w(Y N X)
    date      'CHIP Targeted Low Income Child Determination Date'
    code      'CHIP Targeted Low Income Child Ineligibility Reason', %w(999 555 114 127)

    rule 'Determine CHIP Targeted Low Income Child eligibility' do
      if c('CHIP Targeted Low Income Child Group') == 'N'
        o['Applicant CHIP Targeted Low Income Child Indicator'] = 'X'
        o['CHIP Targeted Low Income Child Determination Date'] = current_date
        o['CHIP Targeted Low Income Child Ineligibility Reason'] = 555
      elsif v('Applicant Age') < c('CHIP Targeted Low Income Child Age Low Threshold') || v('Applicant Age') > c('CHIP Targeted Low Income Child Age High Threshold')
        o['Applicant CHIP Targeted Low Income Child Indicator'] = 'N'
        o['CHIP Targeted Low Income Child Determination Date'] = current_date
        o['CHIP Targeted Low Income Child Ineligibility Reason'] = 127
      elsif v('Has Insurance') == 'Y'
        o['Applicant CHIP Targeted Low Income Child Indicator'] = 'N'
        o['CHIP Targeted Low Income Child Determination Date'] = current_date
        o['CHIP Targeted Low Income Child Ineligibility Reason'] = 114
      else
        o['Applicant CHIP Targeted Low Income Child Indicator'] = 'Y'
        o['CHIP Targeted Low Income Child Determination Date'] = current_date
        o['CHIP Targeted Low Income Child Ineligibility Reason'] = 999
      end
    end
  end
end
