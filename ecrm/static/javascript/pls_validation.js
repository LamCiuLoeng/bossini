$(document).ready(function(){
    var dateFormat = 'dd/mm/yy';

    $('.datePicker').datepicker({firstDay: 1 , dateFormat: dateFormat});

    $("form input[type='text'],form select,form textarea").not(".excluded").each(function(){
            $("form").append("<input type='hidden' name='" + $(this).attr("name") + "_backup' value='" + $(this).val() + "'/>");
    });
	
	$("li:has(input[type='checkbox'])").each(function(){
		var liObj = $(this);
		if( $(":checked",liObj).val() ){
			var checkboxObj = $(":checked",liObj);
			$("form").append("<input type='hidden' name='" + checkboxObj.attr("name") + "_backup' value='" + checkboxObj.val() + "'/>");
		}else{
			var checkboxObj = $(":checkbox",liObj);
			$("form").append("<input type='hidden' name='" + checkboxObj.attr("name") + "_backup' value=''/>");
		}
	});


    $(".v_not_empty").attr("jVal",
                "{valid:function (val) { if (val.length < 1) return false; else return true; }, message:'Required', styleType:'cover'}");
    $(".v_is_number").attr("jVal",
                "{valid:/^[0-9]*$/, message:'Numerical', styleType:'cover'}");
    $(".v_is_date").attr("jVal",
                "{valid:function (val) {if(val!=''){return /^[0-9]{2}\\/[0-9]{2}\\/[0-9]{4}$/.test(val) }return true;}, message:'DD/MM/YYYY', styleType:'cover'}");

	//limit the comment's length
	$("textarea").each(function(){
		var ta = $(this);
		ta.textlimit(ta.nextAll("span.comment"),100);
	});
	

    $("form").submit(function(){
            if ( !$('form').jVal() ){
                return false;
            }
				
			//check the r-pac HK and GMI fields	
			if( $("input[name='rpacHKResult']:checked").val() == "Fail" && $("#rpacHKFailComment").val().length < 1 ){
				alert("Please fill in the comment if you select the 'Fail' option for the r-pac HK 'Overall' field!");
				$("#rpacHKFailComment").focus();
				return false;
			}
			
			if( $("input[name='inspectionResult']:checked").val() == "Fail" && $("#inspectionFailComment").val().length < 1 ){
				alert("Please fill in the comment if you select the 'Fail' option for the GMI 'Overall' field!");
				$("#inspectionFailComment").focus();
				return false;
			}
            
            var cbs = ["spotColorStatus","cmykStatus","pressSheetConsistencyStatus","coatingStatus","colorbarStatus",
            			"barCodeStatus","substrateStatus","spgStructurecheckedStatus","rpacHKResult","inspectionResult"]
            var cbLabels = ["Spot Color","CMYK","Press Sheet Consistency","Coating","Color bar and Register marks",
            			"Bar Code","Substrate","SPG Structure checked","r-pac HK Overall","GMI Overall"]
            var err_msgs = new Array();
            for(index in cbs){
            	if($("input[name='"+cbs[index]+"']:checked").length > 1){
            		err_msgs.push("'"+cbLabels[index]+"'");
            	}
            }
            if(err_msgs.length >0){
            	alert("Please select no more than one option for the field(s) : " + err_msgs.join(","));
	            return false;
            }
            
            
            var rpacHKResult = $("input[name='rpacHKResult']:checked");
            if( !rpacHKResult.attr("disabled") && rpacHKResult.val()=="Pass" ){
            alert("OK");
            	if( !$("input[name='printer']").val().trim() || !$("input[name='courier']").val().trim() || !$("input[name='awb']").val().trim() ){
            		alert("Please fill in all the 3 fields : 'Printer','Courier','AWB#' before you select the 'Pass' option for the field : 'r-pac HK Overall'!");
            		return false;
            	}
            }
            
			//end.
			
            $("input[name='updatedFields']").remove();

			updatedFields = new Array();

            $("form input[type='text'],form select,form textarea").not(".excluded").each(function(){

                temp = $(this)
                temp2 = $( "input[name='" + temp.attr("name")+"_backup']" )

                if( temp.val() !=  temp2.val()  )  {
					updatedFields.push( $(this).attr("name") );
                }

                temp2.val($("label[for='" + temp.attr("id") + "']").text())

            });
			
			$("li:has(input[type='checkbox'])").each(function(){
				var liObj = $(this);
				var checkboxObj = $(":checked",liObj);
				var hiddenObj = $("input[name='"+checkboxObj.attr("name")+"_backup']" );
				if( checkboxObj && checkboxObj.val() != hiddenObj.val() ){
					updatedFields.push( checkboxObj.attr("name") );
				}
				hiddenObj.val( liObj.prev().text() );
			});


            if( updatedFields!= ""){
                $("form").append("<input type='hidden' name='updatedFields' value='" + updatedFields.join("|") + "'/>");
            }

			//js about the GMI files
			var rpac_files = new Array();
			$("input[type='file'][name^='"+rpac_prefix+"']" ).each(function(){
				var tmp = $(this);
				if( tmp.val() ){
					rpac_files.push( tmp.attr("name") );
				}
			});
			if( rpac_files.length > 0 ){
				$("form").append("<input type='hidden' name='rpacHK_upload_fields' value='" + rpac_files.join("|") + "'/>");
			}
			
			var gmi_files = new Array();
			$("input[type='file'][name^='"+gmi_prefix+"']" ).each(function(){
				var tmp = $(this);
				if( tmp.val() ){
					gmi_files.push( tmp.attr("name") );
				}
			});
			if( gmi_files.length > 0 ){
				$("form").append("<input type='hidden' name='gmi_upload_fields' value='" + gmi_files.join("|") + "'/>");
			}				

            return true;
    });


});


//JS about the GMI files 

var total_file_count = 0;
var rpac_prefix = "rpac_files_";
var gmi_prefix = "gmi_files_";


function removeFile(prefix,id){
	$("#"+prefix+"div_"+id).remove();
}

function addFile(prefix){
	var id = ++total_file_count;
	var htmlStr = '<div id="'+prefix+'div_'+id+'"><label for="'+prefix+id+'"><b>File Name</b></label>';
	htmlStr += '<input type="text" name="'+prefix+'_name_'+id+'" id="'+prefix+'_name_'+id+'"size="20"  class="excluded"/>&nbsp;&nbsp;';
	htmlStr += '<input type="file" name="'+prefix+id+'" id="'+prefix+id+'" size="60" onchange="getFileName(this);"  class="excluded"/>';
	htmlStr += '<input type="button" value="remove" onclick="removeFile(\''+prefix+'\','+id+')"/></div>';
	$("#"+prefix+"filesCn").append(htmlStr);
}


function getFileName(obj){
    var tmp = $(obj);
	var path = tmp.val();
	if( path && path.length > 0){
		var location = path.lastIndexOf("\\") > -1 ?path.lastIndexOf("\\") + 1 : 0;
		var fn = path.substr( location,path.length-location );	
		tmp.prev("input[type='text']").val(fn);
	}
}




