var MAGI = {};

(function (ns) {

  var application_fields = [
    {name: 'state', json: 'State'}
  ]

  var person_fields = [
    {name: 'id', json: "Person ID"},
    {name: 'age', json: 'Applicant Age'},
    {name: 'disabled', json: 'Applicant Attest Disabled'},
    {name: 'long_term_care', json: 'Applicant Attest Long Term Care'},
    {name: 'citizen_forty_quarters', json: 'Applicant Has 40 Title II Work Quarters'},
    {name: 'has_insurance', json: 'Has Insurance'},
    {name: 'hours', json: 'Hours Worked Per Week'},
    {name: 'incarcerated', json: 'Incarceration Status'},
    {name: 'eligible', json: 'Medicare Entitlement Indicator'},
    {name: 'state_residency', json: 'Medicaid Residency Indicator'},
    {name: 'prior_insurance', json: 'Prior Insurance'},
    {name: 'prior_insurance_end_date', json: 'Prior Insurance End Date'},
    {name: 'income_taxes_required', json: 'Required to File Taxes'},
    {name: 'state_employee_health_benefits', json: 'State Health Benefits Through Public Employee'},
    {name: 'student', json: 'Student Indicator'},
    {name: 'pregnant', json: 'Applicant Pregnant Indicator'},
    {name: 'pregnant_three_months', json: 'Applicant Post Partum Period Indicator'},
    {name: 'foster_care', json: 'Former Foster Care'},
    {name: 'foster_care_age_left', json: 'Age Left Foster Care'},
    {name: 'foster_care_state', json: 'Foster Care State'},
    {name: 'foster_care_had_medicaid', json: 'Had Medicaid During Foster Care'},
    {name: 'citizen', json: 'US Citizen Indicator', required: true},
    {name: 'citizen_five_year_bar', json: 'Five Year Bar Applies'},
    {name: 'citizen_five_year_bar_ment', json: 'Five Year Bar Met'},
    {name: 'citizen_immigrant_status', json: 'Immigrant Status'},
    {name: 'citizen_lawful', json: 'Lawful Presence Attested'},
    {name: 'citizen_human_trafficking_deport_withheld_date', json: 'Non-Citizen Deport Withheld Date'},
    {name: 'citizen_human_trafficking_entry_date', json: 'Non-Citizen Entry Date'},
    {name: 'citizen_human_trafficking_status_grant_date', json: 'Non-Citizen Status Grant Date'},
    {name: 'citizen_human_trafficking_non_citizen', json: 'Qualified Non-Citizen Status'},
    {name: 'citizen_refugee_assistance_start_date', json: 'Refugee Medical Assistance Start Date'},
    {name: 'citizen_refugee_assistance', json: 'Refugee Status'},
    {name: 'xxx', json: 'Seven Year Limit Applies'},
    {name: 'xxx', json: 'Seven Year Limit Start Date'},
    {name: 'xxx', json: 'Veteran Status'},
    {name: 'citizen_human_trafficking', json: 'Victim of Trafficking'},
    {name: 'xxx', json: 'Attest Primary Responsibility'}
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
    {name: 'income_taxes_required_wages',               json: 'Wages, Salaries, Tips'},
    {name: 'income_taxes_required_taxable_interest',    json: 'Taxable Interest'},
    {name: 'income_taxes_required_tax_exempt_interest', json: 'Tax-Exempt Interest'},
    {name: 'income_taxes_required_taxable_refunds',     json: 'Taxable Refunds, Credits, or Offsets of State and Local Income Taxes'},
    {name: 'income_taxes_required_alimony',             json: 'Alimony'},
    {name: 'income_taxes_required_capital_gain',        json: 'Capital Gain or Loss'},
    {name: 'ncome_taxes_required_pensions',             json: 'Pensions and Annuities Taxable Amount'},
    {name: 'income_taxes_required_farm_income',         json: 'Farm Income or Loss'},
    {name: 'income_taxes_required_unemployment',        json: 'Unemployment Compensation'},
    {name: 'income_taxes_required_other',               json: 'Other Income'},
    {name: 'income_taxes_required_deduction',           json: 'MAGI Deductions'}
  ];

  var isVisible = function($element) {
    return $element.is(":visible")
  };

  var isCheckbox = function($element) {
    return $element.is("input[type='checkbox']");
  }

  var DataMapper = function (nameMangler) {
    this.map = function (data, fields, context, params) {
      var value, name, $el;
      _.each(fields, function (element, index, list) {
        name = nameMangler.call(this, element.name, params);
        value = data[name];
        $el = $("input[name='"+ name + "']")
        if (value) {
          if (isCheckbox($el)) {
            context[element.json] = value == 'on' ? 'Y' : 'N'
          } else {
            context[element.json] = value;
          }
        } else if (isCheckbox($el) && isVisible($el)) {
          context[element.json] = 'N';
        }
      }, context);
    }
  };

  applicantScopedDataMapper = new DataMapper(function (name, params) {
    return "applicant_" + params.applicant_num + "_" + name;
  })

  plainDataMapper = new DataMapper(function (name) {
    return name;
  });

  var Application = function (data, num_applicants) {
    var People, Person, Household, TaxReturn, person_map = {};

    TaxReturn = function() {
      function createDependents() {
        var value;
        // this 20 is a hack
        var list = _.times(20, function(n) {
          value = data['dependent_' + (n+1)];
          if (value) {
            return {"Person ID": value}
          }
        });
        return _.filter(list, function(value) {
          return value != undefined;
        });
      }
      // dry this up
      function createFilers() {
        var value;
        var list = _.times(2, function(n) {
          value = data['filer_' + (n+1)];
          if (value) {
            return {"Person ID": value}
          }
        });
        return _.filter(list, function(value) {
          return value != undefined;
        });
      }

      this.Filers = createFilers();
      this.Dependents = createDependents();
    };

    Household = function() {
      this["Household ID"] = "Household1";
      this["People"] = _.map(person_map, function(value) {
        return {"Person ID" : value["Person ID"]};
      });
    }

    Person = function (applicant_num) {
      var Income, Relationship, relationships;

      Income = function () {
        // TODO In the future which fields to use will be conditional on reporting method
        // read the income fields from the data into the Income object
        applicantScopedDataMapper.map(data, payroll_income_fields, this, {applicant_num: applicant_num});
      }

      Relationship = function (other_num) {
        this["Other ID"] = person_map[other_num]["Person ID"];
        this["Relationship Code"] = data["applicant_" + applicant_num + "_relationship_to_" + other_num];
      };

      createRelationships = function () {
        // create a relationsip with each previous applicant
        return _.times(applicant_num - 1, function (n) {
          return new Relationship(n + 1);
        });
      }

      // read the person fields into the application
      applicantScopedDataMapper.map(data, person_fields, this, {applicant_num: applicant_num})

      this.Income = new Income();
      this.Relationships = createRelationships();

    }

    createPeople = function () {
      _.times(num_applicants, function (n) {
        person_map[n + 1] = new Person(n + 1);
      }, this)
    }

    plainDataMapper.map(data, application_fields, this);
    createPeople();
    this.People = _.map(person_map, function(value) {
      return value;
    });

    this["Physical Households"] = [new Household()];
    this["Tax Returns"] = [new TaxReturn()];
  }

  var Endpoint = function(path) {
    var that = this;
    this.path = path

    this.submit = function(application, complete) {
      $.ajax(path, {
        data: JSON.stringify(application),
        type: 'POST',
        dataType: 'json',
      }).done(function(data) {
        complete.call(that, data);
        that.response = data;
      }).fail(function(data) {
        complete.call(that, "ERROR");
        console.log("ajax error " + status + " : " + data);
      });
    }
  }

  ns.Application = Application;
  ns.Endpoint = Endpoint;

}(MAGI));

