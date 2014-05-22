# encoding: UTF-8

module MAGI
  class CHIPWaitingPeriod < Ruleset
    input "Applicant CHIP Prelim Indicator", "Preliminary CHIP Eligibility", "Char(1)", %w(Y N)
    input "Prior Insurance", "Application", "Char(1)", %w(Y N)
    input "Prior Insurance End Date", "Application", "Date"  

    config "State CHIP Waiting Period", "State Configuration", "Numeric", (0..12)

    calculated "State CHIP Waiting Period End Date" do
      if v("Prior Insurance") == 'Y'
        v("Prior Insurance End Date") + c("State CHIP Waiting Period").months
      else
        nil
      end
    end

    # Outputs
    determination "CHIP Waiting Period Satisfied", %w(Y N X), %w(999 555 139)

    rule "Determine CHIP waiting period" do
      if v("Applicant CHIP Prelim Indicator") == 'Y' && c("State CHIP Waiting Period") > 0 && v("Prior Insurance") == 'Y'
        if v("State CHIP Waiting Period End Date") <= current_date 
          determination_y "CHIP Waiting Period Satisfied"
        else
          o["Applicant CHIP Waiting Period Satisfied Indicator"] = 'N'
          o["CHIP Waiting Period Satisfied Determination Date"] = current_date
          o["CHIP Waiting Period Satisfied Ineligibility Reason"] = 139
        end
      else
        determination_na "CHIP Waiting Period Satisfied"
      end
    end
  end
end
