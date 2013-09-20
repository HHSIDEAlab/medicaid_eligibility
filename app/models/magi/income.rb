# encoding: UTF-8

module MAGI
  class Income < Ruleset
    name        "Determine MAGI Eligibility"
    mandatory   "Mandatory"
    applies_to  "Medicaid and CHIP"
    
    input "Applicant Adult Group Category Indicator", "From MAGI Part I", "Char(1)", %w(Y N)
    input "Applicant Pregnancy Category Indicator", "From MAGI Part I", "Char(1)", %w(Y N)
    input "Applicant Parent Caretaker Category Indicator", "From MAGI Part I", "Char(1)", %w(Y N)
    input "Applicant Child Category Indicator", "From MAGI Part I", "Char(1)", %w(Y N)
    input "Applicant Optional Targeted Low Income Child Indicator", "From MAGI Part I", "Char(1)", %w(Y N X)
    input "Applicant CHIP Targeted Low Income Child Indicator", "From MAGI Part I", "Char(1)", %w(Y N X)
    input "Calculated Income", "Medicaid Household Income Logic", "Integer"
    input "Medicaid Household", "Householding Logic", "Array"

    config "Base FPL", "State Configuration", "Integer"
    config "FPL Per Person", "State Configuration", "Integer"
    config "Option CHIP Pregnancy Category", "State Configuration", "Char(1)", %w(Y N)
    config "Medicaid Percentages", "State Configuration", "Hash"
    config "CHIP Percentages", "State Configuration", "Hash"

    # Outputs
    output    "Category Used to Calculate Medicaid Income", "String"
    indicator "Applicant Income Medicaid Eligible Indicator", %w(Y N)
    date      "Income Medicaid Eligible Determination Date"
    code      "Income Medicaid Eligible Ineligibility Reason", %w(999 A B)
    output    "Category Used to Calculate CHIP Income", "String"
    indicator "Applicant Income CHIP Eligible Indicator", %w(Y N)
    date      "Income CHIP Eligible Determination Date"
    code      "Income CHIP Eligible Ineligibility Reason", %w(999 A B)

    calculated "FPL" do
      c("Base FPL") + (v("Medicaid Household").household_size - 1) * c("FPL Per Person")
    end

    calculated "Max Eligible Medicaid Category" do
      eligible_categories = c("Medicaid Percentages").keys.select{|cat| v("Applicant #{cat} Indicator") == 'Y'}
      if eligible_categories.any?
        eligible_categories.max_by{|cat| c("Medicaid Percentages")[cat]}
      else
        "None"
      end
    end

    calculated "Max Eligible Medicaid Income" do
      if v("Max Eligible Medicaid Category") != "None"
        v("FPL") * (c("Medicaid Percentages")[v("Max Eligible Medicaid Category")] + 5) * 0.01
      else
        0
      end
    end

    calculated "Max Eligible CHIP Category" do
      eligible_categories = c("CHIP Percentages").keys.select{|cat| v("Applicant #{cat} Indicator") == 'Y'}
      if c("Option CHIP Pregnancy Category") != 'Y'
        eligible_categories.delete("Pregnancy Category")
      end
      if eligible_categories.any?
        eligible_categories.max_by{|cat| c("CHIP Percentages")[cat]}
      else
        "None"
      end
    end
    
    calculated "Max Eligible CHIP Income" do
      if v("Max Eligible CHIP Category") != "None"
        v("FPL") * (c("CHIP Percentages")[v("Max Eligible CHIP Category")] + 5) * 0.01
      else
        0
      end
    end

    rule "Set percentage used" do
      o["Percentage for Medicaid Category Used"] = c("Medicaid Percentages")[v("Max Eligible Medicaid Category")]
      o["Percentage for CHIP Category Used"] = c("CHIP Percentages")[v("Max Eligible CHIP Category")]
    end

    rule "Set FPL * percentage" do
      o["FPL"] = v("FPL")
      o["FPL * Percentage Medicaid"] = v("Max Eligible Medicaid Income")
      o["FPL * Percentage CHIP"] = v("Max Eligible Medicaid Income")
      o["Category Used to Calculate Medicaid Income"] = v("Max Eligible Medicaid Category")
      o["Category Used to Calculate CHIP Income"] = v("Max Eligible CHIP Category")
    end

    rule "Determine Income Eligibility" do
      if v("Max Eligible Medicaid Category") == "None"
        o["Applicant Income Medicaid Eligible Indicator"] = "N"
        o["Income Medicaid Eligible Determination Date"] = current_date
        o["Income Medicaid Eligible Ineligibility Reason"] = "Unimplemented"
      elsif v("Calculated Income") > v("Max Eligible Medicaid Income")
        o["Applicant Income Medicaid Eligible Indicator"] = "N"
        o["Income Medicaid Eligible Determination Date"] = current_date
        o["Income Medicaid Eligible Ineligibility Reason"] = "Unimplemented"
      else
        o["Applicant Income Medicaid Eligible Indicator"] = "Y"
        o["Income Medicaid Eligible Determination Date"] = current_date
        o["Income Medicaid Eligible Ineligibility Reason"] = 999
      end

      if v("Max Eligible CHIP Category") == "None"
        o["Applicant Income CHIP Eligible Indicator"] = "N"
        o["Income CHIP Eligible Determination Date"] = current_date
        o["Income CHIP Eligible Ineligibility Reason"] = "Unimplemented"
      elsif v("Calculated Income") > v("Max Eligible CHIP Income")
        o["Applicant Income CHIP Eligible Indicator"] = "N"
        o["Income CHIP Eligible Determination Date"] = current_date
        o["Income CHIP Eligible Ineligibility Reason"] = "Unimplemented"
      else
        o["Applicant Income CHIP Eligible Indicator"] = "Y"
        o["Income CHIP Eligible Determination Date"] = current_date
        o["Income CHIP Eligible Ineligibility Reason"] = 999
      end
    end
  end
end
