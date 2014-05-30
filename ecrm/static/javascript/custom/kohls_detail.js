function toProductExport(){
	var f = $("#showDiv form");
	f.attr("action","/kohlspo/productExport");
	f.submit();
}

function toExport(){
	$("#showDiv form").submit();
}

function showAddDiv(){
	$("#addDiv").fadeIn();
}

function hiddenAddDiv(){
	$("#addDiv form")[0].reset();
	$("#addDiv").fadeOut();
}

function toDelete(){
	if(confirm('Are you sure to delete the PO?')){
		var f = $("#showDiv form");
		f.attr("action","/kohlspo/deletePO");
		f.submit();
	}
}

function saveChange(){
	var so_no = $("#addDiv input[@name='so_no']").val();
    var so_date = $("#addDiv input[@name='so_date']").val();
    var so_remark = $("#addDiv input[@name='so_remark']").val();
    var header_id = $("#addDiv input[@name='header_id']").val();

    if(so_no == "" || so_date == "" || so_remark == ""){
    	alert("[Warning] Please fill in the SO#,SO_Remark or the SO Date before you save!");
    	return false;
    }


	$.post(
		"/kohlspo/addSO",
		{"so_no":so_no,"so_date":so_date,"header_id":header_id,"so_remark":so_remark},
		function(data){
			if(data=="OK"){
				$.prompt("[OK] The PO has been updated successfully!",{opacity: 0.6,prefix:'cleanblue',show:'slideDown'});
				$("#so_text").html(so_no);
			}else{
				$.prompt("[Error] Error occur on the server side!",{opacity: 0.6,prefix:'cleanred',show:'slideDown'});
				//alert("ERROr");
			}

			hiddenAddDiv();
		}
	);
}

function specialClick(){

}

$(document).ready(function(){
          //Date Picker
        $('.datePicker').datepicker({ firstDay: 1 , dateFormat: 'yy-mm-dd' });

		$("tbody :checkbox").bind("click",function(){
			if($(this).attr("checked")==true){
				$("tbody input[@styleno='"+ $(this).attr("styleno")+"']").attr("checked","checked");
			}else{
				$("tbody input[@styleno='"+ $(this).attr("styleno")+"']").removeAttr("checked");
			}
		});

		$("form").submit(function(){
			var podetail_ids = sln_ids = "";
			$("tbody :checked").each(function(){
				var tmp = $(this);
				if(tmp.attr("ref")=="PO1"){
					podetail_ids += tmp.val() + "|";
				}else if(tmp.attr("ref")=="SLN"){
					sln_ids += tmp.val() + "|";
				}
			});

			if( podetail_ids == "" && sln_ids == "" ){
				alert("Please select at least one record to generate the report!");
				return false;
			}

			$("#podetail_ids").val(podetail_ids);
			$("#sln_ids").val(sln_ids);
		});
});
