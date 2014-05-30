$(document).ready(function(){
    //about the batch update
    $(".batchEditForm").submit(function(){

        batchUpdateIDs = "|"
        $("#recordsArea input[name='PLSRecords'][@checked]").each(function(){
            batchUpdateIDs += $(this).val() + "|";
        });

        $("input[@name='batchUpdateIDs']").val("").val( batchUpdateIDs );
    });


    $("td.dataTD").not(":has(a)").each(function(){
        var str = $(this).text();

        if( str.length > 18 ){
            $(this).text( str.substr(0,16) + ".." );
        }
    });

});

var search_url = "/pls/index";
var export_url = "/pls/export"


function toSearch(){
	$("input[name='pendingType']").remove();
	var f = $(".tableform");
	$(f).append('<input type="hidden" name="criteria" value="'+composeCriteria()+'"/>');
	$(f).attr("action",search_url).submit();
}

function toBatch(){
	var isChecked = false;
	
	$("input[@name='PLSRecords']").each(function(){
	if( $(this).attr("checked") ){
	    isChecked = true;
	}
	});
	
	if( isChecked ){
	$(".batchEditForm").submit();
	}else{
	$.prompt("Please Select at least one record to edit!",{opacity: 0.6,prefix:'cleanred',show:'slideDown'});
	return false;
	}

}

function toCopy(){
	cbs = $("tbody :checked");
	if( cbs.length !=1 ){
	//alert("Please select one record to copy !")
	$.prompt("Please select one record to copy !",{opacity: 0.6,prefix:'cleanred',show:'slideDown'});
	return false;
	}else{
	window.location.href = "/pls/copy/" + $(cbs[0]).val();
	}
}

function toBatchQty(){
	if($(":checked").length == 0){
		$.prompt("Please Select at least one record to edit!",{opacity: 0.6,prefix:'cleanred',show:'slideDown'});
		return false;
	}else{
		$(".batchEditForm").attr("action","/pls/updateBatchQty");
		$(".batchEditForm").submit();
	}
}

function toSearchPendingRPAC(){
    _toSearchPending("rpachk");
}

function toSearchPendingGMI(){
    _toSearchPending("gmi");
}

function _toSearchPending(type){
	//clear the hidden fields
	$("input[name='pendingType']").remove();
    var f = $(".tableform")
	$(f).append('<input type="hidden" name="pendingType" value="'+type+'"/>');
	$(f).append('<input type="hidden" name="criteria" value="'+composeCriteria()+'"/>');
	$(f).attr("action",search_url).submit();
}



function toExport(){
	var f = $(".tableform");
	$(f).attr("action",export_url).submit();
}

function composeCriteria(){
	var criteria = new Array();
	$(".tableform input[type='text']").each(function(){
		var tmp = $(this);
		if( tmp.val() ){
            criteria.push( $("label[for='"+tmp.attr("id")+"']").text() + " : " + tmp.val() );
		}
	});
	
	var sval = $(":selected").text();
	if( sval ){
        criteria.push( "Type : " + sval );
	}
	
	if($("input[name='pendingType']").length>0){
		var pt = $("input[name='pendingType']");
		if(pt.val()=="rpachk"){
			criteria.push( "Printer,Courier and AWB# : FILLED , but Date received the proof : NOT FILL" );
		}else if(pt.val()=="gmi"){
			criteria.push( "Date arrived to GMI and Courier# : FILLED , but Inspection Date : NOT FILL" );
			
		}
	}
	
	return criteria.join("|");
}
 