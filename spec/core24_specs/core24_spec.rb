require 'spec_helper'
	

RSpec.describe "Test cases for all Core 24 Json files" do

def get_response(file)
jsonfile = File.open(file).read
json_response = Application.new(jsonfile, 'application/json')
@json_response = JSON.parse(json_response.to_json) 
puts "The number of applicants in #{file} file: #{@json_response['Applicants'].count}" + "\n"
puts "Json Input: #{JSON.pretty_generate(JSON.parse(jsonfile))}"
return @json_response
end

shared_examples_for "Core 24 tests" do

		it "Compares FPL" do
		@json_response["Applicants"].each_with_index do |applicant, index|
		puts "Expected result for applicant:#{index+1} => #{@person[index]}"
		expect(applicant['Medicaid Household']['MAGI as Percentage of FPL']).to eq @person[index][:FPL]
		end
		end

		it "Compares Medicaid Eligibilty " do
		@json_response["Applicants"].each_with_index do |applicant, index|
		expect(applicant['Medicaid Eligible']).to eq @person[index][:MedicaidEligible]
		end
		end

		it "Compares MAGI" do
		@json_response["Applicants"].each_with_index do |applicant, index|
		expect(applicant['Medicaid Household']['MAGI']).to eq @person[index][:MAGI]
		end
		end

		it "Compares APTC Referal" do
		@json_response["Applicants"].each_with_index do |applicant, index|
		expect(applicant['Determinations']['APTC Referral']['Indicator']).to eq @person[index][:APTCReferal]
		end
		end
	

		it "Compares EmergencyMedicaid Eligibility" do
		@json_response["Applicants"].each_with_index do |applicant, index|
		if @person[index].key?(:EmergencyMedicaid)
		expect(applicant['Determinations']['Emergency Medicaid']['Indicator']).to eq @person[index][:EmergencyMedicaid]
		end
		end
		end

end

describe "test_QACORE1UA012" do

before(:all) do
@json_response = get_response('spec/core24_json_files/QA-CORE-1-UA-012.json')
@person = []
@person << { FPL: 84, MAGI: 10000, MedicaidEligible: 'N', APTCReferal: 'Y'}
end

it_behaves_like "Core 24 tests"
end


describe "test_QACORE8MAGIIAUA004_married_filing_separately_big_household" do
	before(:all) do
	@json_response = get_response('spec/core24_json_files/QA-CORE-8-MAGI_IA_UA-004.json')
	@person = []
		@person << {FPL: 240, MAGI: 88348, MedicaidEligible: 'N', APTCReferal: 'Y'}
		@person << {FPL: 407, MAGI: 81939, MedicaidEligible: 'N', APTCReferal: 'Y'}
		@person << {FPL: 407, MAGI: 81939, MedicaidEligible: 'N', APTCReferal: 'Y'}
		@person << {FPL: 240, MAGI: 88348, MedicaidEligible: 'N', APTCReferal: 'Y'}
		@person << {FPL: 0, MAGI: 0, MedicaidEligible: 'Y', APTCReferal: 'N'}
		@person << {FPL: 0, MAGI: 0, MedicaidEligible: 'Y', APTCReferal: 'N'}
		@person << {FPL: 0, MAGI: 0, MedicaidEligible: 'N', APTCReferal: 'Y'}
		@person << {FPL: 0, MAGI: 0, MedicaidEligible: 'Y', APTCReferal: 'N'}
	end

	it_behaves_like "Core 24 tests"
end

describe "test_QACORE6MAGINONMAGI008" do
	before(:all) do
	@json_response = get_response('spec/core24_json_files/QA-CORE-6-MAGI_NONMAGI-008.json')
	@person = []
		@person	<< { FPL: 176,  MAGI: 57546,  MedicaidEligible: 'Y', APTCReferal: 'N'}
		@person << { FPL: 176,  MAGI: 57546,  MedicaidEligible: 'Y', APTCReferal: 'N'}
		@person << { FPL: 176,  MAGI: 57546,  MedicaidEligible: 'Y', APTCReferal: 'N'}
		@person << { FPL: 176,  MAGI: 57546,  MedicaidEligible: 'Y', APTCReferal: 'N'}
		@person << { FPL: 0,    MAGI: 0,      MedicaidEligible: 'Y', APTCReferal: 'N'}
		@person << { FPL: 51,   MAGI: 6100,   MedicaidEligible: 'Y', APTCReferal: 'N'}
	end

	it_behaves_like "Core 24 tests"
end

describe "test_APTC1IA50" do
	before(:all) do
	@json_response = get_response('spec/core24_json_files/APTC-1-IA-50.json')
	@person = []
	@person << { FPL: 229, MAGI: 27000, MedicaidEligible: 'N', APTCReferal: 'Y'}
	end

	it_behaves_like "Core 24 tests"
end

describe "test_APTC2IAUA6067WEEKLY" do
	before(:all) do
	@json_response = get_response('spec/core24_json_files/APTC-2-IA-UA-60-67-WEEKLY.json')
	@person = []
		@person << { FPL: 282, MAGI: 44979, MedicaidEligible: 'N', APTCReferal: 'Y'}
		@person	<< { FPL: 282, MAGI: 44979, MedicaidEligible: 'N', APTCReferal: 'Y'}
	end

	it_behaves_like "Core 24 tests"
end

describe "test_APTC3IAMed404516BIWEEKLY_6000_dependent_child_cutoff" do
	before(:all) do
	@json_response = get_response('spec/core24_json_files/APTC-3-IA-Med-40-45-16-BIWEEKLY.json')
	@person = []
		@person << { FPL: 282, MAGI: 56728, MedicaidEligible: 'N', APTCReferal: 'Y'}
		@person << { FPL: 282, MAGI: 56728, MedicaidEligible: 'N', APTCReferal: 'Y'}
		@person << { FPL: 282, MAGI: 56728, MedicaidEligible: 'Y', APTCReferal: 'N'}
	end

	it_behaves_like "Core 24 tests"
end

describe "test_APTC3IAMedicaid455022" do
	before(:all) do
	@json_response = get_response('spec/core24_json_files/APTC-3-IA-Medicaid-45-50-22.json')
	@person = []
		@person << { FPL: 320, MAGI: 64448, MedicaidEligible: 'N', APTCReferal: 'Y'}
		@person << { FPL: 320, MAGI: 64448, MedicaidEligible: 'N', APTCReferal: 'Y'}
		@person << { FPL: 320, MAGI: 64448, MedicaidEligible: 'N', APTCReferal: 'Y'}
	end

	it_behaves_like "Core 24 tests"
end

describe "test_APTC3IAMedicaid554515BIWEEKLY_6000_dependent_child_cutoff_2" do
	before(:all) do
	@json_response = get_response('spec/core24_json_files/APTC-3-IA-Medicaid-55-45-15-BIWEEKLY.json')
	@person = []
		@person << {FPL: 356, MAGI: 71714, MedicaidEligible: 'N', APTCReferal: 'Y'}
		@person << {FPL: 356, MAGI: 71714, MedicaidEligible: 'N', APTCReferal: 'Y'}
		@person << {FPL: 356, MAGI: 71714, MedicaidEligible: 'N', APTCReferal: 'Y'}
	end

	it_behaves_like "Core 24 tests"
end


describe "test_QACORE2IA008" do
	before(:all) do
	@json_response = get_response('spec/core24_json_files/QA-CORE-2-IA-008.json')
	@person = []
		@person << { FPL: 222, MAGI: 35495, MedicaidEligible: 'N', APTCReferal: 'Y'}
	end

	it_behaves_like "Core 24 tests"
end

describe "test_QACORE2IA009" do
	before(:all) do
	@json_response = get_response('spec/core24_json_files/QA-CORE-2-IA-009.json')
	@person = []
		@person << { FPL: 222, MAGI: 35496, MedicaidEligible: 'N', APTCReferal: 'Y' }
		@person << { FPL: 222, MAGI: 35496, MedicaidEligible: 'N', APTCReferal: 'Y' }
	end

	it_behaves_like "Core 24 tests"
end

describe "test_QACORE2MAGI010_refugee_should_waive_5_year_bar" do
	before(:all) do
	@json_response = get_response('spec/core24_json_files/QA-CORE-2-MAGI-010.json')
	@person = []
		@person << { FPL: 75, MAGI: 12000, MedicaidEligible: 'Y', APTCReferal: 'N', EmergencyMedicaid: 'N' }
		@person << { FPL: 75, MAGI: 12000, MedicaidEligible: 'Y', APTCReferal: 'N', EmergencyMedicaid: 'N' }
	end

	it_behaves_like "Core 24 tests"
end

describe "test_QACORE2MAGI010_except_not_a_refugee_5_year_bar_applies" do
	before(:all) do
	@json_response = get_response('spec/core24_json_files/QA-CORE-2-MAGI-010-nonrefugee.json')
	@person = []
		@person << { FPL: 75, MAGI: 12000, MedicaidEligible: 'N', APTCReferal: 'Y', EmergencyMedicaid: 'Y' }
		@person << { FPL: 75, MAGI: 12000, MedicaidEligible: 'N', APTCReferal: 'Y', EmergencyMedicaid: 'Y' }
	end

	it_behaves_like "Core 24 tests"
end


describe "test_QACORE2MAGI011" do
	before(:all) do
	@json_response = get_response('spec/core24_json_files/QA-CORE-2-MAGI-011.json')
	@person = []
		@person << { FPL: 62, MAGI: 10000, MedicaidEligible: 'Y', APTCReferal: 'N', EmergencyMedicaid: 'N' }
	end

	it_behaves_like "Core 24 tests"
end

describe "test_QACORE2MAGI029" do
	before(:all) do
	@json_response = get_response('spec/core24_json_files/QA-CORE-2-MAGI-029.json')
	@person = []
		@person << { FPL: 63, MAGI: 10141, MedicaidEligible: 'Y', APTCReferal: 'N', EmergencyMedicaid: 'N' }
	end

	it_behaves_like "Core 24 tests"
end

describe "test_QACORE2MAGI030" do
	before(:all) do
	@json_response = get_response('spec/core24_json_files/QA-CORE-2-MAGI-030.json')
	@person = []
		@person << { FPL: 86, MAGI: 10154, MedicaidEligible: 'Y', APTCReferal: 'N', EmergencyMedicaid: 'N'}
		@person << { FPL: 25, MAGI: 3046, MedicaidEligible: 'Y', APTCReferal: 'N', EmergencyMedicaid: 'N'}
	end

	it_behaves_like "Core 24 tests"
end


describe "test_QACORE2MAGIUA011" do
	before(:all) do
	@json_response = get_response('spec/core24_json_files/QA-CORE-2-MAGI-UA-011.json')
	@person = []
		@person << { FPL: 125, MAGI: 20000, MedicaidEligible: 'N', APTCReferal: 'Y'}
		@person << { FPL: 125, MAGI: 20000, MedicaidEligible: 'N', APTCReferal: 'Y'}
	end

	it_behaves_like "Core 24 tests"
end

describe "test_QACORE3IA010" do
	before(:all) do
	@json_response = get_response('spec/core24_json_files/QA-CORE-3-IA-010.json')
	@person = []
		@person << { FPL: 277, MAGI: 55732, MedicaidEligible: 'N', APTCReferal: 'Y'}
		@person << { FPL: 277, MAGI: 55732, MedicaidEligible: 'N', APTCReferal: 'Y'}
		@person << { FPL: 277, MAGI: 55732, MedicaidEligible: 'N', APTCReferal: 'Y'}
	end

	it_behaves_like "Core 24 tests"
end


describe "test_QACORE3MAGI020" do
	before(:all) do
	@json_response = get_response('spec/core24_json_files/QA-CORE-3-MAGI-020.json')
	@person = []
		@person << { FPL: 201, MAGI: 40540, MedicaidEligible: 'Y', APTCReferal: 'N'}
		@person << { FPL: 201, MAGI: 40540, MedicaidEligible: 'Y', APTCReferal: 'N'}
		@person << { FPL: 201, MAGI: 40540, MedicaidEligible: 'N', APTCReferal: 'Y'}
	end

	it_behaves_like "Core 24 tests"
end


describe "test_QACORE3MAGI021_unborn_child_calculation" do
	before(:all) do
	@json_response = get_response('spec/core24_json_files/QA-CORE-3-MAGI-021.json')
	@person = []
		@person << { FPL: 187, MAGI: 45552, MedicaidEligible: 'Y', APTCReferal:'N'}
		@person << { FPL: 187, MAGI: 45552, MedicaidEligible: 'Y', APTCReferal:'N'}
		@person << { FPL: 187, MAGI: 45552, MedicaidEligible: 'Y', APTCReferal:'N'}
	end

	it_behaves_like "Core 24 tests"
end

describe "test_QACORE3MAGI022_refugee_should_waive_5_year_bar" do
	before(:all) do
	@json_response = get_response('spec/core24_json_files/QA-CORE-3-MAGI-022.json')
	@person = []
		@person << { FPL: 84, MAGI: 16900, MedicaidEligible: 'Y', APTCReferal: 'N', EmergencyMedicaid: 'N'}
		@person << { FPL: 84, MAGI: 16900, MedicaidEligible: 'Y', APTCReferal: 'N', EmergencyMedicaid: 'N'}
		@person << { FPL: 84, MAGI: 16900, MedicaidEligible: 'Y', APTCReferal: 'N', EmergencyMedicaid: 'N'}
	end

	it_behaves_like "Core 24 tests"
end

describe "test_QACORE3MAGIIA013" do
	before(:all) do
	@json_response = get_response('spec/core24_json_files/QA-CORE-3-MAGI_IA-013.json')
	@person = []
		@person << { FPL: 353, MAGI: 70931, MedicaidEligible: 'N', APTCReferal: 'Y'}
		@person << { FPL: 353, MAGI: 70931, MedicaidEligible: 'N', APTCReferal: 'Y'}
		@person << { FPL: 62, MAGI: 10000, MedicaidEligible: 'Y', APTCReferal: 'N'}
	end

	it_behaves_like "Core 24 tests"
end


describe "test_QACORE3MAGIUA008" do
	before(:all) do
	@json_response = get_response('spec/core24_json_files/QA-CORE-3-MAGI_UA-008.json')
	@person = []
		@person << { FPL: 252, MAGI: 50662, MedicaidEligible: 'N', APTCReferal: 'Y'}
		@person << { FPL: 252, MAGI: 50662, MedicaidEligible: 'Y', APTCReferal: 'N'}
		@person << { FPL: 252, MAGI: 50662, MedicaidEligible: 'Y', APTCReferal: 'N'}
	end

	it_behaves_like "Core 24 tests"
end


describe "test_QACORE4MAGI06" do
	before(:all) do
	@json_response = get_response('spec/core24_json_files/QA-CORE-4-MAGI-06.json')
	@person = []
		@person << { FPL: 318, MAGI: 50713, MedicaidEligible: 'N', APTCReferal: 'Y'}
		@person << { FPL: 254, MAGI: 40567, MedicaidEligible: 'N', APTCReferal: 'Y'}
		@person << { FPL: 254, MAGI: 40567, MedicaidEligible: 'Y', APTCReferal: 'N'}
		@person << { FPL: 318, MAGI: 50713, MedicaidEligible: 'Y', APTCReferal: 'N'}
	end

	it_behaves_like "Core 24 tests"
end


describe "test_QACORE4MAGIIA007_noncustodial_mom" do
	before(:all) do
	@json_response = get_response('spec/core24_json_files/QA-CORE-4-MAGI_IA-007.json')
	@person = []
		@person << { FPL: 431, MAGI: 50787, MedicaidEligible: 'N', APTCReferal: 'Y'}
		@person << { FPL: 0, MAGI: 0, MedicaidEligible: 'Y', APTCReferal: 'N'}
		@person << { FPL: 0, MAGI: 0, MedicaidEligible: 'Y', APTCReferal: 'N'}
	end

	it_behaves_like "Core 24 tests"
end


describe "test_QACORE4MAGIUA009_married_but_separated_one_kid_moved_out" do
	before(:all) do
	@json_response = get_response('spec/core24_json_files/QA-CORE-4-MAGI_UA-009.json')
	@person = []
		@person << { FPL: 318, MAGI: 50713, MedicaidEligible: 'N', APTCReferal: 'Y'}
		@person << { FPL: 159, MAGI: 25355, MedicaidEligible: 'Y', APTCReferal: 'N'}
		@person << { FPL: 212, MAGI: 25000, MedicaidEligible: 'N', APTCReferal: 'Y'}
		@person << { FPL: 161, MAGI: 25713, MedicaidEligible: 'Y', APTCReferal: 'N'}
	end

	it_behaves_like "Core 24 tests"
end


describe "test_QACORE4UA001_married_filing_separately_one_kid_out_of_house" do
	before(:all) do
	@json_response = get_response('spec/core24_json_files/QA-CORE-4-UA-001.json')
	@person = []
		@person << { FPL: 429, MAGI: 86200, MedicaidEligible: 'N', APTCReferal: 'Y'}
		@person << { FPL: 429, MAGI: 86200, MedicaidEligible: 'N', APTCReferal: 'Y'}
		@person << { FPL: 0, MAGI: 0, MedicaidEligible: 'Y', APTCReferal: 'N'}
		@person << { FPL: 429, MAGI: 86200, MedicaidEligible: 'N', APTCReferal: 'Y'}
	end

	it_behaves_like "Core 24 tests"
end

describe "test_QACORE5MAGIIA010" do
	before(:all) do
	@json_response = get_response('spec/core24_json_files/QA-CORE-5-MAGI_IA-010.json')
	@person = []
		@person << { FPL: 318, MAGI: 50708, MedicaidEligible: 'N', APTCReferal: 'Y'}
		@person << { FPL: 126, MAGI: 25333, MedicaidEligible: 'Y', APTCReferal: 'N'}
		@person << { FPL: 126, MAGI: 25333, MedicaidEligible: 'Y', APTCReferal: 'N'}
		@person << { FPL: 318, MAGI: 50708, MedicaidEligible: 'Y', APTCReferal: 'N'}
		@person << { FPL: 267, MAGI: 76041, MedicaidEligible: 'Y', APTCReferal: 'N'}
	end

	it_behaves_like "Core 24 tests"
end

end
	