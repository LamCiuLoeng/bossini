var mainLabelCache = null;
var sizeLabelCache = null;

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
	refreshWL();
}


function refreshWL(){
	if(!currency){return;}
	
	if(currency == 'RMB'){
		var flag = "¥";
		var attrName = "rmbprice";
	}else if(currency == 'HKD'){
		var flag = "HKD";
		var attrName = "hkprice";
	}
	
	$(".currency").text(flag);
	
	/*var mainSum = 0;*/
	var sizeSum = 0;
	var sizeQtySum = 0;
	
	$(".wl-detail").each(function(){
		var tr =  $(this);
		var l = $("select[name^='nwl_labelType_']",tr);
		var i = $("select[name^='nwl_item_']",tr);
		var q = $("input[name^='nwl_qty_']",tr);
		var p = $(".price",tr);
		var a = $(".amt",tr);
		
		if( i.val() && q.val() ){	
			var price = $(":selected",i).attr(attrName);
			p.text( formatFloat(price,6) );
			var tmp = parseFloat( price ) * parseInt( q.val() );
			
			/*
			if(l.val()=='M'){
				mainSum += tmp;
			}else if(l.val() == 'S'){
				sizeSum += tmp;
				sizeQtySum += parseInt( q.val() );
			}
			*/
			
			sizeSum += tmp;
			sizeQtySum += parseInt( q.val() );

			
			a.text( formatFloat(tmp,6) );
		}
		
	});
	
	
	/*$("#mainLabelAmt").text( formatFloat(mainSum,6) );*/
	$("#sizeLabelAmt").text( formatFloat(sizeSum,6) );
	$("#sizeLabelTotalQty").text( sizeQtySum );
	
	/*
	
	
	var lts = $("select[name^='nwl_labelType_']");
	var amts = $(".amt");
	var items = $("select[name^='nwl_item_']");
	var qtys = $("select[name^='nwl_qty_']");
	
	
	for(var i=0;i<items.length;i++){
		var t = lts[i];
		var item = items[i];
		var qty = qtys[i];
		if(!item.val() || !qty.val()){ continue; }
		
		var amt = parseInt( qty.val() ) * parseFloat( item[i].attr(attrName) );
		
		
		if( t.val() == 'M' ) { mainSum += amt; }
		else if( t.val() == 'S' ){ sizeSum += amt; }
	}
	
	
	
	
	
	
	for(var i=0;i<lts.length;i++){
		var a = $(amts[i]);
		var t = $(lts[i]);

		if(!t.val() || !a.text()){continue;}
		
		//var amt = parseFloat(items[i].attr(attrName)) * parseInt(qtys[i].value());
		
		
		if( t.val() == 'M' ) { mainSum += parseFloat(a.text()); }
		else if( t.val() == 'S' ){ sizeSum += parseFloat(a.text()); }
	}
	
	$("#mainLabelAmt").text( formatFloat(mainSum,6) );
	$("#sizeLabelAmt").text( formatFloat(sizeSum,6) );
	
	if(currency == 'RMB'){
		var flag = "¥";
	}else if(currency == 'HKD'){
		var flag = "HKD";
	}
	
	$(".currency").text(flag);
	*/
}



/* ----------------  main entry for the page --------------------  */

$(document).ready(function(){	
	$("[enterindex]").enter2Tab({'compare':function(a,b){ return parseInt(a)-parseInt(b); }});

	$(".numeric").numeric();
	
	$('.photo').fancyZoom({directory:'/static/images/fancyZoom'});

    /* ------------ ajax for the woven label --------------- */
    /*$("select[name^='nwl_labelType_']").blur(ajaxWovenLabel);*/
    
    /*------------- update the price and qty ----------------*/
    $("select[name^='nwl_item_']").blur(updateQtyAmt);
    
    
    /* ------------------ ajax for the Size mapping -------------------*/
    $("select[name^='nwl_size_']").blur(getSize);
    
    /*------------------- update the amt when the qty change -------------*/
    $("input[name^='nwl_qty_']").blur(updateAmt);
             
});


                    
function attachItem(item,data){
	for(i in data){
		item.append('<option value="'+ data[i].id +'" rmbPrice="'+ data[i].rmbPrice +'" hkPrice="'+ data[i].hkPrice +'">'+ data[i].itemCode +'</option>');
	}
}

/*
	this is used to get the woven label info from the server 
*/
/*
function ajaxWovenLabel(){
	var e = $(this);
	var tr = e.parents("tr")[0];

	
	var item = $("select[name^='nwl_item_']",tr);
	
	item.html("<option value=''></option>");
	
	if(!e.val()){
		return;
	}else{
		if(e.val()=="M" && mainLabelCache){
		  	attachItem(item,mainLabelCache);
		  	
		  	$("select[name^='nwl_size_'],select[name^='nwl_measure_']",tr).attr("disabled",true);
		  	
		}else if(e.val()=="S" && sizeLabelCache){
		  	attachItem(item,sizeLabelCache);
		  	
		  	$("select[name^='nwl_size_'],select[name^='nwl_measure_']",tr).removeAttr("disabled");
		  	
		}else{
	    	$.getJSON("/bossinipo/ajaxItemInfo",
	    			  {itemType: "WOV",labelType : e.val()},
	    			  function(data){
	    			  	attachItem(item,data.result);
	    			  	
	    			  	if(e.val()=="M"){
	    			  		mainLabelCache = data.result;
	    			  		$("select[name^='nwl_size_'],select[name^='nwl_measure_']",tr).attr("disabled",true);
	    			  	}else{
	    			  		sizeLabelCache = data.result;
	    			  		$("select[name^='nwl_size_'],select[name^='nwl_measure_']",tr).removeAttr("disabled");
	    			  	}
	    			  	
	    			  }
	    	);
		}
	}
}
*/

/*
	 this is used to get the size mapping info from the server.
*/

function getSize(){
    var o = $(this);
    var tr = o.parents("tr")[0];
    var measure = $("select[name^='nwl_measure_']",tr); 
    var line = $("#line").text();
    var lineType = "NOLINE"
    if(line=='BOSSINI MEN' || line=='BOSSINI YOUTH M'){
       lineType = 'BOSSINI MEN'; 
    }else if(line=='BOSSINI LADIES' || line=='BOSSINI YOUTH F'){
       lineType = 'BOSSINI LADIES';
    }
    
    var weave = $("#itemType").text();
    if(weave=="SWEATER"){
        weave = "KNIT";
    }
 
     $.getJSON("/bossinipo/ajaxSizeInfo",
     		   {"size" : o.val(),"weave":weave,"line":lineType},
     		   function(data){
     		   		var str = "";
     		   		for(i in data.result){
     		   			str += "<option value='"+ data.result[i].id +"'>"+ data.result[i].measure +"</option>";
     		   		}
     		   		if(!str){
	     		   		measure.attr("disabled","true");
	     		   		$("input[name^='nwl_qty_']",tr).focus();
     		   		}else{
     		   			measure.removeAttr("disabled");
	     		   		measure.html( "<option value=''></option>" + str);
     		   		}	
     		   });

}

     		   		
     		
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
            $.prompt("系统正在提交订单信息，请稍候。",{opacity: 0.6,prefix:'cleanblue',show:'slideDown',buttons:{}});
    		 		return $("form").submit();
    		 	}
    		 }
    		}
    	);
}


function checkInput(){
	var msg = Array();
	
	if(!$("select[name='billTo']").val()){ msg.push("请选\"择收票人\"。") }
	if(!$("select[name='shipTo']").val()){ msg.push("请选择\"收货公司\"。") }
	if( !$("input[name='customerOrderNo']").val() ){ msg.push("请填写\"客户订单号\"。"); }
	
	
	/*var mainLabelList = Array();*/
	var sizeLabelList = Array(); 
	var isSingleSizeLabel = true;
	var isSizeFilled = true;
	var isQtyFilled = true;
	var isItemFilled = false;
	
	$(".wl-detail").each(function(){

		/*
		if( !$("select[name^='nwl_item_']",tr).val() ){ isItemFilled = false; }
		if( labelType.val() == 'M' ){ 
			mainLabelList.push(labelType);
		}
		else if( labelType.val() == 'S' ){ 		
			sizeLabelList.push( $("select[name^='nwl_item_']",tr) ); 				
			if( !$("select[name^='nwl_size_']",tr).val() ){ isSizeFilled = false; }  //check whether the user select the size.
		}
		 */
		
		
		
		var tr = $(this);
		if( $("select[name^='nwl_item_']",tr).val() ){
			if( !$("input",tr).val() ){ isQtyFilled = false; }   //check whether the user input the qty.
			isItemFilled = true;
			sizeLabelList.push( $("select[name^='nwl_item_']",tr) ); 				
			if( !$("select[name^='nwl_size_']",tr).val() ){ isSizeFilled = false; }  //check whether the user select the size.			
		}
		
	});
		

	var cur = null;
	for(var j=0;j<sizeLabelList.length;j++){
		if(j==0){ cur=sizeLabelList[j].val(); }
		else if( cur != sizeLabelList[j].val() ){
			isSingleSizeLabel = false;
			break;	
		}
	}
	
	if( sizeLabelList.length < 1 ){ msg.push("请选择至少一个\"Size Label\"。"); }
	//if( mainLabelList.length >1 ){ msg.push("你选择了多于一个\"Main Label\"。"); }
	if( !isSingleSizeLabel ){ msg.push("你选择了多于一种类型的 Size Label。") }
	if( !isItemFilled ){ msg.push("请选择相应 Woven Label 的产品号码。") }
	if( !isSizeFilled ){ msg.push("请选择相应\"Size Label\"的\"Size\"。"); }
	if( !isQtyFilled ){ msg.push("请填写相应 Woven Label 的订购数量。") }
	
	return msg;
		
	
}


/*
	update the qty ,amt in the page
*/

function updateQtyAmt(){
	var e = $(":selected",this);
	var tr = e.parents("tr")[0];

	/*
	if(currency == 'RMB'){
		var flag = "¥";
		var price = e.attr("rmbprice");
	}else if(currency == 'HKD'){
		var flag = "HKD";
		var price = e.attr("hkprice");
	}
	
	$(".currency",tr).text(flag);
	$(".price",tr).text( formatFloat(price,6) );
	var qty = $(".qty",tr).text();
	if(qty){
		var v = formatFloat(parseInt(qty) * parseFloat(price),6);
		$(".amt",tr).text( v );
	}
	
	*/
	
	
	refreshWL();
	
	/* update the label's image */
	var labelType = $("select[name^='nwl_labelType_']",tr).val();
	var urlPrefix = "/static/images/bossini/";
	
	/*
	if(labelType=='M'){
		$(".mainLabelImg").attr("src",urlPrefix+e.text()+".jpg");
		$("#mainLabelCode").text(e.text());
	}else if(labelType=='S'){
		$(".sizeLabelImg").attr("src",urlPrefix+e.text()+".jpg");
		$("#sizeLabelCode").text(e.text());
	}
	*/
	
	$(".sizeLabelImg").attr("src",urlPrefix+e.text()+".jpg");
	$("#sizeLabelCode").text(e.text());
	
	var len = $("select[name^='nwl_length_']",tr);
	var measure = $("select[name^='nwl_measure_']",tr);
	var size = $("select[name^='nwl_size_']",tr);
	
	if(e.text()=='01WL661307' || e.text()=='01WL661407' || e.text()=='01WL767610' || e.text()=='01WL633707'){
		len.removeAttr("disabled");
	}else if(e.text()=='01WL661007' || e.text()=='01WL622407'){
		measure.attr("disalbed","disabled");
	}else{
		len.attr("disalbed","disabled");
	}
	
	/*
	else if(e.text()=='01WL661007' || e.text()=='01WL622407'){
		measure.attr("disalbed","disabled");
		size.attr("disalbed","disabled");
	}else if(e.text()=='01WL661107' || e.text()=='01WL622407'){
		size.attr("disalbed","disabled");
		len.attr("disalbed","disabled");
	}else{
		len.attr("disalbed","disabled");
	}
	*/
	
}


/*
	update the amount related to the qty
*/
function updateAmt(){
/*
	var e = $(this);
	var tr = e.parents("tr")[0];
	var price = $(".price",tr).text();
	if(price && e.val()){
		var v = formatFloat( parseFloat(price) * parseInt(e.val()),6 );
		$(".amt",tr).text( v );
	}
	*/
	
	
	refreshWL();
}


  
