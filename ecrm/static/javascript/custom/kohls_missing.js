function addPO(){
	$("#addDiv").fadeIn();
}

function hiddenAddDiv(){
	$("#addDiv form")[0].reset();
	$("#addDiv").fadeOut();
}

function saveChange(){
	var po_no = $("#addDiv input[@name='po_no']").val();
	var so_no = $("#addDiv input[@name='so_no']").val();
    var po_remark = $("#addDiv input[@name='remark']").val();

    if(po_no == "" || so_no == "" || po_remark == ""){
    	alert("[Warning] Please fill in the PO#,PO_Remark or the PO Date before you save!");
    	return false;
    }


	$.post(
		"/kohlspo/addPO",
		{"po_no":po_no,"po_remark":po_remark,"so_no":so_no},
		function(data){
			if(data=="OK"){
				$.prompt("[OK] The PO has been updated successfully!",{opacity: 0.6,prefix:'cleanblue',show:'slideDown',callback:mycallbackfunc});
				//$("#so_text").html(po_no);
			}else{
				$.prompt("[Error] Error occur on the server side!",{opacity: 0.6,prefix:'cleanred',show:'slideDown'});
				//alert("ERROr");
			
			}

			hiddenAddDiv();
			
			//$.getJSON("kohlspo/missing",update_page); 
		}
	);
}
function mycallbackfunc(){
	location.reload();	
}
function update_page(){
	alert("update_page");
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