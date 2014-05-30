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


</head>

<body>

<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
    <td width="36" valign="top" align="left"><img src="/static/images/images/menu_start.jpg"/></td>
    <td width="176" valign="top" align="left"><a href="/kohlspo/index"><img src="/static/images/images/menu_kohls_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="/kohlspo/msglist"><img src="/static/images/images/menu_message_g.jpg"/></a></td>   
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/static/images/images/menu_last.jpg"/></td>
    <td align="left" valign="top" background="/static/images/images/menu_end.jpg">&nbsp;</td>
  </tr>
</tbody></table>

</div>



		<div style="width:1200px;">
			<div style="overflow:hidden;margin:10px 0px 10px 0px">   
			
				<div class="case-list-one">				
				        <ul>
				            <li class="label">Sender Code</li>
				            <li id="so_text">${msgHeader.senderCode}</li>
				        </ul>
				        <ul>
				            <li class="label">Receiver Code</li>
				            <li>${msgHeader.receiverCode}</li>
				        </ul>
				        <ul>
				            <li class="label">EDI File Date</li>
				            <li>${msgHeader.ediFileDate}</li>
				        </ul>
				        <ul>
				            <li class="label">Group Control Number</li>
				            <li>${msgHeader.groupControlNumber}</li>
				        </ul>
				        <ul>
				            <li class="label">Industry ID Code</li>
				            <li id="so_text">${msgHeader.industryIDCode}</li>
				        </ul>
				        <ul>
				            <li class="label">Transaction Set Control Number</li>
				            <li>${msgHeader.transactionSetControlNumber}</li>
				        </ul>
				  </div>
				  <div class="case-list-one">				
				        <ul>
				            <li class="label">referenceIndentification</li>
				            <li>${msgHeader.referenceIndentification}</li>
				        </ul>
				        <ul>
				            <li class="label">Reference Desc</li>
				            <li>${msgHeader.referenceDesc}</li>
				        </ul>
				        <ul>
				            <li class="label">Entity Indentifier Code</li>
				            <li>${msgHeader.entityIndentifierCode}</li>
				        </ul>
				        <ul>
				            <li class="label">Free Form Name</li>
				            <li>${msgHeader.freeFormName}</li>
				        </ul>
				        <ul>
				            <li class="label">Contact Function Code</li>
				            <li>${msgHeader.contactFunctionCode}</li>
				        </ul>
				        <ul>
				            <li class="label">Contact E-mail</li>
				            <li>${msgHeader.contactEmail}</li>
				        </ul>
				        <ul>
				            <li class="label">Import Date</li>
				            <li>${msgHeader.importDate}</li>
				        </ul>
				  </div>
				
			</div>
		</div>
		<div style="overflow:hidden;margin:10px 10px 10px 10px;border:1px solid #EEEEEE;width:910px;background-color:#feffe6;font-size:12px;">
			<p style="margin:10px;">
				<div py:for="msg in msgHeader.msgs" py:strip="">
				<span py:replace="msg.content">msg content</span>
				<br />
				</div>
			</p>
		</div>

</body>
</html>


