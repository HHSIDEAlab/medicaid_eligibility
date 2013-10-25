# encoding: UTF-8

module MAGI
  class ParentCaretakerRelativeSpouse < Ruleset
    input "Applicant Relationships", "Application", "List"
    input "Physical Household", "Application", "List"
    input "Applicant Parent Caretaker Category Indicator", "Parent Caretaker Category Ruleset", "Char(1)", %w(Y N T)
    
    config "Option Caretaker Relative Relationship", "State Configuration", "Char(2)", %w(00 01 02 03 04)

    # This extra ruleset can only set the indicator to Y
    indicator "Applicant Parent Caretaker Category Indicator", %w(Y)
    date      "Parent Caretaker Category Determination Date"
    code      "Parent Caretaker Category Ineligibility Reason", %w(999)
    
    calculated "Has Spouse/Domestic Partner" do
      if v("Applicant Relationships").find{|rel| [:spouse, :domestic_partner].include?(rel.relationship_type)}
        'Y'
      else
        'N'
      end
    end

    calculated "Spouse/Domestic Partner" do
      if v("Has Spouse/Domestic Partner") == 'Y'
        v("Applicant Relationships").find{|rel| [:spouse, :domestic_partner].include?(rel.relationship_type)}.person
      else
        nil
      end
    end

    calculated "Spouse/Domestic Partner Relationship" do
      if v("Has Spouse/Domestic Partner") == 'Y'
        v("Applicant Relationships").find{|rel| [:spouse, :domestic_partner].include?(rel.relationship_type)}.relationship_type
      else
        nil
      end
    end

    calculated "Lives With Spouse/Domestic Partner" do
      if v("Has Spouse/Domestic Partner") == 'Y' && v("Physical Household").people.include?(v("Spouse/Domestic Partner"))
        'Y'
      else
        'N'
      end
    end

    rule "Caretaker Relationship – Spouse/Domestic Partner meets criteria" do
      if v("Applicant Parent Caretaker Category Indicator") == 'N' && v("Has Spouse/Domestic Partner") == 'Y' && v("Spouse/Domestic Partner").outputs["Applicant Parent Caretaker Category Indicator"] == 'Y' && v("Lives With Spouse/Domestic Partner") == 'Y'
        if v("Spouse Domestic Partner Relationship") == :spouse || (%w(02 03).include?(c("Option Caretaker Relative Relationship")) && v("Has Spouse Domestic Partner Relationship") == :domestic_partner)
          o["Applicant Parent Caretaker Category Indicator"] = 'Y'
          o["Parent Caretaker Category Determination Date"] = current_date
          o["Parent Caretaker Category Ineligibility Reason"] = 999
        end
      end
    end
  end
end
