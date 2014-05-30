<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#"
    py:extends="'../master.kid'">

<head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
    <title>r-pac - Disney</title>
    <link rel="stylesheet" href="/static/css/flora.datepicker.css" type="text/css" media="screen"/>
    <link rel="stylesheet" href="/static/css/jquery.autocomplete.css" type="text/css" />
    
    <script src="/static/javascript/ui.datepicker.js" language="javascript"></script>
    <script src="/static/javascript/jquery-impromptu.1.5.js" language="javascript"></script>
    <script type="text/javascript" src="/static/javascript/jquery.autocomplete.pack.js"></script>
    
    <script type="text/javascript" src="/static/javascript/custom/disney_report.js"></script>
    
	<script language="JavaScript" type="text/javascript" py:if="tg_flash">
	//<![CDATA[
	    $(document).ready(function(){
	        $.prompt("${tg_flash}",{opacity: 0.6,prefix:'cleanblue',show:'slideDown'});
	    });
	//]]>
	</script>
	
	<script language="JavaScript" type="text/javascript">
	//<![CDATA[
	    
	//]]>
	</script>

</head>

<body>

<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
    <td width="36" valign="top" align="left"><img src="/static/images/images/menu_start.jpg"/></td>
    <td width="95" valign="top" align="left"><a href="/disney/report"><img src="/static/images/images/menu_disney_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="#" onclick="javascript:toExport();"><img src="/static/images/images/menu_export_g.jpg"/></a></td>

    <td width="23" valign="top" align="left"><img height="21" width="23" src="/static/images/images/menu_last.jpg"/></td>
    <td align="left" valign="top" background="/static/images/images/menu_end.jpg">&nbsp;</td>
  </tr>
</tbody></table>

</div>



<div style="width:1200px;">
	<div style="overflow:hidden;margin:10px 0px 10px 0px">   
		<form action="/disney/reportDetail" method="post" name="reportForm">
			<table cellspacing="0" cellpadding="0" border="0" class="export">
			    <thead>
			        <tr>
			        <th> </th>
			        <th>From</th>
			        <th>To</th>
			        </tr>
			    </thead>
			    <tbody>
                                <!--
			        <tr>
			            <th><label for="in_so_no_fr" class="fieldlabel">Company:</label></th>
			            <td>
							<select name="ln_company_code" style="width:250px;" id="ln_company_code">
								<option value="RPAC">r-pac Hong Kong</option>
								<option value="RPACPACK">r-pac Packaging</option>
								<option value="RPACSZ">美皇貿易(深圳)有限公司</option>
							</select>
						</td>
						<td>&nbsp;</td>
			        </tr>
                                 -->
			        <tr>
			            <th><label for="in_issue_date_fr" class="fieldlabel">SO Issue Date :</label></th>
			            <td><input type="text" class="datePicker" name="in_issue_date_fr" id="in_issue_date_fr"/></td>
			            <td><input type="text" class="datePicker" name="in_issue_date_to"/></td>
			        </tr>
			    </tbody>
			</table>
		</form>
	</div>
</div>
		
		
		

		
		
</body>
</html>


