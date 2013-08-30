# encoding: UTF-8

module MAGI
  class PreliminaryCHIPDetermination < Ruleset
    name        "Determine Preliminary CHIP Eligibility"
    applies_to  "CHIP"
    purpose     "Determine preliminary eligibility based on citizenship, immigration status, residency and income."
    description "Preliminary Medicaid and CHIP eligibility indicators are set in MAGI Part 2 and Part 3, based on the values of various indicators previously set that govern Medicaid and CHIP eligibility.  These preliminary eligibility indicators are used to control branching in the application, which is designed to ask only the questions needed to determine eligibility for the insurance affordability program for which the applicant is preliminarily determined eligible based on MAGI. The final CHIP eligibility determination is made in Part 3 after additional CHIP-specific rules are run." 

    input "Medicaid Residency Status Indicator", "From Residency Logic", "Char(1)", %w(Y N P)
    input "Applicant Medicaid Citizen Or Immigrant Status Indicator", "From Immigration Status rule in MAGI Part 2", "Char(1)", %w(Y N D E H I P T)
    input "Applicant Income CHIP Eligible Status Indicator", "From Verify Household Income Rule", "Char(1)", %w(Y N P)
    input "Medicaid Household Status Indicator", "From Medicaid Household Composition logic", "Char(1)", %w(Y N P)

    # Outputs 
    indicator "Applicant CHIP Prelim Eligible Status Indicator", %w(Y N P)
    date      "CHIP Prelim Eligible Determination Date"
    code      "CHIP Prelim Ineligibility Reason", %w(999 107 302)

    rule "Applicant meets all CHIP eligibility criteria" do
      if v("Medicaid Residency Status Indicator") == 'Y' && %w(Y I T D E H).include?(v("Applicant Medicaid Citizen Or Immigrant Status Indicator")) && v("Applicant Income CHIP Eligible Status Indicator") == 'Y' 
        o["Applicant CHIP Prelim Eligible Status Indicator"] = 'Y'
        o["CHIP Prelim Eligible Determination Date"] = current_date
        o["CHIP Prelim Ineligibility Reason"] = 999 
      end
    end

    rule "Residency, Income or HH Size is Inconsistent" do
      if (v("Medicaid Residency Status Indicator") == 'P' || v("Applicant Income CHIP Eligible Status Indicator") == 'P' || v("Medicaid Household Status Indicator") == 'P') && v("Medicaid Residency Status Indicator") != 'N' && v("Applicant Income CHIP Eligible Status Indicator") != 'N' && v("Medicaid Household Status Indicator") != 'N' && %w(Y I T D E H).include?(v("Applicant Medicaid Citizen Or Immigrant Status Indicator"))
        o["Applicant CHIP Prelim Eligible Status Indicator"] = 'P'
        o["CHIP Prelim Eligible Determination Date"] = current_date
        o["CHIP Prelim Ineligibility Reason"] = 302
      end
    end

    rule "Applicant does not meet all eligibility criteria" do
      if v("Medicaid Residency Status Indicator") == 'N' || v("Applicant Medicaid Citizen Or Immigrant Status Indicator") == 'N' || v("Applicant Income CHIP Eligible Status Indicator") == 'N'
        o["Applicant CHIP Prelim Eligible Status Indicator"] = 'N'
        o["CHIP Prelim Eligible Determination Date"] = current_date
        o["CHIP Prelim Ineligibility Reason"] = 107
      end
    end
  end
end
