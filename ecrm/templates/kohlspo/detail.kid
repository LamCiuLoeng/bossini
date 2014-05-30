<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#"
    py:extends="'../master.kid'">

<head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
    <title>r-pac - Kohl's</title>

    <link rel="stylesheet" href="/static/css/flora.datepicker.css" type="text/css" media="screen"/>
    <script src="/static/javascript/ui.datepicker.js" language="javascript"></script>
    <script src="/static/javascript/jquery-impromptu.1.5.js" language="javascript"></script>

	<script language="JavaScript" type="text/javascript" py:if="tg_flash">
	//<![CDATA[
	    $(document).ready(function(){
	        $.prompt("${tg_flash}",{opacity: 0.6,prefix:'cleanblue',show:'slideDown'});
	    });
	//]]>
	</script>

    <script src="/static/javascript/custom/kohls_detail.js" language="javascript"></script>
</head>




<body>



<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
    <td width="36" valign="top" align="left"><img src="/static/images/images/menu_start.jpg"/></td>
    <td width="176" valign="top" align="left"><a href="/kohlspo/index"><img src="/static/images/images/menu_kohls_g.jpg"/></a></td>
    <td width="64" valign="top" align="left" py:if="'KOHLS_EDIT' in tg.identity.permissions and can_edit"><a href="javascript:toProductExport()"><img src="/static/images/images/product_export_g.jpg"/></a></td>

    <td width="64" valign="top" align="left" py:if="'KOHLS_EDIT' in tg.identity.permissions and can_edit"><a href="javascript:showAddDiv()"><img src="/static/images/images/menu_addso_g.jpg"/></a></td>

    <td width="64" valign="top" align="left"><a href="/kohlspo/showVersions/${POHeader.poNo}"><img src="/static/images/images/menu_versions_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="/kohlspo/history?id=${POHeader.id}"><img src="/static/images/images/menu_history_g.jpg"/></a></td>
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/static/images/images/menu_last.jpg"/></td>
    <td align="left" valign="top" background="/static/images/images/menu_end.jpg">&nbsp;</td>
  </tr>
</tbody></table>

</div>

		<div style="width:1200px;">

			<div style="overflow:hidden;margin:10px 0px 10px 0px">
				<div class="case-list-one" id="showDiv">
					<form action="/kohlspo/export" method="post" name="exportForm">
					<input type="hidden" name="header_id" value="${POHeader.id}"/>
					<input type="hidden" name="podetail_ids" value="" id="podetail_ids"/>
					<input type="hidden" name="sln_ids" value="" id="sln_ids"/>
				        <ul>
				            <li class="label">SO#</li>
				            <li id="so_text">${POHeader.soNo}</li>
				        </ul>
				        <ul>
				            <li class="label">PO#</li>
				            <li>${POHeader.poNo}</li>
				        </ul>
				        <ul>
				            <li class="label">Item#</li>
				            <li>${POHeader.hangtag}</li>
				        </ul>
				        <ul>
				            <li class="label">Vendor Name</li>
				            <li>${POHeader.manufacture}</li>
				        </ul>
				        <ul>
				            <li class="label">Remark</li>
				            <li>${POHeader.remark}</li>
				        </ul>
				  	</form>
				  </div>
				  <div class="case-list-four" style="display:none" id="addDiv">
					<form action="/kohlspo/addSO" method="post" name="addForm">
					<input type="hidden" name="header_id" value="${POHeader.id}"/>
				        <ul>
				            <li class="label">SO#</li>
				            <li><input type="text" value="" name="so_no" style="width:200px"/></li>
				        </ul>
				        <ul>
				            <li class="label">SO Remark</li>
				            <li><input type="text" value="" name="so_remark" style="width:200px"/></li>
				        </ul>
				        <ul>
				            <li class="label">SO Date</li>
				            <li><input type="text" value="" name="so_date" class="datePicker" style="width:200px"/></li>
				        </ul>

				        <ul>
				            <li class="label">Action</li>
				            <li><input type="button" value="Save" onclick="saveChange();"/> <input type="button" value="Cancel" onclick="hiddenAddDiv();"/></li>
				        </ul>
				  	</form>
				  </div>
				</div>
			<div style="overflow:hidden;margin:10px 0px 10px 0px">
					${poDetail_widget(items,checkBoxFunction=can_edit)}
			</div>
		</div>
</body>
</html>







