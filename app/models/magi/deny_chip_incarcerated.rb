# encoding: UTF-8

module MAGI
  class DenyCHIPIncarcerated < Ruleset
    name        "Deny CHIP for Children who are Incarcerated"
    mandatory   "Mandatory"
    references  "§42 CFR 457.310(c)(2)"
    applies_to  "CHIP only"
    purpose     "Determine if child is ineligible for CHIP due to incarceration."
    description "Applicants who are inmates in a public institution are not eligible for CHIP."
    
    assumption  "If an attestation indicates an applicant is incarcerated, the Applicant CHIP Incarceration Status Indicator will be set to The Exchange will collect attestations of whether applicants are incarcerated via the application."
    assumption  "The logic is written so that if the child is incarcerated or institutionalized, the indicator will be set to “yes,” which means the applicant is not eligible for CHIP.  This is the opposite of most other indicators, in which a value equal to “yes” supports a positive finding of eligibility."
    assumption  "If an applicant who is a pregnant woman attests to being incarcerated, the baby expected by the pregnant woman will not be eligible for CHIP."

    input "Incarceration Status", "Application", "Char(1)", %w(Y N)

    # Outputs
    determination "CHIP Incarceration", %w(Y N), %w(999 140)

    rule "Applicant is not incarcerated" do
      if v("Incarceration Status") == 'N' 
        o["Applicant CHIP Incarceration Indicator"] = 'N'
        o["CHIP Incarceration Determination Date"] = current_date
        o["CHIP Incarceration Ineligibility Reason"] = 999
      else
        o["Applicant CHIP Incarceration Indicator"] = 'Y'
        o["CHIP Incarceration Determination Date"] = current_date
        o["CHIP Incarceration Ineligibility Reason"] = 140
      end
    end
  end
end
