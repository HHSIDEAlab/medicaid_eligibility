# encoding: UTF-8

module MAGI
  class Residency < Ruleset
    input "Lives In State", "From Application", "Char(1)", %w(Y N)
    input "No Fixed Address", "From Application", "Char(1)", %w(Y N)
    input "Temporarily Out of State", "From Application", "Char(1)", %w(Y N)
    input "Medicaid Household", "From Householding Logic", "Object"
    input "Claimed as Dependent by Person Not on Application", "Application", "Char(1)", %w(Y N)
    input "Claimer Is Out of State", "Application", "Char(1)", %w(Y N)
    input "Student Indicator", "Application", "Char(1)", %w(Y N)
    input "Person ID", "Application", "String"
    input "Tax Returns", "Application", "List"

    config "Option Deny Residency to Temporary Resident Students", "State Configuration", "Char(1)", %w(Y N)

    # Outputs
    indicator "Medicaid Residency Indicator", %w(Y N)
    date      "Medicaid Residency Indicator Determination Date"
    code      "Medicaid Residency Indicator Ineligibility Reason", %w(999 403 404)

    rule "Determine Residency" do
      if v("Lives In State") == 'Y' || v("Temporarily Out of State") == 'Y' || v("No Fixed Address") == 'Y'
        if c("Option Deny Residency to Temporary Resident Students") == 'Y' &&
          v("Student Indicator") == 'Y' &&
          v("Medicaid Household").people.count == 1 &&
          ((v("Claimed as Dependent by Person Not on Application") == 'Y' &&
            v("Claimer Is Out of State") == 'Y') ||
           (v("Tax Returns").any?{|tr|
              tr.dependents.any?{|dep| dep.person_id == v("Person ID")} &&
              tr.filers.any?{|filer| filer.person_attributes["Lives In State"] == 'N'}
            }))
          o["Medicaid Residency Indicator"] = 'N'
          o["Medicaid Residency Indicator Determination Date"] = current_date
          o["Medicaid Residency Indicator Ineligibility Reason"] = 403
        else
          o["Medicaid Residency Indicator"] = 'Y'
          o["Medicaid Residency Indicator Determination Date"] = current_date
          o["Medicaid Residency Indicator Ineligibility Reason"] = 999
        end
      else
        o["Medicaid Residency Indicator"] = 'N'
        o["Medicaid Residency Indicator Determination Date"] = current_date
        o["Medicaid Residency Indicator Ineligibility Reason"] = 404
      end
    end
  end
end
