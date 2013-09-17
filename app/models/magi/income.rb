# encoding: UTF-8

module MAGI
  class Income < Ruleset
    categories = [
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
    
    input "Applicant Pregnancy Category Indicator", "From MAGI Part I", "Char(1)", %w(Y N)
    input "Applicant Child Category Indicator", "From MAGI Part I", "Char(1)", %w(Y N)
    input "Applicant Adult Group Category Indicator", "From MAGI Part I", "Char(1)", %w(Y N)
    input "Applicant Adult Group XX Category Indicator", "From MAGI Part I", "Char(1)", %w(Y N X)
    input "Applicant Optional Targeted Low Income Child Indicator", "From MAGI Part I", "Char(1)", %w(Y N X)
    input "Applicant CHIP Targeted Low Income Child Indicator", "From MAGI Part I", "Char(1)", %w(Y N X)
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
      c("Base FPL") + v("Medicaid Household").household_size * c("FPL Per Person")
    end

    calculated "Max Eligible Income" do
      eligible_categories = categories.select{|cat| v("Applicant #{cat} Indicator") == 'Y'}
      if eligible_categories.any?
        category = eligible_categories.max_by{|cat| c("Category-Percentage Mapping")[cat]}
        {
          :category => category,
          :income   => v("FPL") * (c("Category-Percentage Mapping")[category] + 0.05)
        }
      else
        {
          :category => nil,
          :income   => nil
        }
      end
    end

    calculated "Applicant Household Income" do
      incomes = v("Medicaid Household").income_people.map{|p| p.income}

      incomes.map{|i| i[:primary_income] + i[:other_income].inject(0){|sum, (name, amt)| sum + amt} - i[:deductions].inject(0){|sum, (name, amt)| sum + amt}}.inject(0){|sum, amt| sum + amt}
    end

    rule "Set calculated income" do
      o["Calculated Income"] = v("Applicant Household Income")
    end

    rule "Set percentage used" do
      o["Percentage for Category Used"] = c("Category-Percentage Mapping")[v("Max Eligible Income")[:category]] * 100
    end

    rule "Set FPL * percentage" do
      o["FPL"] = v("FPL")
      o["FPL * Percentage"] = v("FPL") * (c("Category-Percentage Mapping")[v("Max Eligible Income")[:category]] + 0.05)
    end

    rule "Determine Income Eligibility" do
      if !(v("Max Eligible Income")[:category])
        o["Category Used to Calculate Income"] = "None"
        o["Applicant Income Medicaid Eligible Indicator"] = "N"
        o["Income Medicaid Eligible Determination Date"] = current_date
        o["Income Medicaid Eligible Ineligibility Reason"] = "Unimplemented"
      elsif v("Applicant Household Income") > v("Max Eligible Income")[:income]
        o["Category Used to Calculate Income"] = v("Max Eligible Income")[:category]
        o["Applicant Income Medicaid Eligible Indicator"] = "N"
        o["Income Medicaid Eligible Determination Date"] = current_date
        o["Income Medicaid Eligible Ineligibility Reason"] = "Unimplemented"
      else
        o["Category Used to Calculate Income"] = v("Max Eligible Income")[:category]
        o["Applicant Income Medicaid Eligible Indicator"] = "Y"
        o["Income Medicaid Eligible Determination Date"] = current_date
        o["Income Medicaid Eligible Ineligibility Reason"] = 999
      end
    end
  end
end
