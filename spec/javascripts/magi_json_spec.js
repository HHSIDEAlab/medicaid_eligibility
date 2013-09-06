describe("MAGI.Application", function() {

  var header, firstApplicant, secondApplicant, thirdApplicant;

  beforeEach(function() {
    header = {'state': 'CA', 'id': '12345'}
    firstApplicant = {
      'applicant_1_id': 'ABCD',
      'applicant_1_wages': 10
    }
    secondApplicant = {
      'applicant_2_id': 'EFGH',
      'applicant_2_wages': 20,
      'applicant_2_relationship_to_1': 4
    }
    thirdApplicant = {
      'applicant_3_id': 'IJKL',
      'applicant_3_wages': 30,
      'applicant_3_relationship_to_1': 3,
      'applicant_3_relationship_to_2': 15
    }
  });

  it("creates the correct application header fields", function() {
    var testData = _.extend({}, header, firstApplicant);
    var application = new MAGI.Application(testData, 1);
    expect(application.State).toBe('CA')
  });

  it("creates a person from the appropriate fields", function() {
    var testData = _.extend({}, header, firstApplicant);
    var application = new MAGI.Application(testData, 1);
    expect(application.People).not.toBe(null);
    expect(application.People.length).toBe(1);
  });

  it("creates an income for the person from the appropriate fields"), function() {
    var testData = _.extend({}, header, firstApplicant);
    var application = new MAGI.Application(testData, 1);
    expect(application.People[0].Income['Wages, Salaries, Tips']).toBe(10)
  };

  it("creates two people from two sets of fields"), function() {
    var testData = _.extend({}, header, firstApplicant, secondApplicant)
    var application = new MAGI.Application(testData, 2);
    expect(application.People).not.toBe(null);
    expect(application.People.length).toBe(2);
    expect(application.People[0]["Person ID"]).toBe("ABCD")
    expect(application.People[0]["Person ID"]).toBe("EFGH")
  };

  it("creates incomes for all people created", function() {
    var testData = _.extend({}, header, firstApplicant, secondApplicant, thirdApplicant)
    var application = new MAGI.Application(testData, 3);
    expect(application.People[0].Income['Wages, Salaries, Tips']).toBe(10)
    expect(application.People[1].Income['Wages, Salaries, Tips']).toBe(20)
    expect(application.People[2].Income['Wages, Salaries, Tips']).toBe(30)
  });

  it("creates the correct relationships for each person", function() {
    var testData = _.extend({}, header, firstApplicant, secondApplicant, thirdApplicant)
    var application = new MAGI.Application(testData, 3);
    expect(application.People[0].Relationships.length).toBe(0)
    expect(application.People[1].Relationships.length).toBe(1)
    expect(application.People[2].Relationships.length).toBe(2)

    expect(application.People[1].Relationships[0]["Other ID"]).toBe("ABCD");

    expect(application.People[2].Relationships[0]["Other ID"]).toBe("ABCD");
    expect(application.People[2].Relationships[1]["Other ID"]).toBe("EFGH");
  })

})