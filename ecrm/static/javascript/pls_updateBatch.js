dateFields = ["receptDate","agreementFormSendDate","agreementFormApprovalDate","dielineSentDate","dielineApprovalDate",
              "whiteMockupSendDate","whiteMockupApprovalDate","artworkSendDate","artworkApprovalDate","vendorOrderReceivedDate",
              "venderRequestedDeliveryDate","rpacCompleteDate","receivedPaymentDate","venderShipmentDate","rpacPackagingArrivalDate",
              "dateOfPAG","onpressQCDate","qcInspectionDate","sampleSubmissionToTarget","receivedProofDate","gmiArrivedDate","inspectionDate"]

intFields = ["vendorOrderedQty","whiteMockupQty",]

notEmpty = []

function updateFieldValidation(field){
    $("#valueForField").removeAttr("jVal");
    $("#valueForField").datepicker("destroy");


    var dateFormat = 'dd/mm/yy';
    $.each(dateFields,function(i,n){
        if(n==field){
            $("#valueForField").attr("jVal",
                "{valid:function (val) {if(val!=''){return /^[0-9]{2}\\/[0-9]{2}\\/[0-9]{4}$/.test(val) }return true;}, message:'DD/MM/YYYY', styleType:'cover'}");
            $("#valueForField").datepicker({firstDay: 1 , dateFormat: dateFormat});
            return;
        }
    });

    $.each(intFields,function(i,n){
        if(n==field){
            $("#valueForField").attr("jVal",
                "{valid:/^[0-9]+$/, message:'Numerical', styleType:'cover'}");
            return;
        }
    });

}


$(document).ready(function(){
    $("#fieldToUpdate").change(function(){
        updateFieldValidation( $(this).val() );

        $.getJSON("/pls/getSelectedFields?timestamp=" + (new Date()).getTime(),
                  {fieldToUpdate:$(this).val(),batchUpdateIDs:$("input[@name='batchUpdateIDs']").val()},
                  function(returnData){
                      $(".fieldName").text( $("#fieldToUpdate :selected").text() );
                      $("#valueForField").val("");
                      $("#dataShowingArea").html("");

                     $.each(returnData.data,function(i,item){
                         if( i%2 == 0){							 
							 $("#dataShowingArea").append("<tr><td>["+ (i+1) +"] <span>"+item.value+"</span>&nbsp;</td></tr>");
                         }else{
							 $("#dataShowingArea").append("<tr><td bgcolor='#edf3fe'>["+(i+1)+"] <span>"+item.value+"</span>&nbsp;</td></tr>");
                         }

                     });

                     if(returnData.selectRange){
                         var selectElement = '<select id="valueForField" name="valueForField" style="width:350px">';
                         $.each(returnData.selectRange,function(i,item){
                            // selectElement += '<option value="'+ item.id +'">'+ item.value +'</option>';
							selectElement += '<option value="'+ item[0] +'">'+ item[1] +'</option>';
                         });
                         selectElement += '</select>';
                         $("#valueForField").replaceWith(selectElement);
                     }


                     else if( $("select#valueForField").size() > 0  ){
                          $("#valueForField").replaceWith('<input type="text" name="valueForField" id="valueForField" class=""  style="width:350px"/>');
                     }


                 }
        );
    });

    $(".optionForm").submit(function(){
        if ( !$('form').jVal() ){
                return false;
        }

        if (! confirm("There will be more than one records to be updated once,are you sure to continue ?") ){
            return false;
        }
			
		$.getJSON("/pls/saveBatch",
				{	fieldToUpdate : $("#fieldToUpdate :selected").val(),
					valueForField : $("#valueForField").val(),
					batchUpdateIDs : $("#batchUpdateIDs").val(),
					fieldLabel : $("#fieldToUpdate :selected").text()
				},
				function(returnData){
					if(returnData.flag == 0){
						$.prompt(returnData.message,{opacity: 0.6,prefix:'cleanblue',show:'slideDown'});
						$("#dataShowingArea span").text( returnData.updateValue );
					}else{
						$.prompt(returnData.message,{opacity: 0.6,prefix:'cleanred',show:'slideDown'});
					}
				}
		);
		
		return false;
		
    });

}) 