<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#"
    py:extends="'../master.kid'">
<head>
	<meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
	<title>r-pac - Bossini</title>

	<link rel="stylesheet" href="/static/css/custom/order.css" type="text/css" media="screen"/>
	<script src="/static/javascript/jquery-impromptu.1.5.js" language="javascript"></script>

	<script src="/static/javascript/numeric.js" language="javascript"></script>
	<script src="/static/javascript/fancyzoom.js" language="javascript"></script>
	
	<script src="/static/javascript/jquery.enter2Tab.js" language="javascript"></script>
	<script src="/static/javascript/util/common.js" language="javascript"></script>
	<script src="/static/javascript/custom/bossini_input_w.js" language="javascript"></script>
	<script language="JavaScript" type="text/javascript" py:if="tg_flash">
		//<![CDATA[
		    $(document).ready(function(){
		        $.prompt("${tg_flash}",{opacity: 0.6,prefix:'cleanblue',show:'slideDown'});
		    });
		//]]>
	</script>
	<?python
		from datetime import datetime as dt
		from ecrm.util.bossini_helper import mapSizeNo
		from ecrm.util.common import null2blank
		
		indexor = iter(range(100))
	
	
		shipTostr = "{%s}" % ",".join(['''%d : {shipTo:'%s',shipToAddress:'%s',shipToContact:'%s',shipToTel:'%s', shipToEmail:'%s',
									     sampleReceiver:'%s',sampleReceiverTel:'%s',sampleSendAddress:'%s',requirement:'%s'}'''
			% ( s.id,s.shipTo,null2blank(s.address),null2blank(s.contact),null2blank(s.tel),null2blank(s.email),null2blank(s.sampleReceiver),
					null2blank(s.sampleReceiverTel),null2blank(s.sampleSendAddress),null2blank(s.requirement) )  for s in vendor.shipTo])
			
		billToStr = "{%s}" % ",".join([''' %d:{billToAddress:"%s",billToContact:"%s",billToTel:"%s",billToFax:"%s",
				needChangeFactory:"%s",VATInfo:"%s",invoiceInfo:"%s",accountContact:"%s",currency:"%s",needChangeFactory:"%s",payterm:"%s",shipmentInstruction:"%s" }
		''' %(b.id,null2blank(b.address),null2blank(b.contact),null2blank(b.tel),null2blank(b.fax),null2blank(b.needChangeFactory)
				,null2blank(b.needVAT),null2blank(b.needInvoice),null2blank(b.account),null2blank(b.currency),null2blank(b.needChangeFactory),null2blank(b.payterm),null2blank(b.haulage) ) for b in vendor.billTo])
				
		js = '''
			var currentBillTo = null;
			var billToInfo = %s;
			var shipToInfo = %s;
			var currency = '%s';
		''' % ( billToStr,shipTostr,defaultBillToInfo['currency'])	
	?>
<script language="JavaScript" type="text/javascript" py:content="js"/>
</head>
<body>
<div id="function-menu">
  <table width="100%" cellspacing="0" cellpadding="0" border="0">
    <tbody>
      <tr>
        <td width="36" valign="top" align="left"><img src="/static/images/images/menu_start.jpg"/></td>
        <td width="176" valign="top" align="left"><a href="/bossinipo/vendor_index"><img src="/static/images/images/Bossini_PO_g.jpg"/></a></td>
        <td width="64" valign="top" align="left"><a href="#" onclick="toConfirm()"><img src="/static/images/images/confirm_en_g.jpg"/></a></td>
        <td width="64" valign="top" align="left"><a href="/bossinipo/vendor_index"><img src="/static/images/images/cancel_en_g.jpg"/></a></td>
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
    <!-- <p><b>${header.id}</b></p> -->
    <form action="/bossinipo/saveWovenOrder" method="POST">
      <input type="hidden" name="id" value="${header.id}"/>
      <input type="hidden" name="orderType" value="WOV"/>
      <input type="hidden" name="token" value="${token}"/>
      
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
	      <td colspan="3" class="bottom_border"><select name="billTo" style="width:330px;" onChange="changeBillTo(this)">
	          <option py:for="b in vendor.billTo" value="${b.id}" py:content="b.billTo" py:attrs="{} if b.id!= defaultBillToInfo['id'] else {'selected':'selected'} "/>
	        </select>
	      </td>
	    </tr>
	    <tr>
	      <td>&nbsp;</td>
	      <td><strong>ADDRESS / 地址 :</strong></td>
	      <td colspan="3" class="bottom_border"><textarea name="billToAddress" id="billToAddress" style="width:330px;height:50px">${defaultBillToInfo['address']}</textarea>
	      </td>
	    </tr>
	    <tr>
	      <td>&nbsp;</td>
	      <td>&nbsp;</td>
	      <td colspan="3">&nbsp;</td>
	    </tr>
	    <tr>
	      <td>&nbsp;</td>
	      <td><strong>CONTACT / 聯系人 :</strong></td>
	      <td colspan="3" class="bottom_border"><input type="text" name="billToContact" id="billToContact" value="${defaultBillToInfo['contact']}" style="width:330px;"/>
	      </td>
	    </tr>
	    <tr>
	      <td>&nbsp;</td>
	      <td><strong>TELEPHONE / 電話號碼 :</strong></td>
	      <td colspan="3" class="bottom_border"><input type="text" name="billToTel" id="billToTel" value="${defaultBillToInfo['tel']}" style="width:330px;"/>
	      </td>
	    </tr>
	    <tr>
	      <td>&nbsp;</td>
	      <td><strong>E-mail / 電郵 :</strong></td>
	      <td colspan="3" class="bottom_border"><input type="text" name="billToEmail" id="billToEmail" value="${defaultShipToInfo['email']}" style="width:330px;"/>
	      </td>
	    </tr>
	    <tr>
	      <td>&nbsp;</td>
	      <td><span class="STYLE20">Payment Currency &amp; Terms 结算货币和付款条款:</span></td>
	      <td class="bottom_border" colspan="3" >
	      	<input type="hidden" id="currency" name="currency" value="${defaultBillToInfo['currency']}"/>
	        <input type="text" id="payterm" name="payterm" value="${defaultBillToInfo['payterm']}"  style="width:330px;"/>
	      
	      <!--
	      	<select name="currency" id="currency"  style="width:330px;">
	      		<option py:for="v in ['RMB','HKD']" value="${v}" py:content="v" py:attrs="{} if v!=defaultBillToInfo['currency'] else {'selected':'selected'}" />
	      	</select>
	      	-->
	      	
	      </td>
	    </tr>
	    <tr py:if="header.vendorCode=='LWF'">
	      <td>&nbsp;</td>
	      <td><span class="STYLE20">运费指示：</span></td>
	      <td class="bottom_border">
	      	<input type="text" name="shipmentInstruction" id="shipmentInstruction" value="${defaultBillToInfo['haulage']}" style="width: 180px;"/>
	      </td>
	      <td align="right" width="70" class="STYLE20">需否转厂：</td>
	      <td class="bottom_border"><select name="needChangeFactory" id="needChangeFactory">
	          <option value=""></option>
	          <option value="需要">需要</option>
	          <option value="不需要">不需要</option>
	        </select>
	      </td>
	    </tr>
	    <tr py:if="header.vendorCode!='LWF'">
	      <td>&nbsp;</td>
	      <td><span class="STYLE20"  colspan="3">运费指示：</span></td>
	      <td class="bottom_border">
	      	<input type="text" name="shipmentInstruction" id="shipmentInstruction" value="${defaultBillToInfo['haulage']}" style="width: 330px;"/>
	      	</td>
	    </tr>
	    <tr>
	      <td>&nbsp;</td>
	      <td><span class="STYLE2">需要对帐后开税票 ：</span></td>
	      <td colspan="3" class="bottom_border"><input type="text" name="VATInfo" id="VATInfo" value="${defaultBillToInfo['needVAT']}" style="width:330px;"/>
	      </td>
	    </tr>
	    <tr>
	      <td class="STYLE2">&nbsp;</td>
	      <td class="STYLE2">只需要开普通发票 ：</td>
	      <td colspan="3" class="bottom_border"><input type="text" name="invoiceInfo" id="invoiceInfo" value="${defaultBillToInfo['needInvoice']}" style="width:330px;"/>
	      </td>
	    </tr>
	    <tr>
	      <td class="STYLE2">&nbsp;</td>
	      <td class="STYLE2">会计对帐联系人 ： </td>
	      <td colspan="3"><input type="text" name="accountContact" id="accountContact" value="${defaultBillToInfo['account']}" style="width:330px;"/>
	      </td>
	    </tr>
	  </table>
	</div>
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
	      <td colspan="3" class="bottom_border"><select name="shipTo" style="width:400px;" id="shipTo" onChange="changeShipTo(this)">
	          <option py:for="s in vendor.shipTo" value="${s.id}" py:content="s.shipTo" py:attrs="{'selected':'selected'} if s.id==defaultShipToInfo['id'] else {}"/>
	        </select>
	      </td>
	    </tr>
	    <tr>
	      <td>&nbsp;</td>
	      <td><strong>ADDRESS / 地址 :</strong></td>
	      <td colspan="3" class="bottom_border"><textarea name="shipToAddress" id="shipToAddress" style="width:400px;height:30px">${defaultShipToInfo['address']}</textarea>
	      </td>
	    </tr>
	    <tr>
	      <td>&nbsp;</td>
	      <td>&nbsp;</td>
	      <td colspan="3">&nbsp;</td>
	    </tr>
	    <tr>
	      <td>&nbsp;</td>
	      <td><strong>CONTACT / 聯系人 :</strong></td>
	      <td colspan="3" class="bottom_border"><input type="text" name="shipToContact" id="shipToContact" value="${defaultShipToInfo['contact']}" style="width:400px;"/>
	      </td>
	    </tr>
	    <tr>
	      <td>&nbsp;</td>
	      <td><strong>TELEPHONE / 電話號碼 :</strong></td>
	      <td colspan="3" class="bottom_border"><input type="text" name="shipToTel" id="shipToTel" value="${defaultShipToInfo['tel']}" style="width:400px;"/>
	      </td>
	    </tr>
	    <tr>
	      <td>&nbsp;</td>
	      <td><strong>E-mail / 電郵 :</strong></td>
	      <td colspan="3" class="bottom_border"><input type="text" name="shipToEmail" id="shipToEmail" value="${defaultShipToInfo['email']}" style="width:400px;"/>
	      </td>
	    </tr>
	    <tr>
	      <td>&nbsp;</td>
	      <td>&nbsp;</td>
	      <td colspan="3">&nbsp;</td>
	    </tr>
	    <tr>
	      <td>&nbsp;</td>
	      <td><span class="STYLE2">船头办特定收件人名字：</span></td>
	      <td width="120" class="bottom_border"><input type="text" name="sampleReceiver" id="sampleReceiver" value="${defaultShipToInfo['sampleReceiver']}"/>
	      </td>
	      <td width="100" align="right"><span class="STYLE2">电话号码：</span></td>
	      <td class="bottom_border"><input type="text" name="sampleReceiverTel" id="sampleReceiverTel" value="${defaultShipToInfo['sampleReceiverTel']}"/>
	      </td>
	    </tr>
	    <tr>
	      <td class="STYLE2">&nbsp;</td>
	      <td class="STYLE2">船头办送货地址 ：</td>
	      <td colspan="3" class="bottom_border"><input type="text" name="sampleSendAddress" id="sampleSendAddress" value="${defaultShipToInfo['sampleSendAddress']}" style="width:400px;"/>
	      </td>
	    </tr>
	    <tr>
	      <td class="STYLE2">&nbsp;</td>
	      <td class="STYLE2">包装注明/其他特定要求 :</td>
	      <td colspan="3"><textarea name="requirement" id="requirement" style="width:400px;height:60px">${defaultShipToInfo['requirement']}</textarea>
	      </td>
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
            <td align="center" class="color-FFFF99"><strong><span id="line" py:content="header.line"/></strong></td>
          </tr>
	      </table></td>
	    <td rowspan="2" align="left" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
 
	        <tr>
		        <td height="55" align="center" class="bottom_right color-CC99FF"><span class="STYLE18">Customer Order No.<br />客户订单号</span> </td>
		        <td align="center" class="bottom_right"><input type="text" name="customerOrderNo" value="" size="15" enterindex="${indexor.next()}"/></td>
		        <td align="center" class="bottom_right color-CC99FF"  colspan="2"><span class="STYLE18">船头办需<br />要的数量</span></td>
		        <td align="center" class="bottom_right"><input type="text" name="wlShipment" size="7" class="numeric" enterindex="${indexor.next()}"/></td>
		        <td align="center" class="bottom_right color-CC99FF"><span class="STYLE18" >尺码唛总订购单价<br />（运费除外）：</span></td>
		        <td align="center" class="bottom_right color-99CCFF" colspan="2"><span class="currency"/><span id="sizeLabelAmt"/></td>
		        </tr>
		      <tr>
		        <td width="28%" align="center" class="bottom_right color-CCFFFF" colspan="2"><strong>Item Code <br />产品号码</strong></td>
		        <td width="8%" align="center" class="bottom_right color-CCFFFF"><strong>Size (S,M,L)</strong></td>
		        <td width="8%" align="center" class="bottom_right color-CCFFFF"><strong>Length<br/>裤长</strong></td>
		        <td width="13%" align="center" class="bottom_right color-CCFFFF"><strong>Size (no.)</strong></td>
		        <td width="13%" align="center" class="bottom_right color-CCFFFF"><strong>Order Qty<br />订购数量</strong></td>
		        <td width="13%" align="center" valign="middle" class="bottom_right color-CCFFFF"><strong>单价</strong></td>
		        <td width="13%" align="center" valign="middle" class="bottom_right color-CCFFFF"><strong>单总价</strong></td>
		        </tr>
	        
	        <tr py:for="i in range(16)" class="wl-detail">
	          <td class="bottom_right" colspan="2">&nbsp;&nbsp;
	          	<select name="nwl_item_${i}" enterindex="${indexor.next()}">
	          		<option value=""></option>
	          		<option py:for="item in items" value="${item.id}" rmbPrice="${item.rmbPrice}" hkPrice="${item.hkPrice}">${item.display}</option>:
	          	</select>
	          </td>
	          <td align="center" class="bottom_right">
      				<select name="nwl_size_${i}" enterindex="${indexor.next()}">
      					<option py:for="k in ['','XXS','XS','S','M','L','XL','XXL']+[kk for kk in filter( lambda a:a not in [35,37,39],range(24,41))]" py:content="k" value="${k}"/>
      				</select>
    			  </td>
    			  <td align="center" class="bottom_right" >
    			  	<select name="nwl_length_${i}" id="nwl_length_${i}" enterindex="${indexor.next()}" disabled="disabled">
    			  		<option py:for="v in range(29,36)" value="${v}" py:content="v"/>
    			  	</select>
    			  </td>
	          <td align="center" class="bottom_right" >
				      <select name="nwl_measure_${i}" id="nwl_measure_${i}" enterindex="${indexor.next()}"><option value=""></option></select>
	          </td>
	          <td align="center" class="bottom_right"><input type="text" class="numeric wlQty" ref="nwl_labelType_${i}" name="nwl_qty_${i}" size="12" enterindex="${indexor.next()}"/></td>
	          <td align="center" class="bottom_right"><span class="currency"/><span class="price"/>&nbsp;</td>	
	          <td align="center" class="bottom_right"><span class="currency"/><span class="amt"/>&nbsp;</td>	
	        </tr>
	        <tr>
    				<td align="center" class="bottom_right" colspan="5">&nbsp;</td>
    				<td align="center" class="bottom_right">Size Label Total : <br /><span id="sizeLabelTotalQty">0</span></td>
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
	       
	         <tr>
	        	<td align="center" valign="middle" class="color-FF9900"><span id="sizeLabelCode"/>&nbsp;</td> 
	        </tr> 
	        <tr>
	          <td align="center" valign="middle" class="color-FF9900">
	          	 <div><a href="#sizeLabelImgDIV" class="photo"><img class="sizeLabelImg" src="/static/images/blank.png" width="240"/></a></div>
				 <div id="sizeLabelImgDIV"><img class="sizeLabelImg" src="/static/images/blank.png"/></div>	
	          </td> 
	        </tr>
	        <tr>
	          <td align="center" valign="middle" class="color-FF9900">&nbsp;</td>
	        </tr>
	      </table></td>
	  </tr>
	</table>   
      
    </form>
    <!-- main content end -->
  </div>
</div>
</body>
</html>
