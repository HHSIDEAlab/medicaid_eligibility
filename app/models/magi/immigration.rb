# encoding: UTF-8

module MAGI
  class Immigration < Ruleset
    name        "Determine MAGI Eligibility"
    mandatory   "Mandatory"
    applies_to  "Medicaid and CHIP"
    
    input "US Citizen Indicator", "Application", "Char(1)", %w(Y N)


    
    config "Base FPL", "State Configuration", "Integer"
    
    # Outputs
    determination "Medicaid Citizen Or Immigrant Status", %w(Y N), %w(999 141 142)


    rule "Determine citizen or immigrant status" do
      
    end
  end
end
