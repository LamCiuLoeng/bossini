<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#"
    py:extends="'../master.kid'">

<head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
    <title>r-pac - Bossini</title>
    
    <link rel="stylesheet" href="/static/css/custom/order.css" type="text/css" media="screen"/>
    
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
	        $('.photo').fancyZoom({directory:'/static/images/fancyZoom'});
	    });
	    
	    function toCancelOrder(){
	    	if(confirm("Are you sure to cancel the order?")){
	    		return true;
	    	}else{
	    		return false;
	    	}
	    }
	//]]>
	</script>

</head>

<body>



<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
    <td width="36" valign="top" align="left"><img src="/static/images/images/menu_start.jpg"/></td>
    <td width="176" valign="top" align="left"><a href="/bossinipo/dispatch"><img src="/static/images/images/Bossini_PO_g.jpg"/></a></td>
    <div py:if="'BOSSINI_CANCEL_ORDER' in tg.identity.permissions and order.active==0" py:strip="">
    	<td width="176" valign="top" align="left"><a href="/bossinipo/cancelOrder?id=${order.id}" onclick="return toCancelOrder()"><img src="/static/images/images/menu_cancelorder_g.jpg"/></a></td>
    </div>    
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/static/images/images/menu_last.jpg"/></td>
    <td align="left" valign="top" background="/static/images/images/menu_end.jpg">&nbsp;</td>
  </tr>
</tbody></table>

</div>
<div class="nav-tree">Bossini&nbsp;&nbsp;&gt;&nbsp;&nbsp;Main&nbsp;&nbsp;&gt;&nbsp;&nbsp;Formatted Grey Cards,Color Cards &amp; others (定式灰卡,彩卡及其它)</div>
<div style="width:1200px;">
	<div style="overflow:hidden;margin:5px 0px 10px 10px">
			
	<!--  main content begin -->		
		<div class="templat_main_div1">
		  <table width="100%" border="0" cellspacing="0" cellpadding="0">
		    <tr>
		      <td width="10">&nbsp;</td>
		      <td width="170"><span class="STYLE1">Vendor's Code :</span></td>
		      <td colspan="3" class="bottom_border">${order.vendor.vendorName}&nbsp;</td>
		    </tr>
		    <tr>
		      <td class="STYLE3">&nbsp;</td>
		      <td class="STYLE3">BILL TO / 收票人 :</td>
		      <td colspan="3" class="bottom_border"><span py:replace="order.billTo"/>&nbsp;</td>
		    </tr>
		    <tr>
		      <td>&nbsp;</td>
		      <td><strong>ADDRESS / 地址 :</strong></td>
		      <td colspan="3" class="bottom_border">${order.billToAddress}&nbsp;</td>
		    </tr>
		    <tr>
		      <td>&nbsp;</td>
		      <td>&nbsp;</td>
		      <td colspan="3">&nbsp;</td>
		    </tr>
		    <tr>
		      <td>&nbsp;</td>
		      <td><strong>CONTACT / 聯系人 :</strong></td>
		      <td colspan="3" class="bottom_border">${order.billToContact}&nbsp;</td>
		    </tr>
		    <tr>
		      <td>&nbsp;</td>
		      <td><strong>TELEPHONE / 電話號碼 :</strong></td>
		      <td colspan="3" class="bottom_border">${order.billToTel}&nbsp;</td>
		    </tr>
		    <tr>
		      <td>&nbsp;</td>
		      <td><strong>E-mail / 電郵 :</strong></td>
		      <td colspan="3" class="bottom_border">${order.billToEmail}&nbsp;</td>
		    </tr>
		    <tr>
		      <td>&nbsp;</td>
		      <td><strong>Payment Currency &amp; Terms 结算货币和付款条款:</strong></td>
		      <td class="bottom_border" colspan="3" >${order.payterm}&nbsp;</td>
		    </tr>
		    <tr>
		      <td>&nbsp;</td>
		      <td><span class="STYLE20"  colspan="3">运费指示：</span></td>
		      <td class="bottom_border">${order.shipmentInstruction}&nbsp;</td>
		    </tr>
		    <tr>
		      <td>&nbsp;</td>
		      <td><span class="STYLE2">需要对帐后开税票 ：</span></td>
		      <td colspan="3" class="bottom_border">${order.VATInfo}&nbsp;</td>
		    </tr>
		    <tr>
		      <td class="STYLE2">&nbsp;</td>
		      <td class="STYLE2">只需要开普通发票 ：</td>
		      <td colspan="3" class="bottom_border">${order.invoiceInfo}&nbsp;</td>
		    </tr>
		    <tr>
		      <td class="STYLE2">&nbsp;</td>
		      <td class="STYLE2">会计对帐联系人 ： </td>
		      <td colspan="3">${order.accountContact}&nbsp;</td>
		    </tr>
		  </table>
		</div>
		 <table width="500" border="0" cellpadding="0" cellspacing="0">
		  <tr>
		    <td height="11" colspan="2"></td>
		  </tr>
		  <tr>
		    <td width="200" class="STYLE1">Order Date 确认订单日：</td>
		    <td align="center" bgcolor="#FFFF00" class="STYLE1"><span py:replace="order.createDate.strftime('%d %b %Y')"></span>&nbsp;</td>
		  </tr>
		</table>

		<div class="templat_main_div2">
		  <table width="100%" border="0" cellspacing="0" cellpadding="0">
		    <tr>
		      <td width="10">&nbsp;</td>
		      <td>&nbsp;</td>
		      <td colspan="3">&nbsp;</td>
		    </tr>
		    <tr>
		      <td>&nbsp;</td>
		      <td width="170"><span class="STYLE3">SHIP TO / 收貨公司:</span></td>
		      <td colspan="3" class="bottom_border">${order.shipTo}&nbsp;</td>
		    </tr>
		    <tr>
		      <td>&nbsp;</td>
		      <td><strong>ADDRESS / 地址 :</strong></td>
		      <td colspan="3" class="bottom_border">${order.shipToAddress}&nbsp;</td>
		    </tr>
		    <tr>
		      <td>&nbsp;</td>
		      <td>&nbsp;</td>
		      <td colspan="3">&nbsp;</td>
		    </tr>
		    <tr>
		      <td>&nbsp;</td>
		      <td><strong>CONTACT / 聯系人 :</strong></td>
		      <td colspan="3" class="bottom_border">${order.shipToContact}&nbsp;</td>
		    </tr>
		    <tr>
		      <td>&nbsp;</td>
		      <td><strong>TELEPHONE / 電話號碼 :</strong></td>
		      <td colspan="3" class="bottom_border">${order.shipToTel}&nbsp;</td>
		    </tr>
		    <tr>
		      <td>&nbsp;</td>
		      <td><strong>E-mail / 電郵 :</strong></td>
		      <td colspan="3" class="bottom_border">${order.shipToEmail}&nbsp;</td>
		    </tr>
		    <tr>
		      <td>&nbsp;</td>
		      <td>&nbsp;</td>
		      <td colspan="3">&nbsp;</td>
		    </tr>
		    <tr>
		      <td>&nbsp;</td>
		      <td><span class="STYLE2">船头办特定收件人名字：</span></td>
		      <td width="120" class="bottom_border">${order.sampleReceiver}&nbsp;</td>
		      <td width="100" align="right"><span class="STYLE2">电话号码：</span></td>
		      <td class="bottom_border">${order.sampleReceiverTel}&nbsp;</td>
		    </tr>
		    <tr>
		      <td class="STYLE2">&nbsp;</td>
		      <td class="STYLE2">船头办送货地址 ：</td>
		      <td colspan="3" class="bottom_border">${order.sampleSendAddress}&nbsp;</td>
		    </tr>
		    <tr>
		      <td class="STYLE2">&nbsp;</td>
		      <td class="STYLE2">包装注明/其他特定要求 :</td>
		      <td colspan="3">${order.requirement}&nbsp;</td>
		    </tr>
		  </table>
		</div>
		
		
		
		<div class="templat_main_div4">
		  <table width="100%" cellspacing="0" cellpadding="0" bordercolor="#000000" border="1">
		    <tbody><tr>
		      <td class="color-000000"><table width="100%" cellspacing="1" cellpadding="0" border="0">
		        <tbody>
		        <tr>
		          <td class="STYLE18 color-CCFFCC" colspan="2" align="center">Formatted Grey Cards,Color Cards &amp; others (定式灰卡,彩卡及其它)</td>
		        </tr>
		        <tr>
		          <td class="STYLE18 color-CCFFCC">Customer Order No. 客户订单号 : </td>
		          <td width="450" class="STYLE19 color-FFFFFF">&nbsp;<span>${order.customerOrderNo}</span></td>
		        </tr>
		        <tr>
		          <td class="STYLE18 color-CCFFCC">The Item Code 产品号码 :</td>
		          <td class="STYLE19 color-FFFFFF">&nbsp;<span>${fcInfo.item.itemCode}</span></td>
		        </tr>
		        <tr>
		          <td class="STYLE18 color-CCFFCC"><label for="qty">Total this order Quantity (pieces) 这一个订单贵司采购的个数 :</label></td>
		          <td class="STYLE19 color-FFFFFF">&nbsp;<span>${fcInfo.qty}</span>PCS</td>
		        </tr>
		        <tr>
		        	<td class="STYLE18 color-CCFFCC">Reference Total Order Price (before VAT)参考税前单价（运费除外）</td>
		        	<td class="STYLE19 color-FFFFFF">
		        		<div id="amt_div" py:if="order.currency=='HKD'" py:strip="">&nbsp;$ ${fcInfo.item.hkPrice} <b>X</b> ${fcInfo.qty} <b>=</b> $ ${"%.6f" %(fcInfo.qty*fcInfo.item.hkPrice)}</div>
		        		<div id="amt_div" py:if="order.currency=='RMB'" py:strip="">&nbsp;￥ ${fcInfo.item.rmbPrice} <b>X</b> ${fcInfo.qty} <b>=</b> ￥ ${"%.6f" %(fcInfo.qty*fcInfo.item.rmbPrice)}</div>
		        	</td>
		        </tr>
		        <tr>
		          <td class="STYLE18 color-CCFFCC" valign="top"><label>订单相关的Bossini Legacy Codes :</label></td>
		          <td class="STYLE19 color-FFFFFF">
		          	<table cellspacing="0" cellpadding="0" border="0">
		          		<tr py:for="lc in  fcInfo.getDetails()">
		          			<td>&nbsp;${lc.legacyCode}</td>
		          		</tr>
		          	</table>
				  </td>
		        </tr>

		        
		      </tbody></table></td>
		    </tr>
		  </tbody></table>
		</div>

		<div style="float:left;width:200px;margin-left:50px;margin-top:15px">
			<div><a href="#itemImg" class="photo"><img class="hangTagImg" src="/static/images/bossini/${fcInfo.item.itemCode}.jpg" height="190"/></a></div>
			<div id="itemImg"><img class="hangTagImg" src="/static/images/bossini/${fcInfo.item.itemCode}.jpg"/></div>
		</div>

	<!-- main content end -->
	
	</div>
</div>


</body>
</html>


