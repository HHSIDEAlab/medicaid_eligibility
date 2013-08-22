module ApplicationVariables
  PERSON_INPUTS = [
    {
      :name       => "Age Left Foster Care",
      :type       => :integer,
      :xml_group  => :applicant,
      :xpath      => :unimplemented
    },
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
      :name       => "Applicant Has 40 Title II Work Quarters",
      :type       => :flag,
      :values     => %w(Y N),
      :xml_group  => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "Applicant Medicaid Citizen Or Immigrant Status Indicator",
      :type       => :flag,
      :values     => %w(Y N D E H I P T),
      :xml_group  => :applicant,
      :xpath      => "hix-ee:MedicaidMAGIEligibility/hix-ee:MedicaidMAGICitizenOrImmigrantEligibilityBasis/hix-core:StatusIndicator"
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
      :name       => "Attest Primary Responsibility",
      :type       => :flag,
      :values     => %w(Y N),
      :xml_group  => :relationship,
      :xpath      => "PrimaryResponsibility",
      :new_variable => true
    },
    {
      :name       => "Five Year Bar Applies",
      :type       => :flag,
      :values     => %w(Y N),
      :xml_group  => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "Five Year Bar Met",
      :type       => :flag,
      :values     => %w(Y N),
      :xml_group  => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "Foster Care",
      :type       => :flag,
      :values     => %w(Y N),
      :xml_group  => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "Foster Care State",
      :type       => :string,
      :xml_group  => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "Had Medicaid During Foster Care",
      :type       => :flag,
      :values     => %w(Y N),
      :xml_group  => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "Has Insurance",
      :type       => :flag,
      :values     => %w(Y N),
      :xml_group  => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "Home State",
      :type       => :string,
      :xml_group  => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "Hours Worked Per Week",
      :type       => :integer,
      :xml_group  => :person,
      :xpath      => :unimplemented
    },
    {
      :name       => "Incarceration Status",
      :type       => :flag,
      :values     => %w(Y N),
      :xml_group  => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "Lawful Presence",
      :type       => :flag,
      :values     => %w(Y N),
      :xml_group  => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "Legal Permanent Resident",
      :type       => :flag,
      :values     => %w(Y N),
      :xml_group  => :applicant,
      :xpath      => :unimplemented
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
      :name       => "Non-Citizen Deport Withheld Date",
      :type       => :date,
      :xml_group  => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "Non-Citizen Entry Date",
      :type       => :date,
      :xml_group  => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "Non-Citizen Status Grant Date",
      :type       => :date,
      :xml_group  => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "Person Disabled Indicator",
      :type       => :flag,
      :values     => %w(Y N),
      :xml_group  => :applicant,
      :xpath      => "hix-ee:MedicaidNonMAGIEligibility/hix-ee:MedicaidNonMAGIBlindnessOrDisabilityEligibilityBasis/hix-core:StatusIndicator"
    },
    {
      :name       => "Prior Insurance End Date",
      :type       => :date,
      :xml_group  => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "Refugee Medical Assistance Start Date",
      :type       => :date,
      :xml_group  => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "Refugee Status",
      :type       => :flag,
      :values     => %w(Y N),
      :xml_group  => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "Qualified Non-Citizen Status",
      :type       => :flag,
      :values     => %w(Y N),
      :xml_group  => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "Seven Year Limit Applies",
      :type       => :flag,
      :values     => %w(Y N),
      :xml_group  => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "State Health Benefits Through Public Employee",
      :type       => :flag,
      :values     => %w(Y N),
      :xml_group  => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "Student Indicator",
      :type       => :flag,
      :values     => %w(Y N),
      :xml_group  => :applicant,
      :xpath      => "hix-ee:InsuranceApplicantStudentIndicator"
    },
    {
      :name       => "US Citizen Indicator",
      :type       => :flag,
      :values     => %w(Y N),
      :xml_group  => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "Veteran Status",
      :type       => :flag,
      :values     => %w(Y N),
      :xml_group  => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "Victim of Trafficking",
      :type       => :flag,
      :values     => %w(Y N),
      :xml_group  => :applicant,
      :xpath      => :unimplemented
    }
  ].freeze

  DETERMINATIONS = [
    {name: "Parent Caretaker Category", eligibility: :MAGI},
    {name: "Pregnancy Category", eligibility: :MAGI},
    {name: "Child Category", eligibility: :MAGI},
    {name: "Adult Group Category", eligibility: :MAGI},
    {name: "Adult Group XX Category", eligibility: :MAGI},
    {name: "Optional Targeted Low Income Child", eligibility: :MAGI},
    {name: "CHIP Targeted Low Income Child", eligibility: :CHIP},
    #{name: "Income", eligibility: :MAGI},
    {
      name: "Medicaid Non-MAGI Referral",
      eligibility: :MedicaidNonMAGI,
      indicator_xpath: "hix-ee:MedicaidNonMAGIEligibility/hix-ee:EligibilityIndicator",
      date_xpath: "hix-ee:MedicaidNonMAGIEligibility/hix-ee:EligibilityDetermination/nc:ActivityDate/nc:DateTime",
      reason_xpath: "hix-ee:MedicaidNonMAGIEligibility/hix-ee:EligibilityReasonText"
    }
  ].freeze

  CHILD_OUTPUTS = [
    {name: "Child of Caretaker Dependent Age", type: :determination},
    {name: "Child of Caretaker Deprived Child", type: :determination},
    {name: "Child of Caretaker Relationship", type: :determination}
  ].freeze

  OUTPUTS = [
    {
      :name   => "Category Used to Calculate Income",
      :type   => :string,
      :group  => :MAGI,
      :xpath  => "CategoryUsedToCalculateIncome"
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

  CODE_REVERSE = {
    "01" => "01",
    "02" => "02",
    "03" => "04",
    "04" => "03",
    "05" => "12",
    "06" => "15",
    "07" => "07",
    "08" => "08",
    "12" => "05",
    "13" => "14",
    "14" => "13",
    "15" => "06",
    "16" => "16",
    #"17" => "Parent's Domestic Partner",
    "23" => "23",
    "26" => "30",
    "27" => "27",
    "30" => "26"
  }
end
