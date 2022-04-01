#!/bin/bash

curl -d '{"config": {"Option Adult Group": "Y"}, "inputs":{"Applicant Age": 25, "Applicant Pregnancy Category Indicator": "N", "Medicare Entitlement Indicator": "N", "Applicant Dependent Child Covered Indicator": "Y"}}' http://0.0.0:3000/rulesets/MAGI/adult_group/eval --header "Content-Type: application/json" -H 'Accept: application/json'
echo