<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#"
    py:extends="'../master.kid'">

<head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
    <title>r-pac - Master</title>
    <link rel="stylesheet" href="/static/css/flora.datepicker.css" type="text/css" media="screen"/>
    <script src="/static/javascript/ui.datepicker.js" language="javascript"></script>
    <script src="/static/javascript/jquery-impromptu.1.5.js" language="javascript"></script>
    
    <link rel="stylesheet" href="/static/css/jquery.autocomplete.css" type="text/css" />
    
    <script type="text/javascript" src="/static/javascript/jquery.bgiframe.pack.js"></script>
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
	    var self = $("td[limit]"); 
	    self.each(function(){ 
		var objString = $(this).text(); 
	        var objLength = $(this).text().length; 
		var num = $(this).attr("limit");
	        if(objLength > num){ 
		    $(this).attr("title",objString); 
		    objString = $(this).text(objString.substring(0,num) + "......"); 
		}
	    }) ;
    });
    
    function toSave(){
	var companyname = $("#billTo").val();
	if(companyname==""){
	    alert("Please enter company name at least!");
	    return false;	
	}
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
	<td width="64" valign="top" align="left"><a href="${'/vendor/revise?id=%s' %obj.id}"><img src="/static/images/images/menu_revise_g.jpg"/></a></td>
    
    
    
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/static/images/images/menu_last.jpg"/></td>
    <td align="left" valign="top" background="/static/images/images/menu_end.jpg">&nbsp;</td>
  </tr>
</tbody></table>

</div>
<div class="nav-tree">Master&nbsp;&nbsp;&gt;&nbsp;&nbsp;Vendor&nbsp;&nbsp;&gt;&nbsp;&nbsp;Review</div>
<div style="width:1200px;">
	<div style="overflow:hidden;margin:10px 0px 10px 0px">
		<div class="case-960-one">
			<div class="informtion-vendor">
			<a href="/vendor/review?id=${vendor_id}"><img src="/static/images/images/BillTo_Information.jpg" /></a>
			<a href="#" onclick="toSave()"><img src="/static/images/images/_save_g.jpg" /></a>
			</div>
			
				<div class="log-one">Bill To Information</div>
					<form action="/vendor/saveAddress">
						<input type="hidden" name="vendor_id" value="${vendor_id}"/>
						<input type="hidden" name="bill_id" value="${obj.id}"/>
						<input type="hidden" name="update_type" value="update_type"/>
						<div class="case-list-one">
			                <ul>
			                    <li class="label"><label>Company name</label></li>
			                    <li>
			                    	<input type="text" name="billTo" id="billTo" value="${obj.billTo}" class="editContent" style="width:250px"/>
			                    </li>
			                </ul>
			            	<ul>
			                    <li class="label"><label>Address(Ship to)</label></li>
			                    <li>
			                    	<input type="text" name="address" id="address" value="${obj.address}" class="editContent" style="width:250px"/></li>
			                </ul>
			                <ul>
			                    <li class="label"><label>Contact person</label></li>
			                    <li>
			                    	<input type="text" name="contact" id="contact" value="${obj.contact}" class="editContent" style="width:250px"/></li>
			                </ul>
			                <ul>
			                    <li class="label"><label>Contact telephone</label></li>
			                    <li>
			                    	<input type="text" name="tel" id = "tel" value="${obj.tel}" class="editContent" style="width:250px"/></li>
			                </ul>
			            </div>
			            <div class="case-list-one">
					<ul>
			                    <li class="label"><label>Fax</label></li>
			                    <li>
			                    	<input type="text" name="fax" id="fax" value="${obj.fax}" class="editContent" style="width:250px"/></li>
			                </ul>
			                <ul>
			                    <li class="label"><label>Need VAT</label></li>
			                    <li>
			                    	<input type="text" name="needVAT" id="needVAT" value="${obj.needVAT}" class="editContent" style="width:250px"/></li>
			                </ul>
			                <ul>
			                    <li class="label"><label>Need Invoice</label></li>
			                    <li>
			                    	<input type="text" name="needInvoice" id="needInvoice" value="${obj.needInvoice}" class="editContent" style="width:250px"/></li>
			                </ul>
				    <ul>
			                    <li class="label"><label>Default</label></li>
			                    <li>
					    <select py:if="obj.flag==0" name="flag">
						<option value='0' selected="true">No</option>
						<option value='1' >Yes</option>
					    </select>
					    <select py:if="obj.flag==1" name="flag">
						<option value='0'>No</option>
						<option value='1' selected="true">Yes</option>
					    </select>
					
						</li>
			                </ul>
			            </div>
			            <br style="clear:both;"/>
			    </form>
		</div>
		
	</div>
</div>

</body>
</html>


