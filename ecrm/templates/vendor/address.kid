<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#"
    py:extends="'../master.kid'">

<head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
    <title>r-pac - Master</title>
    <link rel="stylesheet" href="/static/css/flora.datepicker.css" type="text/css" media="screen"/>
    <link rel="stylesheet" href="/static/css/jquery.autocomplete.css" type="text/css" />
    
    <style type="text/css">
		.viewContent{
		
		}
		
		.editContent{
			display:none;
		}
	</style>
    
    <script src="/static/javascript/ui.datepicker.js" language="javascript"></script>
    <script src="/static/javascript/jquery-impromptu.1.5.js" language="javascript"></script> 
    <script type="text/javascript" src="/static/javascript/jquery.bgiframe.pack.js"></script>
    <script type="text/javascript" src="/static/javascript/jquery.autocomplete.pack.js"></script>
    
    <script type="text/javascript" src="/static/javascript/custom/vendor_address.js"></script>
   
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
	    
	    function toSave(){
	    	$('form').submit();
	    }
	//]]>
	</script>

</head>

<body>

<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
    <td width="36" valign="top" align="left"><img src="/static/images/images/menu_start.jpg"/></td>
    <td width="176" valign="top" align="left"><a href="/vendor/index"><img src="/static/images/images/menu_plsv_g.jpg"/></a></td>
    
    <td width="64" valign="top" align="left"><a href="/vendor/add"><img src="/static/images/images/menu_new_g.jpg"/></a></td>
	
    <td width="64" valign="top" align="left"><a href="${'/vendor/review?id=%d' %obj.id}"><img src="/static/images/images/menu_detail_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="#" onclick="showNewDiv();"><img src="/static/images/images/menu_new_address_g.jpg"/></a></td>
    
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/static/images/images/menu_last.jpg"/></td>
    <td align="left" valign="top" background="/static/images/images/menu_end.jpg">&nbsp;</td>
  </tr>
</tbody></table>

</div>
<div class="nav-tree">Master&nbsp;&nbsp;&gt;&nbsp;&nbsp;Vendor&nbsp;&nbsp;&gt;&nbsp;&nbsp;Address Information</div>
<div style="width:1200px;">
	<div style="overflow:hidden;margin:0px 0px 10px 0px">

	
		<div py:for="index,address in enumerate(obj.shipTo)" py:strip="">
			<div class="case-960-one" id="${'div-%d' %index}">
				<div class="log-one">Address Information</div>
					<form action="/vendor/saveAddress">
						<input type="hidden" name="address_id" value="${address.id}"/>
						<input type="hidden" name="vendor_id" value="${obj.id}"/>
						<div class="case-list-one">
			                <ul>
			                    <li class="label"><label>Company name</label></li>
			                    <li><span py:content="address.companyName" class="viewContent"></span>
			                    	<input type="text" name="companyName" value="${address.companyName}" class="editContent" style="width:250px"/>
			                    </li>
			                </ul>
			            	<ul>
			                    <li class="label"><label>Address(Ship to)</label></li>
			                    <li><span py:content="address.address" class="viewContent"></span>
			                    	<input type="text" name="address" value="${address.address}" class="editContent" style="width:250px"/></li>
			                </ul>
			                <ul>
			                    <li class="label"><label>Contact person</label></li>
			                    <li><span py:content="address.contact" class="viewContent"></span>
			                    	<input type="text" name="contact" value="${address.contact}" class="editContent" style="width:250px"/></li>
			                </ul>
			                <ul>
			                    <li class="label"><label>Contact telephone</label></li>
			                    <li><span py:content="address.tel" class="viewContent"></span>
			                    	<input type="text" name="tel" value="${address.tel}" class="editContent" style="width:250px"/></li>
			                </ul>
			            </div>
			            <div class="case-list-one">
			                <ul>
			                    <li class="label"><label>Need VAT</label></li>
			                    <li><span py:content="address.VATInfo" class="viewContent"></span>
			                    	<input type="text" name="VATInfo" value="${address.VATInfo}" class="editContent" style="width:250px"/></li>
			                </ul>
			                <ul>
			                    <li class="label"><label>Need Invoice</label></li>
			                    <li><span py:content="address.invoiceInfo" class="viewContent"></span>
			                    	<input type="text" name="invoiceInfo" value="${address.invoiceInfo}" class="editContent" style="width:250px"/></li>
			                </ul>
			                <ul>
			                    <li class="label"><label>Special requirement</label></li>
			                    <li><span py:content="address.requirement" class="viewContent"></span>
			                    	<input type="text" name="requirement" value="${address.requirement}"  class="editContent" style="width:250px"/></li>
			                </ul>
			            </div>
			            <br style="clear:both;"/>
			            <div style="text-align:right;padding-right:40px">
			            	<input type="button" value="Update" onclick="showInput('${'div-%d'%index}')" class="viewContent"/>&nbsp;&nbsp;&nbsp;
			            	<input type="submit" value="Save" class="editContent"/>&nbsp;&nbsp;&nbsp;
			            	<input type="button" value="Cancel" onclick="hideInput('${'div-%d'%index}')" class="editContent" /></div>
					</form>
			</div>
		</div>
		
		
		
		
		
	</div>
</div>

</body>
</html>


