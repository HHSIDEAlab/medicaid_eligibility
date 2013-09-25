module ApplicationResponder
  def to_json(options={})
    @raw_application
    returned_json = {"Determination Date" => @determination_date, "Applicants" => []}


    # for household in @medicaid_households
    #   hh_json = {}
    #   hh_applicants = household.people.select{|p| @applicants.include? p}
    #   if hh_applicants.any?
    #     hh_json["MAGI"] = household.income
    #   end

    for app in @applicants
      app_json = {}
      app_json["Person ID"] = app.person_id

      app_json["Medicaid Household"] = {}
      app_json["Medicaid Household"]["People"] = app.medicaid_household.people.map{|p| p.person_id}
      app_json["Medicaid Household"]["MAGI"] = app.medicaid_household.income
      app_json["Medicaid Household"]["Size"] = app.medicaid_household.household_size

      app_json["Medicaid Eligible"] = app.outputs["Applicant Medicaid Indicator"]
      app_json["CHIP Eligible"] = app.outputs["Applicant CHIP Indicator"]
      
      if app.outputs["Applicant Medicaid Indicator"] == 'N' && app.outputs["Applicant CHIP Indicator"] == 'N'
        ineligibility_reason = "Applicant ineligible for the following reasons:"
        if app.applicant_attributes["Medicaid Residency Indicator"] == 'N'
          ineligibility_reason += "\nApplicant did not meet residency requirements"
        end
        if app.outputs["Applicant Medicaid Citizen Or Immigrant Indicator"] == 'N'
          ineligibility_reason += "\nApplicant did not meet citizenship/immigration requirements"
        end
        if app.outputs["Category Used to Calculate Medicaid Income"] == "None"
          ineligibility_reason += "\nApplicant did not meet the requirements for any eligibility category"
        elsif app.outputs["Applicant Income Medicaid Eligible Indicator"] == 'N'
          ineligibility_reason += "\nApplicant did not meet the income requirements for any category qualified for"            
        end
        app_json["Ineligibility Reason"] = ineligibility_reason
        app_json["Non-MAGI Referral"] = app.outputs["Applicant Medicaid Non-MAGI Referral Indicator"]
      end
      
      app_json["Category"] = app.outputs["Category Used to Calculate Medicaid Income"]
      unless ["None", "Categorically Needy"].include?(app.outputs["Category Used to Calculate Income"])
        app_json["Category Threshold"] = app.outputs["FPL * Percentage Medicaid"].to_i
      end
      app_json["CHIP Category"] = app.outputs["Category Used to Calculate CHIP Income"]
      app_json["CHIP Category Threshold"] = app.outputs["FPL * Percentage CHIP"].to_i

      app_json["Determinations"] = {}

      for det in ApplicationVariables::DETERMINATIONS
        det_json = {}
        det_json["Indicator"] = app.outputs["Applicant #{det[:name]} Indicator"]
        if app.outputs["Applicant #{det[:name]} Indicator"] == 'N'
          det_json["Ineligibility Code"] = app.outputs["#{det[:name]} Ineligibility Reason"]
        end
        app_json["Determinations"][det[:name]] = det_json
      end

      det_json = {}
      det_json["Indicator"] = app.outputs["Medicaid Residency Indicator"]
      if app.outputs["Medicaid Residency Indicator"] == 'N'
        det_json["Ineligibility Code"] = app.outputs["Medicaid Residency Ineligibility Reason"]
      end
      app_json["Determinations"]["Residency"] = det_json

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


    #   hh_json["Non-Applicants"] = household.people.select{|p| !(@applicants.include?(p))}.map{|p| {"Person ID" => p.person_id}}
    #   returned_json["Medicaid Households"] << hh_json
    # end

    JSON.pretty_generate(returned_json)
  end

  def to_xml(options={})
    nokogiri_xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.send("exch:AccountTransferRequest", Hash[XML_NAMESPACES.map{|k, v| ["xmlns:#{k}", v]}]) {
        xml.send("ext:TransferHeader") {
          xml.send("ext:TransferActivity") {
            xml.send("nc:ActivityIdentification") {
              # Need Identification ID
            }
            xml.send("nc:ActivityDate") {
              xml.send("nc:DateTime", Time.now.strftime("%Y-%m-%dT%H:%M:%S"))
            }
            xml.send("ext:TransferActivityReferralQuantity", @applicants.length)
            xml.send("ext:RecipientTransferActivityCode", "MedicaidCHIP")
            xml.send("ext:RecipientTransferActivityStateCode", @state)
          }
        }
        xml.send("hix_core:Sender") {
          # Need to figure out what to put here
        }
        xml.send("hix_core:Receiver") {
          # Need to figure out what to put here
        }
        xml.send("hix-ee:InsuranceApplication") {
          xml.send("hix-core:ApplicationCreation") {
            # Need to figure out what to put here
          }
          xml.send("hix-core:ApplicationSubmission") {
            # Need to figure out what to put here
          }
          # Do we want Application Identification?
          @applicants.each do |applicant|
            xml.send("hix-ee:InsuranceApplicant", {"s:id" => applicant.applicant_id}) {
              xml.send("hix-ee:MedicaidMAGIEligibility") {
                ApplicationVariables::DETERMINATIONS.select{|det| det[:eligibility] == :MAGI}.each do |determination|
                  det_name = determination[:name]
                  xml.send("hix-ee:MedicaidMAGI#{det_name.gsub(/ +/,'')}EligibilityBasis") {
                    build_determinations(xml, det_name, applicant)
                    if det_name == "Parent Caretaker Category"
                      xml.send("ChildrenEligibilityBasis") {
                        applicant.outputs["Children List"].each do |child|
                          xml.send("Child", {"s:ref" => child["Person ID"]}) {
                            ApplicationVariables::CHILD_OUTPUTS.each do |output|
                              xml.send(output[:name].gsub(/ +/,'')) {
                                xml.send("EligibilityBasisStatusIndicator", child["#{output[:name]} Indicator"])
                                xml.send("DateTime", child["#{output[:name]} Determination Date"])
                                xml.send("EligibilityBasisIneligibilityReasonText", child["#{output[:name]} Ineligibility Reason"])
                              }
                            end
                          }
                        end
                      }
                    end
                  }
                end
                ApplicationVariables::OUTPUTS.select{|o| o[:group] == :MAGI}.each do |output|
                  xml.send(output[:xpath], applicant.outputs[output[:name]])
                end
              }
              xml.send("hix-ee:CHIPEligibility") {
                ApplicationVariables::DETERMINATIONS.select{|det| det[:eligibility] == :CHIP}.each do |determination|
                  det_name = determination[:name]
                  xml.send("hix-ee:#{det_name.gsub(/ +/,'')}EligibilityBasis") {
                    build_determinations(xml, det_name, applicant)
                  }
                end
              }
              xml.send("hix-ee:MedicaidNonMAGIEligibility") {
                det_name = "Medicaid Non-MAGI Referral"
                xml.send("hix-ee:EligibilityIndicator", applicant.outputs["Applicant #{det_name} Indicator"])
                xml.send("hix-ee:EligibilityDetermination") {
                  xml.send("nc:ActivityDate") {
                    xml.send("nc:DateTime", applicant.outputs["#{det_name} Determination Date"].strftime("%Y-%m-%d"))
                  }
                }
                xml.send("hix-ee:EligibilityReasonText", applicant.outputs["#{det_name} Ineligibility Reason"])
              }
            }
          end
        }
        if return_application?
          @people.each do |person|
            xml.send("hix-core:Person", {"s:id" => person.person_id}) {

            }
          end
          @physical_households.each do |household|
            xml.send("ext:PhysicalHousehold") {
              household.people.each do |person|
                xml.send("hix-ee:HouseholdMemberReference", {"s:ref" => person.person_id})
              end
            }
          end
        end
      }
    end
    nokogiri_xml.to_xml
  end

  private

  def build_determinations(xml, det_name, applicant)
    xml.send("hix-ee:EligibilityBasisStatusIndicator", applicant.outputs["Applicant #{det_name} Indicator"])
    xml.send("hix-ee:EligibilityBasisDetermination") {
      xml.send("nc:ActivityDate") {
        xml.send("nc:DateTime", applicant.outputs["#{det_name} Determination Date"].strftime("%Y-%m-%d"))
      }
    }
    xml.send("hix-ee:EligibilityBasisIneligibilityReasonText", applicant.outputs["#{det_name} Ineligibility Reason"])
  end

  def build_xpath(xml, xpath)
    xpath = xpath.gsub(/^\/+/,'')
    unless xpath.empty?
      xpath_list = xpath.split('/')
      xml.send(xpath_list.first) {
        build_path(xml, xpath_list[1..-1].join('/'))
      }
    end
  end 
end
