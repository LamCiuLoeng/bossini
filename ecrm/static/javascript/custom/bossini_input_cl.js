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
	
	//$('.photo').fancyZoom({directory:'/static/images/fancyZoom'});
	
	$("#tabs").tabs();
	
	$(".img_show").change(function(){
		var t = $(this);
		var sid = $(":selected",this).attr("styleID");
		if(sid){
			var src = "/static/images/bossini/care_label/CHN/CHN_"+t.attr("name")+"_"+sid+".jpg";
		}else{
			var src = "/static/images/blank.png";
		}
		$("#"+t.attr("name")+"_img").attr("src",src);
		
	});
	
	$("input[name^='qty']").change(function(){
		refreshAmt();
	});
	
	$("#itemCode").change(function(){
		refreshAmt();
	});
	
	//check whether the user select the same legacy code
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
	
	//check whether the user select the same appendix
	$("select[name^='appendix']").change(function(){
		var t = $(this);
		if(!t.val()){ return; }
		
		var others = $("select[name^='appendix']:not([name='"+t.attr("name")+"'])");
		for(var i=0;i<others.length;i++){
			if( $(others[i]).val() == t.val() ){
				alert("请不要选择重复的'补充說明'选项。");
				t.val("");
				break;
			}
		}

	});
	
	//check whether the user select the same component in the same box
	$("select[name^='fibercontent_']").change(function(){
		var t = $(this);
		var p = t.parents("table")[0];
		if(t.val()){
			var others = $("select[name^='fibercontent_']:not([name='"+t.attr("name")+"'])",p);
			for(var i=0;i<others.length;i++){
				if( $(others[i]).val() == t.val() ){
					alert("请不要在同一个产品成分中选择重复的选项。");
					t.val("");
					break;
				}
			}
		}
	});
	
	//check whether the user select the same part
	$("select[name^='part_']").change(function(){
		var t = $(this);
		var isBreak = false;
		if(t.val()){
			var others = $("select[name^='part_']:not([name='"+t.attr("name")+"'])");
			for(var i=0;i<others.length;i++){
				if( $(others[i]).val() == t.val() ){
					alert("请不要选择重复的产品名称。");
					t.val("");
					isBreak = true;
					break;
				}
			}
		}
		/*
		if( !isBreak ){
			var tr = t.parents("tr")[0];
			if( $(":selected",t).attr("need_coating")=="0" ){
				$("input[type='checkbox']",tr).attr("disabled","true");
			}else{
				$("input[type='checkbox']",tr).removeAttr("disabled");
			}
		}
		*/
	});
             
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
            $.prompt("系统正在提交订单信息，请稍候。",{opacity: 0.6,prefix:'cleanblue',show:'slideDown',buttons:{}});
    		 		return $("form").submit();
    		 	}
    		 }
    		}
    	);
}


function checkInput(){
	var msg = Array();

	/*
	if( !$("#customerOrderNo").val() ){ 
		msg.push("请输入客户订单号！"); 
	}else{
		var checkReg = /\\|\/|\*|\?|\||'|:|<|>/;
		var orderNo = $("input[name='customerOrderNo']").val();
		if( checkReg.test(orderNo) ){ msg.push("请更正\"客户订单号\"中的特殊字符，例如'\\','/',':','*','?','<','>','|'。"); }
	}
	*/
	
	
	if( !$("#itemCode").val() ){ msg.push("请选择产品号码！"); }
	
	if( !$("#origin").val() ){ msg.push("请选择'产地'！") }
	
	if( !$("#washing").val() ){ msg.push("请选择'洗水'！") }
	
	if( !$("#bleaching").val() ){ msg.push("请选择'漂白'！") }
	
	if( !$("#ironing").val() ){ msg.push("请选择'烫熨'！") }
	
	if( !$("#dryCleaning").val() ){ msg.push("请选择'干洗'！") }
	
	if( !$("#drying").val() && !$("#othersDrying").val() ){
		msg.push("请选择'晾干'或者'其它晾干'中的一项！");
	}
	
	if( $("#drying").val() && $("#othersDrying").val() ){
		msg.push("请选择'晾干'或者'其它晾干'中的一项！");
	}
	
	
	var componentHeaderNum = 0;
	var componentDetailNum = 0;
	var correctComponent = true;
	var correctPercentage = true;
	var correctCoating = true;
	
	$(".component-table").each(function(){
		var t = $(this);
		var header = $("select[name^='part_']",t);
		if(header.val()){ componentHeaderNum++; }
		
		var count = 0;
		var isFill = false;
		$("input[name^='percentage']",t).each(function(){
			var ie = $(this);
			var fc = $("#"+ie.attr("name").replace("percentage","fibercontent"));
			
			if(ie.val()){ 
				//count+=parseInt(ie.val()); 
				count+=parseFloat(ie.val()); 
				isFill = true;
				if(!fc.val()){ correctComponent = false; }
			}else if(fc.val()){
				correctComponent = false;
				isFill = true;
			}
		});
		
		if(isFill){ 
			componentDetailNum++; 
			if( count!=100 ){ correctPercentage = false; }
		}
		
		
		if($("input[name^='coating_']",t).attr("checked") && $("input[name^='microelement_']",t).attr("checked")){ correctCoating = false;  }
		
	});
	
	
	if( !correctPercentage ){ msg.push("请正确输入每个产品的组成成分，要求百分比总和为100！"); }
	if( !correctComponent ){ msg.push("请正确填写产品名称中每个成分对应的百分比以及组成成分！"); }
	if( !correctCoating ){ msg.push("请正确选择'加涂层'以及'含微量其它纤维',只选择其中的一个！"); }
	
	if( componentDetailNum==0 ){ 
		msg.push("请填写至少一种产品成份！");
	}else if( componentDetailNum==componentHeaderNum ){
		//if( componentDetailNum == 1){ msg.push("当只有一种产品成份时，产品名称不需要填写！"); }
	}else if( componentDetailNum!=componentHeaderNum ){
		if( componentHeaderNum!=0 || componentDetailNum!=1){
			msg.push("请正确选择每一种产品成份的名称与成份！");
		}
	}

	//check whether this part need coating
	$("select[name^='part_']").each(function(){
		var t = $(this);
		if( t.val() ){
			var se = $(":selected",t);
			var coat = $("#coating"+t.attr("name").replace("part",""));
			if( se.attr("need_coating")==0 && coat.attr("checked") ){
				msg.push("产品名称("+ se.text() +")不需要加涂层，请改正！");
			}
		}
	});
	
	
	//check the "STEAM PRESSING ONLY",if the option is selected,the corresponding appendix must also been selected.
	if( $("#ironing :selected").attr("styleid") == "6" ){
		var bindfor = "Ironing_6";
		var isOK = 0;
		$("select[name^='appendix']").each(function(){
			if( $(":selected",this).attr("bindfor")==bindfor ){ isOK++ };
		});
		
		if( isOK!=1 ){ msg.push("如果选择了'STEAM PRESSING ONLY',请相应地选择补充说明: '仅用蒸汽熨烫' 或者 '建议蒸汽熨烫'!") }
	}
	
	//check whether the corresponding leagcy-code,qty,customer po is fill correcttly.
	var isLegacyCodeCorrect = true;
	$(".lc-qty-po").each(function(){
		//var l = $("[name^='legacyCode']",this);
		var q = $("[name^='qty']",this);
		var p = $("[name^='customerOrderNo']",this);
		
		if( q.val() && p.val()){}
		else if(!q.val() && !p.val() ){}
		else{ isLegacyCodeCorrect = false;  }
	});
	
	if(!isLegacyCodeCorrect){ msg.push("请填写正确相应的'Qty','Customer PO'!"); }
	
	return msg;	
}


function changeImg(obj){
	
}


var buttonIndex = 32;

function addLegacy(obj){
	var t = $(obj);
	var p = t.parents("tr")[0];
	var cp = $(p).clone(true);
	var index = buttonIndex++
	$("input[type='text'][name^='legacyCode']",cp).attr("name","legacyCode"+index).val("");
	$("input[type='text'][name^='qty']",cp).attr("name","qty"+index).val("");
	$("input[type='text'][name^='customerOrderNo']",cp).attr("name","customerOrderNo"+index).val("");
	cp.insertAfter(p);
}

function removeLegacy(obj){
	var t = $(obj);
	var p = t.parents("tr")[0];
	$(p).remove();
	refreshAmt();
}


function refreshAmt(){
	var p = $("#itemCode :selected");
	var sum = 0;
	$("input[name^='qty']").each(function(){
		var t = $(this);
		if(t.val()){
			sum += parseInt(t.val());
		}
	});
	$("#totalQty").text(sum);
	
	if(p.val() && sum!=0){
		if($("#currency").val()=='HKD'){
			var u = p.attr("hkprice");
			$(".currenty_flag").text("$");
		}else{
			var u = p.attr("rmbprice");
			$(".currenty_flag").text("￥");
		}
		
		$("#unitPrice").text(u);
		$("#qty_show").text(sum);
		var amt = parseFloat(u) * sum;
		$("#amt").text(formatFloat(amt,6));
		$("#amt_div").show();
	}else{
		$("#amt_div").hide();
	}
}


function checkBeforePreview(){
	var msg = Array();
	
	if( !$("#origin").val() ){ msg.push("请选择'产地'！") }
	
	if( !$("#washing").val() ){ msg.push("请选择'洗水'！") }
	
	if( !$("#bleaching").val() ){ msg.push("请选择'漂白'！") }
	
	if( !$("#ironing").val() ){ msg.push("请选择'烫熨'！") }
	
	if( !$("#dryCleaning").val() ){ msg.push("请选择'干洗'！") }
	
	if( !$("#drying").val() && !$("#othersDrying").val() ){
		msg.push("请选择'晾干'或者'其它晾干'中的一项！");
	}
	
	if( $("#drying").val() && $("#othersDrying").val() ){
		msg.push("请选择'晾干'或者'其它晾干'中的一项！");
	}
	
	
	var componentHeaderNum = 0;
	var componentDetailNum = 0;
	var correctComponent = true;
	var correctPercentage = true;
	var correctCoating = true;
	
	$(".component-table").each(function(){
		var t = $(this);
		var header = $("select[name^='part_']",t);
		if(header.val()){ componentHeaderNum++; }
		
		var count = 0;
		var isFill = false;
		$("input[name^='percentage']",t).each(function(){
			var ie = $(this);
			var fc = $("#"+ie.attr("name").replace("percentage","fibercontent"));
			
			if(ie.val()){ 
				//count+=parseInt(ie.val()); 
				count+=parseFloat(ie.val()); 
				isFill = true;
				if(!fc.val()){ correctComponent = false; }
			}else if(fc.val()){
				correctComponent = false;
				isFill = true;
			}
		});
		
		if(isFill){ 
			componentDetailNum++; 
			if( count!=100 ){ correctPercentage = false; }
		}
		
		if($("input[name^='coating_']",t).attr("checked") && $("input[name^='microelement_']",t).attr("checked")){ correctCoating = false;  }
	});
	
	
	if( !correctPercentage ){ msg.push("请正确输入每个产品的组成成分，要求百分比总和为100！"); }
	if( !correctComponent ){ msg.push("请正确填写产品名称中每个成分对应的百分比以及组成成分！"); }
	if( !correctCoating ){ msg.push("请正确选择'加涂层'以及'含微量其它纤维',只选择其中的一个！"); }
	
	if( componentDetailNum==0 ){ 
		msg.push("请填写至少一种产品成份！");
	}else if( componentDetailNum==componentHeaderNum ){
		//if( componentDetailNum == 1){ msg.push("当只有一种产品成份时，产品名称不需要填写！"); }
	}else if( componentDetailNum!=componentHeaderNum ){
		if( componentHeaderNum!=0 || componentDetailNum!=1){
			msg.push("请正确选择每一种产品成份的名称与成份！");
		}
	}

	//check whether this part need coating
	$("select[name^='part_']").each(function(){
		var t = $(this);
		if( t.val() ){
			var se = $(":selected",t);
			var coat = $("#coating"+t.attr("name").replace("part",""));
			if( se.attr("need_coating")==0 && coat.attr("checked") ){
				msg.push("产品名称("+ se.text() +")不需要加涂层，请改正！");
			}
		}
	});
	
	
	//check the "STEAM PRESSING ONLY",if the option is selected,the corresponding appendix must also been selected.
	if( $("#ironing :selected").attr("styleid") == "6" ){
		var bindfor = "Ironing_6";
		var isOK = 0;
		$("select[name^='appendix']").each(function(){
			if( $(":selected",this).attr("bindfor")==bindfor ){ isOK++ };
		});
		
		if( isOK!=1 ){ msg.push("如果选择了'STEAM PRESSING ONLY',请相应地选择补充说明: '仅用蒸汽熨烫' 或者 '建议蒸汽熨烫'!") }
	}
	
	return msg;	
}




function preview(){

        $('#clPreview').attr('href', '#');
        //$('#clPreview').removeAttr('target')
	
	var msg = checkBeforePreview();
	if(msg.length>0){
		message = "<p>对不起，此订单内容未能生成预览，请依照以下提示修改刚才输入的信息，谢谢。</p><ul>"
		for(i in msg){ message += "<li>" + msg[i] + "</li>"; }
		message += "</ul>";
		
		$.prompt(message,{opacity: 0.6,prefix:'cleanred',buttons:{'OK [确定]':true}} );
		return false;
	}else{
            kw = {
		"origin" : $("#origin").val(),
		"washing" : $("#washing").val(),
		"bleaching" : $("#bleaching").val(),
		"drying" : $("#drying").val(),
		"othersDrying" : $("#othersDrying").val(),
		"ironing" : $("#ironing").val(),
		"dryCleaning" : $("#dryCleaning").val()
            }

            var prefix = ['part_','fibercontent_','percentage_','appendix'];
            for(var i=0;i<prefix.length;i++){
                    $("[name^='"+prefix[i]+"']").each(function(){
                            var t = $(this);
                            kw[t.attr("name")] = t.val();
                    });
            }

            $("[name^='coating_']:checked").each(function(){
                            var t = $(this);
                            kw[t.attr("name")] = t.val();
            });

            $("[name^='microelement_']:checked").each(function(){
                            var t = $(this);
                            kw[t.attr("name")] = t.val();
            });
            var urlStr = '';
            for(var key in kw){
                //alert(key +' : ' + kw[key]);
                urlStr += key+'='+kw[key]+'&'
            }
            url = "/bossinipo/ajaxCareLabelPreview?" + urlStr +"time="+(new Date()).getTime();
            //alert(url)
            //$('#clPreview').attr('href', url);
            window.open(url, '','fullscreen=1,toolbar=0,location=0,directories=0,status=0,menubar=0,resizable=1, scrollbars=1');
            //$('#clPreview').attr('target', '_bank');
        }

	
	/*
	$("#kk").jOverlay({
		  method : "POST",
		  url    : "/bossinipo/ajaxCareLabelPreview?time="+(new Date()).getTime(),
		  data   : kw,
		  imgLoading : '/static/images/ajax-loader.gif'
	});
         */
}


function changePattern(obj){
	
	var prefix = ['origin','washing','bleaching','drying','othersDrying','ironing','dryCleaning',
				  'part','percentage','fibercontent','appendix'];
				  
	for(var i=0;i<prefix.length;i++){
		$("[name^='"+prefix[i]+"']").val("");
	}
	
	$("[name^='coating']").each(function(){
		$(this).removeAttr("checked");
	});
	
	$("templat_main_div5 img").attr("src","/static/images/blank.png");
	
	var t = $(obj);
	var setting = defaultSetting[t.val()];
	
	if( !setting ){ return ;}
	
	var ciList = ['origin','washing','bleaching','drying','othersDrying','ironing','dryCleaning']
	for(var k=0;k<ciList.length;k++){
		var ci = $("#"+ciList[k]);
		ci.val(setting[ciList[k]]);
		ci.change();
	}
		
	var appendixList = setting["appendix"].split("|");
	for(var j=0;j<appendixList.length;j++){
		if(appendixList[j]){
			$("#appendix"+(j+1)).val(appendixList[j]);
		}
	}
	

	var componentList = setting["componentList"];
	var parts = $("select[name^='part_']");
	for(var x=0;x<componentList.length;x++){
		var h = componentList[x];
		var p = $(parts[x]);
		p.val(h['name']);
		var suffix = p.attr('name').replace('part','');
		if(h['coating']){ $("#coating"+suffix).attr("checked",true); }
		
		var dList = h['details'];
		for(var z=0;z<dList.length;z++){
			$("#percentage"+suffix+"_"+z).val(dList[z]['percentage']);
			$("#fibercontent"+suffix+"_"+z).val(dList[z]['fibercontent']);
		}
	}
	
}


