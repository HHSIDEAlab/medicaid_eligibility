##### GENERATED AT 2015-07-07 11:07:02 -0400 ######
class ParentCaretakerRelativeSpouseFixture < MagiFixture
	attr_accessor :magi, :test_sets

	def initialize
		super

		# have to hard set this due to the fixture requiring some certain outputs
		spouse = Applicant.new('Person A','','','','')
		spouse.outputs["Applicant Parent Caretaker Category Indicator"] = "Y"

		@magi = 'ParentCaretakerRelativeSpouse'
		@test_sets = [

			# BROKEN TEST
			{
				test_name: "ParentCaretakerRelativeSpouse - ",
				inputs: {
					"Applicant Relationships" => [Relationship.new('Self', :self,''), Relationship.new("Person A", :spouse, ''), Relationship.new("Person B", :child, '')],
					"Physical Household" => Household.new('Household A', ["Self",'Person A',"Person B"]),
					"Applicant Parent Caretaker Category Indicator" => "N"
				},
				configs: {
					"Option Caretaker Relative Relationship" => "02"
				},
				expected_outputs: {
					# "Applicant Parent Caretaker Category Indicator" => "Y",
					# "Parent Caretaker Category Ineligibility Reason" => 999
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
			},
			{
				test_name: "Bad Info - Inputs",
				inputs: {
					"Applicant Parent Caretaker Category Indicator" => "N"
				},
				configs: {
					"Option Caretaker Relative Relationship" => "00"
				},
				expected_outputs: {
				}
			},	
			# {
			# 	test_name: "Bad Info - Configs",
			# 	inputs: {
			# 		"Applicant Relationships" => [],
			# 		"Physical Household" => [],
			# 		"Applicant Parent Caretaker Category Indicator" => "N"
			# 	},
			# 	configs: {
			# 	},
			# 	expected_outputs: {
			# 	}
			# }	
		]
	end
end

# NOTES
# Bad Info Configs doesn't work in this fixture. 

# I can't get the positive test here to work -- the household people list is looking for a person id but needs to be an applicant object to respond to outputs, and can't find the person id if there's an object. 
# This in turn means that you can either have it respond to :outputs or have 'lives with spouse/domestic partner' set to yes, but not both.
# So as it's set up now I couldn't figure out a combination that would work.