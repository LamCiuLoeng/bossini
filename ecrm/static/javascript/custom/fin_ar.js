function searchCompanies(){
	var company_name = $("#company_name").val();
	var company_code = $("#company_code").val();
	$.getJSON(
		"/finar/searchCompanies",
		{'company_name':company_name,'company_code':company_code},
		function(data){
			var cotentDIV = $("#step1_content");
			cotentDIV.empty();	
			var dt = $("<table border='1'></table>");
			$.each( data['result'] , function(i,row){
				dt.append("<tr><td><input type='radio' name='account_code' value='"
					+row[0]+"'/></td><td>"+row[1]+"</td><td>"+row[2]+"</td></tr>");
			});			
			cotentDIV.append(dt);
		}
	);
	
	return false;
}


function getCompanyDetail(){
	var account_code = $(":checked").val();
	
	$.getJSON(
		"/finar/getCompanyDetail",
		{'account_code':account_code},
		function(data){
			var detail = data['result'];
			$("#cust_name").text(detail[1]);
			$("#cust_short_name").text(detail[2]);
			$("#address").text(detail[3]);
			$("form[@name='step2_form'] input[@name='account_code']").val(detail[0]);
		}
	);
	$("#step2tab").click();
	return false;
}

function searchSOByTime(){
	var account_code = $("form[@name='step2_form'] input[@name='account_code']").val();
	var from_date = $("#from_date").val();
	var to_date = $("#to_date").val();
	
	$.getJSON(
		"/finar/searchSOByTime",
		{'account_code':account_code,'from_date':from_date,'to_date':to_date},
		function(data){
			var cotentDIV = $("#step2_content");
			cotentDIV.empty();	
			var dt = $("<table border='1'></table>");
			$.each( data['result'] , function(i,row){
				dt.append("<tr><td><input type='radio' name='so_no' value='"
					+row[0]+"'/></td><td>"+row[0]+"</td><td>"+row[1]+"</td><td>"+row[2]+"</td></tr>");
			});			
			cotentDIV.append(dt);

		}
	);
	
	return false;
}


function searchSODetail(){
	var so_no = $("#step2_content :checked").val();
	
}


$(document).ready(function(){
	
	new TabContents("#tabNav a");
	
	$("form[@name='step1_form']").submit(function(){
		return searchCompanies()
	});
	
	$("form[@name='step2_form']").submit(function(){
		return searchSOByTime()
	});
	
});
