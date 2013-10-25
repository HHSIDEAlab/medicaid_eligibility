medicaid_eligibility_api
========================


This is a tool that determines Medicaid Eligibility based on an applicant’s Modified Adjusted Gross Income (MAGI), a requirement of the Affordable Care Act which sets the new baseline for eligibility. This project was built in partnership with the State Health Reform Assistance Network (State Network), a Robert Wood Johnson Foundation funded program to build an open source MAGI rules engine, API, and user interface that States and others can use to facilitate MAGI eligibility determination.

To run the tool, run:
```
bundle install
rails s
browse to http://localhost:3000/
```

You can post determinations JSON to http://localhost:3000/determinations/eval

