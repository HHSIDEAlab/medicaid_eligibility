# encoding: UTF-8

module MAGI
  class EmergencyMedicaid < Ruleset
    name        "Determine Emergency Medicaid Eligibility and Eligibility for Former Foster Care"
    mandatory   "Mandatory"
    references  "Section 1902(a)(10)(A)(i)(IX) of the Act"
    applies_to  "Medicaid"
    purpose     "To determine if applicant is eligible under the Former Foster Care category. In addition, this rule determines whether an emergency Medicaid referral is applicable."
    description "The Former Foster Care category is a mandatory group through which states must provide Medicaid coverage to children under age 26 who were in foster care when they turned age 18 or aged out of foster care at such higher age as the state elected under title IV-E of the Social Security Act and who were enrolled in Medicaid when they turned 18 or aged out of foster care. States may require the individual to have been in foster care and receiving Medicaid in that state to be eligible for the former foster care group, or states can cover individuals who were on Medicaid and in foster care when in another state. If the applicant is not eligible for Medicaid under the former foster care rule, the Refugee Medical Assistance rule is run.\nWhen an applicant meets all Medicaid eligibility criteria for income and residency, but does not meet the citizenship or immigration status criteria for Medicaid, the applicant is eligible for emergency Medicaid services."

    input "Medicaid Residency Indicator", "From Residency Logic", "Char(1)", %w(Y N)
    input "Applicant Medicaid Citizen Or Immigrant Indicator", "From Immigration Status rule", "Char(1)", %w(Y N)
    input "Applicant Income Medicaid Eligible Indicator", "From Verify Household Income Rule", "Char(1)", %w(Y N)
    input "Applicant Former Foster Care Category Indicator", "From Former Foster Care Children Rule", "Char(1)", %w(Y N)

    # Outputs
    determination "Medicaid", %w(Y N), %w(999)
    determination "Emergency Medicaid", %w(Y N), %w(999 109)
    output "APTC Referral Indicator", "Char(1)", %w(Y N)
    output "Prelim APTC Referral Indicator", "Char(1)", %w(Y N)

    rule "Determine Emergency Medicaid eligibility" do
      if v("Medicaid Residency Indicator") == 'Y' && v("Applicant Medicaid Citizen Or Immigrant Indicator") == 'Y' && v("Applicant Former Foster Care Category Indicator") == 'Y'
        determination_y "Medicaid"

        o["APTC Referral Indicator"] = 'N'
        o["Prelim APTC Referral Indicator"] = 'N'
      elsif v("Medicaid Residency Indicator") == 'Y' && v("Applicant Income Medicaid Eligible Indicator") == 'Y' && v("Applicant Medicaid Citizen Or Immigrant Indicator") == 'N'
        determination_y "Emergency Medicaid"

        o["APTC Referral Indicator"] = 'Y'
      else
        o["Applicant Emergency Medicaid Indicator"] = 'N'
        o["Emergency Medicaid Determination Date"] = current_date
        o["Emergency Medicaid Ineligibility Reason"] = 109
      end
    end
  end
end
