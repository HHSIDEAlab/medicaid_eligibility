# encoding: UTF-8

module MAGI
  class FormerFosterCare < Ruleset
    input 'Medicaid Residency Indicator', 'From Residency Logic', 'Char(1)', %w(Y N)
    input 'Applicant Medicaid Citizen Or Immigrant Indicator', 'From Immigration Status rule in MAGI Part 2', 'Char(1)', %w(Y N)
    input 'Applicant Age', 'Child Category rule', 'Number'
    input 'Former Foster Care', 'Application', 'Char(1)', %w(Y N)
    input 'Age Left Foster Care', 'Application', 'Numeric'
    input 'Had Medicaid During Foster Care', 'Application', 'Char(1)', %w(Y N)
    input 'Foster Care State', 'Application', 'Char(2)'
    input 'State', 'Application', 'Char(2)'

    config 'Foster Care Age Threshold', 'State Configuration Table', 'Numeric', nil, 18
    config 'In-State Foster Care Required', 'State Configuration Table', 'Char(1)', %w(Y N)

    # Outputs
    determination 'Former Foster Care Category', %w(Y N), %w(999 101 102 103 125 126 380 400)
    determination 'Medicaid Prelim', %w(Y N), %w(999)
    determination 'CHIP Prelim', %w(Y N), %w(380)

    rule 'Determine Former Foster Care eligibility' do
      if v('Former Foster Care') != 'Y'
        o['Applicant Former Foster Care Category Indicator'] = 'N'
        o['Former Foster Care Category Determination Date'] = current_date
        o['Former Foster Care Category Ineligibility Reason'] = 400
      elsif v('Medicaid Residency Indicator') != 'Y' || v('Applicant Medicaid Citizen Or Immigrant Indicator') != 'Y'
        o['Applicant Former Foster Care Category Indicator'] = 'N'
        o['Former Foster Care Category Determination Date'] = current_date
        o['Former Foster Care Category Ineligibility Reason'] = 101
      elsif v('Applicant Age') >= 26
        o['Applicant Former Foster Care Category Indicator'] = 'N'
        o['Former Foster Care Category Determination Date'] = current_date
        o['Former Foster Care Category Ineligibility Reason'] = 126
      elsif c('In-State Foster Care Required') == 'Y' && v('Foster Care State') != v('State')
        o['Applicant Former Foster Care Category Indicator'] = 'N'
        o['Former Foster Care Category Determination Date'] = current_date
        o['Former Foster Care Category Ineligibility Reason'] = 102
      elsif v('Age Left Foster Care') < c('Foster Care Age Threshold')
        o['Applicant Former Foster Care Category Indicator'] = 'N'
        o['Former Foster Care Category Determination Date'] = current_date
        o['Former Foster Care Category Ineligibility Reason'] = 125
      elsif v('Had Medicaid During Foster Care') == 'N'
        o['Applicant Former Foster Care Category Indicator'] = 'N'
        o['Former Foster Care Category Determination Date'] = current_date
        o['Former Foster Care Category Ineligibility Reason'] = 103
      else
        o['Applicant Former Foster Care Category Indicator'] = 'Y'
        o['Former Foster Care Category Determination Date'] = current_date
        o['Former Foster Care Category Ineligibility Reason'] = 999
        o['Applicant Medicaid Prelim Indicator'] = 'Y'
        o['Medicaid Prelim Determination Date'] = current_date
        o['Medicaid Prelim Ineligibility Reason'] = 999
        o['Applicant CHIP Prelim Indicator'] = 'N'
        o['CHIP Prelim Determination Date'] = current_date
        o['CHIP Prelim Ineligibility Reason'] = 380
      end
    end
  end
end
