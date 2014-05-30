function toSave(){
	$("form").submit();
}

function toReset(){
	$("form")[0].reset();
}


$(document).ready(function(){
	$(".numeric").numeric();
	
	$("table :input").each(function(){
		var temp = $(this);
		temp.attr("ref",temp.val());
	});
	
	$("input[type='text'][name^='qty_']").change(function(){
		var tmp = $(this);
		var tr = tmp.parents("tr");
		var price = $("span.price_td",tr).text() ? parseFloat( $("span.price_td",tr).text() ) : 0;
		var amt = $("input[type='text'][name^='amt_']");
		var amt_val = Math.round(price*tmp.val()*100)/100;
		amt.val(amt_val);
	});
	
	$("form").submit(function (){
		var formObj = $(this);
		var updateIDs = "";
		$("input[@ref]").each(function(){
			var temp = $(this);
			if(temp.attr("ref") != temp.val()){
				updateIDs += temp.attr("name") + "|";
			}
		});
		
		formObj.append('<input type="hidden" name="updateIDs" value="'+updateIDs+'"/>');
		
		/*
if(updateIDs == ""){
			$.prompt("No value changed. Won't save!",{opacity: 0.6,prefix:'cleanred',show:'slideDown'});
			return false;
		}else{
			formObj.append('<input type="hidden" name="updateIDs" value="'+updateIDs+'"/>');
		}
*/
		return true;
	});
});