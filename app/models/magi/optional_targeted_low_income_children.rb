# encoding: UTF-8

module MAGI
  class OptionalTargetedLowIncomeChildren < Ruleset
    input 'Applicant Age', 'From Child Category Rule', 'Number'
    input 'Has Insurance', 'Application', 'Char(1)', %w(Y N)

    config 'Optional Targeted Low Income Child Group', 'State configuration table', 'Char(1)', %w(Y N)
    config 'Optional Targeted Low Income Child Age Low Threshold', 'State configuration table', 'Numeric', nil, 0
    config 'Optional Targeted Low Income Child Age High Threshold', 'State configuration table', 'Numeric', nil, 19

    # Outputs
    indicator 'Applicant Optional Targeted Low Income Child Indicator', %w(Y N X)
    date      'Optional Targeted Low Income Child Determination Date'
    code      'Optional Targeted Low Income Child Ineligibility Reason', %w(999 555 114 127)

    rule 'Determine Optional Targeted Low Income Child eligibility' do
      if c('Optional Targeted Low Income Child Group') == 'N'
        o['Applicant Optional Targeted Low Income Child Indicator'] = 'X'
        o['Optional Targeted Low Income Child Determination Date'] = current_date
        o['Optional Targeted Low Income Child Ineligibility Reason'] = 555
      elsif v('Applicant Age') < c('Optional Targeted Low Income Child Age Low Threshold') || v('Applicant Age') > c('Optional Targeted Low Income Child Age High Threshold')
        o['Applicant Optional Targeted Low Income Child Indicator'] = 'N'
        o['Optional Targeted Low Income Child Determination Date'] = current_date
        o['Optional Targeted Low Income Child Ineligibility Reason'] = 127
      elsif v('Has Insurance') == 'Y'
        o['Applicant Optional Targeted Low Income Child Indicator'] = 'N'
        o['Optional Targeted Low Income Child Determination Date'] = current_date
        o['Optional Targeted Low Income Child Ineligibility Reason'] = 114
      else
        o['Applicant Optional Targeted Low Income Child Indicator'] = 'Y'
        o['Optional Targeted Low Income Child Determination Date'] = current_date
        o['Optional Targeted Low Income Child Ineligibility Reason'] = 999
      end
    end
  end
end
