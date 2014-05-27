module MAGI
  class PreliminaryAPTC < Ruleset
    input "Tax Returns", "Application", "List"
    input "Applicant", "Application", "Person"
    
    input "Applicant Refugee Medical Assistance Indicator", "Char(1)", %w(Y N)
    input "Applicant CHIP Indicator", "Char(1)", %w(Y N)
    input "Applicant Medicaid Indicator","Char(1)", %w(Y N)
    input "Other MEC Offer", "Application", %w(Y N) #Indicates that the applicant has COBRA, TRICARE, or ESC
    input "Medicare Entitlement Indicator", "Application", "Char(1)", %w(Y N)
    input "Person ID", "Application", "Integer"
    input "Previous APTC", "Application", %w(Y N) #Indicates that the applicant recieved aptc last yea
    input "Repaid APTC", "Application", %w(Y N)   #Indicates that the filers repaid any extra APTC from previous year

    output "Other MEC Offer Indicator", "Char(1)", %w(Y N)
    output "Joint Filing for Married Indicator", "Char(1)", %w(Y N X)
    output "Previous Year Compliance Indicator", "Char(1)", %w(Y N)
    output "Applicant Non-Filer Indicator", "Char(1)", %w(Y N)

    rule 'Applicant does not have another offer of MEC' do
      if v("Applicant Refugee Medical Assistance Indicator") == 'Y' || v("Applicant CHIP Indicator") == 'Y' || v("Applicant Medicaid Indicator") == 'Y' || v("Medicare Entitlement Indicator") == "Y" || v("Other MEC Offer") == "Y"
        o['Other MEC Offer Indicator'] = 'Y'
      else
        o['Other MEC Offer Indicator'] = 'N'
      end
    end

    rule 'Applicant is a tax filer and is not married filing separately' do
      tax_return = v("Tax Returns").find{|tr| tr.filers.any?{|filer| filer == v("Applicant")}}
      
      if tax_return
        o['Applicant Non-Filer Indicator'] = 'N'
        spouse = v("Applicant").get_relationship(:spouse)
        
        if spouse
          if tax_return.filers.count == 2 && tax_return.filers.include?(spouse)
            o["Joint Filing for Married Indicator"] = 'Y'
          else  
            o["Joint Filing for Married Indicator"] = 'N'
          end
        else
          o["Joint Filing for Married Indicator"] = 'X'
        end
      else
        o['Applicant Non-Filer Indicator'] = 'Y'
        o["Joint Filing for Married Indicator"] = 'X'
      end
    end

    rule 'Tax Filers complied with filing requirements from last year' do
      if (v("Previous APTC") == "Y" && v("Repaid APTC") == "Y") || v("Previous APTC") == "N"
        o["Previous Year Compliance Indicator"] = 'Y'
      else
        o["Previous Year Compliance Indicator"] = 'N'
      end
    end
  end
end