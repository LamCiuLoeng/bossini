function toExport(){
	var f = $("form[name='exportForm']");
	f.attr("action","/bossinipo/exportBatch").submit();
}

function toProduct(){
	var f = $("form[name='exportForm']");
	f.attr("action","/bossinipo/generatePF").submit()
}


function toOrderForm(){
	var f = $("form[name='exportForm']");
	f.attr("action","/bossinipo/orderForm").submit()
}

var re = /^[\d]+$/;
function checkNum(str){
	return str.search(re)>-1;
}

function saveInput(){
	var shipmentQty = $.trim($("#shipmentQty").val());
	var wastageQty = $.trim($("#wastageQty").val());
	var header_ids = $("#header_ids").val();
	
	if(!checkNum(shipmentQty) || !checkNum(wastageQty)){
		alert("Please input number for these fields!");
		return false;
	}

	$.getJSON("/bossinipo/saveQty",
		   {"header_id":header_ids,
		   "shipmentQty":shipmentQty,
		   	"wastageQty":wastageQty},
		   function(data){
		   		if(data['flag']=="0") {
		   			alert(data.msg);
		   			hideInput();
					
					$("tbody tr").each(function(){
						var qty = $(".tb-qty",$(this)).text();
						$(".tb-totalqty",$(this)).text( calculate(parseInt(qty),parseInt(shipmentQty),parseInt(wastageQty)) );
					}); 			
		   			
		   		}
		   		else{
		   			alert(data.msg);
		   			hideInput();
		   		}
		   }
		);
}

function cancelInput(){
	hideInput();
}

function showInput(){
	$("#inputDiv").slideDown();
}

function hideInput(){
	$("#inputDiv").slideUp();
}


function calculate(qty,shipmentQty,wastage){
	var q = (shipmentQty + qty)*(1+ wastage/100);
	var qq = Math.ceil(q/10) *10;
    return qq>50?qq:50;
}


$(document).ready(function(){
	$('#photo').fancyZoom({directory:'/static/images/fancyZoom'});
});
