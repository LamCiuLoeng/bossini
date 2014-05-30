var hangTagCache = null;
var waistCardCache = null;
var stickerCache = null;

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
	if(c=='RMB'){ 
		var flag = "¥";
		var attrname = "rmbprice";
	}else if(c=='HKD'){
		var flag = "HKD";
		var attrname = "hkprice";
	}
	
	
	$(".orderTR").each(function(){
		var tr = $(this);
		var item = $("select[name^='npc_item_']",tr)
		if(item.val()){		
			var price = $(":selected",item).attr(attrname);
			
			$(".pcUnitPrice",tr).text( parseFloat(price,6) );
			
			var qty = $(".totalQtyWithSampleWastage",tr).text();
			$(".pcAmt",tr).text( formatFloat( parseFloat(price)*parseInt(qty) ,6) );
		}
	});
	
	
	$(".currency").text(flag);
	
}


/* ----------------  main entry for the page --------------------  */

$(document).ready(function(){
    
    $("[enterindex]").enter2Tab({'compare':function(a,b){ return parseInt(a)-parseInt(b); }});
        
	$(".numeric").numeric();
	
	$('.photo').fancyZoom({directory:'/static/images/fancyZoom'});
	
    /*------------ ajax for the Hang tag and Waist card ------------ */
    $("select[name^='npc_cardType_']").blur(ajaxHangTagWaistCard);
    $("select[name^='npc_cardType_']").blur(clearACC);
    
    /*------------ change the price and amt when user select the item ---------- */
    $("select[name^='npc_item']").blur(changeQtyAmt);
    $("select[name^='npc_item']").blur(accSearch);
    /*--------------- update the qty when the sample and the wastage ------------*/
    $("input[name='shipmentQty'],input[name='wastageQty']").blur(refreshDetailQty);
    
    /*--------------- check whether the user select the same component ------------*/
    $("#fc_div select").bind("change",checkComponent);
});


                    
function attachItem(item,data){
	for(i in data){
		item.append('<option value="'+ data[i].id +'" rmbPrice="'+ data[i].rmbPrice +'" hkPrice="'+ data[i].hkPrice +'">'+ data[i].itemCode +'</option>');
	}
}


/*
	this is used to get the hang tag and waist card info from the server.
*/

function ajaxHangTagWaistCard(){
	var e = $(this);
	var tr = e.parents("tr")[0];
	var item = $("select[name^='npc_item_']",tr);
	item.html("<option value=''></option>");
	if(!e.val()){
		refreshDetailQty();
    showComponentOrNot();
    return;
	}else{
		if(e.val()=='H' && hangTagCache){
			attachItem(item,hangTagCache);
		}else if(e.val() =='W' && waistCardCache){
			attachItem(item,waistCardCache);
		}else if(e.val() == 'ST' && stickerCache){
      attachItem(item,stickerCache);
    }else{
			$.getJSON("/bossinipo/ajaxItemInfo",
					  {itemType:e.val(),marketList:$("#marketList").text()},
					  function(data){
					  	if(e.val()=='H'){
					  		hangTagCache = data.result;
                attachItem(item,hangTagCache);
					  	}else if(e.val()=='W'){
					  		waistCardCache = data.result;
                attachItem(item,waistCardCache)
					  	}else if(e.val()=='ST'){
                var afterFilter = Array();
                for(d in data.result){
                   if(data.result[d].itemCode.indexOf("01BC801811")>-1){
                      afterFilter.push(data.result[d])
                   }
                }
                stickerCache = afterFilter;
                attachItem(item,afterFilter);
              }
					  });
		}
	}
  refreshDetailQty();
  showComponentOrNot();
}
 		
/*
	prompt to alert the user whether he/she want to confirm the order.
*/

function toConfirm(){
	var msg = checkInput();
	if(msg.length>0){
		message = "<p>对不起，订单未能正确提交，请依照以下提示修改刚才输入的信息，谢谢</p><ul>"
		for(i in msg){ message += "<li>" + msg[i] + "</li>"; }
		message += "</ul>";
		
		$.prompt(message,{opacity: 0.6,prefix:'cleanred',buttons:{'OK [确定]':true}} );
		return false;
	}
	
	if(isComplete== '1'){
		$.prompt("We are going to confirm your order information in our Production System upon your final confirmation.<br /> \
				 Are you sure to confirm the order now?<br /> \
				 贵司已经清楚知道现在确认的订单资料是给我司作为生产和贵司结账依据，<br /> \
				 贵司肯定资料正确和确认这一个订单资料？<br /><br /> \
                亲爱的客户：<br />贵司昨天11月7日确认的订单，因为我司工厂产能已经完全满到12月15日，\
				您今天11月8日开始确认的订单，会在12月15日后的产能才能够安排，<font color='red'>请确认是否可以接受12月15日到12月23日左右的货期</font>，才确认这一个订单，谢谢！<br />" + 
        "Dear Customer,<br />Our capacity is full until 15 December onwards delivery, your order will be ex-factory from <font color='red'>Dec 15 to Dec 23 onwards.</font> Please reconfirm whether you would accept this lead-time before your FINAL confirm of this order.  Upon you accept this term, we will issue PI to your company and delivery the order between Dec 15-23 2010.",
	    		{opacity: 0.6,
	    		 prefix:'cleanblue',
	    		 buttons:{'Yes [确认]':true,'No,Go Back [不确认,返回]':false},
	    		 focus : 1,
	    		 callback : function(v,m,f){
	    		 	if(v){
              $.prompt("系统正在提交订单信息，请稍候。",{opacity: 0.6,prefix:'cleanblue',show:'slideDown',buttons:{}});
	    		 		$("form").submit();
	    		 	}
	    		 }
	    		}
	    	);
	}else{
	    $.prompt("This <font color='green'>"+legacycode_po+"</font> order is still pending for bossini’s Price or EAN code instruction.<br /> \
				 Are you sure you want to continue the basic order confirmation with r-pac?<br /> \
				 这一个 <font color='green'>"+legacycode_po+"</font> 挂牌订单还在等待 Bossini 确认价格/条码，<br /> \
				 请问是否先行确认订单基本资料？ <br /><br />亲爱的客户：<br />贵司昨天11月7日确认的订单，因为我司工厂产能已经完全满到12月15日，\
				您今天11月8日开始确认的订单，会在12月15日后的产能才能够安排，<font color='red'>请确认是否可以接受12月15日到12月23日左右的货期</font>，才确认这一个订单，谢谢！<br />" + 
         "Dear Customer,<br />Our capacity is full until 15 December onwards delivery, your order will be ex-factory from <font color='red'>Dec 15 to Dec 23 onwards.</font> Please reconfirm whether you would accept this lead-time before your FINAL confirm of this order.  Upon you accept this term, we will issue PI to your company and delivery the order between Dec 15-23 2010.",
	    		{opacity: 0.6,
	    		 prefix:'cleanblue',
	    		 buttons:{'Yes, confirm basic details first 是，先确认基本订单资料':true,'No,Go Back 不确认,返回':false},
	    		 focus : 1,
	    		 callback : function(v,m,f){
	    		 	if(v){
              $.prompt("系统正在提交订单信息，请稍候。",{opacity: 0.6,prefix:'cleanblue',show:'slideDown',buttons:{}});
	    		 		$("form").submit();
	    		 	}
	    		 }
	    		}
	    	);
    }
}


/* 
	validate the form when submit
*/

function checkInput(){
	var msg = Array();

	if( !$("input[name='customerOrderNo']").val() ){ 
		msg.push("请填写\"客户订单号\"。"); 
	}else{
		var checkReg = /\\|\/|\*|\?|\||'|:|<|>/;
		var orderNo = $("input[name='customerOrderNo']").val();
		if( checkReg.test(orderNo) ){ msg.push("请更正\"客户订单号\"中的特殊字符，例如'\\','/',':','*','?','<','>','|'。"); }
	}

	if( $("select[name^='npc_item_'][value]").length < 1 ){ msg.push("请选择至少一个产品号码！") }
	
	if( $("select[name^='npc_cardType_'][value='H']").length > 1 ){ msg.push("选择了多个 Hang Tag!") }	
	
	if( $("select[name^='npc_cardType_'][value='W']").length >　1 ){ msg.push("选择了多个 Waist Card!") }	
	
	if( !$("input[name='shipmentQty']").val() ){ msg.push("请填写\"船头办需要的数量\"。"); }
	
	if( !$("input[name='wastageQty']").val() ){ msg.push("请填写\"损耗率\"。"); }
	
	
	if( $("select[name^='npc_item_'] :selected").filter(":contains('01HT80611101')").length > 0 ){
		var tempList =  $.grep( $("input[name^='detail_length_']"),function(v,i){ return $(v).val()=='' } );
		if(tempList.length > 0){ msg.push("因为您选择了 01HT80611101系列的腰牌，请填写全部的\"裤长\"栏位。"); }
	}
	
	if($("#marketList").text()=='CHN'){
	
		var chnSelectFields = ['typeName','prodcuingArea','productName','standard','checker','technicalType','unit','grade'];
		var chnInputFields = ['specification'];
		var isChnOK = true;
		
		for(var i = 0;i<chnSelectFields.length;i++){
			if(!$("select[name='"+chnSelectFields[i]+"']").val()){
				isChnOK = false;
				break;
			}
		}
		for(var j = 0; j<chnInputFields.length;j++){
			if(!$("input[name='"+chnInputFields[j]+"']").val()){
				isChnOK = false;
				break;
			}
		}	
		if(!isChnOK){ msg.push("请填写完整所有中国市场挂牌需要的信息！"); }
		
	}
    
  /*
   * check the stick's percentage and component
   */
  if(ifComponentNeed()){
     var totalpercentage = 0;
     var isMatch = true;
     $("#fc_div .layer").each(function(){
        var tr = $(this);
        var percentage = $("input",tr).val();
        var component = $(":selected",tr).val();
        if(percentage || component){
            if(!percentage || !component){ isMatch=false;}
            if(percentage){ totalpercentage+=parseFloat(percentage); }
        }
     });
     
     if(!isMatch){ msg.push("请正确填写百分比以及相对应的成份！") }
     if(totalpercentage!=100){ msg.push("请正确填写百分比，所有百分比的总和应该等于100%！"); }
  }else{
    clearComponent();
  }
	
	return msg;
}


/*
	refresh all the qty related to the sample and wastage.
*/
function refreshDetailQty(){
	var shipmentQty = $("input[name='shipmentQty']").val();
	var wastageQty = $("input[name='wastageQty']").val();
	if(!shipmentQty || !wastageQty){
		return ;
	}
	
	shipmentQty = parseInt(shipmentQty);
	wastageQty = parseInt(wastageQty);
	
	
	var qty = $("#detailTable tr.detailTR td:nth-child(1)");
	var ship = $("#detailTable tr.detailTR td:nth-child(2)");
	var wast = $("#detailTable tr.detailTR td:nth-child(3)");
	var total = $("#detailTable tr.detailTR td:nth-child(4)");
	
	var sumTotal = 0;
	
	for(var i=0;i<ship.length;i++){

		var q = parseInt($(qty[i]).text());
		var s = q+shipmentQty;
		var w = Math.round((q+shipmentQty)*(1+wastageQty/100));
        
    if(checkIfStickerOnly()){
        var t = w;
    }else{
    		var t = w > 50 ? w :50;
    		t =  Math.ceil(t/10)*10;    
    }
    
		$(ship[i]).text(s);
		$(wast[i]).text(w);
		$(total[i]).text(t);
		
		sumTotal += t;
	}
	
	$(".totalQtyWithSampleWastage").text(sumTotal);
	
	var tq = $("tr.orderTR .totalQtyWithSampleWastage");
	var ps = $("tr.orderTR .pcUnitPrice");
	var ts = $("tr.orderTR .pcAmt");
	
	for(var i=0;i<tq.length;i++){
		$(tq[i]).text(sumTotal);
		var price = $(ps[i]);
		
		if(price.text()){	
			$(ts[i]).text( formatFloat(parseFloat(price.text())*sumTotal,6) );
		}
	}

}     



/*------------ change the price and value -----------------*/
function changeQtyAmt(){
	var e = $(':selected',this);
	
	var tr = e.parents("tr")[0];

	if(!e.val()){
		$(".currency",tr).text("");
		$(".pcUnitPrice",tr).text("");
		$(".pcAmt",tr).text("");
	}else{
		if(currency=='RMB'){
			var flag = "¥";
			var price = e.attr("rmbprice");
		}else if(currency=='HKD'){
			var flag = "HKD";
			var price = e.attr("hkprice");
		}
		
		var q = $(".totalQtyWithSampleWastage",tr).text();
		$(".currency",tr).text(flag);
		$(".pcUnitPrice",tr).text(price+'');
		$(".pcAmt",tr).text( formatFloat(parseFloat(price) * parseInt(q)+'',6) );
	}
	
	var cardType = $("select[name^='npc_cardType_']",tr).val();
	var urlPrefix = "/static/images/bossini/";
  
	if(cardType == 'H'){
		$(".hangTagImg").attr("src",urlPrefix+e.text()+".jpg");
	}else if(cardType == 'W'){
		if(e.text()){
			$(".waistCardImg").attr("src",urlPrefix+e.text()+".jpg");
		}else{
			$(".waistCardImg").attr("src","/static/images/blank.png");
		}	
	}else if(cardType == 'ST'){
        if(e.text()){
            if($("#itemType").text()=='WOVEN'){
              $(".stickerImg").attr("src",urlPrefix+e.text()+"NC.jpg");
            }else{
              $(".stickerImg").attr("src",urlPrefix+e.text()+".jpg");              
            }
        }else{
            $(".stickerImg").attr("src","/static/images/blank.png");
        }
    }
}    


function checkComponent(){
    var tmp = $(this);
    if(!tmp.val()){ return; }
    var flag = false;
    $("#fc_div select").not(this).each(function(){
        if(tmp.val() == $(this).val()){ flag = true;}
    });
    
    if(flag){
        alert("请不要重复选择相同的成分！");
        tmp.val("");
    }
    
}


function checkIfStickerOnly(){
    var isStickerOnly = true;
    $("select[name^='npc_cardType_']").each(function(){
      var tmp = $(this);
      if(tmp.val() && tmp.val()!='ST'){ isStickerOnly = false; }
    });
    return isStickerOnly;
}




function ifComponentNeed(){
    var flag = false;    
    if($("#itemType").text() == 'WOVEN'){ return flag; }
    $("select[name^='npc_cardType_']").each(function(){
      var tmp = $(this);
      if(tmp.val() && tmp.val()=='ST'){ flag = true; }
    });
    return flag;
}


function showComponentOrNot(){
    if(ifComponentNeed()){
        $("#fc_div").slideDown();
    }else{
        clearComponent();
        $("#fc_div").slideUp();
    }
}

function clearComponent(){
      $("input,select","#fc_div").val(""); 
}



function accSearch() {
	var e = $(this);
	var card_name=e.attr("name").replace("npc_item_","npc_cardType_")
    var card = $("select[name^="+card_name+"]");
	var standardExt=$("#standardExt");
	
	if (card.val()=="H" && e.val()==185 ||e.val()==186||e.val()==187||e.val()==191){
	$("#show_name").text("货品名称：");
	$("#show_standard").text("执行标准：");
	$("#show_grade").text("等级：");
	}
	else{
	$("#show_name").text("产品名称：");
	$("#show_standard").text("产品标准：");
    $("#show_grade").text("产品等级：");
	}
	
	if (card.val()=="H" && e.val()==186 ||e.val()==171||e.val()==172||e.val()==187){
	
	if (e.val()==186||e.val()==171){
	standardExt.val("水洗产品");
	}
	else{
     if(e.val()==172||e.val()==187){
	 standardExt.val("原色产品");
	 }	
	}
	standardExt.parent().parent().css({"display":""});
}
else{
standardExt.val("")
standardExt.parent().parent().css({"display":"none"});

}
}
function clearACC(){
if( $("select[name^='npc_cardType_'][value='H']").length > 1 ){
$(this).val("");
alert("不能选多个Hang Tag!");
}
 var cards=$("select[name^='npc_cardType_']");
 var check=false
cards.each(function(){
e=$(this)
if (e.val()=="H"){
check=true;
}
})
if(!check){
var standardExt=$("#standardExt");
standardExt.val("")
standardExt.parent().parent().css({"display":"none"});
$("#show_name").text("产品名称：");
$("#show_standard").text("产品标准：");
$("#show_grade").text("产品等级：");
}
}