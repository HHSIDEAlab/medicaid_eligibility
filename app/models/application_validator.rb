module ApplicationValidator
  class RelationshipError < StandardError
  end

  def validate_relationships!(person)
    if person.get_relationship(:self)
      raise RelationshipError, "#{person.person_id} has a \"Self\" relationship"
    end
    if person.get_relationships(:spouse).count > 1 || 
      person.get_relationships(:domestic_partner).count > 1 || 
      (person.get_relationship(:spouse) && person.get_relationship(:domestic_partner))
      raise RelationshipError, "#{person.person_id} has more than one spouse or domestic partner"
    end
    
    for first_rel, second_rels in ApplicationVariables::SECONDARY_RELATIONSHIPS
      # Get all the people who have the primary relationship to person
      first_people = person.get_relationships(first_rel)
      for first_person in first_people
        for second_rel, computed_rels in second_rels
          # Get all the people who have the secondary relationship to first_person
          second_people = first_person.get_relationships(second_rel)
          for second_person in second_people
            if second_person == person
              # We've already checked inverse relationships elsewhere
              next
            else
              unless computed_rels.any?{|cr| person.get_relationships(cr).include? second_person}
                raise RelationshipError, "#{person.person_id} and #{first_person.person_id} have inconsistent relationships to #{second_person.person_id}"
              end
            end
          end
        end
      end
    end
  end

  def validate_tax_returns(people, tax_returns)
    for person in people
      if tax_returns.select{|tr| tr.filers.include?(person)}.count > 1
        raise "Invalid tax returns: #{person.person_id} is a filer on two returns"
      end
      if tax_returns.select{|tr| tr.dependents.include?(person)}.count > 1
        raise "Invalid tax returns: #{person.person_id} is a dependent on two returns"
      end
    end

    if tax_returns.any?{|tr| tr.dependents.count > 0 && tr.filers.empty?}
      raise "Invalid tax returns: Tax return has dependents but no filer"
    elsif tax_returns.any?{|tr| tr.filers.count > 2}
      raise "Invalid tax returns: Tax return has more than two filers"
    elsif tax_returns.any?{|tr| tr.filers.count == 2 && tr.filers[0].get_relationship(:spouse) != tr.filers[1]}
      raise "Invalid tax returns: Tax return has joint filers who are not married"
    end
  end

  def validate_physical_households(person, physical_households)
    households = physical_households.select{|hh| hh.people.include?(person)}
    if households.count == 0
      raise "Person #{person.person_id} is not in any physical household--every person must be in exactly one physical household"
    end
    if households.count > 1
      raise "Person #{person.person_id} is in multiple physical households--every person must be in exactly one physical household"
    end
  end
end