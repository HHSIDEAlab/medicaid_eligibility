module ApplicationResponder
  def to_json(options={})
    unless @error.nil?
      return JSON.pretty_generate({"Error" => @error.message})
    end

    returned_json = {"Determination Date" => @determination_date, "Applicants" => []}

    for app in @applicants
      app_json = {}
      app_json["Person ID"] = app.person_id

      app_json["Medicaid Household"] = {}
      app_json["Medicaid Household"]["People"] = app.medicaid_household.people.map{|p| p.person_id}
      app_json["Medicaid Household"]["MAGI"] = app.medicaid_household.income
      app_json["Medicaid Household"]["MAGI as Percentage of FPL"] = app.outputs["Calculated Income as Percentage of FPL"]
      app_json["Medicaid Household"]["Size"] = app.medicaid_household.household_size

      app_json["Medicaid Eligible"] = app.outputs["Applicant Medicaid Indicator"]
      app_json["CHIP Eligible"] = app.outputs["Applicant CHIP Indicator"]

      # Medicaid ineligibility explanation
      if app.outputs["Applicant Medicaid Indicator"] == 'N'
        ineligibility_reasons = []
        if app.outputs["Medicaid Residency Indicator"] == 'N'
          ineligibility_reasons << "Applicant did not meet residency requirements"
        end
        if app.outputs["Applicant Medicaid Citizen Or Immigrant Indicator"] == 'N'
          ineligibility_reasons << "Applicant did not meet citizenship/immigration requirements"
        end
        if app.outputs["Category Used to Calculate Medicaid Income"] == "None"
          ineligibility_reasons << "Applicant did not meet the requirements for any Medicaid category"
        elsif app.outputs["Applicant Income Medicaid Eligible Indicator"] == 'N'
          ineligibility_reasons << "Applicant's MAGI above the threshold for category"
        end
        if app.outputs["Applicant Dependent Child Covered Indicator"] == 'N'
          ineligibility_reasons << "Applicant has a dependent child who does not have coverage and is not included on the application"
        end
        if app.outputs["Previously Denied"]
          ineligibility_reasons << "Overriden to ineligible because applicant was previously denied"
        end
        app_json["Ineligibility Reason"] = ineligibility_reasons
        app_json["Non-MAGI Referral"] = app.outputs["Applicant Medicaid Non-MAGI Referral Indicator"]
      end

      # CHIP ineligibility explanation
      if app.outputs["Applicant CHIP Indicator"] == 'N'
        ineligibility_reasons = []
        if app.outputs["Medicaid Residency Indicator"] == 'N'
          ineligibility_reasons << "Applicant did not meet residency requirements"
        end
        if app.outputs["Applicant CHIP Citizen Or Immigrant Indicator"] == 'N'
          ineligibility_reasons << "Applicant did not meet citizenship/immigration requirements"
        end
        if app.outputs["Category Used to Calculate CHIP Income"] == "None"
          ineligibility_reasons << "Applicant did not meet the requirements for any CHIP category"
        elsif app.outputs["Applicant Income CHIP Eligible Indicator"] == 'N'
          ineligibility_reasons << "Applicant's MAGI above the threshold for category"
        end
        if app.applicant_attributes['Has Insurance'] == 'Y'
          ineligibility_reasons << "Applicant already has insurance"
        end
        if app.outputs["Applicant State Health Benefits CHIP Indicator"] == 'N'
          ineligibility_reasons << "Applicant not eligible under state health benefits rule"
        end
        if app.outputs["Applicant CHIP Waiting Period Satisfied Indicator"] == 'N'
          ineligibility_reasons << "Applicant has not satisfied the CHIP waiting period"
        end
        if app.applicant_attributes["Incarceration Status"] == 'Y'
          ineligibility_reasons << "Applicant is incarcerated"
        end
        if app.outputs["Previously Denied"]
          ineligibility_reasons << "Overriden to ineligible because applicant was previously denied"
        end
        app_json["CHIP Ineligibility Reason"] = ineligibility_reasons
      end

      app_json["Category"] = app.outputs["Category Used to Calculate Medicaid Income"]
      unless ["None"].include?(app.outputs["Category Used to Calculate Medicaid Income"])
        app_json["Category Threshold"] = app.outputs["FPL * Percentage Medicaid"].to_i
      end
      app_json["CHIP Category"] = app.outputs["Category Used to Calculate CHIP Income"]
      app_json["CHIP Category Threshold"] = app.outputs["FPL * Percentage CHIP"].to_i

      app_json["Determinations"] = {}

      det_json = {}
      det_json["Indicator"] = app.outputs["Medicaid Residency Indicator"]
      if app.outputs["Medicaid Residency Indicator"] == 'N'
        det_json["Ineligibility Code"] = app.outputs["Medicaid Residency Ineligibility Reason"]
        det_json["Ineligibility Reason"] = MedicaidEligibilityApi::Application.options[:ineligibility_reasons][det_json["Ineligibility Code"]]
      end
      app_json["Determinations"]["Residency"] = det_json

      for det in ApplicationVariables::DETERMINATIONS
        det_json = {}
        det_json["Indicator"] = app.outputs["Applicant #{det[:name]} Indicator"]
        if app.outputs["Applicant #{det[:name]} Indicator"] == 'N'
          det_json["Ineligibility Code"] = app.outputs["#{det[:name]} Ineligibility Reason"]
          det_json["Ineligibility Reason"] = MedicaidEligibilityApi::Application.options[:ineligibility_reasons][det_json["Ineligibility Code"]]
        end
        app_json["Determinations"][det[:name]] = det_json
      end

      if app.outputs["APTC Referral Indicator"]
        det_json = {}
        det_json["Indicator"] = app.outputs["APTC Referral Indicator"]
        if app.outputs["APTC Referral Indicator"] == 'N'
          det_json["Ineligibility Code"] = app.outputs["APTC Referral Ineligibility Reason"]
          det_json["Ineligibility Reason"] = MedicaidEligibilityApi::Application.options[:ineligibility_reasons][det_json["Ineligibility Code"]]
        end
        app_json["Determinations"]["APTC Referral"] = det_json
      end

      if app.outputs["Previously Denied"] == 'Y' || app.outputs["Previously Denied"] == 'N'
        det_json = {}
        det_json["Indicator"] = app.outputs["Previously Denied"]
        if app.outputs["Previously Denied"] == 'N'
          det_json["Ineligibility Code"] = "123"
          det_json["Ineligibility Reason"] = "Not Previously Denied"
        end
        app_json["Determinations"]["Previously Denied"] = det_json
      end

      app_json["Other Outputs"] = {}
      app_json["Other Outputs"]["Qualified Children List"] = []
      for qual_child in app.outputs["Qualified Children List"]
        child_json = {
          "Person ID" => qual_child["Person ID"],
          "Determinations" => {}
        }
        for det_name in ["Dependent Age", "Deprived Child", "Relationship"]
          det_json = {}
          det_json["Indicator"] = qual_child["Child of Caretaker #{det_name} Indicator"]
          if qual_child["Child of Caretaker #{det_name} Indicator"] == 'N'
            det_json["Ineligibility Code"] = qual_child["Child of Caretaker #{det_name} Ineligibility Reason"]
          end
          child_json["Determinations"][det_name] = det_json
        end
        app_json["Other Outputs"]["Qualified Children List"] << child_json
      end

      returned_json["Applicants"] << app_json
    end

    JSON.pretty_generate(returned_json)
  end
end
