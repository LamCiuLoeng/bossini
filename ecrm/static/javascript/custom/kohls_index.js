function productExportBatch(){
	var f = $(".recordForm");
	f.attr("action","/kohlspo/productExportBatch");
	f.submit();
}

function toSearch(){
	$(".tableform").submit();
}

function resetForm(){
	$(".tableform")[0].reset();
}

function exportBatch(){
	if($(".recordForm :checked").val()== undefined){
		alert("Please select at least one record to export!");
	}else{
		$(".recordForm").submit();
	}
}

function span2input(span_id,spanso_id){
	if(spanso_id == null){
		if($("#recordsArea tbody input[@id='"+span_id+"']").length ==0){
			var span2 = $("#"+span_id);
			span2.replaceWith("<input type='text' name='"+ span_id +"' id='"+ span_id +"' value='"+ span2.text() +"' ref='"+span2.text()+"'/>");
		}
	} else{

		if($("#recordsArea tbody input[@id='"+spanso_id+"']").length ==0){
			var span2 = $("#"+spanso_id);
			span2.replaceWith("<input type='text' name='"+ spanso_id +"' id='"+ spanso_id +"' value='"+ span2.text() +"' ref='"+span2.text()+"'/>");
		}
		if($("#recordsArea tbody input[@id='"+span_id+"']").length ==0){
			var span = $("#"+span_id);
			span.replaceWith("<input type='text' name='"+ span_id +"' id='"+ span_id +"' value='"+ span.text() +"' ref='"+span.text()+"'/>");
		}
}
}

function input2span(input_id,flag){
	var input = $("#recordsArea tbody input[@id='"+input_id+"']");
	if(input.length !=0){
		if(flag){
			input.replaceWith("<span id='"+input.attr("id")+"'>"+input.val()+"</span>");
		}else{
			input.replaceWith("<span id='"+input.attr("id")+"'>"+input.attr("ref")+"</span>");
		}
	}
}


var editStatus = false;
function addSO(){
	var checked = $("#recordsArea tbody :checked")
	if(checked.length==0){
		alert("Please select at least one record to add SO NO.");
		return
	}
	$("#recordsArea input[@type='checkbox']").attr("disabled","disabled");
	checked.each(function(){
		span2input( "span_"+$(this).val(),"spanso_"+$(this).val());
	});
	editStatus = true;
}

// add by ray on 05-13-2009



function addStatus(){
	var checked = $("#recordsArea tbody :checked")
	if(checked.length==0){
		alert("Please select at least one record to add PO Status.");
		return
	}
	$("#recordsArea input[@type='checkbox']").attr("disabled","disabled");
	checked.each(function(){
		span2input( "status_"+$(this).val(),null);
	});
	editStatus = true;

}
function toSave(){
	//test for ray
	$(":checked").each(function(){
		var id = $(this).val();
		var value = $("#span_" + id).val();
		var value_so = $("#spanso_" + id).val();
		var status = $("#status_" + id).val();
		//if(status=='') alert("xxxxxxxxx");
	});
	////////////////////////////////////////////////////////////////////////////////////////
	//url flag:1 or 999 or 0

	if(!editStatus){
		return ;
	}else{
		editStatus = false;
	}
	var params = {};
	var statusflag = false;
	var flag = false;
	$("#recordsArea tbody input[@type='text']").each(function(){
		var tmp = $(this);
		if(tmp.val() != tmp.attr("ref")){
			if(tmp.attr("name").substr(0,6) == "status"){statusflag = true;}
			params[tmp.attr("name")] = tmp.val();
			flag = true;
		}
	});

	//If nothing change, don't submit to back-end,just return .
	if(!flag){
		alert("No record change!");
		$("#recordsArea tbody input[@type='text']").each(function(){
			input2span( $(this).attr("id"),false );
		});
		$("#recordsArea input[@type='checkbox']").removeAttr("disabled");
		return;
	}

	$.getJSON(
		"/kohlspo/addBatchSO",
		params,
		function(data){
			if(data["flag"]=="OK"){
				$("#recordsArea tbody input[@type='text']").each(function(){
					input2span( $(this).attr("id"),true );
				});
			}else{
				$.prompt(data["message"],{opacity: 0.6,prefix:'cleanred',show:'slideDown'});
				$("#recordsArea tbody input[@type='text']").each(function(){
					input2span( $(this).attr("id"),false );
				});
			}
			$("#recordsArea input[@type='checkbox']").removeAttr("disabled");
		}
	);

}

function toCancel(){
	if(!editStatus){
		return ;
	}else{
		editStatus = false;
	}

	$("#recordsArea tbody input[@type='text']").each(function(){
		input2span( $(this).attr("id"),false );
	});
	$("#recordsArea input[@type='checkbox']").removeAttr("disabled");
	return;
}

function toReplace(){

}

function NotoReplace(){

}


$(document).ready(function(){
          //Date Picker
        $('.datePicker').datepicker({ firstDay: 1 , dateFormat: 'yy-mm-dd' });
});