<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#"
    py:extends="'../master.kid'">

<head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
    <title>r-pac - Account Management</title>
    <script src="/static/javascript/jquery-impromptu.1.5.js" language="javascript"></script>
    
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


    <td width="23" valign="top" align="left"><img height="21" width="23" src="/static/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/static/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>

</div>

  <div style="overflow:hidden;margin:10px 0px 10px 0px">
  	  <div style="float:left">
	      <div> 			
	      		${userWidget(action="/account/saveNewUser")}
	      </div>
	      
	      <div>
	      		${groupWidget(action="/account/saveNewGroup")}
	      </div>
	      
	      <div>
	      		${permissionWidget(action="/account/saveNewPermission")}
	      </div>
      </div>
  </div>


</body>
</html>


