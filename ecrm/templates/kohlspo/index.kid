<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#"
    py:extends="'../master.kid'">

<head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
    <title>r-pac - Kohl's</title>
    <link rel="stylesheet" href="/static/css/flora.datepicker.css" type="text/css" media="screen"/>
    <script src="/static/javascript/ui.datepicker.js" language="javascript"></script>
    <script src="/static/javascript/jquery-impromptu.1.5.js" language="javascript"></script>

    <script src="/static/javascript/custom/kohls_index.js" language="javascript"></script>



<script language="JavaScript" type="text/javascript" py:if="tg_flash">
//<![CDATA[
    $(document).ready(function(){
        $.prompt("${tg_flash}",{opacity: 0.6,prefix:'cleanblue',show:'slideDown'});
    });
//]]>
</script>

	<script py:if="'Admin' not in tg.identity.groups" language="JavaScript" type="text/javascript">
	//<![CDATA[
	    $(document).ready(function(){
			$("input[@type=checkbox]").each(function(){
				var f = $(this).parent().parent();
				var t = $("span",f).html();
				if(t=="R") {
					//$(this).attr("disabled",'True');
					$(this).remove();
				}
			});
	    });
	//]]>
	</script>
	<script language="JavaScript" type="text/javascript">
	//<![CDATA[
	    function overwrite(){
	    	var flag = false;
	    	var arr_po = new Array();
	    	var arr_flag = new Array();
			var arr_id = new Array();

	    	$(":checked").each(function(){
		    var tmp = $(this);
		    id = tmp.val();
		    if(!tmp.attr("po")) return false;
		    arr_id.push(id);
		    arr_po.push(tmp.attr("po"));
		    arr_flag.push(tmp.attr("flag"));
		    flag = true;
	    	});
	    	if(arr_po.length > 2){alert("Please choose just tow PO.");return false;}
			if(arr_po[0] != arr_po[1]){alert("Please choose the same of two PO.");return false;}
			if(arr_flag[0] < 0 && arr_flag[1] < 0){alert("Please choose correctly PO #.");return false;}
	    	if( !flag ){
	    		alert("Please select one other version PO first!");
	    		return false;
	    	}
	    	if(confirm("Are you sure to overwrite the PO with other version ?")){
			$.getJSON(
				"/kohlspo/Replace",
				{header_ids:arr_id},
				function(data){
					if(data["flag"] = "OK"){
						//$("tr:has(input[flag='999'])").remove();
						$(":checked").parent().parent().remove();
					}
				}
			);

	    	}else{
			$.getJSON(
				"/kohlspo/NoReplace",
				{header_ids:arr_id},
				function(data){
					if(data["flag"] = "OK"){
						//$("tr:has(input[flag='0'])").remove();
						$(":checked").parent().parent().remove();
					}
				}
			);
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
    <td width="176" valign="top" align="left"><a href="/kohlspo/index"><img src="/static/images/images/menu_kohls_g.jpg"/></a></td>

    <td width="64" valign="top" align="left"><a href="javascript:toSearch()"><img src="/static/images/images/menu_search_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="#" onclick="resetForm();"><img src="/static/images/images/menu_reset_g.jpg"/></a></td>
    <td width="64" valign="top" align="left" py:if="'KOHLS_EDIT' in tg.identity.permissions"><a href="javascript:productExportBatch()"><img src="/static/images/images/product_export_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"  py:if="tg.identity.user.user_name=='admin'"><a href="javascript:addStatus()"><img src="/static/images/images/menu_addstatus_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"  py:if="'KOHLS_EDIT' in tg.identity.permissions"><a href="javascript:addSO()"><img src="/static/images/images/menu_addso_g.jpg"/></a></td>

    <td width="64" valign="top" align="left" py:if="'KOHLS_EDIT' in tg.identity.permissions"><a href="javascript:toSave()"><img src="/static/images/images/menu_save_g.jpg"/></a></td>
    <td width="64" valign="top" align="left" py:if="'KOHLS_EDIT' in tg.identity.permissions"><a href="javascript:toCancel()"><img src="/static/images/images/menu_cancel_g.jpg"/></a></td>

	<td width="64" valign="top" align="left" py:if="tg.identity.user.user_name=='admin'"><a href="#" onclick="javascript:overwrite();"><img src="/static/images/images/menu_overwrite_g.jpg"/></a></td>
	<td width="64" valign="top" align="left"><a href="/kohlspo/msglist"><img src="/static/images/images/menu_message_g.jpg"/></a></td>
	<td width="64" valign="top" align="left" py:if="tg.identity.user.user_name=='admin'"><a href="/kohlspo/missing"><img src="/static/images/images/menu_missing-g.jpg"/></a></td>

    <td width="23" valign="top" align="left"><img height="21" width="23" src="/static/images/images/menu_last.jpg"/></td>
    <td align="left" valign="top" background="/static/images/images/menu_end.jpg">&nbsp;</td>
  </tr>
</tbody></table>

</div>

		<div style="width:1200px;">
			<div style="overflow:hidden;margin:10px 0px 10px 0px">
					${search_widget(value=values,action=submit_action)}
			</div>
		</div>

		<div id="recordsArea" py:if="defined('result_widget')">
			<form action="/kohlspo/exportBatch" method="post" class="recordForm">
				${result_widget.display(items,checkBoxFunction=True)}
			</form>
		</div>




</body>
</html>


