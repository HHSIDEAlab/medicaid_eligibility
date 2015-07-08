##### GENERATED AT 2015-07-07 12:06:44 -0400 ######
class QualifiedChildFixture < MagiFixture
	attr_accessor :magi, :test_sets

	def initialize
		super
		@magi = 'QualifiedChild'
		@test_sets = [
		# 	{
		# 		test_name: "FILL_IN_WITH_TEST_NAME",
		# 		inputs: {
		# 			"Caretaker Age" => ?,
		# 			"Child Age" => ?,
		# 			"Child Parents" => ?,
		# 			"Physical Household" => ?,
		# 			"Relationship Type" => ?,
		# 			"Student Indicator" => ?
		# 		},
		# 		configs: {
		# 			"Child Age Threshold" => ?,
		# 			"Dependent Age Threshold" => ?,
		# 			"Option Dependent Student" => ?,
		# 			"Deprivation Requirement Retained" => ?,
		# 			"Option Caretaker Relative Relationship" => ?,
		# 			"State Unemployed Standard" => ?
		# 		},
		# 		expected_outputs: {
		# 			"Child of Caretaker Dependent Age Indicator" => ?,
		# 			"Child of Caretaker Dependent Age Determination Date" => ?,
		# 			"Child of Caretaker Dependent Age Ineligibility Reason" => ?,
		# 			"Child of Caretaker Deprived Child Indicator" => ?,
		# 			"Child of Caretaker Deprived Child Determination Date" => ?,
		# 			"Child of Caretaker Deprived Child Ineligibility Reason" => ?,
		# 			"Child of Caretaker Relationship Indicator" => ?,
		# 			"Child of Caretaker Relationship Determination Date" => ?,
		# 			"Child of Caretaker Relationship Ineligibility Reason" => ?
		# 		}
		# 	}

			{
				test_name: "Bad Info - Inputs",
				inputs: {
					"Student Indicator" => "N"
				},
				configs: {
					"Child Age Threshold" => 19,
					"Dependent Age Threshold" => 18,
					"Option Dependent Student" => "N",
					"Deprivation Requirement Retained" => "N",
					"Option Caretaker Relative Relationship" => 00,
					"State Unemployed Standard" => 100
				},
				expected_outputs: {
				}
			},
			{
				test_name: "Bad Info - Configs",
				inputs: {
					"Caretaker Age" => 23,
					"Child Age" => 19,
					"Child Parents" => [],
					"Physical Household" => Household.new('',''),
					"Relationship Type" => :child,
					"Student Indicator" => "N"
				},
				configs: {
					"State Unemployed Standard" => 100
				},
				expected_outputs: {
				}
			}
		]
	end
end

# NOTES
# no. -CF 7/7/2015
