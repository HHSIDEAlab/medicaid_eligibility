describe("MAGI.Application", function() {

  var testData;


  it("parses a simple set of fields", function() {
    testData = {'state': 'CA', 'applicant_1_foo': 5, 'applicant_1_wages': 10}
    var application = new MAGI.Application(testData, 1);
    expect(application.People).not.toBe(null);
    expect(application.People.length).toBe(1);
    expect(application.State).toBe('CA')
    expect(application.People[0].Income['Wages, Salaries, Tips']).toBe(10)
  });

  it("handles two simple sets of fields"), function() {
    testData = testData = {'state': 'CA', 'applicant_1_foo': 5, 'applicant_1_wages': 10, 'applicant_2_foo': 5, 'applicant_2_wages': 20}
    var application = new MAGI.Application(testData, 2);
    expect(application.People).not.toBe(null);
    expect(application.People.length).toBe(2);
  }
})