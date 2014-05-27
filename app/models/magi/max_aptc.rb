include Slcsp

module MAGI
	class MaxAPTC < Ruleset
		input "County", "Application", "String"
		input "State", "Application", "String"
		input "Applicant Age", "Calculated in Create Applicant Child List logic", "Number"
		input "Physical Household", "Application", "Household Object"
		input "APTC Max Contribution", "Income Logic", "Integer"
		
		output "Max APTC", "Integer"

		calculated "Family Size" do
      		v("Physical Household").people.length
    	end

		rule "Determine Max APTC value" do
		  o["Max APTC"] = get_premium(v("State"), v("Applicant Age"), v("County"), v("Family Size")) - v("APTC Max Contribution")
		end
	end
end

