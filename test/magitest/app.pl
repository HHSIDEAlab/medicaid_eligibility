#!/usr/bin/perl

#############################################################
## Welcome to my very sketchy test harness.  This is a quick 
## overview for whatever poor soul ends up in here.
##  
## Mathematica create a set of test cases and delivered them
## as a series of Excel Workbooks containing multiple sheets.
## Since they are testing a broader set of functionality, we 
## do not need all the inputs.  I have selectively chosen 
## worksheets with data we need and exported them to tab-
## delimited files, which can be placed in the same directory
## as this script, and be added to the "dataFiles" parameter.
## They will be slurped up, and we pull and index all the data
## on those sheets according to the applicant and the testcase.
##
## In the second part, we reconstruct the data we've indexed
## into our JSON format.
##
## In the third, we pass that JSON to the local version of the 
## medicaid eligiblity server, and then compare that result to
## their outcome, deciding if it's a pass or a fail.
## 
## The process will run over all testcases if given no parameters,
## or you can request a specific testcase (which will spit out
## much more detail.  If you also specifiy and applicant, a al:
##   ./app.pl TC20070 A1
## you'll get the full dump of the data we got from Mathematica
## for that applicant. 
##
## To make really effective use of the whole thing, you'll need
## the Mathmatica files and their models so you can debug the
## whole thing.  That broader knowledge I leave up to BlueLabs
## to capture.  I'm hoping this script is of transient usage.
##
use strict;
my $start_run = time(); # record the start time so we can see how long this takes

local $/ = "\r";  # The format I have has carriage returns instead of newlines

## PARAMETERS
my $dataFiles = [
    {
	'filename' => "./GA_apps.txt", 
	'garbageLines' => 2,
	'appIdCol' => 1,
	'format' => 0, 
    },
    {
	'filename' => "./GA_specialCircumstances.txt",
	'garbageLines' => 0,
	'appIdCol' => 0,
	'format' => 1, 
    },
    {
	'filename' => "./GA_listApplicants.txt",
	'garbageLines' => 0,
	'appIdCol' => 0,
	'format' => 1,
    },
    {
	'filename' => "./GA_currentHealthInsurance.txt",
	'garbageLines' => 0,
	'appIdCol' => 0,
	'format' => 1,
    },
    {
	'filename' => "./GA_contactInformation.txt",
	'garbageLines' => 0,
	'appIdCol' => 0,
	'format' => 1,
    },
    {
	'filename' => "./GA_currentIncomeInformation.txt",
	'garbageLines' => 0,
	'appIdCol' => 0,
	'format' => 1,
    },
    {
	'filename' => "./GA_filerPreferences.txt",
	'garbageLines' => 0,
	'appIdCol' => 0,
	'format' => 1,
    },
    {
	'filename' => "./GA_specialEnrollment.txt",
	'garbageLines' => 0,
	'appIdCol' => 0,
	'format' => 1,
    },
    {
	'filename' => "./GA_Outcomes.txt",
	'garbageLines' => 2,
	'appIdCol' => 1,
	'format' => 2,
    },
    {
	'filename' => "./GA_Payload_4.txt",
	'garbageLines' => 0,
	'appIdCol' => 0,
	'format' => 2,
    },
#    {
#	'filename' => "./View3.txt",
#	'garbageLines' => 0,
#	'appIdCol' => 0,
#	'format' => 2,
#    },
    {
	'filename' => "./View5.txt",
	'garbageLines' => 0,
	'appIdCol' => 0,
	'format' => 2,
    },
    {
	'filename' => "./View4.txt",
	'garbageLines' => 0,
	'appIdCol' => 0,
	'format' => 2,
    },
    {
	'filename' => "./GA_personalInformation.txt",
	'garbageLines' => 0,
	'appIdCol' => 0,
	'format' => 1,
    },
    {
	'filename' => "./Relationships.txt",
	'garbageLines' => 0,
	'appIdCol' => 0,
	'format' => 2,
    },
    {
	'filename' => "./GA_homeAddress.txt",
	'garbageLines' => 0,
	'appIdCol' => 0,
	'format' => 3, # broken down by physical household (in columns)
    },
    {
	'filename' => "./GA_incomeSummary.txt",
	'garbageLines' => 0,
	'appIdCol' => 0,
	'format' => 1, 
    },
    
];

my $taxFilename = "./GA_helpUsBYA.txt";

# These columns are mapped directly from their model to ours
my %columnMap = (  
    'Application ID' => 'Name',
    'Person ID' => 'Person ID', 
    'Age in Years' => 'Applicant Age',
    'Disability' =>"Applicant Attest Blind or Disabled",
    'Incarcerated Indicator (H3 Payload 4)'  => 'Incarceration Status', 

    'FullTimeStudent' => 'Student Indicator',

    'CurrentlyEnrolledInHealthInsurance' => 'Has Insurance',
    'AccessStateEmployeeCoverage' => 'State Health Benefits Through Public Employee',
    'Pregnant' => 'Applicant Pregnant Indicator',
    'FosterCare' => 'Former Foster Care',
    'US Citizen or US National' => 'US Citizen Indicator',
    'HoursPerWeek1' => 'Hours Worked Per Week',
    'WhichFosterCare' => 'Foster Care State',
    'HowOldWhenLeftFC' => 'Age Left Foster Care',
    'CoverageThroughStateMedicaidProgram' => 'Had Medicaid During Foster Care',
    'Five Year Bar Applies' => 'Five Year Bar Applies',
    'Attests to Eligible Immigration Status' => 'Immigrant Status',
    'Lawful Presence Indicator (VLP Payload 4)' => 'Lawful Presence Attested',
    'Number of Unborn' => 'Number of Children Expected',
    'NeedHelpWithLiving' => 'Applicant Attest Long Term Care',
    'LostHIin60Days' => 'Prior Insurance',
    'Lostdate' => 'Prior Insurance End Date',
    'Grant Date (DHS)' => 'Non-Citizen Status Grant Date',
    'NonCitEntryDate' => 'Non-Citizen Entry Date',
    'QualifiedNonCitizenCode' => 'Qualified Non-Citizen Status', # includes P in the test data.  Mapping that to Y
    'VeteranStatusImmigrant1' => 'Veteran Status',
    );

my %valueMap = (
    'false' => 'N',
    'No' => 'N',
    'Yes' => 'Y',
    'true' => 'Y',
    '' => 'N',
    'P' => 'Y',
);

# This is the orignal relationship list
my %relationshipLookup = (
    'self' => '01',
    'husband/wife' => '02',
    'parent' => '03',
    'son/daughter' => '04',
    'stepson/stepdaughter' => '05',
    'grandchild' => '06', 
    'great grandchild' => '06',
    'brother/sister' => '07',

    'stepparent' => '12',
    'aunt/uncle' => '13',
    'nephew/niece' => '14',
    'grandparent' => '15',
    'great grandparent' => '15',
    'first cousin' => '16',

    'brother-in-law/sister-in-law' => '23',

    'son-in-law/daughter-in-law' => '26',

    'mother-in-law/father-in-law' => '30',

    'other relative' => '88',
);

# Lowercase before you check this list

# my %relationshipComplementLookup = (
#     'self' => '01',
#     'husband/wife' => '02',
#     'parent' => '04',
#     'son/daughter' => '03',
#     'stepson/stepdaughter' => '12',
#     'grandchild' => '15', 
#     'great grandchild' => '15',
#     'brother/sister' => '07',

#     'stepparent' => '05',
#     'aunt/uncle' => '14',
#     'nephew/niece' => '13',
#     'grandparent' => '06',
#     'first cousin' => '16',

#     'brother-in-law/sister-in-law' => '23',

#     'son-in-law/daughter-in-law' => '30',

#     'mother-in-law/father-in-law' => '26',
# );

use Data::Dumper;
$Data::Dumper::Terse = 1;
use JSON;


# --------------- Inputs -------------------
my ($requestedAppId, $requestedApplicantId) = @ARGV;
my $printCases = 0;
if ($requestedAppId) {
    $printCases = 1;
    $requestedAppId = uc($requestedAppId);
    # forgot the "TC"
    if ($requestedAppId =~ /^\d+$/) {
	$requestedAppId = 'TC' . $requestedAppId;
    }
}

# --------------- Global data stores --------------------
# They're using different means of identifying people on different sheets, 
# I need to look up my Person Id by the person's given name in some cases
my %pidLookup;
my %pidLookupByPersonId;

# The list of people who are applying is stored as a collapsed field, so we get that info and apply it when looping over the applicants
# It's hashed by the app ID, and each entry is a has of the style and the name of the person that is the exception
my %whoIsApplying;

my %apps; # the master data structure
my %taxHHs; # master for tax households
my %physicalHhsByApp; # build the hash of households from the individual data
my %outcomes; # for each app and applicant, what the test data outcome is


# --------------- Functions -----------------------------------
## Print JSON for a specific application
sub jsonApp {
    my ($appId) = @_;
    $outcomes{ $appId } = {}; # create global storage of outcomes for this app

    my $json = {}; # anonymous hash
    my $stateColumn = 'State in which Applying for Benefits';
    $$json{'State'} = $apps{$appId}{'A1'}{$stateColumn};
    $$json{'Name'} = $appId;
    $$json{'People'} = [];

    # This will show you all available data
    #print Dumper $apps{ $appId };

    foreach my $applicantId (keys(%{$apps{ $appId }})) {
	# For debugging output
	if ($requestedApplicantId eq $applicantId) {
	    print Dumper $apps{ $appId }{ $applicantId };
	}

	my %person; # One person on the application

	# Some fields need a default, set at beginning
	$person{'Hours Worked Per Week'} = 0;

	# Loop through the standard mapping and apply the values from their data directly to ours
	foreach my $inputKey (keys(%columnMap)) {
	    if (exists($apps{$appId}{$applicantId}{$inputKey})) {
		my $value = $apps{$appId}{$applicantId}{$inputKey};
		if (exists($valueMap{$value})) {
		    $value = $valueMap{$value};
		}
		$person{$columnMap{$inputKey}} = $value;
	    }
	}
	# special cases

	# Medicare Entitlement Indicator
	$person{'Medicare Entitlement Indicator'} = 'N'; # assumption
	if (exists($apps{ $appId }{ $applicantId }{'MECSeed_MECVerificationIndicator'})) {
	    my $medicaidResidency = $apps{ $appId }{ $applicantId }{'MECSeed_MECVerificationIndicator'};
	    if (($medicaidResidency eq 'Y') ||  ($medicaidResidency eq 'P')) {
		# You need to use “P” or “Y” in the MECSeed_MECVerficationIndicator to determine whether this person has non-ESI
		# coverage. Also, to make sure that you are only using it with Medicare (and not Tricare, VHA, Peace Corps, etc…),
		# you need it use the MECVerificationINdicator in conjunction with
		# CurrentHealthIsuranceAPTC__OthStateFedHealthCoverage and
		# CurrentHealthInsuranceMedicaidC__HealthInsuranceFromOtherSources (column CQ and CR) in the aggregate View 5.
		if ($apps{ $appId }{ $applicantId }{ 'CurrentHealthInsuranceMedicaidC__HealthInsuranceFromOtherSources' } eq 'Medicare') {
		    $person{'Medicare Entitlement Indicator'} = 'Y';
		}
	    }
	}	    

	# Applicant Post Partum Period Indicator
	if (exists($apps{ $appId }{ $applicantId }{'Age in Days for Children Under 1 Year Old'})
	    && ($apps{ $appId }{ $applicantId }{'Age in Days for Children Under 1 Year Old'} <= 60)) {
	    $person{'Applicant Post Partum Period Indicator'} = 'Y';
	} else {
	    $person{'Applicant Post Partum Period Indicator'} = 'N';
	}	    

	# Applicant Has 40 Title II Work Quarters
	if (exists($apps{ $appId }{ $applicantId }{'Lifetime Quarters of Coverage Quantity'})
	    && ($apps{ $appId }{ $applicantId }{'Lifetime Quarters of Coverage Quantity'} >= 40)) {
	    $person{'Applicant Has 40 Title II Work Quarters'} = 'Y';
	} else {
	    $person{'Applicant Has 40 Title II Work Quarters'} = 'N';
	}	    

	# Medicaid Residency Indicator
	$person{'Medicaid Residency Indicator'} = 'N';
	if (exists($apps{ $appId }{ $applicantId }{'Medicaid Residency is Granted'})) {
	    my $medicaidResidency = $apps{ $appId }{ $applicantId }{'Medicaid Residency is Granted'};
	    if (($medicaidResidency eq 'Yes') ||  ($medicaidResidency eq 'Pending')) {
		$person{'Medicaid Residency Indicator'} = 'Y';
	    }
	}	    

	# Five Year Bar Met
	# Data in payload verifications payload 4 AT
	if (exists($apps{ $appId }{ $applicantId }{'FiveYearBarMetCode'})) {
	    my $fiveYearMet = $apps{ $appId }{ $applicantId }{'FiveYearBarMetCode'};
	    if (($fiveYearMet eq 'Y') ||  ($fiveYearMet eq 'P')) {
		$person{'Five Year Bar Met'} = 'Y';
	    } elsif ($fiveYearMet eq 'N') {
		$person{'Five Year Bar Met'} = 'N';
	    }
	}	    
	
	# Is Applicant
	# look up by the first and last name only
	if ($whoIsApplying{ $appId }{'style'} eq 'all') {
	    $person{'Is Applicant'} = 'Y';
	} else {
	    my $shortName = $apps{ $appId }{ $applicantId }{'FirstName'} . ' ' . $apps{ $appId }{ $applicantId }{'LastName'};
	    if ((
		  ($whoIsApplying{ $appId }{'style'} eq 'onlyPerson')
		  && ($whoIsApplying{ $appId }{'exception'} eq $shortName)
		) || (
		  ($whoIsApplying{ $appId }{'style'} eq 'excludePerson')
		  && ($whoIsApplying{ $appId }{'exception'} ne $shortName)
		)) {
		$person{'Is Applicant'} = 'Y';
	    } else {
		$person{'Is Applicant'} = 'N';
	    }
	}

	# Non-Citizen Deport Withheld Date: Thrown out

	# Relationships
	my $relationships = [];
	my $whichRelation = 'Relation to Contact Person';
	my $relCount = 1;
#	print "$applicantId ---------\n";
	REL: while ($relCount <= 12) {
	    if (!exists($apps{ $appId }{ $applicantId }{ $whichRelation})) {
		last REL; # looks like we went off the end
	    }
	    my $relCode = $apps{ $appId }{ $applicantId }{ $whichRelation };

	    if (($relCode !~ /n\/a/) && (lc($relCode) !~ /self/)) {

#		print "a$relCount: $relCode\n";
		if (!exists($relationshipLookup{ lc($relCode) })) {
		    print "Unknown relationship '$relCode'\n";
		    die;
		}
		my $relationship = {};
		$$relationship{'Other ID'} = 'A' . $relCount;
		$$relationship{'Relationship Code'} = $relationshipLookup{ lc($relCode) };
	    
		push(@$relationships, $relationship);
	    }
	    $relCount++;
	    $whichRelation = 'Relation to Psn ' . $relCount;
	}

	$person{'Relationships'} = $relationships;


	if ($apps{ $appId }{ $applicantId }{'EligStatementTxt'} eq 'Lawful Permanent Resident - Employment Authorized') {
	    $person{'Legal Permanent Resident'} = 'Y';
	} else {
	    $person{'Legal Permanent Resident'} = 'N';
	}

	# -------------- BELOW HERE NOT DONE ------------------
	# INCOME!
	my $income = {};
	#'IRS Income (H9 Payload 4)': '48277.5',
#	$$income{'Monthly Income'} = $apps{ $appId }{ $applicantId }{ 'IRS Income (H9 Payload 4)' }/12;
	$$income{'Wages, Salaries, Tips'} = $apps{ $appId }{ $applicantId }{ 'TotalYearlyIncome' };
#         "Wages, Salaries, Tips": 0,
#         "Taxable Interest": 0,
#         "Tax-Exempt Interest": 0,
#         "Taxable Refunds, Credits, or Offsets of State and Local Income Taxes": 0,
#         "Alimony": 0,
#         "Capital Gain or Loss": 0,
#         "Pensions and Annuities Taxable Amount": 0,
#         "Farm Income or Loss": 0,
#         "Unemployment Compensation": 0,
#         "Other Income": 0,
#         "MAGI Deductions": 0
	$person{'Income'} = $income;

	# Victim of Trafficking: Still coming

	# Lives In State
	# this one will be a pain in the ass  
	if ($apps{ $appId }{ $applicantId }{'State in which Applying for Benefits'} eq $apps{ $appId }{ $applicantId }{'State of Residence'}) {
	    $person{'Lives In State'} = 'Y';
	} else {
	    $person{'Lives In State'} = 'N';
	}

	# Claimed as Dependent by Person Not on Application  
        # helpUsBYA CF No = Claimed as Dependent b  THHx+NFx_familyInfo
	# trying to figure out who NF1 is, question into Bridget

	# Required to File Taxes
	# Mathematica is actually calculating this, they passed over the model
	$person{'Required to File Taxes'} = 'Y';
	

	# Refugee Medical Assistance Start Date: Model 2.8
	# Refugee Status
	# Seven Year Limit Applies: Model 1.3
	# Seven Year Limit Start Date: 

	# Attest Primary Responsibility: HelpUsBYA BV (plus CD)
	$person{'Attest Primary Responsibility'} = 'N';
        #  Question: you pointed out that this would be on HelpUsBYA in the "ChildCare" column for each tax
        # household, combined with the "ChildRelationship" column.  Would this be set to "Y" for cases where the
        # "ChildRelationship" column is "Parent", or only for the cases where it's not "Parent"? 
	#   Answer: Depending on the state-specific
        # option for what relationships states allow for the parent/caretaker relative group, the grandparent could be a valid
        # relationship. There are four different definitions for these valid relationships, a.  Permissible core relatives or
        # relationships include: (1) Parent, (2) Stepparent (unless dead or absent from home), (3) Grandparent, (4) Sibling, (5)
        # Stepsibling, (6) Uncles, (7) Aunts, (8) First cousin, (9) Nephew, or (10) Niece. Note: These relationships include the
        # spouse of each relative listed even after the marriage is terminated by death or divorce.  b.  (In addition to option a)
        # All relatives of the child based on blood (including those of half-blood), adoption or marriage, c.  (In addition to
        # option a) The domestic partner of a parent or other relative who is included on the list of core relatives d.  Any adult
        # with whom the child is living and who assumes primary responsibility for the child’s care. This includes unrelated as
        # well as related individuals.
	    
	# ------------------------------------------------------
	
	# I'd like to inclue the PersonID, but to do so I'd need to build a lookup of the person ID keyed off the Application ID and the Applicant ID (A\d)
	$person{'Person ID'} = $applicantId;

	# Save the outcomes for comparison
	$outcomes{ $appId }{ $applicantId } = $apps{ $appId }{ $applicantId }{'FFM Screen Outcome'};
	
	push(@{$$json{'People'}}, {%person});
    }

    # walk through the households building filers
    my $taxReturns = [];
    # there are some applications with no tax return
    # We can check that by seeing if the first household has no primary name
    if ($taxHHs{ $appId }[ 0 ] { 'PrimaryFirstName' } ne '') {
	foreach my $Hh (@{$taxHHs{ $appId }}) {
	    my $taxHh = {};
	    my $filers = [];
	    my $dependents = [];

	    #loop
	    my $filer = {};
	    my $primaryFilerName = $appId . $$Hh{'PrimaryFirstName'} . $$Hh{'PrimaryMiddleName'} . $$Hh{'PrimaryLastName'} . $$Hh{'PrimarySuffix'};
	    $primaryFilerName = lc($primaryFilerName);
	    if (!exists($pidLookup{$primaryFilerName})) {
#	    print Dumper $apps{ $appId };
		die "Primary $primaryFilerName not found in lookup\n";
	    }
	    my $primaryFilerId = $pidLookup{$primaryFilerName};
	    $$filer{'Person ID'} = $primaryFilerId;
	    push(@$filers, $filer);

	    if ($$Hh{'JointReturn'} eq 'Yes') {
		my $coFiler = {};
		my $coFilerName = $appId . $$Hh{'SpouseFirstName'} . $$Hh{'SpouseMiddleName'} . $$Hh{'SpouseLastName'} . $$Hh{'SpouseSuffix'};
		$coFilerName = lc($coFilerName);
		if (!exists($pidLookup{$coFilerName})) {
		    print Dumper $apps{ $appId };
		    die "Cofiler $coFilerName not found in lookup\n";
		}
		my $coFilerId = $pidLookup{$coFilerName};
		$$coFiler{'Person ID'} = $coFilerId;
		push(@$filers, $coFiler);
	    }

	    # there are up to 7 dependents in the data
	    for my $d (1 .. 7) {
		if (exists($$Hh{ "D$d" . "_FirstName" })) {
		    my $dependent = {};
		    my $depName = $appId . $$Hh{"D$d" . "_FirstName"} . $$Hh{"D$d" . "_MiddleName"} . $$Hh{"D$d" . "_LastName"} . $$Hh{"D$d" . "_Suffix"};
		    $depName = lc($depName);
		    if (!exists($pidLookup{$depName})) {
			print Dumper $apps{ $appId };
			die "Dependent $depName not found in lookup\n";
		    }
		    my $depId = $pidLookup{$depName};
		    $$dependent{'Person ID'} = $depId;
		    push(@$dependents, $dependent);
		}
	    }

	    $$taxHh{'Filers'} = $filers;
	    $$taxHh{'Dependents'} = $dependents;

	    push(@$taxReturns, $taxHh);
	}
    }
    $$json{'Tax Returns'} = $taxReturns;


    # Physical households
    # @$physicalHhs is a list of lists of personIDs.  It's not indexed by appID since we build it while building the json data
    my $appPhysicalHhs = [];
    my $HhCount = 0;
    if ($physicalHhsByApp{ $appId }{ 'One Household' }) {
	# loop through the list of people and put them all in the same house
	my $appPhysicalHh = {};	
	my $peopleInHouse = [];
	foreach my $applicant (@{$$json{'People'}}) {
	    my $appPersonInHouse = {};
	    $$appPersonInHouse{'Person ID'} = $$applicant{'Person ID'};
	    push(@$peopleInHouse, $appPersonInHouse);
	}
	$$appPhysicalHh{'People'} = $peopleInHouse;
	$$appPhysicalHh{'Household ID'} = 'Household1';
	push(@$appPhysicalHhs, $appPhysicalHh);

    } else {
	foreach my $physicalHhId (keys(%{$physicalHhsByApp{ $appId }})) {
	    $HhCount++;
	    my $appPhysicalHh = {};
	    my $peopleInHouse = [];
	    foreach my $personInHouse (@{$physicalHhsByApp{ $appId }{ $physicalHhId }}) {
		my $appPersonInHouse = {};
		$$appPersonInHouse{'Person ID'} = $personInHouse;
		push(@$peopleInHouse, $appPersonInHouse);
	    }
	    $$appPhysicalHh{'People'} = $peopleInHouse;
	    $$appPhysicalHh{'Household ID'} = 'Household' . $HhCount;
	    push(@$appPhysicalHhs, $appPhysicalHh);
	}
    }
    $$json{'Physical Households'} = $appPhysicalHhs;
	
    my $out = to_json($json, { 'pretty' => 1 });
    return $out;
}


## Parse the file with tax info
sub parseTaxFile {
    open(FH, $taxFilename) or die $!;
    my $header;
    chomp($header = <FH>);
    my @columnNames;
    @columnNames = split("\t", $header);

    my @line;
    while(<FH>) {
	chomp;
	@line = split("\t");

	my $appId = $line[0];

	# index columns by the header
	my $lineHash = {};
	for my $j (0 .. $#columnNames) {
	    $$lineHash{$columnNames[$j]} = $line[$j];
	}
	
	if ( !exists($taxHHs{ $appId }) ) {
	    $taxHHs{ $appId } = []; # each application is a list of Households
	} 

	# walk through the columns and break out the tax households
	foreach my $key (keys(%$lineHash)) {
	    my $HH = {};
	    if ($$lineHash{$key} eq '') { next };
	    my $newKey;
	    my $HhId;
	    if ($key =~ /THH(\d+)\_(.+)/) {
		$HhId = $1 - 1;
		$newKey = $2;
	    } else {
		$HhId = '0';
		$newKey = $key
	    }
	    if (!exists($taxHHs{ $appId }[ $HhId ])) {
		$taxHHs{ $appId }[ $HhId ] = {};
	    }
	    $taxHHs{ $appId }[ $HhId ]{ $newKey } = $$lineHash{ $key };
	}
	if ($appId eq 'TC10010') {
	#    print Dumper $taxHHs{ 'TC10010' };
	}
    }
}


## Parse a mathematica file
sub parseFile {
    my ($rdatafile) = @_;
    my %dataFile = %$rdatafile;
    
    open(FH, $dataFile{'filename'}) or die $!;

    # Jump over junk at the front of the file
    #Clumsy.  Perl doesn't have a good function for this.
    for (my $i = 1; $i <= $dataFile{'garbageLines'}; $i++) {
	<FH>; 
    }

    my $header; 
    chomp($header = <FH>);
    my @columnNames;
    @columnNames = split("\t", $header);

    ## Pass through and index all the applications
    my @line;
    my $appIdCol = $dataFile{'appIdCol'};
    while(<FH>) {
	chomp;
	@line = split("\t");
	# convert the line to a hash using the column headers
	my $lineHash = {};
	for my $j (0 .. $#columnNames) {
	    $$lineHash{$columnNames[$j]} = $line[$j];
	}

	# get the application ID
	$line[$appIdCol] =~ /([^\-]+)\-*/; #Strip the state ID from the ID
	my $id = $1;
	
	if ( !exists($apps{ $id }) ) {
	    $apps{ $id } = {}; # each application is a hash of applicants
	} 

	if ($id eq $requestedAppId) {
#	    print Dumper $lineHash;
	}

	# drop empty fields
	foreach my $key (@columnNames) {
	    if ($$lineHash{$key} =~ /^\s*$/) {
		delete $$lineHash{$key};
	    }
	}
	
	# get the applicant ID
	my $userId;
	# This format has multiple lines per applicant.
	if ($dataFile{'format'} == 0) {
	    # 1 is the applicant
	    # 2 is the spouse (and may not exist)
	    # 3 is A1, 4 is A2, etc.
	    $userId = 'A' . $$lineHash{'App Role #'};

	    #currently relying on the fact this one runs first, otherwise need to check for exist
	    $apps{ $id }{ $userId } = $lineHash;
	    
	    # build a lookup by personID
	    my $personId = $$lineHash{'Person ID'};
	    if (!exists($pidLookupByPersonId{ $personId })) {
		$pidLookupByPersonId{ $personId } = $userId;
	    }

        # this is another style, where I have to look up the userId based on the personId
	} elsif ($dataFile{'format'} == 2) {
	    # more lovely inconsistencies
	    my $personId;
	    if (exists($$lineHash{'Person ID'})) {
		$personId = $$lineHash{'Person ID'};
	    } else {
		$personId = $$lineHash{'PersonID'};
	    }
	    $userId = $pidLookupByPersonId{ $personId };
	    if ($userId eq '') {
		print "Person ID '$personId' could not be resolved" && die;
	    }

	    if ( !exists($apps{ $id }{ $userId }) ) {
		$apps{ $id }{ $userId } = $lineHash;
	    } else {
		foreach my $attrId (keys(%$lineHash)) {
		    $apps{ $id }{ $userId }{ $attrId } = $$lineHash{ $attrId };
		}
	    }

	# columned by physical household
	} elsif ($dataFile{'format'} == 3) {
	    $physicalHhsByApp{ $id } = {};
	    if ($$lineHash{'Doeseveryoneyoulistedliveatthisaddress?'} eq 'Yes') {
		$physicalHhsByApp{ $id }{ 'One Household' } = 1;
		# we loop through all the applicants later
	    } else {
		# Loop through "WhoLiveAtThisAddress<#>"
		my $basicIndex = 'WhoLiveAtThisAddress';
		my $index = $basicIndex;
		my $hhId = 1;
		while (exists($$lineHash{ $index })) {
		    my $houseList = $$lineHash{ $index };
		    if ($houseList =~ /^\"(.*)\"$/) {
			$houseList = $1;
		    }
		    my @oneHouse = split(/\s*,\s*/, $houseList);
		    foreach my $houseMember (@oneHouse) {
			$houseMember =~ s/\s//g; #strip spaces
			my $houseMemberId = $id . $houseMember;
			$houseMemberId = lc($houseMemberId);
			if (!exists($pidLookup{$houseMemberId})) {
			    #print Dumper $apps{ $appId };
			    die "Household member $houseMember ($houseMemberId) not found in lookup\n";
			}
			my $personId = $pidLookup{$houseMemberId};
			if (!exists($physicalHhsByApp{ $id }{ $hhId })) {
			    $physicalHhsByApp{ $id }{ $hhId } = []; # add a new list to store a list of person IDs
			}
			push(@{$physicalHhsByApp{ $id }{ $hhId }}, $personId);
		    }
		    $index = $basicIndex . $hhId;
		    $hhId++; # get ready for the next row.  This is indentionally off 1
		}
	    }

	# This format has people in columns based on the applicant number
	} else { 
	    #convert the line hash into a hash of hashes
	    my $peopleHash = {};
	    my $applyingFor;
	    foreach my $key (keys(%$lineHash)) {
		if ($$lineHash{$key} =~ /^\s*$/) { next };
		my $newKey;
		if ($key =~ /A(\d+)\_(.+)/) {
		    $userId = $1 + 2;
		    $userId = 'A' . $userId;
		    $newKey = $2;
		} elsif ($key =~ /Spouse_(.+)/) {
		    $userId = 'A2';
		    $newKey = $1;
		} else {
		    $userId = 'A1';
		    $newKey = $key
		}

                # A bit dirty, this one.  There are three kinds of applications:
		#  1. everyone is an applicant save one (excludePerson)
		#  2. everyone is an applicant 
		#  3. one person is an applicant
		# We'll grab it and apply it later, when we loop through all the applicants
		if ($key eq 'Areyouinterestedinobtaininghealthinsurancefor') {
		    my $whoApplies = {};
		    if ($$lineHash{ $key } =~ /, not (.+)"/) {
			$$whoApplies{'style'} = 'excludePerson';
			$$whoApplies{'exception'} = $1;
		    } elsif ($$lineHash{ $key } !~ /other family/) {
			$$whoApplies{'style'} = 'onlyPerson';
			$$whoApplies{'exception'} = $$lineHash{ $key };
		    } else {
			$$whoApplies{'style'} = 'all';
		    }
		    $whoIsApplying{ $id } = $whoApplies;
		}

		my $i = 0; # for key collision
		my $startingKey = $newKey;
		while (exists($$peopleHash{ $userId }{ $newKey })) {
		    $i++;
		    $newKey = $startingKey . $i;
		}
		
		$$peopleHash{ $userId }{ $newKey } = $$lineHash{ $key };
	    }
	    
	    ## Create indexes for finding the right people
	    foreach my $peopleKey (keys(%$peopleHash)) {
		my $fullName = $id . $$peopleHash{ $peopleKey}{ 'FirstName' } . $$peopleHash{ $peopleKey}{ 'MiddleName' } . $$peopleHash{ $peopleKey}{ 'LastName' } . $$peopleHash{ $peopleKey}{ 'Suffix' };
		$fullName = lc($fullName); # Let's lowercase this so it's more likely to match
		if ($fullName ne lc($id)) {
		    if (!exists($pidLookup{ $fullName })) {
			$pidLookup{ $fullName } = $peopleKey;
		    }
		}
	    }

	    # now you've broken the line up, collate it into the existing structure
	    foreach $userId (keys(%$peopleHash)) {
		if ( !exists($apps{ $id }{ $userId }) ) {
		    $apps{ $id }{ $userId } = $$peopleHash{ $userId };
		} else {
		    foreach my $attrId (keys(%{$$peopleHash{ $userId }})) {
			$apps{ $id }{ $userId }{ $attrId } = $$peopleHash{ $userId } { $attrId };
		    }
		}
	    }
	}
    }
}


## MAIN
foreach my $dataFile (@$dataFiles) {
    &parseFile($dataFile);
}
&parseTaxFile();

use LWP::UserAgent;
my $lwp = LWP::UserAgent->new();
my $url = 'http://localhost:3000/determinations/eval';

my @requestedApps;
if ($requestedAppId ne '') {
    @requestedApps = ($requestedAppId);
    
} else {
    # Known broken, skip
    my @skip = (
	'TC20054', # missing pregnancy eligibility
	);
    foreach my $skip (@skip) {
	delete($apps{$skip});
    }
    @requestedApps = keys(%apps);
}

my $limitCount;
my $total;
my %totalErrors; # by type
my $totalErrors;
my %totalDisagreements; # by type
my $totalDisagreements;
my $totalCaretakerError; # a case I'm tracking at the moment
my $totalAgreements;
foreach my $appId (@requestedApps) {
    my $agree = 1; # assume we'll be correct, if we get a disagreement, fail the whole application
    $total++;

    my $payload = &jsonApp($appId);
    if ($requestedAppId ne '') {
	print $payload;
    }

    my $req = HTTP::Request->new( 'POST', $url );
    $req->header('Accept' => 'application/json');
    $req->header( 'Content-Type' => 'application/json' );
    $req->content( $payload );
    my $response = $lwp->request( $req );
    my $content = $response->decoded_content;
    #print "$content\n";

    if ($printCases) {
	print $appId . ": \n";
    }

    my $ourResult;
    eval {
	$ourResult = from_json($content);
	1;
    } or do {
	my $e = $@; # $e = Ruby error
	my $error;
	if ($content =~ /<pre>(.+)<\/pre>/) {
	    $error = $1;
	} else {
	    $error = "Couldn't parse out error";
	}

	if ($printCases) {
	    print $error . "\n";
	}
	# simplify
	if ($error =~ /inconsistent relationship/i) {
	    $error = 'Inconsistent relationship';
	}
	print "$appId: $error\n";
	if ($printCases) {
           print $content;
	   exit; # pipe into an HTML file
	}
	$totalErrors++;
	$totalErrors{$error}++;
	next;
    };
    #print Dumper $ourResult;

    # index ours by applicant
    my %ourDeterminations;
    foreach my $ourApplicant (@{$$ourResult{'Applicants'}}) {
	$ourDeterminations{ $$ourApplicant{'Person ID'} } = $ourApplicant;
    }

    if ($requestedAppId) {
	print Dumper $ourResult;
	print "\n";
    }
    
    # outs values: Ineligible, Ineligible for RMA, 'Not eligible for QHP based on Medicaid and CHIP eligibility'
    # determinations, theirs => ours
    my %dets = ( 
#	    'Eligible for Immediate Referral to Medicaid' => 
# 	    'Eligible for Medicaid Adult Title XX Group',
# 	    'Eligible for Medicaid Adult Title XIX Group',
	'Eligible for Medicaid Pregnant Women Group' => 'Pregnancy Category',
	'Eligible for Parent Caretaker Relative Group' => 'Parent Caretaker Category',
	'Eligible for Medicaid Child Group' => 'Child Category',
	'Eligible for Medicaid Option Targeted Low Income Child Group' => 'Optional Targeted Low Income Child',
# 	    'Eligible for CHIP Pregnant Women Group',
	'Eligible for Unborn Group' => 'Unborn Child',
	'Eligible for CHIP Targeted Low Income Child Group' => 'CHIP Targeted Low Income Child',
	'Eligible for Refugee Medical Assistance' => 'Refugee Medical Assistance',
# 	    'Eligible for QHP and Subsidies',
    );
    my $failType; # when an app fails, pick the last reason it failed for
    my $caretakerError = 0; # A case I'm tracking until we get an answer

    foreach my $applicantId (keys(%{$outcomes{ $appId }})) {
	# let's make this more readable 
	my $tO = $outcomes{ $appId }{ $applicantId };
	my $oC = $ourDeterminations{ $applicantId }{ 'CHIP Eligible' };
	my $oM = $ourDeterminations{ $applicantId }{ 'Medicaid Eligible' };
	my $oNM = $ourDeterminations{ $applicantId }{ 'Non-MAGI Referral' };
	my $pf = 'pass';  # Start with this assumption

	# In any case where they've flagged an inconsistency, we skip comparing, since we'll go with the attested data, and they with the 
	# payloads from the external sources
	if (($apps{ $appId }{ $applicantId }{ 'SSA Inconsistencies Outcome' } =~ /triggered/)
	    || ($apps{ $appId }{ $applicantId }{ 'Citizenship, Immigration, and Lawful Presence Inconsistencies Outcome' } =~ /triggered/)
	    || ($apps{ $appId }{ $applicantId }{ 'SSN-Related Inconsistencies Outcome' } =~ /triggered/)
	    || ($apps{ $appId }{ $applicantId }{ 'Income Inconsistencies Outcome' } =~ /triggered/)
	    || ($apps{ $appId }{ $applicantId }{ 'Non-ESI MEC inconsistencies Outcome' } =~ /triggered/)
	    || ($apps{ $appId }{ $applicantId }{ 'ESI MEC Inconsistencies Outcome' } =~ /triggered/)
	    || (($apps{ $appId }{ $applicantId }{ 'Disability' } eq 'Yes')
		&& ($apps{ $appId }{ $applicantId }{ 'PAYLOAD3_H3_ PERSONDISABLEDINDICATOR' } eq 'false') # sometimes they don't mark the inconsistency  
               )
	    || (($apps{ $appId }{ $applicantId }{ 'Disability' } eq 'No')
		&& ($apps{ $appId }{ $applicantId }{ 'PAYLOAD3_H3_ PERSONDISABLEDINDICATOR' } eq 'true') # sometimes they don't mark the inconsistency  
               )
	   ) {
	    if ($printCases) {
		print "n/a  $applicantId: Mathematica inconsistency flag triggered.  Skipping\n";
	    }
	    next;
	}

	# They have 5 outcomes
	if ($tO eq 'Eligible for Medicaid') {
	    # they may give the medicaid yes determination for the non-magi referral case
	    # But only when the person is older than 64 or is disabled
	    #print "age: " . $apps{ $appId }{ $applicantId }{ 'Age in Years' } . "\n";
	    #print "abd: " . $apps{ $appId }{ $applicantId }{ 'Disability' } . "\n";
	    #print "LTSS: " . $apps{ $appId }{ $applicantId }{ 'NeedHelpWithLiving' } . "\n";
	    if (($oM eq 'N') && ($oNM eq 'N')) {
		$pf = 'FAIL';
		$failType = "Math Med Y\tBL N";
	    } elsif (($oM eq 'N') && ($oNM eq 'Y') 
		     && ($apps{ $appId }{ $applicantId }{ 'Age in Years' } < 65)
		     && ($apps{ $appId }{ $applicantId }{ 'Disability' } eq 'No')
		     && ($apps{ $appId }{ $applicantId }{ 'NeedHelpWithLiving' } eq 'No')
		) {
		$pf = 'FAIL';
		$failType = "Math Med Y\tBL N";
	    }		
	} elsif ($tO eq 'Eligible for CHIP') {
	    if (($oM eq 'Y') || ($oC eq 'N')) {
		$pf = 'FAIL';
		$failType = "Math CHIP Y\tBL N";
	    }
	} elsif (($tO eq 'Eligible for QHP without Subsidy')
		 || ($tO eq 'Eligible for QHP with Subsidy')) {
	    if (($oM eq 'Y') || ($oC eq 'Y')) {
		$pf = 'FAIL';
		$failType = "Math Med/CHIP N\tBL Y";
	    }
	} elsif ($tO eq 'Not seeking health insurance coverage') {
	    # In that case, I figure our output doesn't matter
	} elsif ($tO eq 'Ineligible for QHP') {
	    # Seems odd, but as long as we don't say yes for Medicaid or Chip, I figure we're good
	    if (($oM eq 'Y') || ($oC eq 'Y')) {
		$pf = 'FAIL';
		$failType = "Totally ineligible, we say yes";
	    }
	} else {
	    die "Unknown Mathematica determination: $tO\n";
	}
	
	if ($printCases) {
	    print "$pf $applicantId Mathematica:  $tO\n";
	    print "          Blue Labs:  Medicaid $oM\n";
	    print "                      CHIP     $oC\n";
	    print "                      Non-MAGI $oNM\n";
 	}

	# Go through the category determinations
	foreach my $tDet (keys(%dets)) {
	    my $groupMatch = 'pass'; # assume
	    my $oEligString = $ourDeterminations{ $applicantId }{ 'Determinations' }{ $dets{ $tDet} }{ 'Indicator' };
	    my $tEligString = $apps{ $appId }{ $applicantId }{ $tDet };
	    # We say yes, they say no
	    if (($tEligString =~ /Ineligible/) && ($oEligString eq 'Y')) {
		$groupMatch = 'FAIL';
	    }
	    # We say no, they say yes
	    if (($tEligString =~ /Eligible/) && (($oEligString eq 'N') || ($oEligString eq 'X'))) {
		$groupMatch = 'FAIL';
	    }
	    
	    if ($printCases) {
		print "  $groupMatch  $dets{$tDet}: $oEligString\t";
		print "  $tDet: $tEligString\n";
	    }
	}

	# track this specific case
	# FAIL  Parent Caretaker Category: Y	  Eligible for Parent Caretaker Relative Group: Ineligible
	if (($ourDeterminations{ $applicantId }{ 'Determinations' }{ 'Parent Caretaker Category' }{ 'Indicator' } eq 'Y')
	    && ($apps{ $appId }{ $applicantId }{ 'Eligible for Parent Caretaker Relative Group'} =~ 'Ineligible')
	    ) {
	    $caretakerError = 1;
	}

        # These are our determinations that I didn't have an obvious mapping for
#	      "Adult Group Category": {
# 	      "Income Medicaid Eligible": {
# 	      "Income CHIP Eligible": {
# 	      "CHIPRA 214": {
# 	      "Trafficking Victim": {
# 	      "Seven Year Limit": {
# 	      "Five Year Bar": {
# 	      "Title II Work Quarters Met": {
# 	      "Medicaid Citizen Or Immigrant": {
# 	      "Former Foster Care Category": {
# 	      "Work Quarters Override Income": {
# 	      "State Health Benefits CHIP": {
# 	      "CHIP Waiting Period Satisfied": {
# 	      "Dependent Child Covered": {
# 	      "Medicaid Non-MAGI Referral": {
# 	      "Emergency Medicaid": {
# 	      "APTC Referral": {


	# if any case fails, fail the whole app
	if ($pf eq 'FAIL') {
	    $agree = 0;
	}
    }

    if ($agree) {
	$totalAgreements++;
    } else {
	print "$appId: $failType\n";
	$totalCaretakerError++;
	$totalDisagreements++;
	$totalDisagreements{$failType}++;
    } 
}

print "$total testcases\n";
print "$totalAgreements agreements\n";
print "$totalErrors errors\n";
foreach my $error (sort { $totalErrors{$b} <=> $totalErrors{$a} } keys %totalErrors) {
    print "  $totalErrors{$error}\t$error\n";
}
print "$totalDisagreements disagreements\n";
foreach my $disagreement (sort { $totalDisagreements{$b} <=> $totalDisagreements{$a} } keys %totalDisagreements) {
    print "  $totalDisagreements{$disagreement}\t$disagreement\n";
}
print "$totalCaretakerError Error with parent/caretaker group\n";

my $end_run = time();
my $run_time = $end_run - $start_run;
print "Job took $run_time seconds\n";
