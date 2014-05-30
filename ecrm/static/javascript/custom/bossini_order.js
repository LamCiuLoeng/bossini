//var currentBillTo = null;

function changeBillTo(e){
	var o = $(e);
	if(o.val()){
		var s = currentBillTo = billToInfo[o.val()];
		$("#billToAddress").val( s.billToAddress );
		$("#billToContact").val(s.billToContact);
		$("#billToTel").val(s.billToTel);
		$("#billToFax").val(s.billToFax);
		$("#currency").val(s.currency);

		$("#needChangeFactory").val(s.needChangeFactory);
		$("#VATInfo").val(s.VATInfo);
		$("#invoiceInfo").val(s.invoiceInfo);
		$("#accountContact").val(s.accountContact);
		
		var b = $("#shipTo");
		b.empty();
		b.append('<option></option>');
		clearShipTo();
		
		for(k in s.shipTo){
			b.append('<option value="'+k+'">'+s.shipTo[k].shipTo+'</option>');
		}		
		if(currency!=s.currency){
			currency = s.currency;
			changeCurrency(s.currency);
		}
		
		
	}else{
		clearBillTo();	
		clearShipTo();
		var b = $("#shipTo");
		b.empty();
		b.append('<option></option>');
		
		currentBillTo = null;
	}
}


function changeShipTo(e){
	var o = $(e);	
	if(o.val()){
		var s = currentBillTo.shipTo[o.val()];
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

/*
function sumTotal(o){
    var e = $(o);
    var tr = e.parents("tr")[0];
    
    var sum = "";
    if(currency=="RMB"){
    	sum = parseFloat(e.attr("rmbprice")) * parseInt(e.val());
    }else if(currency=="HKD"){
    	sum = parseFloat(e.attr("hkprice")) * parseInt(e.val());
    }
    
    if(sum){
        $(".pcAmt",tr).text(sum);
    }
}
*/


function changeCurrency(c){
	refreshPC();
	refreshWL();
}


function changeCurrency4PL(attrName){
	$(".pcQty").each(function(){
		var tmp = $(this);
		var tr = tmp.parents("tr")[0];
		$(".pcUnitPrice",tr).text( tmp.attr(attrName) );
		
		var sum = parseInt(tmp.val()) * parseFloat(tmp.attr(attrName));
		if(sum){
			$(".pcAmt",tr).text(sum);
		}
	});
}


function changeCurrency4WL(attrName){
	var mainSum = 0;
	var sizeSum = 0;
		
	$(".wlQty").each(function(){
		var tmp = $(this);
		var labelType = $("select[name='"+tmp.attr("ref")+"']");
		if(labelType.val()=="Main Label"){
			mainSum += parseInt(tmp.val()) * parseFloat(tmp.attr(attrName));
		}else if(labelType.val()=="Size Label"){
			sizeSum += parseInt(tmp.val()) * parseFloat(tmp.attr(attrName));
		}
	});
	
	if(mainSum){$("#mainLabelSum").text(mainSum);}
	if(sizeSum){$("#sizeLabelSum").text(sizeSum);}
	
}


function getSize(){
    var o = $(this);
    var c = null;
    if(o.hasClass("col-left")){
    	c = "col-left";
    }else if(o.hasClass("col-right")){
    	c = "col-right";
    }
    
    if(!c){return;}
    
    var tr = o.parents("tr")[0];
    
    $.get("/bossinipo/ajaxSizeInfo",
    	  {"size" : o.val()},
    	  function(data){
    	  	var str = "";
    	  	$.each(data.split(";"),function(i,d){
    	  		str += "<option value='"+d+"'>"+d+"</option>";
    	  	});
    	  	
    	  	var measureObj = $(".measure",tr).filter("."+c);
    	  	measureObj.empty();
    	  	measureObj.append(str);
    	  	
     });
}
       
       
       
function toSave(){
    $("form").submit();
} 

function toCancel(o){
    if(confirm("All the update won't save.Are you sure to leave the page?")){
        window.location = $(o).attr("hrefBack");
    }
    return false;
}



function refreshPC(){
	if(!currency){return;}
	$(".pcQty").each(function(){
		var o = $(this);
		var tr = o.parents("tr")[0];
		if(o.val()){
			if(currency=='RMB'){
				$(".pcUnitPrice",tr).text(o.attr("rmbPrice"));
				
				var sum = parseInt(o.val())*parseFloat(o.attr("rmbPrice"));
				if(sum){ $(".pcAmt",tr).text(sum); }
	
			}else if(currency=='HKD'){
				$(".pcUnitPrice",tr).text(o.attr("hkPrice"));
				
				var sum = parseInt(o.val())*parseFloat(o.attr("hkPrice"));
				if(sum){$(".pcAmt",tr).text(sum);}
				
			}
		}		
	});
}


function checkLeftOrRight(e){
	if(e.hasClass("col-left")){
		return "col-left";
	}else if(e.hasClass("col-right")){
		return "col-right";
	}
	return "";
	
}

function refreshWL(){
	if(!currency){return;}
	
	var mainSum = 0;
	var mainPrice = 0;
	var sizeSum = 0;
	var sizePrice = 0;
	
	$(".wlQty").each(function(){
		var o = $(this);
		if(o.val()){	
			var tr = o.parents("tr")[0];		
			var type = $("select[name*='_labelType_']."+checkLeftOrRight(o),tr);
			
			if(type.val()=='Main Label'){
				if(currency=='RMB'){
					mainSum += parseInt(o.val()) * parseFloat(o.attr("rmbPrice"));
					mainPrice = o.attr("rmbPrice");
				}else if(currency=='HKD'){
					mainSum += parseInt(o.val()) * parseFloat(o.attr("hkPrice"));
					mainPrice = o.attr("hkPrice");
				}
			}else if(type.val()=='Size Label'){
				if(currency=='RMB'){
					sizeSum += parseInt(o.val()) * parseFloat(o.attr("rmbPrice"));
					sizePrice = o.attr("rmbPrice");
				}else if(currency=='HKD'){
					sizeSum += parseInt(o.val()) * parseFloat(o.attr("hkPrice"));
					sizePrice = o.attr("hkPrice");
				}
			}
		}
	});
	
	$("#mainPrice").text(mainPrice);
	$("#sizePrice").text(sizePrice);
	$("#mainLabelSum").text(mainSum);
	$("#sizeLabelSum").text(sizeSum);
	$("#totalSum").text( mainSum+sizeSum );
}



/* ------------------------------------  */

$(document).ready(function(){
	$('.datePicker').datepicker({firstDay: 1 , dateFormat: 'dd/mm/yy'});
	
	$(".numeric").numeric();
    
    $(".pcQty,.pcItem").change(refreshPC);
    
    
    $(".col-left,.col-right").not(".measure").not("[name*='_size_']").change(refreshWL);
    
    $("select[name^='owl_size_'],select[name^='nwl_size_']").change(getSize);
    
    
	/*----------------------- ajax for printing card -----------*/
	$(".pcItem").each(function(){
        var jqObj = $(this);
            jqObj.autocomplete("/bossinipo/ajaxItemInfo", {
               /*     extraParams: {
                       fieldName: jqObj.attr("fieldName")
                    }, */
                    formatItem: function(data){
                           return data[0];
                    },
                    matchCase : true
            }).result(function(event,data){            
            	var tr = jqObj.parents("tr")[0];
            	var qtyInput = $(".pcQty",tr);
            	
            	qtyInput.attr("rmbprice",data[1]);
            	qtyInput.attr("hkprice",data[2]);
            });

    });
    
    /*---------- ajax for the woven label ----------------*/
    $(".wlItem").each(function(){
        var jqObj = $(this);
            jqObj.autocomplete("/bossinipo/ajaxItemInfo", {
               /*     extraParams: {
                       fieldName: jqObj.attr("fieldName")
                    }, */
                    formatItem: function(data){
                           return data[0];
                    },
                    matchCase : true
            }).result(function(event,data){
            	var tr = jqObj.parents("tr")[0];
            
            	if(jqObj.hasClass("col-left")){
            		var q = $(".wlQty",tr).filter(".col-left");            		
            	}else{
            		var q = $(".wlQty",tr).filter(".col-right");
            	}
            	q.attr("rmbprice",data[1]);
            	q.attr("hkprice",data[2]);
            });

    });
    
    
    /*--------------- backup the orgin value for the update fields -----------------*/
    var backupDIV = $('<div id="backupDIV" style="display:none"></div>');
    $(".templat_main_div1 input,.templat_main_div1 textarea,.templat_main_div2 input,.templat_main_div2 textarea").each(function(){
    	var tmp = $(this);
		backupDIV.append('<input type="hidden" name="'+tmp.attr("name")+'_backup" value="'+tmp.val()+'"/>');    	
    });
    
    $(".templat_main_div1 select,.templat_main_div2 select").each(function(){
    	var tmp = $(this);
    	backupDIV.append('<input type="hidden" name="'+tmp.attr("name")+'_backup" value="'+tmp.val()+'"/>');    	
    });
    
    $("input[name^='opc_'],input[name^='owl_']").each(function(){
    	var tmp = $(this);
    	backupDIV.append('<input type="hidden" name="'+tmp.attr("name")+'_backup" value="'+tmp.val()+'"/>');
    });
    
    $("select[name^='owl_'],select[name^='opc_']").each(function(){
    	var tmp = $(this);
    	backupDIV.append('<input type="hidden" name="'+tmp.attr("name")+'_backup" value="'+tmp.val()+'"/>');   
    });
    
    $("body").append(backupDIV);
    
    
    $("form").submit(formAction);
    

});
                    


function formAction(){
	$("#changedFields").remove();
	var f = $(this);
	var changedFields = [];
	var objList = []
	var selectors = [".templat_main_div1 input,.templat_main_div1 textarea,.templat_main_div2 input,.templat_main_div2 textarea"
					,".templat_main_div1 select,.templat_main_div2 select",
					"input[name^='opc_'],input[name^='owl_']","select[name^='owl_'],select[name^='opc_']"];
		
		
	for(var i=0;i<selectors.length;i++){
		$(selectors[i],f).each(function(){
			var t = $(this);
			var b = $("input[name='"+t.attr("name")+"_backup']");
			if(t.val()!=b.val()){
				changedFields.push(t.attr("name"));
				objList.push(b);
			}
		});
	}
	
	f.append('<input type="hidden" id="changedFields" name="changedFields" value="'+changedFields.join("|")+'"/>');
	alert(changedFields.join("|"));
	for(var j=0;j<objList.length;j++){
		f.append(objList[j]);
	}
	//return false;
}


                