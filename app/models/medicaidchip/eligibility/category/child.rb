# encoding: UTF-8

module Medicaidchip::Eligibility::Category
  class Child < Ruleset
    references  "§435.118 (Medicaid); 1102 of SSA (for CHIP)"
    applies_to  "Medicaid and CHIP"
    purpose     "Determine if child category applies."
    description "States are required to provide Medicaid to children under age 19.  At state option, individuals under age 20 (i.e., age 19) or under age 21 (i.e., ages 19 and 20) may also be covered under an optional group for this age range.  The income standard applicable in the state for each of three age ranges of children under 19 (under age 1, ages 1 – 5, and ages 6 – 18), as well as the income standard for optionally-covered 19 and 20 year olds may differ."

    calculated "Applicant Age" do
      (current_date - v("Person Birth Date"))/365.25
    end

    # Outputs
    indicator "Applicant Child Category Indicator", %w(Y N)
    date "Child Category Determination Date"
    code "Child Category Ineligibility Reason", %w(999 115 394)

    rule "Child is under 19 years old" do
      if v("Applicant Age") < c("Child Age Threshold")
        o["Applicant Child Category Indicator"] = 'Y'
        o["Child Category Determination Date"] = current_date
        o["Child Category Ineligibility Reason"] = 999
      end
    end

    rule "State does not  cover young adults- Child is over 18" do
      if c("Option Young Adults") == 'Y' && v("Applicant Age") < c("Young Adult Age Threshold")
        o["Applicant Child Category Indicator"] = 'Y'
        o["Child Category Determination Date"] = current_date
        o["Child Category Ineligibility Reason"] = 999
      end
    end
  end
end
