module ApplicationVariables
  PERSON_INPUTS = [
    {
      :name       => "Applicant Age",
      :type       => :integer,
      :xml_group  => :person,
      :xpath      => "PersonAge",
      :new_variable => true
    },
    {
      :name       => "Applicant Attest Disabled",
      :type       => :flag,
      :values     => %w(Y N),
      :xml_group  => :applicant,
      :xpath      => "hix-ee:InsuranceApplicantBlindnessOrDisabilityIndicator"
    },
    {
      :name       => "Applicant Attest Long Term Care",
      :type       => :flag,
      :values     => %w(Y N),
      :xml_group  => :applicant,
      :xpath      => "hix-ee:InsuranceApplicantBlindnessOrDisabilityIndicator"
    },
    # {
    #   :name       => "Applicant Household Income",
    #   :type       => :integer,
    #   :xml_group  => :undefined,
    #   :xpath      => :undefined
    # },
    {
      :name       => "Applicant Medicaid Citizen Or Immigrant Status Indicator",
      :type       => :flag,
      :values     => %w(Y N D E H I P T),
      :xml_group  => :applicant,
      :xpath      => "hix-ee:MedicaidMAGIEligibility/hix-ee:MedicaidMAGICitizenOrImmigrantEligibilityBasis/hix-ee:StatusIndicator"
    },
    {
      :name       => "Applicant Pregnant Indicator",
      :type       => :flag,
      :values     => %w(Y N),
      :xml_group  => :person,
      :xpath      => "hix-core:PersonAugmentation/hix-core:PersonPregnancyStatus/hix-core:StatusIndicator"
    },
    {
      :name       => "Applicant Post Partum Period Indicator",
      :type       => :flag,
      :values     => %w(Y N),
      :xml_group  => :person,
      :xpath      => "hix-core:PersonAugmentation/hix-core:PersonPostPartumPeriod/hix-core:StatusIndicator",
      :new_variable => true
    },
    {
      :name       => "Medicare Entitlement Indicator",
      :type       => :flag,
      :values     => %w(Y N),
      :xml_group  => :applicant,
      :xpath      => "hix-ee:MedicaidNonMAGIEligibility/hix-ee:MedicaidNonMAGIMedicareEntitlementEligibilityBasis/hix-core:StatusIndicator"
    },
    {
      :name       => "Medicaid Residency Status Indicator",
      :type       => :flag,
      :values     => %w(Y N P),
      :xml_group  => :applicant,
      :xpath      => "hix-ee:MedicaidMAGIEligibility/hix-ee:MedicaidMAGIResidencyEligibilityBasis/hix-ee:StatusIndicator"
    },
    {
      :name       => "Person Disabled Indicator",
      :type       => :flag,
      :values     => %w(Y N),
      :xml_group  => :applicant,
      :xpath      => "hix-ee:MedicaidNonMAGIEligibility/hix-ee:MedicaidNonMAGIBlindnessOrDisabilityEligibilityBasis/hix-core:StatusIndicator"
    },
    {
      :name       => "Student Indicator",
      :type       => :flag,
      :values     => %w(Y N),
      :xml_group  => :applicant,
      :xpath      => "hix-ee:InsuranceApplicantStudentIndicator"
    }
  ].freeze

  DETERMINATIONS = [
    {name: "Pregnancy Category", eligibility: :MAGI},
    {name: "Child Category", eligibility: :MAGI},
    {name: "Adult Group Category", eligibility: :MAGI},
    {name: "Adult Group XX Category", eligibility: :MAGI},
    {name: "Optional Targeted Low Income Child", eligibility: :MAGI},
    {name: "CHIP Targeted Low Income Child", eligibility: :CHIP},
    {name: "Income", eligibility: :MAGI},
    {
      name: "Medicaid Non-MAGI Referral",
      group: :other,
      indicator_xpath: "hix-ee:MedicaidNonMAGIEligibility/hix-ee:EligibilityIndicator",
      date_xpath: "hix-ee:MedicaidNonMAGIEligibility/hix-ee:EligibilityDetermination/nc:ActivityDate/nc:DateTime",
      reason_xpath: "hix-ee:MedicaidNonMAGIEligibility/hix-ee:EligibilityReasonText"
    }
  ].freeze

  OUTPUTS = [
    {
      :name   => "Category Used to Calculate Income",
      :type   => :string,
      :xpath  => :undefined
    }
  ].freeze

  RELATIONSHIP_CODES = {
    "01" => "Self",
    "02" => "Spouse of other relative within required degree of relation",
    "03" => "Parent",
    "04" => "Son/Daughter",
    "05" => "Stepdaughter/Stepson",
    "06" => "Grandchild",
    "07" => "Sibling/Stepsibling",
    "08" => "Domestic Partner of other relative within required degree of relation",
    "12" => "Step-Parent",
    "13" => "Uncle/Aunt",
    "14" => "Nephew/Niece",
    "15" => "Grandparent",
    "16" => "First Cousin",
    "17" => "Parent's Domestic Partner",
    "23" => "Brother-in-Law/Sister-in-Law",
    "26" => "Daughter-in-Law/Son-in-Law",
    "27" => "Former Spouse",
    "30" => "Mother-in-Law/Father-in-Law"
  }.freeze
end
