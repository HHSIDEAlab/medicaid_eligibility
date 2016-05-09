##### GENERATED AT 2015-07-06 11:20:37 -0400 ######
class DependentChildCoveredFixture < MagiFixture
  include ApplicationComponents
  attr_accessor :magi, :test_sets

  def initialize
    super
    @magi = 'DependentChildCovered'
    @test_sets = [
      {
        test_name: "Determine Eligibility - No Qualified Children",
        inputs: {
          "Applicant List" => [],
          "Person List" => [],
          "Applicant Adult Group Category Indicator" => "Y",
          "Qualified Children List" => []
        },
        configs: {
          # none 
        },
        expected_outputs: {
          "Applicant Dependent Child Covered Indicator" => "X",
          "Dependent Child Covered Ineligibility Reason" => 555
        }
      },
      {
        test_name: "Determine Eligibility - All Children Eligible for Coverage - Child in Applicant List",
        inputs: {
          "Applicant List" => [
            Person.new("Parent Caretaker", {"Has Insurance" => "Y"}, 'Parent Caretaker', '',''),
            Person.new("Billy", {"Has Insurance" => "Y"}, 'Billy', '','')
          ],
          "Person List" => [
            Person.new("Parent Caretaker", {"Has Insurance" => "N"}, 'Parent Caretaker'),
            Person.new("Billy", {"Has Insurance" => "N"}, 'Billy')
          ],
          "Applicant Adult Group Category Indicator" => "Y",
          "Qualified Children List" => [
            {'Person ID' => 'Billy'}
          ]
        },
        configs: {
          # none 
        },
        expected_outputs: {
          "Applicant Dependent Child Covered Indicator" => "Y",
          "Dependent Child Covered Ineligibility Reason" => 999
        }
      },
      {
        test_name: "Determine Eligibility - All Children Eligible for Coverage - Child Has Separate Insurance",
        inputs: {
          "Applicant List" => [
            Person.new("Parent Caretaker", {"Has Insurance" => "N"}, 'Parent Caretaker', '','')
          ],
          "Person List" => [
            Person.new("Parent Caretaker", {"Has Insurance" => "N"}, 'Parent Caretaker'),
            Person.new("Billy", {"Has Insurance" => "Y"}, 'Billy')
          ],
          "Applicant Adult Group Category Indicator" => "Y",
          "Qualified Children List" => [
            {'Person ID' => 'Billy'}
          ]
        },
        configs: {
          # none 
        },
        expected_outputs: {
          "Applicant Dependent Child Covered Indicator" => "Y",
          "Dependent Child Covered Ineligibility Reason" => 999
        }
      },
      {
        test_name: "Determine Eligibility - Child Not Covered Scenario (Fallback Determination)",
        inputs: {
          "Applicant List" => [
            Person.new("Parent Caretaker", {"Has Insurance" => "N"}, 'Parent Caretaker', '','')
          ],
          "Person List" => [
            Person.new("Parent Caretaker", {"Has Insurance" => "N"}, 'Parent Caretaker'),
            Person.new("Billy", {"Has Insurance" => "N"}, 'Billy')
          ],
          "Applicant Adult Group Category Indicator" => "Y",
          "Qualified Children List" => [
            {'Person ID' => 'Billy'}
          ]
        },
        configs: {
          # none 
        },
        expected_outputs: {
          "Applicant Dependent Child Covered Indicator" => "N",
          "Dependent Child Covered Ineligibility Reason" => 128
        }
      },
      {
        test_name: "Bad Info - Inputs",
        inputs: {
          "Qualified Children List" => [
            {'Person ID' => 'Billy'}
          ]
        },
        configs: {
          # none 
        },
        expected_outputs: {
        }
      }
    ]
  end
end
