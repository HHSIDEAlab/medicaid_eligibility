medicaid_eligibility_api
========================

Notes from the documentation on reading rule descriptions:

```
  Each of the sections within this document contains the following components:
  
  1. Rule Set ID
  2. Mandatory/Optional: this status indicates whether implementation of the policy defined by the rule set is mandatory or a state option 
  3. References: this is the citation of where the option is described in regulation
  4. Applies To:  indicates to which program the rule applies: Medicaid, CHIP or Both
  5. Purpose:  a brief statement of the rule purpose 
  6. Description:  a more detailed description of the rule 
  7. Assumptions: assumptions made in the design of the rule
  8. Inputs: a list of input variables, including the source of the variable (application, external data source, or derived), the field type, and possible values
  9. Configurable Parameters: these are the configuration parameters, system and state-configurable options are included in this section  
  10. Calculated Data Elements: data elements that  are derived in system logic
  11. Output Variables: data elements to capture the output/results of the rule
  12. Business Rule Logic:  a plain-English statement of the business rules, data elements are underlined and comparison values are bold
  13. Constraints/Special Instructions: directions to developers
```

## Output specifications

Each rule set results in a determination. The output for the function for a rule set contains the following:
- Result indicator code giving a yes or no for this particular rule for the input person. Possible codes are:
  - "Y" => Yes
  - "N" => No
  - "X" => "N/A, Rule does not apply"
  - "T" => "Temporary" (Based on this particular rule set, could be yes or no, but cannot be fully determined until a later step)
  - a few others
- Determination date
- Ineligibility reason code, explaining the reason for ineligibility if the determination for the rule set is No. I believe in most cases the code that should be given is provided in the documentation for the rule set. There are also a couple standard reasons that can be given by multiple rule sets:
  - 555 => "N/A, Rule does not apply"
  - 999 => "N/A, Indicator is yes"
- Inconsistency reason. I'm not sure what this is for yet; need to finish reading through the documentation.

## List of determinations the API needs to make
We can put this somewhere else, just thought I'd store this here right now.

### MAGI – Part 1: Rules Related to Defining Medicaid & CHIP Categories
1. Identify Medicaid Category – Parent or Caretaker Relative
2. Identify Medicaid or CHIP Category – Pregnant Women
3. Identify Medicaid or CHIP Category - Child
4. Identify Medicaid Category – Adult Group
5. Optional Targeted Low-Income Children
6. CHIP Targeted Low-Income Children
7. Determine Non-MAGI Referral Type

### MAGI – Part 2: Medicaid and CHIP Citizenship and Immigration Eligibility
1. Citizenship Verified
2. Save Verified Immigration Status
3. Children & Pregnant Women Who are Lawfully Present Non-Citizens and Not Subject to Five-Year Bar (CHIPRA214)
4. Victims of Trafficking
5. Seven-Year Limit
6. Five-Year Bar
7. 40 Title II Work Quarters
8. Immigration Status
9. Determine Preliminary Medicaid Eligibility
10. Determine Preliminary CHIP Eligibility
11. Former Foster Care Children

### MAGI – Part 3: Medicaid and CHIP Eligibility
1. Dependent Deprived of Parental Support – Unemployed
2. Optional, Targeted Low-Income Children- Other Coverage
3. CHIP Targeted Low-Income Children- Other Coverage
4. 40 Title II Work Quarters – Continued from MAGI Part 2
5. Determine Preliminary Medicaid & CHIP Eligibility
6. Optional CHIP Category - Unborn Child Category
7. State Health Benefits through Public Employees
8. CHIP Waiting Period
9. Deny CHIP for Children who are Incarcerated
10. Determine CHIP Eligibility
11. Determine Medicaid Eligibility - Dependent Child Covered
12. Determine Medicaid Eligibility
13. Determine Emergency Medicaid Eligibility and Eligibility for Former Foster Care
14. Identify Medicaid Category – Refugee Medical Assistance

# Demo

For manual evaluation and access to documentation, rulesets are mapped onto URLs of the form:

    http://localhost:3000/rulesets/path/to/class/file

where `path/to/class/file` is the path to the Ruby class file in `app/models`. Thus,
`Medicaidchip::Eligibility::Category::Child` is at

    http://localhost:3000/rulesets/medicaidchip/eligibility/category/child

To evaluate a specific ruleset on specific input / configs, POST the JSON to the above URL plus `/eval`. For example:

    ~ $ curl -d '{"config": {"Option Young Adults": "N", "Child Age Threshold": 18}, "inputs":{"Person Birth Date": "2013-12-02"}}' http://localhost:3000/rulesets/medicaidchip/eligibility/category/child/eval --header "Content-Type: application/json" -H 'Accept: application/json'; echo
    {"Applicant Child Category Indicator":"Y","Child Category Determination Date":"2013-07-05","Child Category Ineligibility Reason":999}
