##### GENERATED AT 2015-07-07 12:07:45 -0400 ######
class ReferralTypeFixture < MagiFixture
  attr_accessor :magi, :test_sets

  def initialize
    super
    @magi = 'ReferralType'
    @test_sets = [
      {
        test_name: "Referral Type - Age Over 65",
        inputs: {
          "Applicant Age" => 70,
          "Applicant Attest Blind or Disabled" => "N",
          "Applicant Attest Long Term Care" => "N",
          "Medicare Entitlement Indicator" => "N",
          "Receives SSI" => "N"
        },
        configs: {
          # none
        },
        expected_outputs: {
          "Applicant Medicaid Non-MAGI Referral Indicator" => "Y",
          "Medicaid Non-MAGI Referral Ineligibility Reason" => 999
        }
      },
      {
        test_name: "Referral Type - Blind",
        inputs: {
          "Applicant Age" => 40,
          "Applicant Attest Blind or Disabled" => "Y",
          "Applicant Attest Long Term Care" => "N",
          "Medicare Entitlement Indicator" => "N",
          "Receives SSI" => "N"
        },
        configs: {
          # none
        },
        expected_outputs: {
          "Applicant Medicaid Non-MAGI Referral Indicator" => "Y",
          "Medicaid Non-MAGI Referral Ineligibility Reason" => 999
        }
      },
      {
        test_name: "Referral Type - Long Term Care",
        inputs: {
          "Applicant Age" => 40,
          "Applicant Attest Blind or Disabled" => "N",
          "Applicant Attest Long Term Care" => "Y",
          "Medicare Entitlement Indicator" => "N",
          "Receives SSI" => "N"
        },
        configs: {
          # none
        },
        expected_outputs: {
          "Applicant Medicaid Non-MAGI Referral Indicator" => "Y",
          "Medicaid Non-MAGI Referral Ineligibility Reason" => 999
        }
      },
      {
        test_name: "Referral Type - Medicare Entitlement",
        inputs: {
          "Applicant Age" => 40,
          "Applicant Attest Blind or Disabled" => "N",
          "Applicant Attest Long Term Care" => "N",
          "Medicare Entitlement Indicator" => "Y",
          "Receives SSI" => "N"
        },
        configs: {
          # none
        },
        expected_outputs: {
          "Applicant Medicaid Non-MAGI Referral Indicator" => "Y",
          "Medicaid Non-MAGI Referral Ineligibility Reason" => 999
        }
      },
      {
        test_name: "Referral Type - SSI",
        inputs: {
          "Applicant Age" => 40,
          "Applicant Attest Blind or Disabled" => "N",
          "Applicant Attest Long Term Care" => "N",
          "Medicare Entitlement Indicator" => "N",
          "Receives SSI" => "Y"
        },
        configs: {
          # none
        },
        expected_outputs: {
          "Applicant Medicaid Non-MAGI Referral Indicator" => "Y",
          "Medicaid Non-MAGI Referral Ineligibility Reason" => 999
        }
      },
      {
        test_name: "Referral Type - Fallback",
        inputs: {
          "Applicant Age" => 40,
          "Applicant Attest Blind or Disabled" => "N",
          "Applicant Attest Long Term Care" => "N",
          "Medicare Entitlement Indicator" => "N",
          "Receives SSI" => "N"
        },
        configs: {
          # none
        },
        expected_outputs: {
          "Applicant Medicaid Non-MAGI Referral Indicator" => "N",
          "Medicaid Non-MAGI Referral Ineligibility Reason" => 108
        }
      },
      {
        test_name: "Bad Info - Inputs",
        inputs: {
          # "Applicant Age" => 40,
          # "Applicant Attest Blind or Disabled" => "N",
          # "Applicant Attest Long Term Care" => "N",
          # "Medicare Entitlement Indicator" => "N",
          "Receives SSI" => "N"
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
