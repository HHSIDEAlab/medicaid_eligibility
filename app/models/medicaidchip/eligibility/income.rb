# encoding: UTF-8

module Medicaidchip::Eligibility
  class Income < Ruleset
    categories = [
      "Pregnancy Category",
      "Child Category",
      "Adult Group Category",
      "Adult Group XX Category",
      "Optional Targeted Low Income Child"
    ]

    name        "Determine MAGI Eligibility"
    mandatory   "Mandatory"
    applies_to  "Medicaid and CHIP"
    
    input "Applicant Household Income", "Application", "Integer"
    input "Applicant Pregnancy Category Indicator", "From MAGI Part I", "Char(1)", %w(Y N)
    input "Applicant Child Category Indicator", "From MAGI Part I", "Char(1)", %w(Y N)
    input "Applicant Adult Group Category Indicator", "From MAGI Part I", "Char(1)", %w(Y N)
    input "Applicant Adult Group XX Category Indicator", "From MAGI Part I", "Char(1)", %w(Y N X)
    input "Applicant Optional Targeted Low Income Child Indicator", "From MAGI Part I", "Char(1)", %w(Y N T X)
    #input "Applicant CHIP Targeted Low Income Child Indicator", "From MAGI Part I", "Char(1)", %w(Y N T X)
    input "Household", "Householding Logic", "Array"

    config "Category->Percentage Mapping", "State Configuration", "Hash" 
    config "Base FPL", "State Configuration", "Integer"
    config "FPL Per Person", "State Configuration", "Integer"

    # Outputs
    output    "Category Used to Calculate Income", "String", categories
    indicator "Applicant Income Indicator", %w(Y N T)
    date      "Income Determination Date"
    code      "Income Ineligibility Reason", %w(999 A B)

    calculated "FPL" do
      c("Base FPL") + v("Household").length * c("FPL Per Person")
    end

    calculated "Max Eligible Income" do
      eligible_categories = categories.select{|cat| v("Applicant #{cat} Indicator") == 'Y'}
      if eligible_categories.any?
        category = eligible_categories.max_by{|cat| c("Category->Percentage Mapping")[cat]}
        {
          :category => category,
          :income   => v("FPL") * (c("Category->Percentage Mapping")[category] + .05)
        }
      else
        {
          :category => nil,
          :income   => nil
        }
      end
    end

    calculated "Max Temporary Income" do
      eligible_categories = categories.select{|cat| v("Applicant #{cat} Indicator") == 'T'}
      if eligible_categories.any?
        category = eligible_categories.max_by{|cat| c("Category->Percentage Mapping")[cat]}
        {
          :category => category,
          :income   => v("FPL") * (c("Category->Percentage Mapping")[category] + .05)
        }
      else
        {
          :category => nil,
          :income   => nil
        }
      end
    end

    rule "Applicant does not meet the requirements for any category" do
      unless v("Max Eligible Income")[:category] || v("Max Temporary Income")[:category]
        o["Category Used to Calculate Income"] = "None"
        o["Applicant Income Indicator"] = "N"
        o["Income Determination Date"] = current_date
        o["Income Ineligibility Reason"] = "Unimplemented"
      end
    end

    rule "Applicant does not meet the income requirements for any qualified category" do
      if (v("Max Eligible Income")[:category] || v("Max Temporary Income")[:category]) && (v("Max Eligible Income")[:category].nil? || v("Applicant Household Income") > v("Max Eligible Income")[:income]) && (v("Max Temporary Income")[:category].nil? || v("Applicant Household Income") > v("Max Temporary Income")[:income])
        o["Category Used to Calculate Income"] = v("Max Eligible Income")[:category] ? v("Max Eligible Income")[:category] : v("Max Temporary Income")[:category]
        o["Applicant Income Indicator"] = "N"
        o["Income Determination Date"] = current_date
        o["Income Ineligibility Reason"] = "Unimplemented"
      end
    end

    rule "Applicant meets the income requirements for a qualified category" do
      if v("Max Eligible Income")[:category] && v("Applicant Household Income") <= v("Max Eligible Income")[:income]
        o["Category Used to Calculate Income"] = v("Max Eligible Income")[:category]
        o["Applicant Income Indicator"] = "Y"
        o["Income Determination Date"] = current_date
        o["Income Ineligibility Reason"] = 999
      end
    end

    rule "Applicant meets the income requirements for a temporarily qualified category" do
      if (v("Max Eligible Income")[:category].nil? || v("Applicant Household Income") > v("Max Eligible Income")[:income]) && v("Max Temporary Income")[:category] && v("Applicant Household Income") <= v("Max Temporary Income")[:income]
        o["Category Used to Calculate Income"] = v("Max Temporary Income")[:category]
        o["Applicant Income Indicator"] = "T"
        o["Income Determination Date"] = current_date
        o["Income Ineligibility Reason"] = 999
      end
    end
  end
end
