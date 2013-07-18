# encoding: UTF-8

module Medicaid::Preliminary::Eligibility
  class Determination < Ruleset
    name        "Determine Preliminary Medicaid Eligibility"
    mandatory   "Mandatory"
    applies_to  "Medicaid"
    purpose     "Determine preliminary Medicaid eligibility based on citizenship, immigration status, residency and income and set emergency Medicaid referral indicator, when applicable."
    description "Preliminary Medicaid and CHIP eligibility indicators are set in MAGI Part 2 and Part 3, based on the values of various indicators previously set that govern Medicaid and CHIP eligibility.  These preliminary eligibility indicators are used to control branching in the application, which is designed to ask only the questions needed to determine eligibility for the insurance affordability program for which the applicant is preliminarily determined eligible based on MAGI. The final Medicaid determination is made in MAGI Part 3 after the Dependent Child rule checks for minimal essential coverage."
    
    input "Medicaid Residency Status Indicator", "From Residency Logic", "Char(1)", %w(Y N P)
    input "Applicant Medicaid Citizen Or Immigrant Status Indicator", "From Immigration Status rule in MAGI Part 2", "Char(1)", %w(Y N D E H I P T)
    input "Applicant Income Medicaid Eligible Status Indicator", "From Verify Household Income Rule", "Char(1)", %w(Y N P)
    input "Medicaid Household Status Indicator", "From Medicaid Household Composition logic", "Char(1)", %w(Y N P)

    # Outputs
    indicator "Applicant Medicaid Prelim Eligible Status Indicator", %w(Y N P)
    date      "Medicaid Prelim Eligible Determination Date"
    code      "Medicaid Prelim Ineligibility Reason", %w(999 106 302)
    indicator "Applicant Emergency Medicaid Eligible Status Indicator", %w(Y N)
    date      "Emergency Medicaid Eligible Determination Date"
    code      "Emergency Medicaid Ineligibility Reason", %w(999)

    rule "Applicant meets all Medicaid eligibility criteria" do
      if v("Medicaid Residency Status Indicator") == 'Y' && %w(Y I T D E H).include?(v("Applicant Medicaid Citizen Or Immigrant Status Indicator")) && v("Applicant Income Medicaid Eligible Status Indicator") == 'Y'
        o["Applicant Medicaid Prelim Eligible Status Indicator"] = 'Y'
        o["Medicaid Prelim Eligible Determination Date"] = current_date
        o["Medicaid Prelim Ineligibility Reason"] = 999
      end
    end

    rule "Residency, Income or HH Size is Inconsistent" do
      if (v("Medicaid Residency Status Indicator") == 'P' || v("Applicant Income Medicaid Eligible Status Indicator") == 'P' || v("Medicaid Household Status Indicator") == 'P') && v("Medicaid Residency Status Indicator") != 'N' && v("Applicant Income Medicaid Eligible Status Indicator") != 'N' && v("Medicaid Household Status Indicator") != 'N' && %w(Y I T D E H).include?(v("Applicant Medicaid Citizen Or Immigrant Status Indicator"))
        o["Applicant Medicaid Prelim Eligible Status Indicator"] = 'P'
        o["Medicaid Prelim Eligible Determination Date"] = current_date
        o["Medicaid Prelim Ineligibility Reason"] = 302
      end
    end
    
    rule "Applicant does not meet income criteria" do
      if v("Medicaid Residency Status Indicator") == 'Y' && %w(Y I T D E H).include?(v("Applicant Medicaid Citizen Or Immigrant Status Indicator")) && v("Applicant Income Medicaid Eligible Status Indicator") == 'N'
        o["Applicant Medicaid Prelim Eligible Status Indicator"] = 'N'
        o["Medicaid Prelim Eligible Determination Date"] = current_date
        o["Medicaid Prelim Ineligibility Reason"] = 106
      end
    end
    
    rule "Applicant does not meet citizenship/immigration status requirement- set prelim emergency Medicaid referral indicator" do
      if v("Medicaid Residency Status Indicator") == 'Y' && v("Applicant Medicaid Citizen Or Immigrant Status Indicator") == 'N' && v("Applicant Income Medicaid Eligible Status Indicator") == 'Y' 
        o["Applicant Medicaid Prelim Eligible Status Indicator"] = 'N'
        o["Medicaid Prelim Eligible Determination Date"] = current_date
        o["Medicaid Prelim Ineligibility Reason"] = 106
        o["Applicant Emergency Medicaid Prelim Eligible Status Indicator"] = 'Y' 
        o["Emergency Medicaid Eligible Determination Date"] = current_date
        o["Emergency Medicaid Ineligibility Reason"] = 999
      end
    end

    rule "Applicant does not meet residency requirement" do
      if (v("Medicaid Residency Status Indicator") == 'N' || v("Applicant Medicaid Citizen Or Immigrant Status Indicator") == 'N') && v("Applicant Income Medicaid Eligible Status Indicator") == 'Y'
        o["Applicant Medicaid Prelim Eligible Status Indicator"] = 'N'
        o["Medicaid Prelim Eligible Determination Date"] = current_date
        o["Medicaid Prelim Ineligibility Reason"] = 106
      end
    end
  end
end
