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
      :name       => "Applicant Attest Blind or Disabled",
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
      :group      => :person,
      :xpath      => :unimplemented
    },
    {
      :name       => "Hours Worked Per Week",
      :type       => :integer,
      :group      => :person,
      :xpath      => :unimplemented,
      :required   => true
    },
    {
      :name       => "Incarceration Status",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :applicant,
      :xpath      => :unimplemented
    },
    {
      :name       => "Lives In State",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :person,
      :xpath      => :unimplemented,
      :required   => true
    },
    {
      :name       => "Medicare Entitlement Indicator",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :applicant,
      :xpath      => "hix-ee:MedicaidNonMAGIEligibility/hix-ee:MedicaidNonMAGIMedicareEntitlementEligibilityBasis/hix-core:StatusIndicator"
    },
    {
      :name       => "No Fixed Address",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :applicant,
      :xpath      => :unimplemented
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
      :name       => "Receives SSI",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :applicant,
      :xpath      => :unimplemented,
      :default    => "N"
    },
    {
      :name       => "Required to File Taxes",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :person,
      :xpath      => :unimplemented,
      :required   => true
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
    {
      :name       => "Temporarily Out of State",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :applicant,
      :xpath      => :unimplemented
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
      :name       => "Number of Children Expected",
      :type       => :integer,
      :values     => (1..10),
      :group      => :person,
      :xpath      => :unimplemented,
      :required_if => "Applicant Pregnant Indicator",
      :required_if_value => "Y"
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
      :name       => "Amerasian Immigrant",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :applicant,
      :required_if => "Immigration Status",
      :required_if_value => "01"
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
      :name       => "Immigration Status",
      :type       => :string,
      :values     => %w(01 02 03 04 05 06 07 08 09 10 99),
      :group      => :applicant
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
    },

    #Native Inputs
    {
      :name       => "Native American or Alaska Native",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :applicant,
      :xpath      => :unimplemented,
      :default    => "N"
    },

    #Other MEC Input
    {
      :name       => "Other MEC Offer",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :applicant,
      :xpath      => :unimplemented,
      :default    => "N"
    },

    #APTC Repayment Inputs
    {
      :name       => "Previous APTC",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :applicant,
      :xpath      => :unimplemented,
      :default    => "N"
    },

     {
      :name       => "Repaid APTC",
      :type       => :flag,
      :values     => %w(Y N),
      :group      => :applicant,
      :xpath      => :unimplemented,
      :default    => "N"
    }    

  ].freeze

  DETERMINATIONS = [
    {name: "Adult Group Category", eligibility: :MAGI},
    {name: "Parent Caretaker Category", eligibility: :MAGI},
    {name: "Pregnancy Category", eligibility: :MAGI},
    {name: "Child Category", eligibility: :MAGI},
    {name: "Optional Targeted Low Income Child", eligibility: :MAGI},
    {name: "CHIP Targeted Low Income Child", eligibility: :CHIP},
    {name: "Unborn Child"},

    {name: "Income Medicaid Eligible", eligibility: :MAGI},
    {name: "Income CHIP Eligible", eligibility: :CHIP},
    
    {name: "Medicaid CHIPRA 214"},
    {name: "CHIP CHIPRA 214"},
    {name: "Trafficking Victim"},
    {name: "Seven Year Limit"},
    {name: "Five Year Bar"},
    {name: "Title II Work Quarters Met"},
    {name: "Medicaid Citizen Or Immigrant"},
    {name: "CHIP Citizen Or Immigrant"},
    
    {name: "Former Foster Care Category"},
    {name: "Work Quarters Override Income"},
    {name: "State Health Benefits CHIP"},
    {name: "CHIP Waiting Period Satisfied"},
    {name: "Dependent Child Covered"},

    {
      name: "Medicaid Non-MAGI Referral",
      eligibility: :MedicaidNonMAGI,
      indicator_xpath: "hix-ee:MedicaidNonMAGIEligibility/hix-ee:EligibilityIndicator",
      date_xpath: "hix-ee:MedicaidNonMAGIEligibility/hix-ee:EligibilityDetermination/nc:ActivityDate/nc:DateTime",
      reason_xpath: "hix-ee:MedicaidNonMAGIEligibility/hix-ee:EligibilityReasonText"
    },
    
    #{name: "APTC"},
    #{name: "CSR"},
    {name: "Emergency Medicaid"},
    {name: "Refugee Medical Assistance"}
  ].freeze

  INCOME_INPUTS = {
    :tax_return => {
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
        "Social Security Benefits Taxable Amount",
        "Lump Sum Payments",
        "Educational Scholarships, Fellowship Grants, and Awards",
        "AIAN Income"
      ]
    },
    :personal => {
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
  }.freeze

  CHILD_OUTPUTS = [
    {name: "Child of Caretaker Dependent Age", type: :determination},
    {name: "Child of Caretaker Deprived Child", type: :determination},
    {name: "Child of Caretaker Relationship", type: :determination}
  ].freeze

  OUTPUTS = [
    {
      :name   => "Category Used to Calculate Medicaid Income",
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
    "07" => :sibling, # Could also be stepsibling
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
    "70" => :domestic_partners_child,
    "87" => :other_relative,
    "88" => :other
  }.freeze

  IMMIGRATION_STATUS_CODES = {
    "01" => "Lawful Permanent Resident (LPR/Green Card Holder)",
    "02" => "Asylee",
    "03" => "Refugee",
    "04" => "Cuban/Haitian entrant",
    "05" => "Paroled into the U.S. for at least one year",
    "06" => "Conditional entrant granted before 1980",
    "07" => "Battered non-citizen, spouse, child, or parent",
    "08" => "Victim of trafficking or his or her spouse, child, sibling, or parent or individual with a pending application for a victim of trafficking visa",
    "09" => "Granted withholding of deportation",
    "10" => "Member of a federally recognized Indian tribe or American Indian born in Canada",
    "99" => "Other"
  }

  CONFIGURATION_CODES = {
    "Count Unborn Children for Household" => {
      "01" => "Do not count unborn children",
      "02" => "Add one child for each pregnant applicant",
      "03" => "Add the number of children expected to household size"
    }
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
    :parents_domestic_partner => :domestic_partners_child,
    :sibling_in_law => :sibling_in_law,
    :child_in_law => :parent_in_law,
    :former_spouse => :former_spouse,
    :parent_in_law => :child_in_law,
    :domestic_partners_child => :parents_domestic_partner,
    :other_relative => :other_relative,
    :other => :other
  }

  SECONDARY_RELATIONSHIPS = {
    :spouse => {
      :spouse => [:self],
      :parent => [:parent_in_law],
      :child => [:child, :stepchild],
      :stepchild => [:child],
      :sibling => [:sibling_in_law],
      :nephew_niece => [:nephew_niece]
    },
    :parent => {
      :spouse => [:parent, :stepparent],
      :parent => [:grandparent],
      :child => [:self, :sibling],
      :stepchild => [:sibling],
      :sibling => [:uncle_aunt],
      :domestic_partner => [:parent, :parents_domestic_partner]
    },
    :child => {
      :spouse => [:child_in_law],
      :child => [:grandchild]
    },
    :stepchild => {
      :parent => [:spouse]
    },
    :stepparent => {
      :spouse => [:parent],
      :child => [:sibling],
      :stepchild => [:self, :sibling]
    },
    :uncle_aunt => {
      :spouse => [:uncle_aunt]
    },
    :parents_domestic_partner => {
      :domestic_partner => [:parent]
    },
    :child_in_law => {
      :spouse => [:child]
    }
  }
end
