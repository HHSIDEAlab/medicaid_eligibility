module MAGI
  class CSRCategory < Ruleset
    input "Native American or Alaskan Native", "Application", %w(Y N)
    input "Calculated Income", "Medicaid Household Income Logic", "Integer"
    input "Applicant CSR Indicator","CSR Eligibility Logic","Char(1)", %w(Y N)
    input "Medicaid Household", "Householding Logic", "Array"
    
    config "Base FPL", "State Configuration", "Integer"
    config "FPL Per Person", "State Configuration", "Integer"

	output "CSR Category", "Integer"

    calculated "FPL" do
      c("Base FPL") + (v("Medicaid Household").household_size - 1) * c("FPL Per Person")
    end


    	rule "Determine CSR Category" do
    		if v("Applicant CSR Indicator")
    			if v("Native American or Alaskan Native") == "N"
    				if ((v("Calculated Income")/v("FPL")) >= 1 && (v("Calculated Income")/v("FPL")) <= 1.5)
    					o["CSR Category"] = 06
    				elsif ((v("Calculated Income")/v("FPL")) > 1.5 && (v("Calculated Income")/v("FPL")) <= 2)
    					o["CSR Category"] = 05
    				elsif ((v("Calculated Income")/v("FPL")) > 2 && (v("Calculated Income")/v("FPL")) <= 2.5)
    					o["CSR Category"] = 04
    				else
    					o["CSR Category"] = "None"
    				end
    			else
    				if (v("Calculated Income")/v("FPL")) <= 3
    					o["CSR Category"] = 02
    				else
    					o["CSR Category"] = 03
    				end
    			end
    		else
    			o["CSR Category"] = 00
    		end
    	end
	end

end