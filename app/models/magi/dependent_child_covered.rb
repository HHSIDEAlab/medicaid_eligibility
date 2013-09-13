# encoding: UTF-8

module MAGI
  class DependentChildCovered < Ruleset
    name        "Determine Medicaid Eligibility - Dependent Child Covered"
    mandatory   "Mandatory"
    references  "§435.119(c) and §435.218(b)(2)(ii)"
    applies_to  "Medicaid"
    purpose     "Determine if child has minimum essential coverage."
    description "Applicants cannot be determined eligible for Medicaid under the Adult Group or the Adult XX Group if:\n- The applicant is a parent of a child under a specified age with whom they are living or a caretaker relative of a dependent child; and\n- Such child or dependent child is not covered by Medicaid, CHIP or other minimum essential coverage (MEC), unless the child is also applying for coverage on the application.\nPer policy, the specified age used for a parent’s children for this rule is a state-configurable age equal to 19, 20 or 21, depending on whether or not the state currently covers individuals up to age of 19, 20 or 21 under Medicaid"

    assumption "Note that the logic currently contained in this rule requires that an applicant’s own children, as well as other children for whom the applicant may exercise primary responsibility, meet the requirements to be a “dependent child” – i.e., be under age 18 or, at state option age 18 and a full time student and be deprived of parental support – in order for the child’s parent to be subject to this restriction on coverage under the Adult Group or Adult XX Group."  
    assumption "The logic does not implement the policy with respect to older children (ages 18, 19 and 20) or younger children who do not meet the definition of a \"dependent child.\""

    input "Applicant List", "Application", "List"
    input "Person List", "Application", "List"
    input "Applicant Adult Group Category Indicator", "From Identify Medicaid Category – Adult Group rule", "Char(1)", %w(Y N)
    input "Applicant Adult Group XX Category Indicator", "From Identify Medicaid Category – Adult Group rule", "Char(1)", %w(Y N)
    input "Qualified Children List", "From Parent Caretaker Category Rule", "List"

    # Outputs
    determination "Dependent Child Covered", %w(Y N X), %w(999 128 555)

    rule "Determine eligibility - Dependent Child Covered" do
      if v("Applicant Adult Group Category Indicator") == 'N' || v("Applicant Adult Group XX Category Indicator") == 'N' || v("Qualified Children List").empty?
        determination_na "Dependent Child Covered"
      elsif v("Qualified Children List").all?{|child| v("Applicant List").any?{|app| app.person_id == child["Person ID"]} || v("Person List").find{|p| p.person_id == child["Person ID"]}.applicant_attributes["Has Insurance"] == 'Y'}
        determination_y "Dependent Child Covered"
      else
        o["Applicant Dependent Child Covered Indicator"] = 'N'
        o["Dependent Child Covered Determination Date"] = current_date
        o["Dependent Child Covered Ineligibility Reason"] = 128
      end
    end
  end
end