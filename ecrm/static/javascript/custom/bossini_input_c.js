function changeBillTo(e){
	var o = $(e);
	if(o.val()){
		var s = currentBillTo = billToInfo[o.val()];
		$("#billToAddress").val( s.billToAddress );
		$("#billToContact").val(s.billToContact);
		$("#billToTel").val(s.billToTel);
		$("#currency").val(s.currency);
		$("#payterm").val(s.payterm);

		$("#shipmentInstruction").val(s.shipmentInstruction);
		$("#needChangeFactory").val(s.needChangeFactory);
		$("#VATInfo").val(s.VATInfo);
		$("#invoiceInfo").val(s.invoiceInfo);
		$("#accountContact").val(s.accountContact);
		
		if(currency!=s.currency){
			currency = s.currency;
			changeCurrency(s.currency);
		}			
	}else{
		clearBillTo();	
	}
}


function changeShipTo(e){
	var o = $(e);	
	if(o.val()){	
		var s = shipToInfo[o.val()];
	
		$("#shipToAddress").val(s.shipToAddress);
		$("#shipToContact").val(s.shipToContact);
		$("#shipToTel").val(s.shipToTel);
		$("#shipToFax").val(s.shipToFax);
		$("#shipToEmail").val(s.shipToEmail);
		$("#sampleReceiver").val(s.sampleReceiver);
		$("#sampleReceiverTel").val(s.sampleReceiverTel);
		$("#sampleSendAddress").val(s.sampleSendAddress);
		$("#requirement").val(s.requirement);
	}else{
		clearShipTo();
	}
		
}


function clearBillTo(){
	$("#billToAddress").val("");
	$("#billToContact").val("");
	$("#billToTel").val("");
	$("#billToFax").val("");
	$("#currency").val("");
	$("#payterm").val("");

	$("#shipmentInstruction").val("");
	$("#needChangeFactory").val("");
	$("#VATInfo").val("");
	$("#invoiceInfo").val("");
	$("#accountContact").val("");
}

function clearShipTo(){
	$("#shipToAddress").val("");
		$("#shipToContact").val("");
		$("#shipToTel").val("");
		$("#shipToFax").val("");
		$("#shipToEmail").val("");
		$("#sampleReceiver").val("");
		$("#sampleReceiverTel").val("");
		$("#sampleSendAddress").val("");
		$("#requirement").val("");	
}

function changeCurrency(c){
	refreshAmt();
}



/* ----------------  main entry for the page --------------------  */

$(document).ready(function(){	

	$(".numeric").numeric();
	
	$('.photo').fancyZoom({directory:'/static/images/fancyZoom'});
	
	$("#qty").change(function(){ refreshAmt(); });
	
	$("#item").change(function(){
		changeImg(this);
		refreshAmt();
	});
	
	/*
	$(".legacy-code").change(function(){
		var t = $(this);
		if(!t.val()){ return; }
		
		var others = $(".legacy-code:not([name='"+t.attr("name")+"'])");
		for(var i=0;i<others.length;i++){
			if( $(others[i]).val() == t.val() ){
				alert("请不要选择或者输入重复的 Legacy Code.");
				t.val("");
				break;
			}
		}

	});
	*/
             
});


     		   		
     		
/*
	prompt to alert the user whether he/she want to confirm the order.
*/

function toConfirm(){
	var msg = checkInput();
	if(msg.length>0){
		message = "<p>对不起，订单未能正确提交，请依照以下提示修改刚才输入的信息，谢谢。</p><ul>"
		for(i in msg){ message += "<li>" + msg[i] + "</li>"; }
		message += "</ul>";
		
		$.prompt(message,{opacity: 0.6,prefix:'cleanred',buttons:{'OK [确定]':true}} );
		return false;
	}
	
	$.prompt("We are going to confirm your order information in our Production System upon your final confirmation.<br /> \
			 Are you sure to confirm the order now?<br /> \
			 贵司已经清楚知道现在确认的订单资料是给我司作为生产和贵司结账依据，<br /> \
			 贵司肯定资料正确和确认这一个订单资料？",
    		{opacity: 0.6,
    		 prefix:'cleanblue',
    		 buttons:{'Yes [确认]':true,'No,Go Back [不确认,返回]':false},
    		 focus : 1,
    		 callback : function(v,m,f){
    		 	if(v){
    		 		return $("form").submit();
    		 	}
    		 }
    		}
    	);
}


function checkInput(){
	var msg = Array();
	
	if( !$("#customerOrderNo").val() ){ msg.push("请输入客户订单号！"); }
	
	if( !$("#item").val() ){ msg.push("请选择产品号码！"); }
	
	if( !$("#qty").val() ){ msg.push("请输入贵司要采购的个数！"); }

	var isFillLegacyCode = false;
	
	$(".legacy-code").each(function(){
		var t = $(this);
		if(t.val()){ isFillLegacyCode = true; }
	});
	
	if(!isFillLegacyCode){ msg.push("请选择或者输入至少一个 Legacy Code!") }

	return msg;	
}


function changeImg(obj){
	var t = $(":selected",obj);
	$(".hangTagImg").attr("src","/static/images/bossini/" + t.attr("itemCode") + ".jpg")
}


var buttonIndex = 32;

function addLegacy(obj){
	var t = $(obj);
	var p = t.parents("tr")[0];
	var cp = $(p).clone(true);
	$("input[type='text']",cp).attr("name","legacyCode"+(buttonIndex++)).val("");
	cp.insertAfter(p);
}

function removeLegacy(obj){
	var t = $(obj);
	var p = t.parents("tr")[0];
	$(p).remove();
}


function refreshAmt(){
	var p = $("#item :selected");
	var q = $("#qty");
	if(p.val() && q.val()){
		if($("#currency").val()=='HKD'){
			var u = p.attr("hkprice");
			$(".currenty_flag").text("$");
		}else{
			var u = p.attr("rmbprice");
			$(".currenty_flag").text("￥");
		}
		
		$("#unitPrice").text(u);
		$("#qty_show").text(q.val());
		var amt = parseFloat(u) * parseInt(q.val());
		$("#amt").text(formatFloat(amt,6));
		$("#amt_div").show();
	}else{
		$("#amt_div").hide();
	}
}
