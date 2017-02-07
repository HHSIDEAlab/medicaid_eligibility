##### GENERATED AT 2015-07-06 18:00:51 -0400 ######
class MedicaidEligibilityFixture < MagiFixture
  attr_accessor :magi, :test_sets

  def initialize
    super
    @magi = 'MedicaidEligibility'
    @test_sets = [
      {
        test_name: 'Final Eligibility - Prelim No',
        inputs: {
          'Applicant Medicaid Prelim Indicator' => 'N'
        },
        configs: {
          # none
        },
        expected_outputs: {
          'Applicant Medicaid Indicator' => 'N',
          'Medicaid Ineligibility Reason' => 106,
          'APTC Referral Indicator' => 'Y'
        }
      },
      {
        test_name: 'Final Eligibility - Prelim Yes',
        inputs: {
          'Applicant Medicaid Prelim Indicator' => 'Y'
        },
        configs: {
          # none
        },
        expected_outputs: {
          'Applicant Medicaid Indicator' => 'Y',
          'Medicaid Ineligibility Reason' => 999,
          'APTC Referral Indicator' => 'N',
          'APTC Referral Ineligibility Reason' => 406
        }
      },
      {
        test_name: 'Bad Info - Inputs',
        inputs: {
          # none
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

# NOTES
# No 999 on aptc referral ineligibility reason here when aptc referral is yes? -CF 7/6/2015
