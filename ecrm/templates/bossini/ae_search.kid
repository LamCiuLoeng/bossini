<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#"
    py:extends="'../master.kid'">

<head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
    <title>r-pac - Bossini</title>
    <link rel="stylesheet" href="/static/css/flora.datepicker.css" type="text/css" media="screen"/>
    <link rel="stylesheet" href="/static/css/jquery.autocomplete.css" type="text/css" />
    
    <script src="/static/javascript/ui.datepicker.js" language="javascript"></script>
    <script src="/static/javascript/jquery-impromptu.1.5.js" language="javascript"></script>
    <script type="text/javascript" src="/static/javascript/jquery.bgiframe.pack.js"></script>
    <script type="text/javascript" src="/static/javascript/jquery.autocomplete.pack.js"></script>
    
	<script language="JavaScript" type="text/javascript" py:if="tg_flash">
	//<![CDATA[
	    $(document).ready(function(){
	        $.prompt("${tg_flash}",{opacity: 0.6,prefix:'cleanblue',show:'slideDown'});
	    });
	//]]>
	</script>

	<script language="JavaScript" type="text/javascript">
	//<![CDATA[
		$(document).ready(function(){

			$('.datePicker').datepicker({ firstDay: 1 , dateFormat: 'yy-mm-dd' });
			
			$(".ajaxSearchField").each(function(){
        var jqObj = $(this);

            jqObj.autocomplete("/bossinipo/getAjaxField", {
                    extraParams: {
                       fieldName: jqObj.attr("fieldName")
                    },
                    formatItem: function(item){
                           return item[0]
                    },
                    matchCase : true
            });

    });
	
			var orderType=$("#form_orderType");
			if (orderType.val()=="H"||orderType.val()=="ST"){
			$("#form_marketList").removeAttr("disabled");
			$("#form_iscomplete").removeAttr("disabled");
			$("#form_poNo").removeAttr("disabled");
			$("#form_legacyCode").removeAttr("disabled");
			$("#form_marketList").css({"display":""});
		    $("#form_iscomplete").css({"display":""});
            $("#form_poNo").css({"display":""});
		    $("#form_legacyCode").css({"display":""});
			}
			else{
			if (orderType.val()=="WOV"){
			$("#form_marketList").removeAttr("disabled");
			$("#form_iscomplete").attr("disabled","true");
			$("#form_poNo").removeAttr("disabled");
			$("#form_legacyCode").removeAttr("disabled");
			$("#form_iscomplete").css({"display":"none"});
			$("#form_marketList").css({"display":""});
			$("#form_poNo").css({"display":""});
			$("#form_legacyCode").css({"display":""});
			}
			else{
			$("#form_marketList").attr("disabled","true");
			$("#form_iscomplete").attr("disabled","true");
			$("#form_poNo").attr("disabled","true");
			$("#form_legacyCode").attr("disabled","true");
			$("#form_iscomplete").css({"display":"none"});
			$("#form_marketList").css({"display":"none"});
			$("#form_poNo").css({"display":"none"});
			$("#form_legacyCode").css({"display":"none"});
			}
			}
			$("select[name^='orderType']").blur(changeOrderType);
		});
	
		function toSearch(){
			$(".tableform").submit();
		}
		
	
	    function showAddDiv(){
			$("#addDiv").fadeIn();
		}
		
		function hiddenAddDiv(){
			$("#addDiv form")[0].reset();
			$("#addDiv").fadeOut();
		}
		
		function saveDate(){
			var _factory_date = $("#hidden_x_factory_date").val();
			var _recepipt_date = $("#hidden_receipt_date").val();
			var checked = $(".recordForm tbody :checked");
			
			if(checked.length<1){
				alert("Please select at least one record to export!");
				return false;
			}else{
				var ids = [];
				checked.each(function(){
					ids.push($(this).val());
				});
				
				$.getJSON("/bossinipo/updateDate",
						  {"x_f_date":_factory_date,"r_date":_recepipt_date,"ids":ids.join("|")},
						  function(res){
						  	if(res.flag == "0"){
						  		$.prompt("[OK] The PO has been updated successfully!",{opacity: 0.6,prefix:'cleanblue',show:'slideDown'});
						  		checked.each(function(){
						  			var t = $(this);
						  			var tr = t.parents("tr")[0];
						  			if( _factory_date ){ $("td:eq(3)",tr).text(_factory_date) };
						  			if( _recepipt_date ){ $("td:eq(4)",tr).text(_recepipt_date) };
						  		});
						  	}else{
						  		$.prompt("[Error] Error occur on the server side!",{opacity: 0.6,prefix:'cleanred',show:'slideDown'});		
						  	}
						  });
						  
				hiddenAddDiv();
			}
		}
		function changeOrderType(){
		var e=$(this);
		if (e.val()=="WOV"){
		$("#form_iscomplete").attr("disabled","true");
		$("#form_iscomplete").css({"display":"none"});
		$("#form_marketList").removeAttr("disabled");
		$("#form_marketList").css({"display":""});
		$("#form_poNo").removeAttr("disabled");
        $("#form_poNo").css({"display":""});
		$("#form_legacyCode").removeAttr("disabled");
		$("#form_legacyCode").css({"display":""});
		}
		else{
        if(e.val()=="H"||e.val()=="ST"){
		$("#form_marketList").css({"display":""});
		$("#form_iscomplete").css({"display":""});
        $("#form_poNo").css({"display":""});
		$("#form_legacyCode").css({"display":""});
		$("#form_marketList").removeAttr("disabled");
		$("#form_iscomplete").removeAttr("disabled");
		$("#form_poNo").removeAttr("disabled");
		$("#form_legacyCode").removeAttr("disabled");
		}
		else{
		$("#form_marketList").css({"display":"none"});
		$("#form_iscomplete").css({"display":"none"});
        $("#form_poNo").css({"display":"none"});
		$("#form_legacyCode").css({"display":"none"});
		$("#form_marketList").attr("disabled","true");
		$("#form_iscomplete").attr("disabled","true");
		$("#form_poNo").attr("disabled","true");
		$("#form_legacyCode").attr("disabled","true");
		}
		}
		
		}
		
		
		
	//]]>
	</script>
</head>




<body>



<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
    <td width="36" valign="top" align="left"><img src="/static/images/images/menu_start.jpg"/></td>
    <td width="176" valign="top" align="left"><a href="/bossinipo/ae_search"><img src="/static/images/images/Bossini_PO_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="#" onclick="javascript:toSearch()"><img src="/static/images/images/menu_search_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="javascript:showAddDiv()"><img src="/static/images/images/fill_date_g.jpg"/></a></td>  
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/static/images/images/menu_last.jpg"/></td>
    <td align="left" valign="top" background="/static/images/images/menu_end.jpg">&nbsp;</td>
  </tr>
</tbody></table>

</div>
<div class="nav-tree">Bossini&nbsp;&nbsp;&gt;&nbsp;&nbsp;Main&nbsp;&nbsp;&gt;&nbsp;&nbsp;Place CONFIRM Order</div>

<div style="width:1200px;">

	<div style="overflow:hidden;margin:5px 0px 10px 0px">
			${search_widget(value=values,action=submit_action)}
	</div>
	<div class="case-list-four" style="display:none" id="addDiv">
	  <form action="/bossinipo/updateDate" method="post" name="addForm">
	  <ul>
	      <li class="label">Exit Factory Date</li>
	      <li><input type="text" value="" name="hidden_x_factory_date" id="hidden_x_factory_date" class="datePicker v_is_date" style="width:200px"/></li>
	  </ul>
	 <ul>
	      <li class="label">Receipt Date</li>
	      <li><input type="text" value="" name="hidden_receipt_date" id="hidden_receipt_date" class="datePicker v_is_date" style="width:200px"/></li>
	  </ul>

	  <ul>
	      <li class="label">Action</li>
	      <li><input type="button" value="Save" onclick="saveDate();"/> <input type="button" value="Cancel" onclick="hiddenAddDiv();"/></li>
	  </ul>
	  </form>
    </div>
</div>
<div style="clear:both"><br /></div>
<div id="recordsArea" py:if="defined('result_widget')">
	<form action="#" method="post" class="recordForm">
		${result_widget.display(items,checkBoxFunction=True)}
	</form>
</div>

</body>
</html>


