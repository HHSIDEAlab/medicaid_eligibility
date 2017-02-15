##### GENERATED AT 2015-07-07 11:07:02 -0400 ######
class ParentCaretakerRelativeSpouseFixture < MagiFixture
  attr_accessor :magi, :test_sets

  def initialize
    super

    @spouse = Person.new('Spouse', '', '', '', '')
    @spouse.outputs['Applicant Parent Caretaker Category Indicator'] = 'Y'
    @person = Person.new('Self', '', '', '', '')

    @spouse_not_caretaker = Person.new('Spouse', '', '', '', '')
    @spouse_not_caretaker.outputs['Applicant Parent Caretaker Category Indicator'] = 'N'
    @nonapplicant = Person.new('Spouse', '', '')

    @magi = 'ParentCaretakerRelativeSpouse'
    @test_sets = [
      {
        test_name: 'ParentCaretakerRelativeSpouse - Lives With Spouse, Meets Criteria',
        inputs: {
          'Applicant Relationships' => [Relationship.new(@person, :self, {}), Relationship.new(@spouse, :spouse, {})],
          'Physical Household' => Household.new('Household A', [@person, @spouse]),
          'Applicant Parent Caretaker Category Indicator' => 'N'
        },
        configs: {
          'Option Caretaker Relative Relationship' => '02'
        },
        expected_outputs: {
          'Applicant Parent Caretaker Category Indicator' => 'Y',
          'Parent Caretaker Category Ineligibility Reason' => 999
        }
      },
      {
        test_name: 'ParentCaretakerRelativeSpouse - Does Not Live With Spouse, Meets Criteria',
        inputs: {
          'Applicant Relationships' => [Relationship.new(@person, :self, {}), Relationship.new(@spouse, :spouse, {})],
          'Physical Household' => Household.new('Household A', [@person]),
          'Applicant Parent Caretaker Category Indicator' => 'N'
        },
        configs: {
          'Option Caretaker Relative Relationship' => '02'
        },
        expected_outputs: {
        }
      },
      {
        test_name: 'ParentCaretakerRelativeSpouse - Spouse not an Applicant, Meets Criteria',
        inputs: {
          'Applicant Relationships' => [Relationship.new(@person, :self, {}), Relationship.new(@nonapplicant, :spouse, {})],
          'Physical Household' => Household.new('Household A', [@person, @nonapplicant]),
          'Applicant Parent Caretaker Category Indicator' => 'N'
        },
        configs: {
          'Option Caretaker Relative Relationship' => '02'
        },
        expected_outputs: {
        }
      },
      {
        test_name: 'ParentCaretakerRelativeSpouse - No Spouse, Meets Criteria',
        inputs: {
          'Applicant Relationships' => [Relationship.new(@person, :self, {}), Relationship.new(@spouse, :sibling, {})],
          'Physical Household' => Household.new('Household A', [@person, @spouse]),
          'Applicant Parent Caretaker Category Indicator' => 'N'
        },
        configs: {
          'Option Caretaker Relative Relationship' => '02'
        },
        expected_outputs: {
        }
      },
      {
        test_name: 'ParentCaretakerRelativeSpouse - Parent Caretaker Category Y, Meets Criteria',
        inputs: {
          'Applicant Relationships' => [Relationship.new(@person, :self, {}), Relationship.new(@spouse, :spouse, {})],
          'Physical Household' => Household.new('Household A', [@person, @spouse]),
          'Applicant Parent Caretaker Category Indicator' => 'Y'
        },
        configs: {
          'Option Caretaker Relative Relationship' => '02'
        },
        expected_outputs: {
        }
      },
      {
        test_name: 'ParentCaretakerRelativeSpouse - Spouse Caretaker Category N, Meets Criteria',
        inputs: {
          'Applicant Relationships' => [Relationship.new(@person, :self, {}), Relationship.new(@spouse_not_caretaker, :spouse, {})],
          'Physical Household' => Household.new('Household A', [@person, @spouse_not_caretaker]),
          'Applicant Parent Caretaker Category Indicator' => 'N'
        },
        configs: {
          'Option Caretaker Relative Relationship' => '02'
        },
        expected_outputs: {
        }
      },
      {
        test_name: 'ParentCaretakerRelativeSpouse - No Relationships Fallback',
        inputs: {
          'Applicant Relationships' => [],
          'Physical Household' => [],
          'Applicant Parent Caretaker Category Indicator' => 'N'
        },
        configs: {
          'Option Caretaker Relative Relationship' => '00'
        },
        expected_outputs: {
          # should be none for this
        }
      },
      {
        test_name: 'Bad Info - Inputs',
        inputs: {
          'Applicant Parent Caretaker Category Indicator' => 'N'
        },
        configs: {
          'Option Caretaker Relative Relationship' => '00'
        },
        expected_outputs: {
        }
      },
      # {
      #   test_name: "Bad Info - Configs",
      #   inputs: {
      #     "Applicant Relationships" => [],
      #     "Physical Household" => [],
      #     "Applicant Parent Caretaker Category Indicator" => "N"
      #   },
      #   configs: {
      #   },
      #   expected_outputs: {
      #   }
      # }
    ]

    %w(02 03).each do |eligible_option|
      @test_sets << {
        test_name: "ParentCaretakerRelativeSpouse - Domestic Partner in Eligible State Option #{eligible_option}, Meets Criteria",
        inputs: {
          'Applicant Relationships' => [Relationship.new(@person, :self, {}), Relationship.new(@spouse, :domestic_partner, {})],
          'Physical Household' => Household.new('Household A', [@person, @spouse]),
          'Applicant Parent Caretaker Category Indicator' => 'N'
        },
        configs: {
          'Option Caretaker Relative Relationship' => eligible_option
        },
        expected_outputs: {
          'Applicant Parent Caretaker Category Indicator' => 'Y',
          'Parent Caretaker Category Ineligibility Reason' => 999
        }
      }
    end

    %w(00 01 04).each do |ineligible_option|
      @test_sets << {
        test_name: "ParentCaretakerRelativeSpouse - Domestic Partner in Ineligible State Option #{ineligible_option}, Meets Criteria",
        inputs: {
          'Applicant Relationships' => [Relationship.new(@person, :self, {}), Relationship.new(@spouse, :domestic_partner, {})],
          'Physical Household' => Household.new('Household A', [@person, @spouse]),
          'Applicant Parent Caretaker Category Indicator' => 'N'
        },
        configs: {
          'Option Caretaker Relative Relationship' => ineligible_option
        },
        expected_outputs: {
        }
      }
    end
  end
end

# NOTES
# Bad Info Configs doesn't work in this fixture.
