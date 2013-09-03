module ApplicationResponder
  def to_json(options={})
    @raw_application
    returned_json = {"Determination Date" => @determination_date, "Applicants" => []}
    for app in @applicants
      app_json = {}
      app_json["Person ID"] = app.person_id
      app_json["Determinations"] = {}

      app_json["Determinations"]["Applicant Parent Caretaker Category Indicator"] = app.outputs["Applicant Parent Caretaker Category Indicator"]
      ineligibility_reason = app.outputs["Parent Caretaker Category Ineligibility Reason"]
      if ineligibility_reason != 999
        app_json["Determinations"]["Parent Caretaker Category Ineligibility Reason"] = ineligibility_reason
      end
      app_json["Determinations"]["Qualified Children List"] = []
      for qual_child in app.outputs["Qualified Children List"]
        child_json = {}
        for k in qual_child.keys
          unless /Determination Date$/ =~ k || (/Ineligibility Reason$/ =~ k && qual_child[k] == 999)
            child_json[k] = qual_child[k]
          end
        end
        app_json["Determinations"]["Qualified Children List"] << child_json
      end

      for det in ApplicationVariables::DETERMINATIONS.select{|d| !(["Parent Caretaker Category", "Income"].include?(d[:name]))}
        app_json["Determinations"]["Applicant #{det[:name]} Indicator"] = app.outputs["Applicant #{det[:name]} Indicator"]
        ineligibility_reason = app.outputs["#{det[:name]} Ineligibility Reason"]
        if ineligibility_reason != 999
          app_json["Determinations"]["#{det[:name]} Ineligibility Reason"] = ineligibility_reason
        end
      end

      app_json["Determinations"]["Applicant Income Determination Indicator"] = app.outputs["Applicant Income Indicator"]
      ineligibility_reason = app.outputs["Income Ineligibility Reason"]
      if ineligibility_reason != 999
        app_json["Determinations"]["Income Ineligibility Reason"] = ineligibility_reason
      end
      for output in ["Category Used to Calculate Income", "Percentage for Category Used", "FPL * Percentage", "Calculated Income"]
        app_json["Determinations"][output] = app.outputs[output]
      end

      returned_json["Applicants"] << app_json
    end

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
