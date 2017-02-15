require 'test_helper'

class HouseholdingTest < ActionDispatch::IntegrationTest
  @fixtures = load_fixtures

  def setup
    @app_4_person_family = reload_fixture('4_person_family')[:result]
    @app_3_generation_family = reload_fixture('3_generation_family')[:result]
  end

  test 'this householding test ought to succeed' do
    assert_equal true, true
  end

  test 'counting income: a person not claimed as a dependent should have income counted' do
    app = @app_4_person_family
    person_1 = app.people.first

    assert app.tax_returns.none? { |tr| tr.dependents.include? person_1 },
           'Person 1 should not claimed as a dependent on any tax return'

    mhs_with_person_1 = app.people.map(&:medicaid_household).select { |mh| mh.people.include? person_1 }
    assert mhs_with_person_1.all? { |mh| mh.income_people.include? person_1 },
           'In all Medicaid households that include Person 1, Person 1\'s income should not be counted'
  end

  test 'counting income: a person claimed as a dependent by a parent/stepparent should never have income counted' do
    app = @app_4_person_family
    person_1 = app.people[0]
    person_4 = app.people[3]

    assert (person_1.medicaid_household.people.include? person_4),
           'Person 4 should be in the Medicaid household of Person 1 (parent of Person 4)'

    mhs_with_person_4 = app.people.map(&:medicaid_household).select { |mh| mh.people.include? person_4 }
    assert mhs_with_person_4.none? { |mh| mh.income_people.include? person_4 },
           'Person 4\'s income should not be counted in any Medicaid household'
  end

  test 'counting income: a person claimed as a dependent by a non-parent/stepparent should have income counted in all but the claimer\'s household' do
    app = @app_3_generation_family
    person_1 = app.people[0]
    person_2 = app.people[1]
    person_3 = app.people[2]
    assert_equal person_3.get_relationship(:grandparent), person_1

    tr = app.tax_returns.find { |tr| tr.dependents.include? person_3 }
    assert tr.filers.first == person_1
    'Person 3 should be claimed as a dependent by his/her grandparent'
    assert !(person_2.medicaid_household.people.include? person_3),
           'Person 3 should not be in the parent\'s Medicaid household'
    assert !(person_1.medicaid_household.income_people.include? person_3),
           'Person 3\'s income should not be counted in the grandparent\'s Medicaid household'
    assert (person_3.medicaid_household.income_people.include? person_3),
           'Person 3\'s income should be counted in his/her own Medicaid household'
  end
end
