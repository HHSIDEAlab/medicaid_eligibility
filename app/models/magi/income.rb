# encoding: UTF-8

module MAGI
  class Income < Ruleset
    categories = [
      "Parent Caretaker Category",
      "Pregnancy Category",
      "Child Category",
      "Adult Group Category",
      "Adult Group XX Category",
      "Optional Targeted Low Income Child",
      "CHIP Targeted Low Income Child"
    ]

    name        "Determine MAGI Eligibility"
    mandatory   "Mandatory"
    applies_to  "Medicaid and CHIP"
    
    input "Applicant Parent Caretaker Category Indicator", "From MAGI Part I", "Char(1)", %w(Y N)
    input "Applicant Pregnancy Category Indicator", "From MAGI Part I", "Char(1)", %w(Y N)
    input "Applicant Child Category Indicator", "From MAGI Part I", "Char(1)", %w(Y N)
    input "Applicant Adult Group Category Indicator", "From MAGI Part I", "Char(1)", %w(Y N)
    input "Applicant Adult Group XX Category Indicator", "From MAGI Part I", "Char(1)", %w(Y N X)
    input "Applicant Optional Targeted Low Income Child Indicator", "From MAGI Part I", "Char(1)", %w(Y N X)
    input "Applicant CHIP Targeted Low Income Child Indicator", "From MAGI Part I", "Char(1)", %w(Y N X)
    input "Calculated Income", "Medicaid Household Income Logic", "Integer"
    input "Medicaid Household", "Householding Logic", "Array"

    config "Category-Percentage Mapping", "State Configuration", "Hash" 
    config "Base FPL", "State Configuration", "Integer"
    config "FPL Per Person", "State Configuration", "Integer"

    # Outputs
    output    "Category Used to Calculate Income", "String", categories
    indicator "Applicant Income Medicaid Eligible Indicator", %w(Y N)
    date      "Income Medicaid Eligible Determination Date"
    code      "Income Medicaid Eligible Ineligibility Reason", %w(999 A B)

    calculated "FPL" do
      c("Base FPL") + (v("Medicaid Household").household_size - 1) * c("FPL Per Person")
    end

    calculated "Max Eligible Category" do
      eligible_categories = categories.select{|cat| v("Applicant #{cat} Indicator") == 'Y'}
      if eligible_categories.any?
        eligible_categories.max_by{|cat| c("Category-Percentage Mapping")[cat]}
      else
        "None"
      end
    end

    calculated "Max Eligible Income" do
      if v("Max Eligible Category") != "None"
        v("FPL") * (c("Category-Percentage Mapping")[v("Max Eligible Category")] + 5) * 0.01
      else
        0
      end
    end

    rule "Set percentage used" do
      o["Percentage for Category Used"] = c("Category-Percentage Mapping")[v("Max Eligible Category")]
    end

    rule "Set FPL * percentage" do
      o["FPL"] = v("FPL")
      o["FPL * Percentage"] = v("Max Eligible Income")
      o["Category Used to Calculate Income"] = v("Max Eligible Category")
    end

    rule "Determine Income Eligibility" do
      if v("Max Eligible Category") == "None"
        o["Applicant Income Medicaid Eligible Indicator"] = "N"
        o["Income Medicaid Eligible Determination Date"] = current_date
        o["Income Medicaid Eligible Ineligibility Reason"] = "Unimplemented"
      elsif v("Calculated Income") > v("Max Eligible Income")
        o["Applicant Income Medicaid Eligible Indicator"] = "N"
        o["Income Medicaid Eligible Determination Date"] = current_date
        o["Income Medicaid Eligible Ineligibility Reason"] = "Unimplemented"
      else
        o["Applicant Income Medicaid Eligible Indicator"] = "Y"
        o["Income Medicaid Eligible Determination Date"] = current_date
        o["Income Medicaid Eligible Ineligibility Reason"] = 999
      end
    end
  end
end
