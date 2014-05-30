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
		<p class="STYLE2">Please select order type 请选择订单类型:</p>
		
		<h2>以下项目在2010年9月30日开始通行操作</h2>
		
		<!-- <p><a href="/bossinipo/vendor_w_allline" class="STYLE2" style="color:red">(1) Woven Label 所有织唛</a></p> -->
		
        <p><a href="/bossinipo/mainLabelOrder" class="STYLE2" style="color:red">(1) Woven Label(Main Label) 主唛</a></p>
		<p><a href="/bossinipo/vendor_w_order" class="STYLE2" style="color:red">(2) Woven Label(Size Label) 尺码唛</a></p>
		<p><a href="/bossinipo/careLabelOrder" class="STYLE2" style="color:blue">(3) Care Label 所有洗水唛</a></p>
		<p><a href="/bossinipo/styleLabelOrder" class="STYLE2" style="color: purple">(4) Style Printed Label 款号唛</a></p>
		<p><a href="/bossinipo/COOrder" class="STYLE2" style="color:gray">(5) Country of Origin Label 产地唛</a></p>
		<p><a href="/bossinipo/downJacketOrder" class="STYLE2" style="color:orange">(6) Down Jacket Label 羽绒服成分唛</a></p>
		<br />
		
		<h2>以下项目在2010年10月11日开始通行操作</h2>
		<p><a href="/bossinipo/vendor_h_order" class="STYLE2" style="color:black">(a) Bar Code Hang Tag &amp; Waist Card &amp; 01BC8018XXXX range sticker 条码挂牌,腰卡和 01BC8018XXXX 系列的条码贴纸</a></p>
		<p><a href="/bossinipo/fcuntionCardOrder" class="STYLE2" style="color:green">(b) Grey Cards &amp; Color Cards 灰卡和彩卡</a></p>
	</div>
</div>


</body>
</html>


