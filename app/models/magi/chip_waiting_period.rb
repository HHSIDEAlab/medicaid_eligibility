# encoding: UTF-8

module MAGI
  class CHIPWaitingPeriod < Ruleset
    name        "CHIP Waiting Period"
    mandatory   "Optional"
    references  "§457.350, 2102(b)(3)(C) of the Act"
    applies_to  "CHIP only, children only"
    purpose     "Determine if the child is subject to a waiting period."
    description "States may impose a waiting period following the date of an applicant's disenrollment from private group health coverage before he or she may enroll in CHIP. In this rule, the Exchange will check a state configuration table to determine if the state imposes a waiting period, and if so, the length of the waiting period."
    
    assumption  "If the waiting period is satisfied, the indicator will be set to \"yes.\"" 
    assumption  "The Exchange will calculate the end date of the waiting period by adding the length of the state’s waiting period to the date the applicant disenrolled from the other coverage, which will be obtained from the application."
    assumption  "The Exchange does not support rules applying state exceptions to the waiting period."

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

    special_instruction "The state CHIP agency will be responsible for tracking and informing the Exchange when the waiting period has expired so that APTC/CSR can be terminated, when applicable, and the applicant can be enrolled in CHIP (provided that all other eligibility criteria are met)."
  end
end
