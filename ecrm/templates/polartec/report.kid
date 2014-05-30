<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#"
    py:extends="'../master.kid'">

<head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
    <title>r-pac - Polartec</title>
    <link rel="stylesheet" href="/static/css/flora.datepicker.css" type="text/css" media="screen"/>
    <link rel="stylesheet" href="/static/css/jquery.autocomplete.css" type="text/css" />
    
    <script src="/static/javascript/ui.datepicker.js" language="javascript"></script>
    <script src="/static/javascript/jquery-impromptu.1.5.js" language="javascript"></script>
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
	        
	    });
	//]]>
	</script>
	
	<script language="JavaScript" type="text/javascript">
	//<![CDATA[
	    function us_report(){
	    	$("#us_report").attr("action","/polartec/export?type=US").submit();
	    }
	    
	    function no_us_report(){
	    	$("#no_us_report").attr("action","/polartec/export?type=NOUS").submit();
	    }
	//]]>
	</script>

</head>

<body>

<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
    <td width="36" valign="top" align="left"><img src="/static/images/images/menu_start.jpg"/></td>
    <td width="176" valign="top" align="left"><a href="/polartec/report"><img src="/static/images/images/menu_polartec_g.jpg"/></a></td>

    
    <!--td width="64" valign="top" align="left"><a href="javascript:exportBatch()"><img src="/static/images/images/menu_export_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="#" onclick="javascript:toExport();"><img src="/static/images/images/menu_export_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="javascript:addSO()"><img src="/static/images/images/menu_addso_g.jpg"/></a></td>  
    
    <td width="64" valign="top" align="left"><a href="javascript:toSave()"><img src="/static/images/images/menu_save_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="javascript:toCancel()"><img src="/static/images/images/menu_cancel_g.jpg"/></a></td-->

    <td width="23" valign="top" align="left"><img height="21" width="23" src="/static/images/images/menu_last.jpg"/></td>
    <td align="left" valign="top" background="/static/images/images/menu_end.jpg">&nbsp;</td>
  </tr>
</tbody></table>

</div>



<div style="width:1200px;">
	<div style="overflow:hidden;margin:10px 0px 10px 0px">   
		<form id="us_report" method="post" onsubmit="us_report();">
			<input type="submit" value="Generate Reports(With US)"/>
		</form>
	</div>
	<div style="overflow:hidden;margin:10px 0px 10px 0px">   
		<form id="no_us_report" method="post" onsubmit="no_us_report();">
			<input type="submit" value="Generate Reports(Without US)"/>
		</form>
	</div>
</div>
		
		
		

		
		
</body>
</html>


