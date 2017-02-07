##### GENERATED AT 2015-07-07 11:15:50 -0400 ######
class PregnantFixture < MagiFixture
  attr_accessor :magi, :test_sets

  def initialize
    super
    @magi = 'Pregnant'
    @test_sets = [
      {
        test_name: 'Pregnant - Applicant Pregnant',
        inputs: {
          'Applicant Pregnant Indicator' => 'Y',
          'Applicant Post Partum Period Indicator' => 'N'
        },
        configs: {
          # none
        },
        expected_outputs: {
          'Applicant Pregnancy Category Indicator' => 'Y',
          'Pregnancy Category Ineligibility Reason' => 999
        }
      },
      {
        test_name: 'Pregnant - Applicant Postpartum',
        inputs: {
          'Applicant Pregnant Indicator' => 'N',
          'Applicant Post Partum Period Indicator' => 'Y'
        },
        configs: {
          # none
        },
        expected_outputs: {
          'Applicant Pregnancy Category Indicator' => 'Y',
          'Pregnancy Category Ineligibility Reason' => 999
        }
      },
      {
        test_name: 'Pregnant - Applicant Not Pregnant or Postpartum',
        inputs: {
          'Applicant Pregnant Indicator' => 'N',
          'Applicant Post Partum Period Indicator' => 'N'
        },
        configs: {
          # none
        },
        expected_outputs: {
          'Applicant Pregnancy Category Indicator' => 'N',
          'Pregnancy Category Ineligibility Reason' => 124
        }
      },
      {
        test_name: 'Bad Info - Inputs',
        inputs: {
          'Applicant Post Partum Period Indicator' => 'N'
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
