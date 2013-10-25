medicaid_eligibility_api
========================


This is a rules engine, API, and web application that determines Medicaid Eligibility based on an applicant’s Modified Adjusted Gross Income (MAGI) and other eligibility criteria, a requirement of the Affordable Care Act which sets the new baseline for eligibility. This project was built in partnership with the State Health Reform Assistance Network (State Network), a Robert Wood Johnson Foundation funded program. It makes determinations without accepting any personally identifiable information.

A hosted version of this tool is available at https://www.medicaideligibilityapi.org/ 

To run the tool, run:
```
bundle install
rails s
browse to http://localhost:3000/
```

You can post determinations JSON to http://localhost:3000/determinations/eval

(c) 2013 BlueLabs. License is available in the LICENSE file
