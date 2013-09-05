var MAGI = {};

(function (ns) {

  var people = {};

  var DataMapper = function (nameMangler) {
    this.map = function (data, fields, context, params) {
      var value;
      _.each(fields, function (element, index, list) {
        value = data[nameMangler.call(this, element.name, params)]
        if (value) {
          context[element.json] = value;
        }
      }, context);
    }
  };


  applicantScopedDataMapper = new DataMapper(function (name, params) {
    return "applicant_" + params.applicant_num + "_" + name;
  })


  plainDataMapper = new DataMapper(function () {
  });


  var mapFieldsForApplicant = function (applicant_num, data, fields, context) {
    var value;
    _.each(fields, function (element, index, list) {
      value = data[_.template(element.name)({id: applicant_num})]
      if (value) {
        context[element.json] = value;
      }
    }, context);
  }

  var mapFields = function (data, fields, context) {
    _.each(fields, function (element, index, list) {
      if (data[element.name]) {
        context[element.json] = data[element.name];
      }
    }, context);
  };

  var person_fields = [
    {name: 'foo', json: 'Applicant Age', required: true},
    {name: 'bar', json: 'Applicant Attest Disabled'},
    {name: 'baz', json: 'Applicant Attest Long Term Care'},
    {name: '', json: 'Applicant Has 40 Title II Work Quarters'},
    {name: '', json: 'Has Insurance'},
    {name: '', json: 'Hours Worked Per Week'},
    {name: '', json: 'Incarceration Status'},
    {name: '', json: 'Medicare Entitlement Indicator'},
    {name: '', json: 'Medicaid Residency Indicator', required: true},
    {name: '', json: 'Prior Insurance'},
    {name: '', json: 'Prior Insurance End Date'},
    {name: '', json: 'Required to File Taxes', required: true},
    {name: '', json: 'State Health Benefits Through Public Employee'},
    {name: '', json: 'Student Indicator'},
    {name: '', json: 'Applicant Pregnant Indicator'},
    {name: '', json: 'Applicant Post Partum Period Indicator'},
    {name: '', json: 'Former Foster Care'},
    {name: '', json: 'Age Left Foster Care'},
    {name: '', json: 'Foster Care State'},
    {name: '', json: 'Had Medicaid During Foster Care'},
    {name: '', json: 'US Citizen Indicator', required: true},
    {name: '', json: 'Five Year Bar Applies'},
    {name: '', json: 'Five Year Bar Met'},
    {name: '', json: 'Immigrant Status'},
    {name: '', json: 'Lawful Presence Attested'},
    {name: '', json: 'Non-Citizen Deport Withheld Date'},
    {name: '', json: 'Non-Citizen Entry Date'},
    {name: '', json: 'Non-Citizen Status Grant Date'},
    {name: '', json: 'Qualified Non-Citizen Status'},
    {name: '', json: 'Refugee Medical Assistance Start Date'},
    {name: '', json: 'Refugee Status'},
    {name: '', json: 'Seven Year Limit Applies'},
    {name: '', json: 'Seven Year Limit Start Date'},
    {name: '', json: 'Veteran Status'},
    {name: '', json: 'Victim of Trafficking'},
    {name: '', json: 'Attest Primary Responsibility'}
  ];


  var agi_income_fields = [
    {name: 'AGI', json: 'AGI'},
    {name: '', json: 'Deductible Part of Self-Employment Tax'},
    {name: '', json: 'IRA Deduction'},
    {name: '', json: 'Student Loan Interest Deduction'},
    {name: '', json: 'Tuition and Fees'},
    {name: '', json: 'Tax-Exempt Interest'},
    {name: '', json: 'Other MAGI-Eligible Income'}
  ]

  var magi_income_fields = [
    {name: '', json: 'AGI'}
  ]

  var payroll_income_fields = [
    {name: 'wages', json: 'Wages, Salaries, Tips'},
    {name: '', json: 'Taxable Interest'},
    {name: '', json: 'Tax-Exempt Interest'},
    {name: '', json: 'Taxable Refunds, Credits, or Offsets of State and Local Income Taxes'},
    {name: '', json: 'Alimony'},
    {name: '', json: 'Capital Gain or Loss'},
    {name: '', json: 'Pensions and Annuities Taxable Amount'},
    {name: '', json: 'Farm Income or Loss'},
    {name: '', json: 'Unemployment Compensation'},
    {name: '', json: 'Other Income'},
    {name: '', json: 'MAGI Deductions'}
  ];

  var relationship_field = {
    name: 'applicant_{{ id }}_relationship_to_{{ other }}', json: 'RelationshipCode'
  }

  var Person = function (data, applicant_num) {
    var Income, Relationship, relationships;

    Income = function () {
      // TODO In the future which fields to use will be conditional on reporting methd
      applicantScopedDataMapper.map(data, payroll_income_fields, this, {applicant_num: applicant_num})
    }

    Relationship = function (other_num) {
      this["Other ID"] = people[other_num]["Person ID"];
      this["Relationship Code"] = data["applicant_" + applicant_num + "_relationship_to_" + other_num];
    };

    relationships = function () {
      _.times(applicant_num - 1, function(n) {
        return new Relationship(n);
      }
    }

    applicantScopedDataMapper.map(data, person_fields, this, {applicant_num: applicant_num})
    people[applicant_num] = this;
    this.Income = new Income();
    this.Relationships = relationships();
  }

  var People = function(data) {
    
  }

  ns.Person = Person;
}(MAGI));