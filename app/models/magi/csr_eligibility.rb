module MAGI
  class CSREligibility < Ruleset
    input "Exchange Eligibility Indicator","Exchange Eligibility Logic","Char(1)", %w(Y N)
    input "Applicant APTC Indicator","APTC Eligibility Logic","Char(1)", %w(Y N)
    input "Applicant Income CSR Eligible Indicator","Income Logic","Char(1)", %w(Y N)
    input "Native American or Alaska Native", "Application", %w(Y N)


    determination "CSR", %w(Y N), %w(176 282 419)
    

    rule "Determine CSR eligibility" do
      if v("Exchange Eligibility Indicator") == 'N'
        o["Applicant CSR Indicator"] = 'N'
        o["CSR Determination Date"] = current_date
        o["CSR Ineligibility Reason"] = 282
      elsif v("Native American or Alaska Native") == 'N' && !(v("Applicant APTC Indicator") == "Y" && v("Applicant Income CSR Eligible Indicator") == "Y")
        if v("Applicant APTC Indicator") == "N"
          o["Applicant CSR Indicator"] = 'N'
          o["CSR Determination Date"] = current_date
          o["CSR Ineligibility Reason"] = 176
        elsif v("Applicant Income CSR Eligible Indicator") == "N"
          o["Applicant CSR Indicator"] = 'N'
          o["CSR Determination Date"] = current_date
          o["CSR Ineligibility Reason"] = 419
        end
      else
        determination_y "CSR"
    end
  end

  end
end