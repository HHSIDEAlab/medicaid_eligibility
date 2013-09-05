# encoding: UTF-8

module MAGI
  class FormerFosterCare < Ruleset
    name        "Former Foster Care Children"
    mandatory   "Mandatory" 
    references  "section 1902(a)(10)(A)(i)(IX) of the Act"
    applies_to  "Medicaid Only"
    purpose     "Determine if the applicant is entitled to Medicaid as a former foster care child."
    description "The Former Foster Care category is a mandatory group through which states must provide Medicaid coverage to children under age 26 who were in foster care when they turned age 18 or aged out of foster care at such higher age as the state elected under title IV-E of the Social Security Act and who were enrolled in Medicaid when they turned 18 or aged out of foster care. States may require the individual to have been in foster care and receiving Medicaid in that state to be eligible for the former foster care group, or states can cover individuals who were on Medicaid and in foster care when in another state. This rule also evaluates the residency and citizenship/immigration status of the applicant in order to set an indicator for this category."

    assumption "FFE will accept self-attestation without further verification as to whether the applicant was in foster care on the date of attaining 18 years of age (or such higher age as the State has elected) and whether he or she received Medicaid while on foster care."
    assumption "There is no income limit for these individuals."
    
    input "Medicaid Residency Indicator", "From Residency Logic", "Char(1)", %w(Y N)
    input "Applicant Medicaid Citizen Or Immigrant Indicator", "From Immigration Status rule in MAGI Part 2", "Char(1)", %w(Y N)
    input "Applicant Age", "Child Category rule", "Number"
    input "Former Foster Care", "Application", "Char(1)", %w(Y N) 
    input "Age Left Foster Care", "Application", "Numeric"
    input "Had Medicaid During Foster Care", "Application", "Char(1)", %w(Y N)
    input "Foster Care State", "Application", "Char(2)"
    input "State", "Application", "Char(2)"

    config "Foster Care Age Threshold", "State Configuration Table", "Numeric", nil, 18
    config "In-State Foster Care Required", "State Configuration Table", "Char(1)", %w(Y N)

    # Outputs 
    determination "Former Foster Care Category", %w(Y N), %w(999 101 102 103 125 126 380)
    determination "Medicaid Prelim", %w(Y N), %w(999)
    determination "CHIP Prelim", %w(Y N), %w(380)

    rule "Applicant does not meet residency or immigration status criteria" do
      if v("Medicaid Residency Indicator") != 'Y' || v("Applicant Medicaid Citizen Or Immigrant Indicator") != 'Y'
        o["Applicant Former Foster Care Category Indicator"] = 'N'
        o["Former Foster Care Category Determination Date"] = current_date
        o["Former Foster Care Category Ineligibility Reason"] = 101
      end
    end

    rule "Applicant is over age limit for former foster care category" do
      if v("Applicant Age") >= 26
        o["Applicant Former Foster Care Category Indicator"] = 'N'
        o["Former Foster Care Category Determination Date"] = current_date
        o["Former Foster Care Category Ineligibility Reason"] = 126
      end
    end

    rule "State requires in-state foster care record- child received out-of state foster care" do
      if c("In-State Foster Care Required") == 'Y' && v("Foster Care State") != v("State")
        o["Applicant Former Foster Care Category Indicator"] = 'N'
        o["Former Foster Care Category Determination Date"] = current_date
        o["Former Foster Care Category Ineligibility Reason"] = 102
      end
    end

    rule "Applicant did not age out of foster care" do
      if v("Age Left Foster Care") != c("Foster Care Age Threshold") 
        o["Applicant Former Foster Care Category Indicator"] = 'N'
        o["Former Foster Care Category Determination Date"] = current_date
        o["Former Foster Care Category Ineligibility Reason"] = 125
      end
    end

    rule "Applicant did not receive Medicaid while receiving foster care" do
      if v("Had Medicaid During Foster Care") == 'N'
        o["Applicant Former Foster Care Category Indicator"] = 'N'
        o["Former Foster Care Category Determination Date"] = current_date
        o["Former Foster Care Category Ineligibility Reason"] = 103
      end
    end

    rule "Applicant meets all criteria for former foster care" do
      if v("Applicant Age") < 26 && v("Age Left Foster Care") == c("Foster Care Age Threshold") && v("Had Medicaid During Foster Care") == 'Y' && ((c("In-State Foster Care Required") == 'Y' && v("Foster Care State") == v("State")) || c("In-State Foster Care Required") == 'N') && v("Medicaid Residency Indicator") == 'Y' && v("Applicant Medicaid Citizen Or Immigrant Indicator") == 'Y'
        o["Applicant Former Foster Care Category Indicator"] = 'Y'
        o["Former Foster Care Category Determination Date"] = current_date
        o["Former Foster Care Category Ineligibility Reason"] = 999
        o["Applicant Medicaid Prelim Indicator"] = 'Y'
        o["Medicaid Prelim Determination Date"] = current_date
        o["Medicaid Prelim Ineligibility Reason"] = 999
        o["Applicant CHIP Prelim Indicator"] = 'N'
        o["CHIP Prelim Determination Date"] = current_date
        o["CHIP Prelim Ineligibility Reason"] = 380
      end
    end
  end
end
