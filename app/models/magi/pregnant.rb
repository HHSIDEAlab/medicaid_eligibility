# encoding: UTF-8

module MAGI
  class Pregnant < Ruleset
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
