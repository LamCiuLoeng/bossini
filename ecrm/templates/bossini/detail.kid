<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#"
    py:extends="'../master.kid'">

<head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
    <title>r-pac - Bossini</title>

    <link rel="stylesheet" href="/static/css/flora.datepicker.css" type="text/css" media="screen"/>

    
    <script src="/static/javascript/ui.datepicker.js" language="javascript"></script>
    <script src="/static/javascript/jquery-impromptu.1.5.js" language="javascript"></script>
    <script src="/static/javascript/fancyzoom.js" language="javascript"></script>   
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
			$('#photo').fancyZoom({directory:'/static/images/fancyZoom'});
		});
		
		function toResolve(){
			return confirm("Are you sure to resolve the conflict record?");
		}
		
	//]]>
	</script>     
	
	
	
	
    
</head>


<body>

<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
    <td width="36" valign="top" align="left"><img src="/static/images/images/menu_start.jpg"/></td>
    <td width="176" valign="top" align="left"><a href="/bossinipo/index"><img src="/static/images/images/Bossini_PO_g.jpg"/></a></td>

	<div py:if="POHeader.latestFlag == 1" py:strip="">    
		<?python from ecrm.util.common import rpacEncrypt ?>
	    <div py:if="hangTagOrder">
	    	<td width="64" valign="top" align="left"><a href="/bossinipo/viewOrder?code=${rpacEncrypt(hangTagOrder.id)}"><img src="/static/images/images/menu_ho_g.jpg"/></a></td>
	    	<td width="64" valign="top" align="left"><a href="/bossinipo/exportHangTagOrder?id=${hangTagOrder.id}"><img src="/static/images/images/menu_pro_g.jpg"/></a></td>
	    </div>
		<div py:if="stickerOrder">
		<td width="64" valign="top" align="left"><a href="/bossinipo/viewOrder?code=${rpacEncrypt(stickerOrder.id)}" target="_blank"><img src="/static/images/images/st_order_g.jpg"/></a></td>
	    	<td width="64" valign="top" align="left"><a href="/bossinipo/exportSTOrder?id=${stickerOrder.id}" ><img src="/static/images/images/st_production_g.jpg"/></a></td>
		</div>
	    <td width="64" valign="top" align="left" py:if="wovenLabelOrder">
	    	<a href="/bossinipo/viewOrder?code=${rpacEncrypt(wovenLabelOrder.id)}"><img src="/static/images/images/menu_wo_g.jpg"/></a>
	    </td>
	    <td width="64" valign="top" align="left" py:if="needResolve">
	    	<a href="/bossinipo/resolve?id=${POHeader.id}" onclick="return toResolve()"><img src="/static/images/images/menu_resolve_g.jpg"/></a>
	    </td>
	</div>


    <td width="64" valign="top" align="left"><a href="${'/bossinipo/history?id=%d' %POHeader.id}"><img src="/static/images/images/menu_history_g.jpg"/></a></td>  
    <td width="64" valign="top" align="left"><a href="/bossinipo/viewAttachment?id=${POHeader.id}"><img src="/static/images/images/menu_attach_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="${'/bossinipo/versions?id=%d' %POHeader.id}"><img src="/static/images/images/menu_versions_g.jpg"/></a></td>  
        
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/static/images/images/menu_last.jpg"/></td>
    <td align="left" valign="top" background="/static/images/images/menu_end.jpg">&nbsp;</td>
  </tr>
</tbody></table>
<div class="nav-tree">Bossini&nbsp;&nbsp;&gt;&nbsp;&nbsp;Main&nbsp;&nbsp;&gt;&nbsp;&nbsp;Detail</div>
</div>

		<div style="width:2000px;">

			<div style="overflow:hidden;margin:5px 0px 10px 0px"> 
				
				<div py:if="needResolve" style="margin-left:20px;">
					<p style="color:red">
						<b>WARNING !!</b><br />
						The detail has been updated after the order confirmed!<br/>
						You need to resolve the conflict!
					</p>
				</div>
			
				<div class="case-list-one">
				        <ul><li class="label">SO#</li><li>${POHeader.soNo}</li></ul>
				        <ul><li class="label">Bossini PO#</li><li>${POHeader.poNo}</li></ul>
				        <ul><li class="label">Season</li><li>${POHeader.season}</li></ul>
				        <ul><li class="label">Collection</li><li>${POHeader.collection}</li></ul>
				        <ul><li class="label">Line</li><li>${POHeader.line}</li></ul>
				        <ul><li class="label">Sub Cat</li><li>${POHeader.subCat}</li></ul>
						<ul><li class="label">Item Type</li><li>${POHeader.itemType}</li></ul>
				        <ul><li class="label">Revision</li><li>${POHeader.versions}</li></ul>
				 </div>
				 <div class="case-list-one">  
				  		<ul><li class="label">Legacy Code</li><li>${POHeader.printedLegacyCode}</li></ul>
						<ul><li class="label">Style#</li><li>${POHeader.styleNo}</li></ul>
				        <ul><li class="label">Hang Tag Type</li><li>${POHeader.printedHangTagType}</li></ul>
				        <ul><li class="label">Vendor Name</li><li>${POHeader.vendorCode}</li></ul>
				        <ul><li class="label">Market List</li><li>${POHeader.marketList}</li></ul>
				        <!--<ul><li class="label">Net Price</li><li>${POHeader.priceInHTML}</li></ul>-->
				        <!--<ul><li class="label">Blank Price</li><li>${POHeader.blankPrice}</li></ul>-->
				  </div>
				  
				  
				<div>
					<a href="#github" id="photo" style="float:left;margin-left:50px;">
						<img src="${image_url}" width="60" height="180" style="border-right:1px solid #999;"/>
					</a>
				</div>

				  <div id="github">
				  		<img src="${image_url}"/>
				</div>
				  
			</div>
			<div style="overflow:hidden;margin:10px 0px 10px 0px"> 
					${poDetail_widget(items,checkBoxFunction=False)}
			</div>
		</div>
</body>
</html>
		
    
    




