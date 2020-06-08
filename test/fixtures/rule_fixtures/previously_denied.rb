##### GENERATED AT 2015-07-07 11:34:20 -0400 ######
class PreviouslyDeniedFixture < MagiFixture
    attr_accessor :magi, :test_sets

    def initialize
      super
      @magi = 'PreviouslyDenied'
      @test_sets = [
        {
          test_name: "Previously Denied - Y",
          inputs: {
            "Previously Denied" => "Y"
          },
          configs: {
            # none
          },
          expected_outputs: {
            "Previously Denied" => "Y"
          }
        },
        {
          test_name: "Previously Denied - N",
          inputs: {
            "Previously Denied" => "N"
          },
          configs: {
            # none
          },
          expected_outputs: {
            "Previously Denied" => "N"
          }
        }

      ]
    end
  end
