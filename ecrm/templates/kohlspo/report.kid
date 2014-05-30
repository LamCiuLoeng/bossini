<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#"
    py:extends="'../master.kid'">

<head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
    <title>r-pac - Kohl's</title>
    <link rel="stylesheet" href="/static/css/flora.datepicker.css" type="text/css" media="screen"/>
    <link rel="stylesheet" href="/static/css/jquery.autocomplete.css" type="text/css" />
    
    <script src="/static/javascript/ui.datepicker.js" language="javascript"></script>
    <script src="/static/javascript/jquery-impromptu.1.5.js" language="javascript"></script>
    <script type="text/javascript" src="/static/javascript/jquery.autocomplete.pack.js"></script>
    
    <script type="text/javascript" src="/static/javascript/custom/kohls_report.js"></script>
    
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
	        $("#report_type").change(function(){
	        	if( $(this).val()=="m" ){
	        		$("#show_charge").attr("disabled","true");
	        	}else{
	        		$("#show_charge").removeAttr("disabled");
	        	}
	        });
	    });
	//]]>
	</script>

</head>

<body>

<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
    <td width="36" valign="top" align="left"><img src="/static/images/images/menu_start.jpg"/></td>
    <td width="176" valign="top" align="left"><a href="/kohlspo/index"><img src="/static/images/images/menu_kohls_g.jpg"/></a></td>

    <td width="64" valign="top" align="left"><a href="#" onclick="javascript:toExport();"><img src="/static/images/images/menu_export_g.jpg"/></a></td>
    
    <!--td width="64" valign="top" align="left"><a href="javascript:exportBatch()"><img src="/static/images/images/menu_export_g.jpg"/></a></td>
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
		<form action="/kohlspo/reportDetail" method="post" name="reportForm">
			<table cellspacing="0" cellpadding="0" border="0" class="export">
			    <thead>
			        <tr>
			        <th> </th>
			        <th>From</th>
			        <th>To</th>
			        </tr>
			    </thead>
			    <tbody>
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
			        <tr>
			            <th><label for="in_issue_date_fr" class="fieldlabel">Issue Date :</label></th>
			            <td><input type="text" class="datePicker" value="" name="in_issue_date_fr" id="in_issue_date_fr"/></td>
			            <td><input type="text" class="datePicker" value="" name="in_issue_date_to"/></td>
			        </tr>
			        <tr>
			            <th><label for="in_so_no_fr" class="fieldlabel">SO No.:</label></th>
			            <td><input type="text"  value="" name="in_so_no_fr" id="in_so_no_fr"/></td>
			            <td><input type="text"  value="" name="in_so_no_to"/></td>
			        </tr>
			        <tr>
			            <th><label for="in_supl_code" class="fieldlabel">Supplier Code:</label></th>
			            <td><input type="text"  value="" name="in_supl_code" id="in_supl_code"/></td>
			            <td>&nbsp;</td>
			        </tr>
			        <tr>
			            <th><label for="in_supl_name" class="fieldlabel">Supplier Name:</label></th>
			            <td><input type="text"  value="" name="in_supl_name" id="in_supl_name" class="ajaxSearchField"/></td>
			            <td>&nbsp;</td>
			        </tr>
			        <!--tr>
			            <th><label for="in_item_name" class="fieldlabel">Item Name:</label></th>
			            <td><input type="text"  value="" name="in_item_name" id="in_item_name"/></td>
			            <td>&nbsp;</td>
			        </tr-->
			        <tr>
			            <th><label for="in_item_code" class="fieldlabel">Item Code:</label></th>
			            <td><input type="text"  value="" name="in_item_code" id="in_item_code" class="ajaxSearchField"/></td>
			            <td>&nbsp;</td>
			        </tr>
			        <tr>
			            <th><label for="in_item_cat" class="fieldlabel">Packaging Category:</label></th>
			            <td>
							<select name="in_item_cat" style="width:250px;" id="in_item_cat">
								<OPTION VALUE=''></OPTION>
								<OPTION VALUE='BX'>Boxes</OPTION>
								<OPTION VALUE='BU'>Buttons</OPTION>
								<OPTION VALUE='IP'>Internal Packaging</OPTION>
								<OPTION VALUE='LA'>Labels</OPTION>
								<OPTION VALUE='PI'>Paper Items</OPTION>
								<OPTION VALUE='PA'>Patches</OPTION>
								<OPTION VALUE='PL'>Plastic</OPTION>
								<OPTION VALUE='PN'>Pins</OPTION>
								<OPTION VALUE='SF'>Snap fasteners</OPTION>
								<OPTION VALUE='SP'>Specialty</OPTION>
								<OPTION VALUE='ST'>Stickers</OPTION>
								<OPTION VALUE='TP'>Tape</OPTION>
								<OPTION VALUE='ZP'>Zipper pullers</OPTION>
								<OPTION VALUE='ZI'>Zippers</OPTION>
							</select>
						</td>
						<td>&nbsp;</td>
			        </tr>
			        <tr>
			            <th><label for="in_sub_cat1" class="fieldlabel">Packaging Type:</label></th>
			            <td>
							<select name="in_sub_cat1" style="width:250px;" id="in_sub_cat1">
								
							</select>
						</td>
						<td>&nbsp;</td>
			        </tr>
			        <!--tr>
			        	<th><label for="dnDetail" class="fieldlabel">Include DN detail:</label></th>
			        	<td><select name="dnDetail" id="dnDetail" style="width:250px;">
			        		<option value="no">No</option>
			        		<option value="yes">Yes</option>
			        	</select></td>
			        	<td>&nbsp;</td>
			        </tr-->
			        
			        <tr>
			        	<th><label for="report_type" class="fieldlabel">Report Type:</label></th>
			        	<td><select name="report_type" id="report_type" style="width:250px;">
			        		<option value="m">Monthly</option>
			        		<option value="q">Quarterly</option>
			        	</select></td>
			        	<td>&nbsp;</td>
			        </tr>
			        
			        <tr>
			        	<th><label for="show_charge" class="fieldlabel">Show Charge:</label></th>
			        	<td><select name="show_charge" id="show_charge" style="width:250px;" disabled="true">
			        		<option value="no">No</option>
			        		<option value="yes">Yes</option>
			        	</select></td>
			        	<td>&nbsp;</td>
			        </tr>
			        
			    </tbody>
			</table>
		</form>
	</div>
</div>
		
		
		

		
		
</body>
</html>


