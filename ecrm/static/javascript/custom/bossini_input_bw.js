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
		var item = $("select[name='item']",tr)
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
    
    $("[enterindex]").enter2Tab({'compare':function(a,b){return parseInt(a)-parseInt(b);}});
        
	$(".numeric").numeric();
	
	$('.photo').fancyZoom({directory:'/static/images/fancyZoom'});
	
    /*------------ ajax for the Hang tag and Waist card ------------ */
    //$("select[name^='npc_cardType_']").blur(ajaxHangTagWaistCard);
    
    
    /*------------ change the price and amt when user select the item ---------- */
    $("select[name^='item']").blur(changeQtyAmt);
    
    
    /*--------------- update the qty when the sample and the wastage ------------*/
    $("input[name='shipmentQty']").blur(refreshDetailQty);

    $(".img_show").change(function(){
		var t = $(this);
		var sid = $(":selected",this).attr("styleID");
                var num=$(":selected",this).attr("numID");
		if(sid){
			var src = "/static/images/bossini/care_label/EXP/EXP_"+t.attr("name")+"_"+sid+".jpg";
                        var text_num = num;
		}else{
			var src = "/static/images/blank.png";
                        var text_num = '';
		}
		$("#"+t.attr("name")+"_img").attr("src",src);
                $("#"+t.attr("name")+"_styleID").text(text_num);

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
            
});


                    
function attachItem(item,data){
	for(i in data){
		item.append('<option value="'+ data[i].id +'" rmbPrice="'+ data[i].rmbPrice +'" hkPrice="'+ data[i].hkPrice +'">'+ data[i].itemCode +'</option>');
	}
}


 		
/*
	prompt to alert the user whether he/she want to confirm the order.
*/

function toConfirm(){
	var msg = checkInput();
	if(msg.length>0){
		message = "<p>对不起，订单未能正确提交，请依照以下提示修改刚才输入的信息，谢谢</p><ul>"
		for(i in msg){message += "<li>" + msg[i] + "</li>";}
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
	    		 		$("form").submit();
	    		 	}
	    		 }
	    		}
	    );
}


/* 
	validate the form when submit
*/

function checkInput(){
	var msg = Array();

	if( !$("input[name='customerOrderNo']").val() ){ 
		msg.push("请填写\"客户订单号\"。");
                $("input[name='customerOrderNo']").addClass("validation-failed");
	}else{
		var checkReg = /\\|\/|\*|\?|\||'|:|<|>/;
		var orderNo = $("input[name='customerOrderNo']").val();
		if( checkReg.test(orderNo) ){
                    msg.push("请更正\"客户订单号\"中的特殊字符，例如'\\','/',':','*','?','<','>','|'。");
                    $("input[name='customerOrderNo']").addClass("validation-failed");
                }else{
                    $("input[name='customerOrderNo']").removeClass("validation-failed");
                }
	}

	if( $("select[name='item'][value]").length < 1 ){
            msg.push("请选择至少一个产品号码！");
            $("select[name='item']").addClass("validation-failed");
        }else{
            $("select[name='item']").removeClass("validation-failed");
        }

	if( !$("input[name='shipmentQty']").val() ){
            msg.push("请填写\"船头办需要的数量\"。");
            $("input[name='shipmentQty']").addClass("validation-failed");
        }else{
            $("input[name='shipmentQty']").removeClass("validation-failed");
        }
	
	//if( !$("input[name='wastageQty']").val() ){msg.push("请填写\"损耗率\"。");}

        var validate=true;
        $("select[name^='measure_']").each(function(){
            if($(this).val()==''){
                validate=false;
                $(this).addClass("validation-failed");
            }else{
                $(this).removeClass("validation-failed");
            }
        })
        if(!validate){
            msg.push("请填写所有的'Size(no.)'！");
        }

        if( !$("#washing").val() ){
            msg.push("请选择'洗水'！");
            $("#washing").addClass("validation-failed");
        }else{
            $("#washing").removeClass("validation-failed");
        }

	if( !$("#bleaching").val() ){
            msg.push("请选择'漂白'！");
            $("#bleaching").addClass("validation-failed");
        }else{
             $("#bleaching").removeClass("validation-failed");
        }

	if( !$("#ironing").val() ){
            msg.push("请选择'烫熨'！");
            $("#ironing").addClass("validation-failed");
        }else{
            $("#ironing").removeClass("validation-failed");
        }

	if( !$("#dryCleaning").val() ){
            msg.push("请选择'干洗'！");
            $("#dryCleaning").addClass("validation-failed");
        }else{
            $("#dryCleaning").removeClass("validation-failed");
        }

	if( !$("#drying").val() && !$("#othersDrying").val() ){
		msg.push("请选择'晾干'或者'其它晾干'中的一项！");
                $("#drying").addClass("validation-failed");
	}else{
            $("#drying").removeClass("validation-failed");
        }

	if( $("#drying").val() && $("#othersDrying").val() ){
		msg.push("请选择'晾干'或者'其它晾干'中的一项！");
                $("#othersDrying").addClass("validation-failed");
	}else{
            $("#othersDrying").removeClass("validation-failed");
        }

        var componentDetailNum = 0;
	var correctComponent = true;
	var correctPercentage = true;

        var count = 0;
        var isFill = false;
        $("input[name^='percentage']").each(function(){
            var ie = $(this);
            var fc = $("#"+ie.attr("name").replace("percentage","fibercontent"));

            if(ie.val()){
                //count+=parseInt(ie.val());
                count+=parseFloat(ie.val());
                isFill = true;
                if(!fc.val()){
                    correctComponent = false;
                }
            }else if(fc.val()){
                correctComponent = false;
                isFill = true;
            }
        });

        if(isFill){
            componentDetailNum++;
            if( count!=100 ){
                correctPercentage = false;
            }
        }

        if( !correctPercentage ){
            msg.push("请正确输入每个产品的组成成分，要求百分比总和为100！");
            $('#component').addClass("validation-failed");
        }
        if( !correctComponent ){
            msg.push("请正确填写产品名称中每个成分对应的百分比以及组成成分！");
            $('#component').addClass("validation-failed");
        }
        if( componentDetailNum==0 ){
		msg.push("请填写至少一种产品成份！");
                $('#component').addClass("validation-failed");
        }

        if(correctPercentage && correctComponent && componentDetailNum > 0){
            $('#component').removeClass("validation-failed");
        }

	return msg;
}


/*
	refresh all the qty related to the sample and wastage.
*/
function refreshDetailQty(){
	var shipmentQty = $("input[name='shipmentQty']").val();
	if(!shipmentQty){
		return ;
	}
	
	shipmentQty = parseInt(shipmentQty);
	
	
	var qty = $("#detailTable tr.detailTR td:nth-child(1)");
	var ship = $("#detailTable tr.detailTR td:nth-child(2)");
	var total = $("#detailTable tr.detailTR td:nth-child(3)");
	
	var sumTotal = 0;
	
	for(var i=0;i<ship.length;i++){

		var q = parseInt($(qty[i]).text());
		var s = q+shipmentQty;
		var t = s;
		
		//t =  Math.ceil(t/10)*10;
		
		$(ship[i]).text(s);
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
	
	//var cardType = $("select[name^='npc_cardType_']",tr).val();
	var urlPrefix = "/static/images/bossini/";
	
		if(e.text()){
			$(".hangTagImg").attr("src",urlPrefix+e.text()+".jpg");
		}else{
			$(".hangTagImg").attr("src","/static/images/blank.png");
		}

	

}


       
