describe("MAGI.Application", function() {

  var header, firstApplicant, secondApplicant, thirdApplicant;

  beforeEach(function() {
    header = {'state': 'CA', 'id': '12345'}
    firstApplicant = {
      'applicant_1_id': 'ABCD',
      'applicant_1_wages': 10
    }
    secondApplicant = {
      'applicant_2_id': 'FGHI',
      'applicant_2_wages': 20,
      'applicant_2_relationship_to_1': 4
    }
    thirdApplicant = {
      'applicant_3_id': 'JKLM',
      'applicant_3_wages': 30,
      'applicant_3_relationship_to_1': 3,
      'applicant_3_relationship_to_2': 15
    }
  });

  it("parses a simple set of fields", function() {
    var testData = _.extend({}, header, firstApplicant);
    var application = new MAGI.Application(testData, 1);
    expect(application.People).not.toBe(null);
    expect(application.People.length).toBe(1);
    expect(application.State).toBe('CA')
    expect(application.People[0].Income['Wages, Salaries, Tips']).toBe(10)
  });

  it("handles two simple sets of fields"), function() {
    var testData = _.extend({}, header, firstApplicant, secondApplicant)
    var application = new MAGI.Application(testData, 2);
    expect(application.People).not.toBe(null);
    expect(application.People.length).toBe(2);
    expect(application.People[0].Income['Wages, Salaries, Tips']).toBe(10)
    expect(application.People[1].Income['Wages, Salaries, Tips']).toBe(20)
  }
})