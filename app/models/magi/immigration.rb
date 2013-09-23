# encoding: UTF-8

module MAGI
  class Immigration < Ruleset
    name        "Determine MAGI Eligibility"
    mandatory   "Mandatory"
    applies_to  "Medicaid and CHIP"
    
    input "US Citizen Indicator", "Application", "Char(1)", %w(Y N)
    input "Legal Permanent Resident", "Application", "Char(1)", %w(Y N)
    input "Lawful Presence Attested", "Application", "Char(1)", %w(Y N)
    input "Qualified Non-Citizen Status", "Application", "Char(1)", %w(Y N)
    input "Applicant Income Medicaid Eligible Indicator", "Income Rule", "Char(1)", %w(Y N)
    input "Applicant Age", "Application", "Number"  
    input "Applicant Pregnancy Category Indicator", "Pregnancy Rule", "Char(1)", %w(Y N)
    input "Victim of Trafficking", "Application", "Char(1)", %w(Y N)
    input "Applicant Seven Year Limit Applies", "Application", "Char(1)", %w(Y N)
    input "Seven Year Limit Start Date", "Application", "Date"
    input "Five Year Bar Applies", "Application", "Char(1)", %w(Y N)
    input "Five Year Bar Met", "Application", "Char(1)", %w(Y N)
    input "Veteran Status", "Application", "Char(1)", %w(Y N)    
    input "Applicant Has 40 Title II Work Quarters", "Application", "Char(1)", %w(Y N)
    
    config "Option CHIPRA 214 Applicable Program", "State Configuration", "Char(2)", %w(01 02 03)
    config "Option CHIPRA 214 Child Age Threshold", "State Configuration", "Number", [19, 20, 21]
    config "Option CHIPRA 214 Applies To", "State Configuration", "Char(2)", %w(01 02 03)
    config "Option CHIPRA 214 CHIP Applies To", "State Configuration", "Char(2)", %w(01 02 03)
    config "State Applies Seven Year Limit", "State Configuration", "Char(1)", %w(Y N)
    config "Option Require Work Quarters", "State Configuration", "Char(1)", %w(Y N)
    
    calculated "Applicant Seven Year Limit End Date" do
      if v("Seven Year Limit Applies") == 'Y'
        v("Seven Year Limit Start Date") + 7.years
      else
        nil
      end
    end

    # Outputs
    determination "Medicaid Citizen Or Immigrant", %w(Y N), %w(999 101 141 142 372 381)
    determination "CHIPRA 214", %w(Y N X), %w(999 555 118 119 120)
    determination "Trafficking Victim", %w(Y N X), %w(999 555)
    determination "Seven Year Limit", %w(Y N X), %w(999 555 111)
    determination "Five Year Bar", %w(Y N X), %w(999 555 143)
    determination "Title II Work Quarters Met", %w(Y N X), %w(999 555 104)

    rule "Determine citizen or immigrant status" do
      if v("US Citizen Indicator") == 'Y'
        determination_y "Medicaid Citizen Or Immigrant"
        
        determination_na "CHIPRA 214"
        determination_na "Trafficking Victim"
        determination_na "Seven Year Limit"
        determination_na "Five Year Bar"
        determination_na "Title II Work Quarters Met"
      elsif v("Lawful Presence Attested") == 'N'
        determination_na "CHIPRA 214"
        if v("Qualified Non-Citizen Status") == 'N'
          o["Applicant Medicaid Citizen Or Immigrant Indicator"] = 'N'
          o["Medicaid Citizen Or Immigrant Determination Date"] = current_date
          o["Medicaid Citizen Or Immigrant Inconsistency Reason"] = 152
          
          determination_na "Trafficking Victim"
          determination_na "Seven Year Limit"
          determination_na "Five Year Bar"
          determination_na "Title II Work Quarters Met"
        end
      end

      # CHIPRA 214 logic
      unless o["Applicant CHIPRA 214 Indicator"] == 'X'
        if c("Option CHIPRA 214 Applicable Program") == '03' 
          determination_na "CHIPRA 214"
        elsif c("Option CHIPRA 214 Applicable Program") == '02' && v("Applicant Income Medicaid Eligible Indicator") == 'N'
          determination_na "CHIPRA 214"
        elsif c("Option CHIPRA 214 Applies To") == '01' && c("Option CHIPRA 214 CHIP Applies To") == '01'
          if v("Applicant Age") < c("Option CHIPRA 214 Child Age Threshold") || v("Applicant Pregnancy Category Indicator") == 'Y'
            determination_y "CHIPRA 214"

            determination_na "Trafficking Victim"
            determination_na "Seven Year Limit"
            determination_na "Five Year Bar"
            determination_na "Title II Work Quarters Met"
          else
            o["Applicant CHIPRA 214 Indicator"] = 'N'
            o["CHIPRA 214 Determination Date"] = current_date
            o["CHIPRA 214 Ineligibility Reason"] = 119
          end
        elsif (c("Option CHIPRA 214 Applies To") == '01' && c("Option CHIPRA 214 CHIP Applies To") == '02') || c("Option CHIPRA 214 Applies To") == '02'
          if v("Applicant Age") < c("Option CHIPRA 214 Child Age Threshold")
            determination_y "CHIPRA 214"

            determination_na "Trafficking Victim"
            determination_na "Seven Year Limit"
            determination_na "Five Year Bar"
            determination_na "Title II Work Quarters Met"
          else
            o["Applicant CHIPRA 214 Indicator"] = 'N'
            o["CHIPRA 214 Determination Date"] = current_date
            o["CHIPRA 214 Ineligibility Reason"] = 118
          end
        elsif (c("Option CHIPRA 214 Applies To") == '01' && c("Option CHIPRA 214 CHIP Applies To") == '03') || c("Option CHIPRA 214 Applies To") == '03'
          if v("Applicant Pregnancy Category Indicator") == 'Y'
            determination_y "CHIPRA 214"

            determination_na "Trafficking Victim"
            determination_na "Seven Year Limit"
            determination_na "Five Year Bar"
            determination_na "Title II Work Quarters Met"
          else
            o["Applicant CHIPRA 214 Indicator"] = 'N'
            o["CHIPRA 214 Determination Date"] = current_date
            o["CHIPRA 214 Ineligibility Reason"] = 120
          end
        end
      end

      # Victim of Trafficking logic
      unless o["Applicant Trafficking Victim Indicator"] == 'X'
        if v("Victim of Trafficking") == 'Y'
          determination_y "Trafficking Victim"
        else
          determination_na "Trafficking Victim"
        end
      end

      # Seven Year Limit logic
      unless o["Applicant Seven Year Limit Indicator"] == 'X'
        if c("State Applies Seven Year Limit") == 'N' 
          determination_na "Seven Year Limit"
        elsif v("Seven Year Limit Start Date").nil?
          determination_na "Seven Year Limit"
        elsif v("Applicant Seven Year Limit Applies") == 'Y' && v("Applicant Seven Year Limit End Date") > current_date
          determination_y "Seven Year Limit"

          determination_na "Five Year Bar"
          determination_na "Title II Work Quarters Met"
        else 
          o["Applicant Seven Year Limit Indicator"] = 'N'
          o["Seven Year Limit Determination Date"] = current_date
          o["Seven Year Limit Ineligibility Reason"] = 111

          determination_na "Five Year Bar"
          determination_na "Title II Work Quarters Met"
        end
      end

      # Five Year Bar logic
      unless o["Applicant Five Year Bar Indicator"] == 'X'
        if v("Five Year Bar Applies") == 'N' 
          determination_na "Five Year Bar"

          if v("Legal Permanent Resident") == 'Y'
            determination_na "Title II Work Quarters Met"
          end
        elsif v("Veteran Status") == 'Y'
          determination_na "Five Year Bar"
          determination_na "Title II Work Quarters Met"
        elsif v("Five Year Bar Met") == 'Y' 
          determination_y "Five Year Bar"
        else
          o["Applicant Five Year Bar Indicator"] = 'N'
          o["Five Year Bar Determination Date"] = current_date
          o["Five Year Bar Ineligibility Reason"] = 143

          determination_na "Title II Work Quarters Met"
        end
      end

      # Title II Work Quarters logic
      unless o["Applicant Title II Work Quarters Met Indicator"] == 'X'
        if c("Option Require Work Quarters") == 'N' || v("Legal Permanent Resident") == 'Y'
          determination_na "Title II Work Quarters Met"
        elsif v("Applicant Has 40 Title II Work Quarters") == 'Y'
          determination_y "Title II Work Quarters Met"
        else
          o["Applicant Title II Work Quarters Met Indicator"] = 'N'
          o["Title II Work Quarters Met Determination Date"] = current_date
          o["Title II Work Quarters Met Ineligibility Reason"] = 104
        end
      end

      # Final Immigration status
      unless o["Applicant Medicaid Citizen Or Immigrant Indicator"]
        if o["Applicant CHIPRA 214 Indicator"] == 'Y' || o["Applicant Trafficking Indicator"] == 'Y' || o["Applicant Seven Year Limit Indicator"] == 'Y' || (o["Applicant Seven Year Limit Indicator"] == 'X' && %w(Y X).include?(o["Applicant Five Year Bar Indicator"]) && %w(Y X).include?(o["Applicant Title II Work Quarters Met Indicator"]))
          determination_y "Medicaid Citizen Or Immigrant"
        else
          o["Applicant Medicaid Citizen Or Immigrant Indicator"] = 'N'
          o["Medicaid Citizen Or Immigrant Determination Date"] = current_date
          o["Medicaid Citizen Or Immigrant Ineligibility Reason"] = 101 
        end
      end
    end
  end
end
