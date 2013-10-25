# encoding: UTF-8

module MAGI
  class PreliminaryMedicaid < Ruleset
    input "Medicaid Residency Indicator", "From Residency Logic", "Char(1)", %w(Y N)
    input "Applicant Medicaid Citizen Or Immigrant Indicator", "From Immigration Status rule in MAGI Part 2", "Char(1)", %w(Y N)
    input "Applicant Income Medicaid Eligible Indicator", "From Verify Household Income Rule", "Char(1)", %w(Y N)

    # Outputs
    indicator "Applicant Medicaid Prelim Indicator", %w(Y N P)
    date      "Medicaid Prelim Determination Date"
    code      "Medicaid Prelim Ineligibility Reason", %w(999 106)
    indicator "Applicant Emergency Medicaid Indicator", %w(Y N)
    date      "Emergency Medicaid Determination Date"
    code      "Emergency Medicaid Ineligibility Reason", %w(999)

    rule "Applicant meets all Medicaid eligibility criteria" do
      if v("Medicaid Residency Indicator") == 'Y' && 
         v("Applicant Medicaid Citizen Or Immigrant Indicator") == 'Y' && 
         v("Applicant Income Medicaid Eligible Indicator") == 'Y'
        determination_y "Medicaid Prelim"
      else
        o["Applicant Medicaid Prelim Indicator"] = 'N'
        o["Medicaid Prelim Determination Date"] = current_date
        o["Medicaid Prelim Ineligibility Reason"] = 106
      end

      if v("Medicaid Residency Indicator") == 'Y' && 
         v("Applicant Medicaid Citizen Or Immigrant Indicator") == 'N' && 
         v("Applicant Income Medicaid Eligible Indicator") == 'Y'
        determination_y "Emergency Medicaid"
      end
    end
  end
end
