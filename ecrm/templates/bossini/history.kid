<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#"
    py:extends="'../master.kid'">

<head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
    <title>r-pac - Bossini</title>

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
    
</head>




<body>



<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
    <td width="36" valign="top" align="left"><img src="/static/images/images/menu_start.jpg"/></td>
    <td width="176" valign="top" align="left"><a href="/bossinipo/index"><img src="/static/images/images/Bossini_PO_g.jpg"/></a></td>

	<!--
	    <td width="64" valign="top" align="left"><a href="/bossinipo/reviseOrder?id=${POHeader.id}"><img src="/static/images/images/menu_revise_g.jpg"/></a></td>
	-->
	
    <td width="64" valign="top" align="left"><a href="${'/bossinipo/detail?id=%d' %POHeader.id}" ><img src="/static/images/images/menu_detail_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="/bossinipo/viewAttachment?id=${POHeader.id}"><img src="/static/images/images/menu_attach_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="${'/bossinipo/versions?id=%d' %POHeader.id}"><img src="/static/images/images/menu_versions_g.jpg"/></a></td>  

    <td width="23" valign="top" align="left"><img height="21" width="23" src="/static/images/images/menu_last.jpg"/></td>
    <td align="left" valign="top" background="/static/images/images/menu_end.jpg">&nbsp;</td>
  </tr>
</tbody></table>

</div>
<div class="nav-tree">Bossini&nbsp;&nbsp;&gt;&nbsp;&nbsp;Main&nbsp;&nbsp;&gt;&nbsp;&nbsp;History</div>

		<div style="width:1200px;">
			<div style="overflow:hidden;margin:5px 0px 10px 0px"> 
				<div class="case-list-one">
				        <ul><li class="label">SO#</li><li>${POHeader.soNo}</li></ul>
				        <ul><li class="label">PO#</li><li>${POHeader.poNo}</li></ul>
				        <ul><li class="label">Season</li><li>${POHeader.season}</li></ul>
				        <ul><li class="label">Collection</li><li>${POHeader.collection}</li></ul>
				        <ul><li class="label">Line</li><li>${POHeader.line}</li></ul>
				        <ul><li class="label">Sub Cat</li><li>${POHeader.subCat}</li></ul>
				 </div>
				 <div class="case-list-one">
				  		<ul><li class="label">Legacy Code</li><li>${POHeader.printedLegacyCode}</li></ul>
						<ul><li class="label">Style#</li><li>${POHeader.styleNo}</li></ul>
				        <ul><li class="label">Hang Tag Type</li><li>${POHeader.hangTagType}</li></ul>
				        <ul><li class="label">Vendor Name</li><li>${POHeader.vendorCode}</li></ul>
				        <ul><li class="label">Market List</li><li>${POHeader.marketList}</li></ul>
				        <ul><li class="label">Item Type</li><li>${POHeader.itemType}</li></ul>
				        <!-- <ul><li class="label">Remark</li><li>${POHeader.remark}</li></ul>
				        <ul><li class="label">Revision</li><li>${POHeader.versions}</li></ul> -->
				  </div>
				</div>
			<div style="overflow:hidden;margin:10px 0px 10px 0px"> 
					${result_widget(items)}
			</div>
		</div>
</body>
</html>
		
    
    




