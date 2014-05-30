function showNewForm(){
	$($(".input_class").parent()).fadeIn("slow");
}

function resetForm(){
	$(".input_class").val("");
}

function cancelForm(){
	resetForm();
	$($(".input_class").parent()).fadeOut("slow");
}


function getVIItemDetail(id){
	$.getJSON(
		"/finar/getVIItemDetail",
		{"id":id},
		function(data){
			if(data['result']=='ERROR'){
				alert('ERROR');
			}else{		
				var ut = $("#updateVIDiv tbody");
				ut.empty();
				$.each(data['result'],function(i,d){
					ut.append("<tr><td>"+d['item_code']
					+"</td><td>"+d['issue_qty']+"</td><td>"+d['issue_amount']+"</td><td><a href='"+d['id']+"'>Update</a></td></tr>")					
				});
				$("#updateVIDiv").slideDown();
			}
		}
	);
	return false;
}


  $(document).ready(function(){
          //Date Picker
        $('.datePicker').datepicker({ firstDay: 1 , dateFormat: 'yy-mm-dd' });
		
		$($(".input_class").parent()).hide();
		
		$("a.update_class").each(function(){
			var ref = $(this).attr('ref');
			$(this).attr('onclick','return getVIItemDetail('+ref+');');
		});
		
        
        var submitForm = $("form[@name='addForm']");
        
        
        submitForm.submit(function(){
        	alert("begin");
        	params = {
        		'vi_no':$("#vi_no").val(),
        		'issue_date':$("#issue_date").val(),
        	}
        	
        	$("form[@name='addForm'] .gridTable .input_class").each(function(i,el){
        		var amt = $(el);               		
        		params[amt.attr('name')] = amt.val() + "|" +amt.attr("ref")
        	});
        	
        	$.post(
				"/finar/saveNewVI",
				params,
				function(data){
					if(data=="OK"){
						alert("OK");
						cancelForm();
					}else{
						alert("Error");
					}
				}
				
			);
        
        	return false;
        });
});