# encoding: UTF-8

module MAGI
  class DependentChildCovered < Ruleset
    input "Applicant List", "Application", "List"
    input "Person List", "Application", "List"
    input "Qualified Children List", "From Parent Caretaker Category Rule", "List"

    # Outputs
    determination "Dependent Child Covered", %w(Y N X), %w(999 128 555)

    rule "Determine eligibility - Dependent Child Covered" do
      if v("Qualified Children List").empty?
        determination_na "Dependent Child Covered"
      elsif v("Qualified Children List").all?{|child| v("Applicant List").any?{|app| app.person_id == child["Person ID"]} || v("Person List").find{|p| p.person_id == child["Person ID"]}.person_attributes["Has Insurance"] == 'Y'}
        determination_y "Dependent Child Covered"
      else
        o["Applicant Dependent Child Covered Indicator"] = 'N'
        o["Dependent Child Covered Determination Date"] = current_date
        o["Dependent Child Covered Ineligibility Reason"] = 128
      end
    end
  end
end