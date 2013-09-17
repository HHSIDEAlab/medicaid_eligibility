module ApplicationVariables
  PERSON_INPUTS = [
    {
      :name       => "Applicant Age",
      :type       => :integer,
      :group      => :person,
      :xpath      => "PersonAge",
      :required   => true
    },
    {
      :name       => "Applicant Attest Disabled",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :applicant,
      :xpath      => "hix-ee:InsuranceApplicantBlindnessOrDisabilityIndicator",
      :default    => "N"
    },
    {
      :name       => "Applicant Attest Long Term Care",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :applicant,
      :xpath      => "hix-ee:InsuranceApplicantBlindnessOrDisabilityIndicator",
      :default    => "N"
    },
    {
      :name       => "Applicant Has 40 Title II Work Quarters",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :applicant,
      :xpath      => :unimplemented,
      :default    => "N"
    },
    {
      :name       => "Claimed as Dependent by Person Not on Application",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :person,
      :xpath      => :unimplemented,
      :default    => "N"
    },
    {
      :name       => "Claimer Is Out of State",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :person,
      :xpath      => :unimplemented,
      :default    => "N"
    },
    {
      :name       => "Has Insurance",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "Hours Worked Per Week",
      :type       => :integer,
      :group      => :person,
      :xpath      => :unimplemented
    },
    {
      :name       => "Incarceration Status",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "Medicare Entitlement Indicator",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :applicant,
      :xpath      => "hix-ee:MedicaidNonMAGIEligibility/hix-ee:MedicaidNonMAGIMedicareEntitlementEligibilityBasis/hix-core:StatusIndicator"
    },
    {
      :name       => "Medicaid Residency Indicator",
      :type       => :flag,
      :values     => %w(Y N P),
      :group      => :applicant,
      :xpath      => "hix-ee:MedicaidMAGIEligibility/hix-ee:MedicaidMAGIResidencyEligibilityBasis/hix-ee:StatusIndicator",
      :required   => true
    },
    {
      :name       => "Prior Insurance",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "Prior Insurance End Date",
      :type       => :date,
      :group      => :applicant,
      :xpath      => :unimplemented,
      :required_if => "Prior Insurance",
      :required_if_value => "Y"
    },
    {
      :name       => "Required to File Taxes",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :person,
      :xpath      => :unimplemented,
      :required   => :true
    },
    {
      :name       => "State Health Benefits Through Public Employee",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "Student Indicator",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :applicant,
      :xpath      => "hix-ee:InsuranceApplicantStudentIndicator"
    },
    
    # Pregnancy inputs
    {
      :name       => "Applicant Pregnant Indicator",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :person,
      :xpath      => "hix-core:PersonAugmentation/hix-core:PersonPregnancyStatus/hix-core:StatusIndicator",
      :default    => "N"
    },
    {
      :name       => "Applicant Post Partum Period Indicator",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :person,
      :xpath      => "hix-core:PersonAugmentation/hix-core:PersonPostPartumPeriod/hix-core:StatusIndicator",
      :default    => "N"
    },

    # Foster Care inputs
    {
      :name       => "Former Foster Care",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "Age Left Foster Care",
      :type       => :integer,
      :group      => :applicant,
      :xpath      => :unimplemented,
      :required_if => "Former Foster Care",
      :required_if_value => "Y"
    },
    {
      :name       => "Foster Care State",
      :type       => :string,
      :group      => :applicant,
      :xpath      => :unimplemented,
      :required_if => "Former Foster Care",
      :required_if_value => "Y"
    },
    {
      :name       => "Had Medicaid During Foster Care",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :applicant,
      :xpath      => :unimplemented,
      :required_if => "Former Foster Care",
      :required_if_value => "Y"
    },
    
    # Citizenship and Immigration Status inputs
    {
      :name       => "US Citizen Indicator",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :applicant,
      :xpath      => :unimplemented,
      :required   => true
    },
    {
      :name       => "Five Year Bar Applies",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "Five Year Bar Met",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :applicant,
      :xpath      => :unimplemented,
      :required_if => "Five Year Bar Applies",
      :required_if_value => "Y"
    },
    {
      :name       => "Immigrant Status",
      :type       => :string,
      :group      => :applicant,
      :xpath      => :unimplemented,
      :required_if => "US Citizen Indicator",
      :required_if_value => "N"
    },
    {
      :name       => "Lawful Presence Attested",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "Non-Citizen Deport Withheld Date",
      :type       => :date,
      :group      => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "Non-Citizen Entry Date",
      :type       => :date,
      :group      => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "Non-Citizen Status Grant Date",
      :type       => :date,
      :group      => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "Qualified Non-Citizen Status",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "Refugee Medical Assistance Start Date",
      :type       => :date,
      :group      => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "Refugee Status",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :applicant,
      :default    => "N",
      :xpath      => :unimplemented
    },
    {
      :name       => "Seven Year Limit Applies",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "Seven Year Limit Start Date",
      :type       => :date,
      :group      => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "Veteran Status",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "Victim of Trafficking",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :applicant,
      :xpath      => :unimplemented
    },
    
    # Relationship inputs
    {
      :name       => "Attest Primary Responsibility",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :relationship,
      :xpath      => "PrimaryResponsibility",
      :default    => "N"
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
    {name: "Unborn Child"},

    {name: "Income Medicaid Eligible", eligibility: :MAGI},
    
    {name: "CHIPRA 214"},
    {name: "Trafficking Victim"},
    {name: "Seven Year Limit"},
    {name: "Five Year Bar"},
    {name: "Title II Work Quarters Met"},
    {name: "Medicaid Citizen Or Immigrant"},
    
    {name: "Former Foster Care Category"},
    {name: "Work Quarters Override Income"},
    {name: "State Health Benefits CHIP"},
    {name: "CHIP Waiting Period Satisfied"},
    {name: "CHIP Incarceration"},
    {name: "Dependent Child Covered"},

    {
      name: "Medicaid Non-MAGI Referral",
      eligibility: :MedicaidNonMAGI,
      indicator_xpath: "hix-ee:MedicaidNonMAGIEligibility/hix-ee:EligibilityIndicator",
      date_xpath: "hix-ee:MedicaidNonMAGIEligibility/hix-ee:EligibilityDetermination/nc:ActivityDate/nc:DateTime",
      reason_xpath: "hix-ee:MedicaidNonMAGIEligibility/hix-ee:EligibilityReasonText"
    },
    {name: "APTC Referral"},

    {name: "CHIP"},
    {name: "Medicaid"},
    {name: "Emergency Medicaid"},
    {name: "Refugee Medical Assistance"}
  ].freeze

  INCOME_INPUTS = [
    {
      :primary_income => "AGI",
      :other_income => [ 
        "Deductible Part of Self-Employment Tax",
        "IRA Deduction",
        "Student Loan Interest Deduction",
        "Tuition and Fees",
        "Tax-Exempt Interest",
        "Other MAGI-Eligible Income"
      ],
      :deductions => [
        "Social Security Benefits Taxable Amount"
      ]
    },
    {
      :primary_income => "MAGI",
      :other_income => [],
      :deductions => []
    },
    {
      :primary_income => "Wages, Salaries, Tips",
      :other_income => [
        "Taxable Interest",
        "Tax-Exempt Interest",
        "Taxable Refunds, Credits, or Offsets of State and Local Income Taxes",
        "Alimony",
        "Capital Gain or Loss",
        "Pensions and Annuities Taxable Amount",
        "Farm Income or Loss",
        "Unemployment Compensation",
        "Other Income"
      ],
      :deductions => [
        "MAGI Deductions"
      ]
    }
  ].freeze

  # INCOME_INPUTS = {
  #   :tax_return => {
  #     :income => [
  #       "AGI",
  #       "Deductible Part of Self-Employment Tax",
  #       "IRA Deduction",
  #       "Student Loan Interest Deduction",
  #       "Tuition and Fees",
  #       "Tax-Exempt Interest",
  #       "Other MAGI-Eligible Income"
  #     ],
  #     :deductions => [
  #       "Social Security Benefits Taxable Amount"
  #     ]
  #   },
  #   :personal => [
  #     {
  #       :primary_income => "MAGI",
  #       :other_income => [],
  #       :deductions => []
  #     },
  #     {
  #       :primary_income => "Wages, Salaries, Tips",
  #       :other_income => [
  #         "Taxable Interest",
  #         "Tax-Exempt Interest",
  #         "Taxable Refunds, Credits, or Offsets of State and Local Income Taxes",
  #         "Alimony",
  #         "Capital Gain or Loss",
  #         "Pensions and Annuities Taxable Amount",
  #         "Farm Income or Loss",
  #         "Unemployment Compensation",
  #         "Other Income"
  #       ],
  #       :deductions => [
  #         "MAGI Deductions"
  #       ]
  #     }
  #   ]
  # }.freeze

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
    "01" => :self,
    "02" => :spouse,
    "03" => :parent,
    "04" => :child,
    "05" => :stepchild,
    "06" => :grandchild,
    "07" => :sibling,
    "08" => :domestic_partner,
    "12" => :stepparent,
    "13" => :uncle_aunt,
    "14" => :nephew_niece,
    "15" => :grandparent,
    "16" => :cousin,
    "17" => :parents_domestic_partner,
    "23" => :sibling_in_law,
    "26" => :child_in_law,
    "27" => :former_spouse,
    "30" => :parent_in_law,
    "88" => :other
  }.freeze

  RELATIONSHIP_INVERSE = {
    :self => :self,
    :spouse => :spouse,
    :parent => :child,
    :child => :parent,
    :stepchild => :stepparent,
    :grandchild => :grandparent,
    :sibling => :sibling,
    :domestic_partner => :domestic_partner,
    :stepparent => :stepchild,
    :uncle_aunt => :nephew_niece,
    :nephew_niece => :uncle_aunt,
    :grandparent => :grandchild,
    :cousin => :cousin,
    :parents_domestic_partner => :other,
    :sibling_in_law => :sibling_in_law,
    :child_in_law => :parent_in_law,
    :former_spouse => :former_spouse,
    :parent_in_law => :child_in_law,
    :other => :other
  }
end
