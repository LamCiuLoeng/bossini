$(document).ready(function(){
	align( $("#source li[@objectType='PO1']"),$("#target li[@objectType='PO1']") );
	
	var sPO1 = $("#source li[@objectType='PO1']");
	var tPO1 = $("#target li[@objectType='PO1']");
	for(var i=0;i<sPO1.length;i++){
		var sObj = $(sPO1[i]);
		var tObj = $(tPO1[i]);
		align($("li[@objectType='SLN']",sObj),$("li[@objectType='SLN']",tObj));
	}	
	
	$("#target span[@checkpoint]").each(function(){
		var target = $(this);
		var source = $("#source span[@checkpoint='"+target.attr("checkpoint")+"']")
		if( target.text() != source.text() ){
			source.addClass("diffsource");
			target.addClass("difftarget");
		}
	});

});

function checkAfter(){
	$("#target span[@checkpoint]").each(function(){
		var target = $(this);
		var source = $("#source span[@checkpoint='"+target.attr("checkpoint")+"']")
		if( target.text() != source.text() ){
			source.addClass("diffsource");
			target.addClass("difftarget");
		}
	});
}

function align(sList,tList){
	var sIndex = 0; var tIndex = 0;
	while( sIndex < sList.length && tIndex < tList.length ){
		var sObj = $(sList[sIndex]);
		var tObj = $(tList[tIndex]);
		
		//1. the UPC is same
		if( sObj.attr("UPC") == tObj.attr("UPC") ){
			sIndex += 1;
			tIndex += 1;
		}
		//2. the sPO1's UPC is large
		else if( sObj.attr("UPC") > tObj.attr("UPC")){
			//add the target's PO1 to the source with blank value.
			var tmp = tObj.clone();
			$("span",tmp).text("---missed---");
			sObj.before(tmp);
			//add the tIndex
			tIndex += 1;
		}
		//3. the tPO1's UPC is large
		else{
			//add the source's PO1 to the target with blank value.
			var tmp = sObj.clone();
			$("span",tmp).text("---missed---");
			tObj.before(tmp);
			//add the sIndex
			sIndex += 1;		
		}
				
		//add the left of the source to the target if no child in the target
		if(tIndex==tList.length){	
			var tParent = tObj.parent();	
			for(;sIndex<sList.length;sIndex++){
				var tail = $(sList[sIndex]).clone();
				$("span",tail).text("---missed---");
				tParent.append(tail);
			}
			break;
		}
		//add the left of the target to the source if no child in the source
		else if(sIndex==sList.length){	
			var sParent = sObj.parent();	
			for(;tIndex<tList.length;tIndex++){
				var tail = $(tList[tIndex]).clone();
				$("span",tail).text("---missed---");
				sParent.append(tail);
			}
			break;
		}
	}
}


function showDiffOnly(){
	$("#source span:not([@class*='diffsource'])").parent("li").fadeOut();
	$("#target span:not([@class*='difftarget'])").parent("li").fadeOut();
}

function showAll(){
	$("#source span:not([@class*='diffsource'])").parent("li").fadeIn();
	$("#target span:not([@class*='difftarget'])").parent("li").fadeIn();
}
