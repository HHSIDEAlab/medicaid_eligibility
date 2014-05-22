module MAGI
  class APTCEligibility < Ruleset
    
    input "Other MEC Offer Indicator","Preliminary APTC Logic","Char(1)", %w(Y N)
    input "Exchange Eligibility Indicator","Exchange Eligibility Logic","Char(1)", %w(Y N)
    input "Joint Filing for Married Indicator","Preliminary APTC Logic","Char(1)", %w(Y N X)
    input "Previous Year Compliance Indicator","Preliminary APTC Logic","Char(1)", %w(Y N)
    input "Applicant Non-Filer Indicator","Preliminary APTC Logic","Char(1)", %w(Y N)
    input "Applicant Income APTC Eligible Indicator","Income Logic","Char(1)", %w(Y O F)
    input "APTC Income Override Indicator","From Applicant did not meet Title II Work Quarters requirement rule","Char(1)", %w(Y N)

    determination "APTC", %w(Y N), %w(410 411 416 414 412 413 406)
    


    rule "Determine final APTC eligibility" do
      if v("Exchange Eligibility Indicator") == 'N'
        o["Applicant APTC Indicator"] = 'N'
        o["APTC Determination Date"] = current_date
        o["APTC Ineligibility Reason"] = 410
      elsif v("Applicant Income APTC Eligible Indicator") == 'F'
        o["Applicant APTC Indicator"] = 'N'
        o["APTC Determination Date"] = current_date
        o["APTC Ineligibility Reason"] = 411
      elsif v("Applicant Income APTC Eligible Indicator") == 'O' && v("APTC Income Override Indicator") == "N"
        o["Applicant APTC Indicator"] = 'N'
        o["APTC Determination Date"] = current_date
        o["APTC Ineligibility Reason"] = 416
      elsif v("Other MEC Offer Indicator") == "Y"
        o["Applicant APTC Indicator"] = 'N'
        o["APTC Determination Date"] = current_date
        o["APTC Ineligibility Reason"] = 414
      elsif v("Joint Filing for Married Indicator") == "N"
        o["Applicant APTC Indicator"] = 'N'
        o["APTC Determination Date"] = current_date
        o["APTC Ineligibility Reason"] = 412
      elsif v("Previous Year Compliance Indicator") == "N"
        o["Applicant APTC Indicator"] = 'N'
        o["APTC Determination Date"] = current_date
        o["APTC Ineligibility Reason"] = 413
      elsif v("Applicant Non-Filer Indicator") == "Y"
        o["Applicant APTC Indicator"] = 'N'
        o["APTC Determination Date"] = current_date
        o["APTC Ineligibility Reason"] = 415
      else
        determination_y "APTC"
      end
    end





  end
end