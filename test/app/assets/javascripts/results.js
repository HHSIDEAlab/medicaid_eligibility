var Results = {};

function refreshResults(json){
	var template = $("#household_template").html();
    	$("#results").html(_.template(template,{households: Results["Medicaid Households"]}));
    	$('.household .person .head').on("click",function(event){
    		var me = $(this);
    		me.parent().toggleClass("collapsed");
    	});
};
