##### GENERATED AT 2015-07-07 11:07:02 -0400 ######
class ParentCaretakerRelativeSpouseFixture < MagiFixture
	attr_accessor :magi, :test_sets

	def initialize
		super
		@magi = 'ParentCaretakerRelativeSpouse'
		@test_sets = [

			{
				test_name: "ParentCaretakerRelativeSpouse - ",
				inputs: {
					"Applicant Relationships" => [],
					"Physical Household" => [],
					"Applicant Parent Caretaker Category Indicator" => "N"
				},
				configs: {
					"Option Caretaker Relative Relationship" => "00"
				},
				expected_outputs: {
					# should be none for this 
				}
			},


			{
				test_name: "ParentCaretakerRelativeSpouse - No Relationships Fallback",
				inputs: {
					"Applicant Relationships" => [],
					"Physical Household" => [],
					"Applicant Parent Caretaker Category Indicator" => "N"
				},
				configs: {
					"Option Caretaker Relative Relationship" => "00"
				},
				expected_outputs: {
					# should be none for this 
				}
			}
		]
	end
end



# expected_outputs					
# "Applicant Parent Caretaker Category Indicator" => ?,
# "Parent Caretaker Category Determination Date" => ?,
# "Parent Caretaker Category Ineligibility Reason" => ?


# def initialize(person, relationship_type, relationship_attributes) relationships

# def initialize(household_id, people) household