<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#"
    py:extends="'../master.kid'">

<head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
    <title>r-pac - Bossini</title>
    <link rel="stylesheet" href="/static/css/flora.datepicker.css" type="text/css" media="screen"/>
    <script src="/static/javascript/ui.datepicker.js" language="javascript"></script>
    <script src="/static/javascript/jquery-impromptu.1.5.js" language="javascript"></script>
    
    <link rel="stylesheet" href="/static/css/jquery.autocomplete.css" type="text/css" />
    
    <script type="text/javascript" src="/static/javascript/jquery.bgiframe.pack.js"></script>
    <script type="text/javascript" src="/static/javascript/jquery.autocomplete.pack.js"></script>
    
    <script type="text/javascript" src="/static/javascript/bossini_ac.js"></script>

    <script src="/static/javascript/custom/bossini_index.js" language="javascript"></script>



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
    <td width="176" valign="top" align="left"><a href="/bossinipo/index"><img src="/static/images/images/Bossini_PO_g.jpg"/></a></td>

    <td width="64" valign="top" align="left"><a href="#" onclick="javascript:toSearch()"><img src="/static/images/images/menu_search_g.jpg"/></a></td>
    
    <!--
    <td width="64" valign="top" align="left"><a href="#" onclick="resetForm();"><img src="/static/images/images/menu_reset_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="#" onclick="javascript:exportBatch()"><img src="/static/images/images/menu_export_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="/bossinipo/export" onclick="javascript:export()"><img src="/static/images/images/SearchExport_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="#" onclick="javascript:toProduct()"><img src="/static/images/images/menu_pro_g.jpg"/></a></td>
    -->
    
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/static/images/images/menu_last.jpg"/></td>
    <td align="left" valign="top" background="/static/images/images/menu_end.jpg">&nbsp;</td>
  </tr>
</tbody></table>

</div>
<div class="nav-tree">Bossini&nbsp;&nbsp;&gt;&nbsp;&nbsp;Main</div>
<div style="width:1200px;">
	<div style="overflow:hidden;margin:5px 0px 10px 0px">
			${search_widget(value=values,action=submit_action)}
	</div>
</div>

<div id="recordsArea" py:if="defined('result_widget')">
	<form action="/bossinipo/exportBatch" method="post" class="recordForm">
		${result_widget.display(items,checkBoxFunction=True)}
	</form>
</div>

</body>
</html>


