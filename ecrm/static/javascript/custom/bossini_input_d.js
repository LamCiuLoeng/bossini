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
		showFilling(this);
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
	
	if( !$("#item").val() ){ 
		msg.push("请选择产品号码！"); 
	}else{
		if( $("#item :selected").attr("component") == "Satin" ){
			var children = $("input[name^='fillingC'][value!='']");
			var bb = $("input[name^='fillingB'][value!='']");
			
			if( children.length > 0 && bb.length > 0  ){
				msg.push("请只填写'小童尺码'或者'BB尺码'中的一种！");
			}else if( children.length < 1 && bb.length < 1 ){
				msg.push("请填写'小童尺码'或者'BB尺码'中的一种！");
			}
			/*
			else if( children.length > 0 ){
				var isChildrenRight = true;
				$("input[name^='fillingC']:not('.skip')").each(function(){
					if( !$(this).val() ){ isChildrenRight=false; }
				});
				if(!isChildrenRight){ msg.push("请填写完全充绒量(小童尺码)的数据！"); }
			}else if( bb.length > 0 ){
				var isBBRight = true;
				$("input[name^='fillingB']").each(function(){
					if( !$(this).val() ){ isBBRight=false; }
				});
				if(!isBBRight){ msg.push("请填写完全充绒量(BB尺码)的数据！"); }
			}	
			*/
		}else if( $("#item :selected").attr("component") == "Nylon" ){
			var isNylonRight = true;
			
			var normal = $(".Nylon input[name^='filling1'][value!='']");
			var women = $(".Nylon input[name^='fillingW'][value!='']");
			
			if( normal.length < 1 && women.length < 1){
				msg.push("请填写'普通尺码'或者'女裝上裝'中的一种！");
			}else if( normal.length >0 && women.length >0 ){
				msg.push("请只填写'普通尺码'或者'女裝上裝'中的一种！");
			}
			
			/*
			$(".Nylon input[name^='filling']").each(function(){
				if(!$(this).val()){ isNylonRight=false; }
			});
			if(!isNylonRight){ msg.push("请填写完全充绒量的数据!") }
			*/
		}
	}
	
	if( !$("#qty").val() ){ msg.push("请输入贵司要采购的个数！"); }
	
	if( !$("#downContent").val() ){ msg.push("请填写含绒量！"); }
	
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
	if(!t.val()){
		$(".hangTagImg").attr("src","/static/images/blank.png");
	}else{
		$(".hangTagImg").attr("src","/static/images/bossini/" + t.attr("itemCode") + ".jpg")
	}
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

function checkDuplicateLegacy(obj){
	var t = $(obj);
	if(!t.val()){ return ;}
	$(".legacy-code").each(function(){
		if(t.val()==$(this).val()){ alert("请不要选择或者输入重复的Legacy Code"); }
	});
}


function showFilling(obj){
	var t = $(":selected",obj);
	$("fieldset").hide();
	if(t.attr("component") == "Satin"){
		$(".Satin").show();
	}else if(t.attr("component") == "Nylon"){
		$(".Nylon").show();
	}
}
