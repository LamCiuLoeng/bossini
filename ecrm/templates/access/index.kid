<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#"
    py:extends="'../master.kid'">

<head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
    <title>r-pac - Account Management</title>
    <script src="/static/javascript/jquery-impromptu.1.5.js" language="javascript"></script>
    
    
    <script language="JavaScript" type="text/javascript">
	//<![CDATA[
	    function toSearch(){
	    	$("form").submit();
	    }
	    
	    function updateGroup(){
	    	var gid = $("#DataTable_groups").val()
	    	if(!gid){
	    		alert("Please select the group first!");
	    		$("#DataTable_groups").focus();
	    	}else{
	    		window.location = "/account/updateGroup/" + gid;
	    	}
	    }
	    
	    function updatePermission(){
	    	var pid = $("#DataTable_permissions").val()
	    	if(!pid){
	    		alert("Please select the Permission first!");
	    		 $("#DataTable_permissions").focus();
	    	}else{
	    		window.location = "/account/updatePermission/" + pid;
	    	}
	    }
	//]]>
	</script>

<script language="JavaScript" type="text/javascript" py:if="tg_flash">
//<![CDATA[
    $(document).ready(function(){
        $.prompt("${tg_flash}",{opacity: 0.6,prefix:'cleanblue',show:'slideDown'});
    });
//]]>
</script>


</head>




<body>

<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
    <td width="36" valign="top" align="left"><img src="/static/images/images/menu_start.jpg"/></td>
    <td width="176" valign="top" align="left"><a href="/account/index"><img src="/static/images/images/menu_am_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="/account/add"><img src="/static/images/images/menu_new_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="javascript:toSearch()"><img src="/static/images/images/menu_search_g.jpg"/></a></td>
    
    <td width="64" valign="top" align="left"><a href="#" onclick="javascript:updateGroup();"><img src="/static/images/images/menu_ug_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="#" onclick="javascript:updatePermission();"><img src="/static/images/images/menu_up_g.jpg"/></a></td>
    
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/static/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/static/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>

</div>

  <div style="overflow:hidden;margin:10px 0px 10px 0px">
      ${search_widget(action=submit_action,value=values)}
  </div>

  <div id="recordsArea">
      ${result_widget.display(items)}

  </div>

</body>
</html>


