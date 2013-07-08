# encoding: UTF-8

module Medicaidchip::Eligibility::Category
  class Pregnant < Ruleset
    name        "Identify Medicaid or CHIP Category – Pregnant Women"
    mandatory   "Mandatory"
    references  "§435.116 (Medicaid); 1115 of SSA (for CHIP)"
    applies_to  "Medicaid and CHIP"
    purpose     "Determine if applicant belongs in the pregnant women category."
    description "Women who are currently pregnant or within postpartum period are in the Medicaid or CHIP Pregnancy category until the end of the postpartum period.  The Postpartum period is defined as beginning on the date the pregnancy terminates and ending on the last day of the month in which a 60-day period (beginning on the date the pregnancy terminates) ends (§435.4)."

    assumption "System logic will determine if a woman is in a postpartum period based on her attestation of pregnancy and the age of her children."

    input "Applicant Pregnant Indicator", "Application", "Char(1)", %w(Y N)
    input "Applicant Post Partum Period Indicator", "From Pregnant Woman Category Logic", "Char(1)", %w(Y N)

    # Outputs
    indicator "Applicant Pregnancy Category Indicator", %w(Y N)
    date      "Pregnancy Category Determination Date"
    code      "Pregnancy Category Ineligibility Reason", %w(999 124)

    rule "Applicant is pregnant or in postpartum period" do
      if v("Applicant Pregnant Indicator") == 'Y' || v("Applicant Post Partum Period Indicator") == 'Y'
        o["Applicant Pregnancy Category Indicator"] = 'Y' 
        o["Pregnancy Category Determination Date"] = current_date
        o["Pregnancy Category Ineligibility Reason"] = 999
      end
    end

    rule "Applicant is not pregnant or within postpartum period" do
      if v("Applicant Pregnant Indicator") == 'N' && v("Applicant Post Partum Period Indicator") == 'N'
        o["Applicant Pregnancy Category Indicator"] = 'N' 
        o["Pregnancy Category Determination Date"] = current_date
        o["Pregnancy Category Ineligibility Reason"] = 124
      end
    end
  end
end
