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
    <tbody>
      <tr>
        <td width="36" valign="top" align="left"><img src="/static/images/images/menu_start.jpg"/></td>
        <td width="176" valign="top" align="left"><a href="/bossinipo/dispatch"><img src="/static/images/images/Bossini_PO_g.jpg"/></a></td>
        <div py:if="'Admin' in tg.identity.groups" py:strip="">
        	<td width="64" valign="top" align="left"><a href="/bossinipo/detail?id=${header.id}"><img src="/static/images/images/menu_detail_g.jpg"/></a></td>        
        </div>
    	  <div py:if="'BOSSINI_CANCEL_ORDER' in tg.identity.permissions and order.active==0" py:strip="">
    	    <td width="176" valign="top" align="left"><a href="/bossinipo/cancelOrder?id=${order.id}" onclick="return toCancelOrder()"><img src="/static/images/images/menu_cancelorder_g.jpg"/></a></td>
        </div>
        <td width="23" valign="top" align="left"><img height="21" width="23" src="/static/images/images/menu_last.jpg"/></td>
        <td align="left" valign="top" background="/static/images/images/menu_end.jpg">&nbsp;</td>
      </tr>
    </tbody>
  </table>
</div>
<div class="nav-tree">Bossini&nbsp;&nbsp;&gt;&nbsp;&nbsp;Main&nbsp;&nbsp;&gt;&nbsp;&nbsp;Woven Label (尺码唛)</div>
<div style="width:1200px;">
  <div style="overflow:hidden;margin:5px 0px 10px 10px">
    <!--  main content begin -->
     
      <div class="templat_main_div1">
		  <table width="100%" border="0" cellspacing="0" cellpadding="0">
		    <tr>
		      <td width="10">&nbsp;</td>
		      <td width="170"><span class="STYLE1">Vendor's Code :</span></td>
		      <td colspan="3" class="bottom_border"><b>${header.vendorCode}</b>&nbsp;</td>
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
		    <tr py:if="header.vendorCode=='LWF'">
	    	  <td>&nbsp;</td>
		      <td><span class="STYLE20">运费指示：</span></td>
		      <td class="bottom_border">${order.shipmentInstruction}&nbsp;</td>
		      <td align="right" width="70" class="STYLE20">需否转厂：</td>
		      <td class="bottom_border" width="50">${order.needChangeFactory}&nbsp;</td>
		    </tr>
		    <tr py:if="header.vendorCode!='LWF'">
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
		
		<br class="clear"/>
	<!-- part 2 -->
      
	<table width="100%" border="2" cellpadding="0" cellspacing="0" bordercolor="#000000">
	  <tr>
	    <td height="35" colspan="2" align="left" valign="middle" class="color-000080"><span class="STYLE4">&nbsp;&nbsp;</span><span class="STYLE4">客户订购类别 Customer Order Categories</span></td>
	  </tr>
	  <tr>
	    <td width="250" align="left" valign="top" class="color-000000"><table width="100%" border="0" cellpadding="0" cellspacing="1">
	        <tr>
	          <td width="50%" height="25" align="center" class="color-FF6600"><span class="STYLE5">Season</span></td>
	          <td width="50%" align="center" class="STYLE5 color-FF6600"><span py:replace="header.season"/></td>
	        </tr>
	        <tr>
	          <td align="center" class="STYLE5 color-FF6600">Legacy Code</td>
	          <td align="center" class="color-FFFF99"><strong><span py:replace="header.printedLegacyCode"/></strong></td>
	        </tr>
	        <tr>
	          <td align="center" class="STYLE5 color-FF6600">bossini PO no.</td>
	          <td align="center" class="color-FFFF99"><strong><span py:replace="header.poNo"/></strong></td>
	        </tr>
	        <tr>
	          <td align="center" class="STYLE5 color-FF9900">Market</td>
	          <td align="center" class="color-FFFF99"><strong><span id="marketList" py:content="header.marketList"/></strong></td>
	        </tr>
	        <tr>
	          <td align="center" class="STYLE5 color-FF9900">Collection</td>
	          <td align="center" class="color-FFFF99"><strong><span py:replace="header.collection"/></strong></td>
	        </tr>
	        <tr>
	          <td align="center" class="STYLE5 color-FF9900">GMT Type</td>
	          <td align="center" class="color-FFFF99"><strong><span id="itemType" py:content="header.itemType"/></strong></td>
	        </tr>
	        <tr>
	          <td align="center" class="STYLE5 color-FF9900">Order Type</td>
	          <td align="center" class="color-FFFF99"><strong><span py:replace="header.orderType"/></strong></td>
	        </tr>
	        <tr>
	          <td align="center" class="STYLE5 color-FF9900">Sub Cat</td>
	          <td align="center" class="color-FFFF99"><strong><span py:replace="header.subCat"/></strong></td>
	        </tr>
	        <tr>
            <td align="center" class="STYLE5 color-FF9900">Line</td>
            <td align="center" class="color-FFFF99"><strong><span py:replace="header.line"/></strong></td>
          </tr>
	      </table></td>
	    <td rowspan="2" align="left" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
 
	        <tr>
		        <td height="55" align="center" class="bottom_right color-CC99FF"><span class="STYLE18">Customer Order No.<br />客户订单号</span> </td>
		        <td align="center" class="bottom_right">${order.customerOrderNo}&nbsp;</td> 
		        <td align="center" class="bottom_right color-CC99FF" colspan="2"><span class="STYLE18">船头办需<br />要的数量</span> </td>
		        <td align="center" class="bottom_right">${order.wlShipment}&nbsp;</td>
		        <td align="center" class="bottom_right color-CC99FF"><span class="STYLE18" >尺码唛总订购单价<br />（运费除外）：</span></td>
		        <td align="center" class="bottom_right color-99CCFF" colspan="2"><span class="currency"/><span class="currency" py:content="'&yen;' if order.currency=='RMB' else 'HKD'"/>${"%.6f" %order.countSizeLabelAmt}&nbsp;</td>
		        </tr>
		      <tr>
		        <td width="26%" align="center" class="bottom_right color-CCFFFF" colspan="2"><strong>Item Code <br />产品号码</strong></td>
		        <td width="8%" align="center" class="bottom_right color-CCFFFF"><strong>Size (S,M,L)</strong></td>
		        <td width="8%" align="center" class="bottom_right color-CCFFFF"><strong>Length<br/>裤长</strong></td>
		        <td width="13%" align="center" class="bottom_right color-CCFFFF"><strong>Size (no.)</strong></td>
		        <td width="13%" align="center" class="bottom_right color-CCFFFF"><strong>Order Qty<br />订购数量</strong></td>
		        <td width="13%" align="center" valign="middle" class="bottom_right color-CCFFFF"><strong>单价</strong></td>
		        <td width="13%" align="center" valign="middle" class="bottom_right color-CCFFFF"><strong>单总价</strong></td>
		        </tr>
		   		    
		    	
		    <?python sumQty = 0 ?>   
		    <tr py:for="wlitem in items">
		          <td align="center" class="bottom_right" colspan="2">${wlitem.item}&nbsp;</td>
		          <td align="center" class="bottom_right">${wlitem.size}&nbsp;</td>
		          <td align="center" class="bottom_right" >${wlitem.length}&nbsp;</td>
		          <td align="center" class="bottom_right" >${wlitem.measure}&nbsp;</td>
		          <td align="center" class="bottom_right">${wlitem.qty}&nbsp;</td>
		          <td align="center" class="bottom_right"><span class="currency" py:content="'&yen;' if order.currency=='RMB' else 'HKD'"/>${'%.6f' % wlitem.item.rmbPrice if order.currency=='RMB' else "%.6f" %wlitem.item.hkPrice}&nbsp;</td>	
		          <td align="center" class="bottom_right"><span class="currency" py:content="'&yen;' if order.currency=='RMB' else 'HKD'"/>${"%.6f" %(wlitem.qty*wlitem.item.rmbPrice) if order.currency=='RMB' else "%.6f" %(wlitem.qty*wlitem.item.hkPrice)}&nbsp;</td>	
		   		  
		   		  <?python 
		   		  	if wlitem.item.labelType == "S": sumQty+=wlitem.qty
		   		  ?>
		    </tr>	        
			<tr>
				<td align="center" class="bottom_right" colspan="5">&nbsp;</td>
				<td align="center" class="bottom_right">Size Label Total :<br />${sumQty}</td>
				<td align="center" class="bottom_right">&nbsp;</td>
				<td align="center" class="bottom_right">&nbsp;</td>
			</tr>
	      </table></td>
	  </tr>
	  <tr>
	    <td align="left" valign="top" class="color-FF9900">
	    	<table width="100%" border="0" cellspacing="0" cellpadding="0">
	        <tr>
	          <td><span class="STYLE19">所需条码牌／挂卡图样</span></td>
	        </tr>
	        <tr>
	          <td align="center" valign="middle" class="color-FF9900">&nbsp;</td> 
	        </tr> 
	        
	        <tr py:if="images" py:for="index,img in enumerate(images)">
	        	<tr>
		          <td align="center" valign="middle" class="color-FF9900">${img}</td> 
		        </tr> 
	        	<td  align="center" valign="middle" class="color-FF9900">                 
		          <div><a href="#imgDIV${index}" class="photo"><img src="/static/images/bossini/${img}.jpg" width="240"/></a></div>
				  <div id="imgDIV${index}"><img src="/static/images/bossini/${img}.jpg"/></div>
	          </td> 
	           <tr>
	          <td align="center" valign="middle" class="color-FF9900">&nbsp;</td> 
	        </tr>
	        </tr>
	        <tr>
	          <td align="center" valign="middle" class="color-FF9900">&nbsp;</td>
	        </tr>
	      </table></td>
	  </tr>
	</table>   

    <!-- main content end -->
  </div>
</div>
</body>
</html>
