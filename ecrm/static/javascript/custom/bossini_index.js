function showAddDiv(){
	$("#addDiv").fadeIn();
}

function hiddenAddDiv(){
	$("#addDiv form")[0].reset();
	$("#addDiv").fadeOut();
}


function saveChange(){
	var _factory_date = $("#hidden_x_factory_date").val();
	var _recepipt_date = $("#hidden_receipt_date").val();
	if($(".recordForm tbody :checked").length<1){
		alert("Please select at least one record to export!");
		return false;
	}else{
		
		var ids = new Array();
		$(".recordForm tbody :checked").each(function(){
			ids.push($(this).val());
			id = $(this).val();
			if(_factory_date != ""){
			$($("span[attrxfd='" + id + "']")[0]).text(_factory_date);
			}
			if(_recepipt_date != ""){
			$($("span[attrred='" + id + "']")[0]).text(_recepipt_date);
			}
		});
		$.post(
			"/bossinipo/updateDate",
			{"x_f_date":_factory_date,"r_date":_recepipt_date,"ids":ids},
			function(data){
			    if(data=="OK"){
			        $.prompt("[OK] The PO has been updated successfully!",{opacity: 0.6,prefix:'cleanblue',show:'slideDown'});
				
			    }
			    else{
				$.prompt("[Error] Error occur on the server side!",{opacity: 0.6,prefix:'cleanred',show:'slideDown'});			    
			    }
			    hiddenAddDiv();
			}
		);
	}

}


function toSearch(){
	$(".tableform").submit();
}
$(document).ready(function(){
          //Date Picker
        $('.datePicker').datepicker({ firstDay: 1 , dateFormat: 'yy-mm-dd' });
});


function exportBatch(){
	$("#header_ids").remove();

	if($(".recordForm tbody :checked").length<1){
		alert("Please select at least one record to export!");
		return false
	}else{
		var ids = new Array();
		$(".recordForm tbody :checked").each(function(){
			ids.push($(this).val());
		});
		var f = $(".recordForm");
		f.append("<input type='hidden' id='header_ids' name='header_ids' value='"+ ids.join("|") +"'/>");
		f.attr("action","/bossinipo/exportBatch");
		f.submit();
		
		//$(".recordForm").append("<input type='hidden' id='header_ids' name='header_ids' value='"+ ids.join("|") +"'/>").submit();
		
	}
	
	return false;
}

function toProduct(){
	$("#header_ids").remove();

	if($(".recordForm tbody :checked").length<1){
		alert("Please select at least one record to export!");
		return false
	}else{
		var ids = new Array();
		$(".recordForm tbody :checked").each(function(){
			ids.push($(this).val());
		});
		
		var f = $(".recordForm");
		f.append("<input type='hidden' id='header_ids' name='header_ids' value='"+ ids.join("|") +"'/>");
		f.attr("action","/bossinipo/generatePF");
		f.submit();
		
		//$(".recordForm").append("<input type='hidden' id='header_ids' name='header_ids' value='"+ ids.join("|") +"'/>").submit();
		
	}
	
	return false;
}
