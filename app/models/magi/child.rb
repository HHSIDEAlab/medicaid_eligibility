# encoding: UTF-8

module MAGI
  class Child < Ruleset
    input 'Applicant Age', 'Calculated in Create Applicant Child List logic', 'Number'

    config 'Child Age Threshold', 'System Configuration', 'Integer', nil, 19
    config 'Option Young Adults', 'State Configuration', 'Char(1)', %w(Y N)
    config 'Young Adult Age Threshold', 'State Configuration', 'Integer', %w(20 21)

    # Outputs
    indicator 'Applicant Child Category Indicator', %w(Y N)
    date      'Child Category Determination Date'
    code      'Child Category Ineligibility Reason', %w(999 115 394)

    rule 'Child is under 19 years old' do
      if v('Applicant Age') < c('Child Age Threshold')
        o['Applicant Child Category Indicator'] = 'Y'
        o['Child Category Determination Date'] = current_date
        o['Child Category Ineligibility Reason'] = 999
      end
    end

    rule 'State does not cover young adults- Child is over 18' do
      if v('Applicant Age') >= c('Child Age Threshold') && c('Option Young Adults') == 'N'
        o['Applicant Child Category Indicator'] = 'N'
        o['Child Category Determination Date'] = current_date
        o['Child Category Ineligibility Reason'] = 115
      end
    end

    rule 'State covers young adults- Child is less than age limit for young adults' do
      if c('Option Young Adults') == 'Y' && v('Applicant Age') < c('Young Adult Age Threshold')
        o['Applicant Child Category Indicator'] = 'Y'
        o['Child Category Determination Date'] = current_date
        o['Child Category Ineligibility Reason'] = 999
      end
    end

    rule 'State covers young adults- Child is older than age limit for young adults' do
      if c('Option Young Adults') == 'Y' && v('Applicant Age') >= c('Young Adult Age Threshold')
        o['Applicant Child Category Indicator'] = 'N'
        o['Child Category Determination Date'] = current_date
        o['Child Category Ineligibility Reason'] = 394
      end
    end
  end
end
