module MAGI
  class ExchangeEligibility < Ruleset
    input "Medicaid Residency Indicator", "From Residency Logic", "Char(1)", %w(Y N)
    input "Incarceration Status", "Application", "Char(1)", %w(Y N)
    input "Applicant Medicaid Citizen Or Immigrant Indicator", "From Immigration Status rule in MAGI Part 2", "Char(1)", %w(Y N)
  
    output "Exchange Eligibility Indicator", "Char(1)", %w(Y N)

    rule 'Determine Exchange Eligibility' do
      if v('Medicaid Residency Indicator') == 'Y' && v('Incarceration Status') == 'N' && v('Applicant Medicaid Citizen Or Immigrant Indicator') == 'Y'
        o['Exchange Eligibility Indicator'] = 'Y'
      else
        o['Exchange Eligibility Indicator'] = 'N'
      end
    end
  end
end