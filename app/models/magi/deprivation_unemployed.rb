# encoding: UTF-8

module MAGI
  class DeprivationUnemployed < Ruleset
    # name        "Dependent Deprived of Parental Support – Unemployed"
    # mandatory   "Optional"
    # references  "§435.110, §435.4"
    # applies_to  "Medicaid Only"
    # purpose     "Determine if dependent child who lives with both parents is deprived of parental support due to one or both parents working less than the state standard for unemployment."
    # description "To be considered a dependent child as defined in 42 CFR 435.4, the child must be “deprived of parental support” by reason of the death, absence from the home, physical or mental incapacity, or unemployment of at least one parent, unless the state has opted to eliminate this requirement, which often is referred to as the “deprivation requirement.” A parent is considered to be unemployed if he or she is working less than 100 hours per month, or a higher number of hours set by the state.\nAll but the unemployed requirement were evaluated in the Dependent Deprived of Parental Support logic in MAGI Part 1."
    
    # assumption "This rule applies to applicants flagged in MAGI Part 1 with Applicant Parent Caretaker Category Indicator of T (temporary) because the child lives with both parents and the rule to determine if one or more parent is unemployed could not be run until the number of hours each parent works is obtained."
    # assumption "If a child is living with no or only one parent, the child is considered deprived due to absence or death of a parent."
    # assumption "For children living with both parents, the rule calculates the number of hours each parent is employed per month in one of two ways as described below.\n  - When the parent reports income that is paid hourly for a job, the application will ask how many hours per week the parent works.  If all of the jobs are paid hourly, the logic sums the hours per week and multiplies the hours worked per week by 4.33 to arrive at the number of hours the parent works per month.\n  - When one or more of the parent’s jobs are not paid hourly, the application will ask for the number of hours worked per week for all jobs and multiply the number of hours by 4.33 to arrive at the number of hours the parent works per month."
      
    # input "Qualified Children list", "Parent Caretaker Rule", "List", "Child ids"
    # input "Count Parents Living With", "From Medicaid Household Composition logic", "Integer" 
    # input "Child Lives With Both Parents", "Application", "Char(1)"  
    # input "Applicant Parent Caretaker Category Indicator", "Parent Caretaker Rule", "Char(1)", %w(Y N T)
    # input "Hours Worked Per Week All Jobs", "Application – Medicaid Specific Section", "Integer" 
    # input "Hours Worked Per Week", "Application – Current Income Section", "Integer" 
    # input "Applicable Medicaid Standard Basis", "Medicaid Part 1 logic", "Char(2)", %w(01 02 03 04 05 06)

    # config "State Unemployed Standard", "State Configuration", "Integer", (1..100), 100

    # #calculated "Sum Hours Worked Per Week" do

    # #  Integer Sum of all Hours Worked Per Week for the applicant
    # Hours Worked Per Month(Parent X)  Integer If Hours Worked Per Week All Jobs = Null,
    # Then Hours Worked Per Month(Parent X) = Sum Hours Worked Per Week(Parent X) * 4.3 
    # Else Hours Worked Per Month(Parent X) = Hours Worked Per Week All Jobs(Parent X) * 4.3

    # Outputs 
    # Name  Type  Possible Values
    # Applicant Parent Caretaker Category Indicator Char(1) Y: Yes
    # N: No
    # T: Temporary
    # Parent Caretaker Category Determination Date  Date  
    # Parent Caretaker Category Ineligibility Reason  Numeric 999:  N/A  (Rule Indicator = Y)
    # 148: No deprived child is associated with the caretaker
    # Child of Caretaker Deprived Child Indicator Char(1) Y: Yes
    # N: No
    # T: Temporary
    # Child of Caretaker Deprived Child Determination Date  Date  
    # Child of Caretaker Deprived Child Ineligibility Reason  Char(3) 999:  N/A (Rule Indicator = Y)
    # 129: both parents are employed
    # Re-determine Applicable Standard  Char(1) Y: Yes
    # N:No
    # Applicant Parent Caretaker Medicaid Standard  Number  
    # Applicable Medicaid Standard Basis  Char(2) 01: Pregnant Category
    # 02: Child Category
    # 03: Parent/Caretaker Relative Category
    # 04: Adult Category
    # 05: Optional, Targeted, Low-income Children Category
    # 06: Adult Group XX Category

    # Business Rule Logic: Determine if Child Meets Deprivation Requirement
    # 1.  Do not run the rule When Applicant Parent Caretaker Category Indicator <> T 
    # Skip rest of parent caretaker rules
    # 2.  Child lives with less than 2 parents
    #   When (Count Parents Living With <= 1 or Child Lives With Both Parents = N)
    # Then Child of Caretaker Deprived Child Indicator= Y and Child of Caretaker Deprived Child Determination Date = current date and Child of Caretaker Deprived Child Ineligibility Reason Code = 999
    # Get next record from Qualified Children list
    # 3.  Child lives with both parents, but neither meets state unemployed standard  When Hours Worked Per Month (Parent 1) >= State Unemployed Standard and Hours Worked Per Month (Parent 2) >= State Unemployed Standard
    # Then Child of Caretaker Deprived Child Indicator= N and Child of Caretaker Deprived Child Determination Date = current date and Child of Caretaker Deprived Child Ineligibility Reason Code = 129
    # Remove record from Qualified Children list and get next record from Qualified Children list
    # 4.  Child lives with both parents, and at least one meets state unemployed standard When Hours Worked Per Month (Parent 1) < State Unemployed Standard or Hours Worked Per Month (Parent 2) < State Unemployed Standard
    # Then Child of Caretaker Deprived Child Indicator= Y and Child of Caretaker Deprived Child Determination Date = current date and Child of Caretaker Deprived Child Ineligibility Reason Code = 999
    # Get next record from Qualified Children list


    # Business Rule Logic: Set Parent or Caretaker Category
    # 1.  Child of Caretaker meets requirements When Qualified Children list is not empty
    # Then Applicant Parent Caretaker Category Indicator = Y and Parent Caretaker Category Determination Date = current date and Parent Caretaker Category Ineligibility Reason = 999 and Redetermine Applicable Standard = N 
    # 2.  No child of Caretaker meets requirements – rerun income eligibility When Qualified Children list  is empty and Child of Caretaker Deprived Child Indicator = N and Applicable Medicaid Standard Basis = 03
    # Then Applicant Parent Caretaker Category Indicator = N and Parent Caretaker Category Determination Date = current date and Parent Caretaker Category Ineligibility Reason = 148 and Redetermine Applicable Standard = Y and Applicant Parent Caretaker Medicaid Standard = 0 and Applicable Medicaid Standard Basis = null
    # 3.  No child of Caretaker meets parent unemployment requirement – no need to rerun income eligibility When Qualified Children list  is empty and Child of Caretaker Deprived Child Indicator = N and Applicable Medicaid Standard Basis <> 03
    # Then Applicant Parent Caretaker Category Indicator = N and Parent Caretaker Category Determination Date = current date and Parent Caretaker Category Ineligibility Reason = 148 and Redetermine Applicable Standard = N and Applicant Parent Caretaker Medicaid Standard = 0 

    # Constraints/ Special Instructions
    # 1.  In MAGI Part 1, when the child lives with both parents, the deprivation requirement cannot be confirmed at this time because we do not have the number of hours worked to determine whether one or both parents meet the states unemployed standard.  In MAGI Part 3 the unemployment deprivation requirement is run to arrive at a final indicator for the parent/caretaker relative category.   
    # 2.  When the indicator is changed from T to N and the Applicable MAGI Standard Basis was the Parent/Caretaker Relative Category, the applicable MAGI standard logic needs to be re-run to get a new Applicable MAGI Standard and the income eligibility logic needs to be rerun to re-determine income eligibility.
  end
end
