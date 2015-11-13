medicaid_eligibility
========================

This is a rules engine, API, and web application that assesses Medicaid eligibility based on an applicant’s household's Modified Adjusted Gross Income (MAGI) and other eligibility criteria, a requirement of the Affordable Care Act which sets the new baseline for eligibility. This system was implemented in partnership with the HHSEntrepeneurs program, BlueLabs, and the State Health Reform Assistance Network (State Network), a Robert Wood Johnson Foundation funded program. It makes determinations without accepting any personally identifiable information. 

This is provided as a reference implementation and out of the box solution for states and other interested parties to determine an individual's medicaid eligibility. It is not currently used in any federal systems. 

A hosted version of this tool is available at https://www.medicaideligibilityapi.org/ 

To run the tool locally, run:
```
bundle install
rails s
browse to http://localhost:3000/
```

To calculate Medicaid eligibility for a group of applications, post the JSON blob for an application to `/determinations/eval`

You can also evaluate a specific ruleset on specified inputs/configs. POST the JSON to `http://localhost:3000/rulesets/MAGI/{ruleset}/eval` For example:
```
~ $ curl -d '{"config": {"Option Adult Group": "Y"}, "inputs":{"Applicant Age": 25, "Applicant Pregnancy Category Indicator": "N", "Medicare Entitlement Indicator": "N"}}' http://0.0.0:3000/rulesets/MAGI/adult_group/eval --header "Content-Type: application/json" -H 'Accept: application/json'; echo
{"Applicant Adult Group Category Indicator":"Y","Adult Group Category Determination Date":"2014-01-17","Adult Group Category Ineligibility Reason":999}
```

Additional information about how to integrate the project using the API can be found in doc/MitC integration.docx

The test suite is Minitest. To run: 
```
~ $ rake test
```
In the event that this returns a Gem::LoadError or a mysterious error about how `+' is an undefined method, run bundle update first.

This project is licensed with a BSD license, open source with attribution. Details in the LICENSE file.

(c) 2013 BlueLabs.
