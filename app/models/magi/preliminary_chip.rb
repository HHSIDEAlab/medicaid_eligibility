# encoding: UTF-8

module MAGI
  class PreliminaryCHIP < Ruleset
    input "Medicaid Residency Indicator", "From Residency Logic", "Char(1)", %w(Y N)
    input "Applicant Medicaid Citizen Or Immigrant Indicator", "From Immigration Status rule in MAGI Part 2", "Char(1)", %w(Y N)
    input "Applicant Income CHIP Eligible Indicator", "From Verify Household Income Rule", "Char(1)", %w(Y N)
    input "Has Insurance", "Application", "Char(1)", %w(Y N)

    # Outputs 
    indicator "Applicant CHIP Prelim Indicator", %w(Y N)
    date      "CHIP Prelim Determination Date"
    code      "CHIP Prelim Ineligibility Reason", %w(999 107)

    rule "Determine preliminary CHIP eligibility" do
      if v("Medicaid Residency Indicator") == 'Y' && 
         v("Applicant Medicaid Citizen Or Immigrant Indicator") == 'Y' && 
         v("Applicant Income CHIP Eligible Indicator") == 'Y' && 
         v("Has Insurance") == 'N'
        determination_y "CHIP Prelim"
      else
        o["Applicant CHIP Prelim Indicator"] = 'N'
        o["CHIP Prelim Determination Date"] = current_date
        o["CHIP Prelim Ineligibility Reason"] = 107
      end
    end
  end
end
