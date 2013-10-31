medicaid_eligibility
========================


This is a rules engine, API, and web application that assesses Medicaid Eligibility based on an applicant’s household's Modified Adjusted Gross Income (MAGI) and other eligibility criteria, a requirement of the Affordable Care Act which sets the new baseline for eligibility. This system was implemented in partnership with the HHSEntrepeneurs program, BlueLabs, and the State Health Reform Assistance Network (State Network), a Robert Wood Johnson Foundation funded program. It makes determinations without accepting any personally identifiable information. 

This is provided as a reference implementation and out of the box solution for states and other interested parties to determine an individual's medicaid eligibility. It is not currently used in any federal systems. 

A hosted version of this tool is available at https://www.medicaideligibilityapi.org/ 

To deploy the tool, run:
```
bundle install
rails s
browse to http://localhost:3000/
```

You can post determinations JSON to http://localhost:3000/determinations/eval

This project is licensed with a BSD license, open source with attribution. Details in the LICENSE file.

(c) 2013 BlueLabs.
