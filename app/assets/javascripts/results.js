var Results = {};

function refreshResults(json){
	var template = $("#household_template").html();
    	$("#sidebar").html(_.template(template,{households: Results["Medicaid Households"]}));
    	$(".household table tr").on("click",showPerson);
};

function showPerson(event){
	var me = $(this);
	$(".household table tr").removeClass("selected");
	$(this).addClass("selected");
	var household_index = me.parents(".household").data("household-index");
	var applicant_index = me.data("applicant-index");
	var details = Results["Medicaid Households"][household_index]["Applicants"][applicant_index];
	details["MAGI"] = Results["Medicaid Households"][household_index]["MAGI"];
	var template = $("#person_template").html();
	$("#person").html(_.template(template,{person: details}));
};

$.getJSON("/test.json",function(results){
	Results = results;
	refreshResults();
});