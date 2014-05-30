<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#"
    py:extends="'../master.kid'">

<head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
    <title>r-pac - Bossini</title>
    <link rel="stylesheet" href="/static/css/custom/order.css" type="text/css" media="screen"/>
    <script src="/static/javascript/jquery-impromptu.1.5.js" language="javascript"></script>

    <style type="text/css">
	<!--
	div.cleanblue .cleanbluebuttons{
   		text-align : center;
   	}
   	
	.STYLE2 {
		font-size: 18px;
		font-weight: bold;
		font-family: Arial, Helvetica, sans-serif;
	}
	.STYLE3 {
		font-family: Arial, Helvetica, sans-serif;
		color: #630063;
		font-weight: bold;
		font-size: 18px;
	}
	.STYLE4 {
		font-family: Arial, Helvetica, sans-serif;
		color: #006100;
		font-weight: bold;
		font-size: 18px;
	}
	.TSTYLE {
		font-family: Arial, Helvetica, sans-serif;
		color: #ff0000;
		font-weight: bold;
		font-size: 18px;
	}
	-->
	</style>


	<script language="JavaScript" type="text/javascript" py:if="tg_flash">
	//<![CDATA[
	    $(document).ready(function(){
	        $.prompt("${tg_flash}",{
	        			opacity: 0.6,
	        			prefix:'cleanblue',
	        			show:'slideDown',
	        			buttons:{'Acknowledge and Go back to Main Manual<br />明白，返回总页面':true}
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
    <td width="176" valign="top" align="left"><a href="/bossinipo/vendor_index"><img src="/static/images/images/Bossini_PO_g.jpg"/></a></td>

    <td width="23" valign="top" align="left"><img height="21" width="23" src="/static/images/images/menu_last.jpg"/></td>
    <td align="left" valign="top" background="/static/images/images/menu_end.jpg">&nbsp;</td>
  </tr>
</tbody></table>

</div>
<div class="nav-tree">Bossini&nbsp;&nbsp;&gt;&nbsp;&nbsp;Main</div>
<div style="width:1200px;">
	<div style="overflow:hidden;margin:5px 0px 10px 10px">
		<p class="STYLE2">Dear ${vendorCode}, welcome your visit  欢迎您的来访！</p>
		<p class="STYLE2">Please select 请选择:</p>	
		<p><a href="/bossinipo/vendor_new_order" class="STYLE2">1.Place NEW Order 确认 bossini 新的订单</a></p>
		<p><a href="/bossinipo/vendor_index2" class="STYLE3">2.Review Confirmed Order Status and Expected Ex-factory Dates 查询已经通过1.成功确认的订单 和 订单的预计出厂日期 </a></p>
		<p><a href="/bossinipo/vendor_index3" class="STYLE4">3.Check bossini outstanding / pending for information order 查看还在[等待bossini确认挂卡价格/代号资料的订单]</a></p>
	</div>
</div>


</body>
</html>


