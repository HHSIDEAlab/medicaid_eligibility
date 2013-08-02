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
    indicator "Applicant MAGI Income Eligibility Indicator", %w(Y N T)
    date      "MAGI Income Eligibility Determination Date"
    #code      "MAGI Income Eligibility Ineligibility Reason", %w()

    calculated "FPL" do
      c("Base FPL") + v("Household Size").length * c("FPL Per Person")
    end

    calculated "Max Eligibile Income" do
      eligible_categories = categories.select{|cat| v("Applicant #{cat} Indicator") == 'Y'}
      if eligible_categories.any?
        category = eligible_categories.max_by{|cat| c("Category->Percentage Mapping")[cat]}
        {
          :category => category,
          :income   => v("FPL") * c("Category->Percentage Mapping")[cat]
        }
      else
        nil
      end
    end

    calculated "Max Temporary Income" do
      eligible_categories = categories.select{|cat| v("Applicant #{cat} Indicator") == 'T'}
      if eligible_categories.any?
        category = eligible_categories.max_by{|cat| c("Category->Percentage Mapping")[cat]}
        {
          :category => category,
          :income   => v("FPL") * c("Category->Percentage Mapping")[cat]
        }
      else
        nil
      end
    end

    rule "Applicant does not meet the requirements for any category" do
      unless v("Max Eligible Income") || v("Max Temporary Income")
        o["Category Used to Calculate Income"] = "None"
        o["Applicant MAGI Income Eligibility Indicator"] = "N"
        o["MAGI Income Eligibility Determination Date"] = current_date
      end
    end

    rule "Applicant does not meet the income requirements for any qualified category" do
      if (v("Max Eligible Income") || v("Max Temporary Income")) && (v("Max Eligible Income").nil? || v("Applicant Household Income") > v("Max Eligible Income")[:income]) && (v("Max Temporary Income").nil? v("Applicant Household Income") > v("Max Temporary Income")[:income])
        o["Category Used to Calculate Income"] = v("Max Eligible Income") ? v("Max Eligible Income")[:category] : v("Max Temporary Income")[:category]
        o["Applicant MAGI Income Eligibility Indicator"] = "N"
        o["MAGI Income Eligibility Determination Date"] = current_date
      end
    end

    rule "Applicant meets the income requirements for a qualified category" do
      if v("Max Eligible Income") && v("Applicant Household Income") <= v("Max Eligible Income")[:income]
        o["Category Used to Calculate Income"] = v("Max Eligible Income")[:category]
        o["Applicant MAGI Income Eligibility Indicator"] = "Y"
        o["MAGI Income Eligibility Determination Date"] = current_date
      end
    end

    rule "Applicant meets the income requirements for a temporarily qualified category" do
      if (v("Max Eligible Income").nil? || v("Applicant Household Income") > v("Max Eligible Income")[:income]) && v("Max Temporary Income") && v("Applicant Household Income") <= v("Max Temporary Income")[:income]
        o["Category Used to Calculate Income"] = v("Max Temporary Income")[:category]
        o["Applicant MAGI Income Eligibility Indicator"] = "T"
        o["MAGI Income Eligibility Determination Date"] = current_date
      end
    end
  end
end
