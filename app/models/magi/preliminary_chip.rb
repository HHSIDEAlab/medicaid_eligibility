# encoding: UTF-8

module MAGI
  class PreliminaryCHIP < Ruleset
    name        "Determine Preliminary CHIP Eligibility"
    applies_to  "CHIP"
    purpose     "Determine preliminary eligibility based on citizenship, immigration status, residency and income."
    description "Preliminary Medicaid and CHIP eligibility indicators are set in MAGI Part 2 and Part 3, based on the values of various indicators previously set that govern Medicaid and CHIP eligibility.  These preliminary eligibility indicators are used to control branching in the application, which is designed to ask only the questions needed to determine eligibility for the insurance affordability program for which the applicant is preliminarily determined eligible based on MAGI. The final CHIP eligibility determination is made in Part 3 after additional CHIP-specific rules are run." 

    input "Medicaid Residency Indicator", "From Residency Logic", "Char(1)", %w(Y N)
    input "Applicant Medicaid Citizen Or Immigrant Indicator", "From Immigration Status rule in MAGI Part 2", "Char(1)", %w(Y N)
    input "Applicant Income Medicaid Eligible Indicator", "From Verify Household Income Rule", "Char(1)", %w(Y N)
    input "Has Insurance", "Application", "Char(1)", %w(Y N)

    # Outputs 
    indicator "Applicant CHIP Prelim Indicator", %w(Y N)
    date      "CHIP Prelim Determination Date"
    code      "CHIP Prelim Ineligibility Reason", %w(999 107 302)

    rule "Applicant meets all CHIP eligibility criteria" do
      if v("Medicaid Residency Indicator") == 'Y' && v("Applicant Medicaid Citizen Or Immigrant Indicator") == 'Y' && v("Applicant Income Medicaid Eligible Indicator") == 'Y' && v("Has Insurance") == 'N'
        determination_y "CHIP Prelim"
      else
        o["Applicant CHIP Prelim Indicator"] = 'N'
        o["CHIP Prelim Determination Date"] = current_date
        o["CHIP Prelim Ineligibility Reason"] = 107
      end
    end
  end
end
