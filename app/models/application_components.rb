module ApplicationComponents
  class Person
    attr_reader :person_id, :person_attributes, :income, :applicant_id, :applicant_attributes
    attr_accessor :relationships, :medicaid_household, :outputs

    def initialize(person_id, person_attributes, income, applicant_id = nil, applicant_attributes = {})
      @person_id = person_id
      @person_attributes = person_attributes
      @relationships = []
      @income = income
      @applicant_id = applicant_id
      @applicant_attributes = applicant_attributes
      @outputs = {}
    end

    def get_relationships(relationship_type)
      @relationships.select { |rel| rel.relationship_type == relationship_type }.map(&:person)
    end

    def get_relationship(relationship_type)
      get_relationships(relationship_type).first
    end

    def parents_stepparents
      get_relationships(:parent) + get_relationships(:stepparent)
    end
  end

  class Relationship
    attr_reader :person, :relationship_type, :relationship_attributes

    def initialize(person, relationship_type, relationship_attributes)
      @person = person
      @relationship_type = relationship_type
      @relationship_attributes = relationship_attributes
    end
  end

  class Household
    attr_accessor :people
    attr_reader :household_id

    def initialize(household_id, people)
      @household_id = household_id
      @people = people
    end
  end

  class MedicaidHousehold < Household
    attr_accessor :income_people, :income
    attr_reader :household_size

    def initialize(household_id, people, income_people, income, household_size)
      super household_id, people
      @income_people = income_people
      @income = income
      @household_size = household_size
    end
  end

  class TaxReturn
    attr_reader :filers, :dependents

    def initialize(filers, dependents)
      @filers = filers
      @dependents = dependents
    end
  end
end
