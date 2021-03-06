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
    <script src="/static/javascript/custom/bossini_input_h.js" language="javascript"></script>
    
	<script language="JavaScript" type="text/javascript" py:if="tg_flash">
	//<![CDATA[
	    $(document).ready(function(){
	        $.prompt("${tg_flash}",{opacity: 0.6,prefix:'cleanblue',show:'slideDown'});
	    });
	//]]>
	</script>


	
	<?python
		from datetime import datetime as dt
		from ecrm.util.bossini_helper import getChinaStandardCode,getFiberContent,getChinaArea,getChinaChecker,getProductName
		from ecrm.util.common import null2blank
			
		indexor = iter(range(100))
	
	
		shipTostr = "{%s}" % ",".join(['''%d : {shipTo:'%s',shipToAddress:'%s',shipToContact:'%s',shipToTel:'%s', shipToEmail:'%s',
									     sampleReceiver:'%s',sampleReceiverTel:'%s',sampleSendAddress:'%s',requirement:'%s'}'''
			% ( s.id,s.shipTo,null2blank(s.address),null2blank(s.contact),null2blank(s.tel),null2blank(s.email),null2blank(s.sampleReceiver),
					null2blank(s.sampleReceiverTel),null2blank(s.sampleSendAddress),null2blank(s.requirement) )  for s in vendor.shipTo])
			
		billToStr = "{%s}" % ",".join([''' %d:{billToAddress:"%s",billToContact:"%s",billToTel:"%s",billToFax:"%s",
				needChangeFactory:"%s",VATInfo:"%s",invoiceInfo:"%s",accountContact:"%s",currency:"%s",needChangeFactory:"%s",shipmentInstruction:"%s",payterm:"%s"  }
		''' %(b.id,null2blank(b.address),null2blank(b.contact),null2blank(b.tel),null2blank(b.fax),null2blank(b.needChangeFactory)
				,null2blank(b.needVAT),null2blank(b.needInvoice),null2blank(b.account),null2blank(b.currency),null2blank(b.needChangeFactory),null2blank(b.haulage),null2blank(b.payterm)) for b in vendor.billTo])
				
		js = '''
			var currentBillTo = null;
			var billToInfo = %s;
			var shipToInfo = %s;
			var currency = '%s';
			var legacycode_po = '%s';
			var isComplete = '%d';
		''' % ( billToStr,shipTostr,defaultBillToInfo['currency'], "%s %s" %(header.printedLegacyCode,header.poNo),isComplete)	
		
		
		isStickerPreset = True if item and item.itemType == "ST" else False
	?>
	

	<script language="JavaScript" type="text/javascript" py:content="js"/>

</head>

<body>



<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
    <td width="36" valign="top" align="left"><img src="/static/images/images/menu_start.jpg"/></td>
    <td width="176" valign="top" align="left"><a href="/bossinipo/vendor_index"><img src="/static/images/images/Bossini_PO_g.jpg"/></a></td>
    
    
    <td width="64" valign="top" align="left"><a href="#" onclick="toConfirm()"><img src="/static/images/images/confirm_en_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="/bossinipo/vendor_index"><img src="/static/images/images/cancel_en_g.jpg"/></a></td>
    
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/static/images/images/menu_last.jpg"/></td>
    <td align="left" valign="top" background="/static/images/images/menu_end.jpg">&nbsp;</td>
  </tr>
</tbody></table>

</div>
<div class="nav-tree">Bossini&nbsp;&nbsp;&gt;&nbsp;&nbsp;Main&nbsp;&nbsp;&gt;&nbsp;&nbsp;Bar Code Hang Tag or Waist Card 条码吊牌/腰卡</div>
<div style="width:1400px;">
	<div style="overflow:hidden;margin:5px 0px 10px 10px">
	
	<div style="margin-left:20px">
		<h3 style="color:red">请各位 Bossini 工厂注意</h3>
		<p>我司服务 Bossini 印刷卡和条码挂牌到2011春季为止，夏季的订单，请贵司询问 Bossini 的指示。</p>
		<p>谢谢贵司的合作。</p>
		<br />
	</div>
	
	<!--  main content begin -->	
	<form action="/bossinipo/saveHTOrder" method="POST">
		<input type="hidden" name="id" value="${header.id}"/>
		<input type="hidden" name="orderType" value="H"/>
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
		      <td colspan="3" class="bottom_border">
					<select name="billTo" style="width:330px;" onchange="changeBillTo(this)">
			      		<option py:for="b in vendor.billTo" value="${b.id}" py:content="b.billTo" py:attrs="{} if b.id!= defaultBillToInfo['id'] else {'selected':'selected'} "/>
			      	</select>	
		      </td>
		    </tr>
		    <tr>
		      <td>&nbsp;</td>
		      <td><strong>ADDRESS / 地址 :</strong></td>
		      <td colspan="3" class="bottom_border">
       			<textarea name="billToAddress" id="billToAddress" style="width:330px;height:50px">${defaultBillToInfo['address']}</textarea>
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
		      <td colspan="3" class="bottom_border">
				<input type="text" name="billToContact" id="billToContact" value="${defaultBillToInfo['contact']}" style="width:330px;"/>
			  </td>
		    </tr>
		    <tr>
		      <td>&nbsp;</td>
		      <td><strong>TELEPHONE / 電話號碼 :</strong></td>
		      <td colspan="3" class="bottom_border">
				<input type="text" name="billToTel" id="billToTel" value="${defaultBillToInfo['tel']}" style="width:330px;"/>
			  </td>
		    </tr>
		    <tr>
		      <td>&nbsp;</td>
		      <td><strong>E-mail / 電郵 :</strong></td>
		      <td colspan="3" class="bottom_border">
				<input type="text" name="billToEmail" id="billToEmail" value="${defaultShipToInfo['email']}" style="width:330px;"/>
			  </td>
		    </tr>
		    <tr>
		      <td>&nbsp;</td>
		      <td><span class="STYLE20">Payment Currency &amp; Terms 结算货币和付款条款 :</span></td>
		      <td class="bottom_border" colspan="3" >
		      <input type="hidden" id="currency" name="currency" value="${defaultBillToInfo['currency']}"/>
	          <input type="text" id="payterm" name="payterm" value="${defaultBillToInfo['payterm']}" style="width:330px;"/>
		      
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
		      	<input type="text" name="shipmentInstruction" id="shipmentInstruction" value="${defaultBillToInfo['haulage']}" style="width: 170px;"/>
		      </td>
		      <td align="right" width="70" class="STYLE20">需否转厂：</td>
		      <td class="bottom_border">
		      	<select name="needChangeFactory" id="needChangeFactory">
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
		      <td colspan="3" class="bottom_border">
 				<input type="text" name="VATInfo" id="VATInfo" value="${defaultBillToInfo['needVAT']}" style="width:330px;"/>
              </td>
		    </tr>
		    <tr>
		      <td class="STYLE2">&nbsp;</td>
		      <td class="STYLE2">只需要开普通发票 ：</td>
		      <td colspan="3" class="bottom_border">
		      	<input type="text" name="invoiceInfo" id="invoiceInfo" value="${defaultBillToInfo['needInvoice']}" style="width:330px;"/>	
		      </td>
		    </tr>
		    <tr>
		      <td class="STYLE2">&nbsp;</td>
		      <td class="STYLE2">会计对帐联系人 ： </td>
		      <td colspan="3">
				<input type="text" name="accountContact" id="accountContact" value="${defaultBillToInfo['account']}" style="width:330px;"/>	
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
		      <td colspan="3" class="bottom_border">
				<select name="shipTo" style="width:400px;" id="shipTo" onchange="changeShipTo(this)">
			      		<option py:for="s in vendor.shipTo" value="${s.id}" py:content="s.shipTo" py:attrs="{'selected':'selected'} if s.id==defaultShipToInfo['id'] else {}"/>
			      	</select>
			  </td>
		    </tr>
		    <tr>
		      <td>&nbsp;</td>
		      <td><strong>ADDRESS / 地址 :</strong></td>
		      <td colspan="3" class="bottom_border">
				<textarea name="shipToAddress" id="shipToAddress" style="width:400px;height:30px">${defaultShipToInfo['address']}</textarea>
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
		      <td colspan="3" class="bottom_border">
				<input type="text" name="shipToContact" id="shipToContact" value="${defaultShipToInfo['contact']}" style="width:400px;"/>
			  </td>
		    </tr>
		    <tr>
		      <td>&nbsp;</td>
		      <td><strong>TELEPHONE / 電話號碼 :</strong></td>
		      <td colspan="3" class="bottom_border">
				<input type="text" name="shipToTel" id="shipToTel" value="${defaultShipToInfo['tel']}" style="width:400px;"/>	
			  </td>
		    </tr>
		    <tr>
		      <td>&nbsp;</td>
		      <td><strong>E-mail / 電郵 :</strong></td>
		      <td colspan="3" class="bottom_border">
				<input type="text" name="shipToEmail" id="shipToEmail" value="${defaultShipToInfo['email']}" style="width:400px;"/>	
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
		      <td width="120" class="bottom_border">
				<input type="text" name="sampleReceiver" id="sampleReceiver" value="${defaultShipToInfo['sampleReceiver']}"/>
			  </td>
		      <td width="100" align="right"><span class="STYLE2">电话号码：</span></td>
		      <td class="bottom_border">
				<input type="text" name="sampleReceiverTel" id="sampleReceiverTel" value="${defaultShipToInfo['sampleReceiverTel']}"/>
			  </td>
		    </tr>
		    <tr>
		      <td class="STYLE2">&nbsp;</td>
		      <td class="STYLE2">船头办送货地址 ：</td>
		      <td colspan="3" class="bottom_border">
				<input type="text" name="sampleSendAddress" id="sampleSendAddress" value="${defaultShipToInfo['sampleSendAddress']}" style="width:400px;"/>	
			  </td>
		    </tr>
		    <tr>
		      <td class="STYLE2">&nbsp;</td>
		      <td class="STYLE2">包装注明/其他特定要求 :</td>
		      <td colspan="3">
				<textarea name="requirement" id="requirement" style="width:400px;height:60px">${defaultShipToInfo['requirement']}</textarea>
			  </td>
		    </tr>
		  </table>
		</div>
		
			<br class="clear"/>

		<!-- part 2 -->
		
		<table width="98%" border="2" cellpadding="0" cellspacing="0" bordercolor="#000000">
		  <tr>
		    <td height="35" colspan="2" align="left" valign="middle" class="color-000080"><span class="STYLE4">&nbsp;&nbsp;</span><span class="STYLE4">客户订购类别 Customer Order Categories</span></td>
		  </tr>
		  <tr>
		    <td width="200" align="left" valign="top" class="color-000000"><table width="100%" border="0" cellpadding="0" cellspacing="1">
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
		    <td align="left" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
		        <tr>
		          <td colspan="8" class="bottom_right color-0000FF"><div align="center" class="STYLE7">bossini Bar Code Tags / Waist Cards  条码牌 / 腰卡</div></td>
		        </tr>
		        <tr>
		          <td width="15%" height="55" align="center" class="bottom_right color-0000FF"><span class="STYLE8">Customer Order No.<br />客户订单号</span></td>
		          <td width="11%" align="center" class="bottom_right color-0000FF"><span class="STYLE8">Card Type<br />类别</span> </td>
		          <td width="13%" align="center" class="bottom_right color-0000FF"><span class="STYLE8">Item Code<br />产品号码</span></td>
		          <td width="15%" align="center" class="bottom_right color-0000FF"><span class="STYLE8">Shipping Samples<br />船头办需要的数量</span></td>
		          <td width="12%" align="center" class="bottom_right color-0000FF"><span class="STYLE8">Wastage %<br />损耗率</span></td>
		          <td width="14%" align="center" class="bottom_right color-0000FF"><span class="STYLE8">Total Order Quantity<br />订购总数量</span></td>
		          <td width="9%" align="center" class="bottom_right color-0000FF"><span class="STYLE8">Unit Price<br />单价</span></td>
		          <td align="center" class="bottom_right color-0000FF"><span class="STYLE8">Reference Total Order Price (before VAT)<br/>参考税前单价（运费除外）</span></td>
		        </tr>
		        
		        <tr py:for="i in range(3)" class="orderTR">
	  
  					  <div py:if="i==0" py:strip="">
  					  	  <td rowspan="3" align="center" class="STYLE1 bottom_right" ><input type="text" name="customerOrderNo" value="" size="15" enterindex="${indexor.next()}"/></td>
  				          <td align="center" class="STYLE1 bottom_right">
  				          	<select name="npc_cardType_${i}">
  				          		<option py:for="h,c in [('',''),('H','Hang Tag'),('W','Waist Card'),('ST','Sticker')]" value="${h}" py:content="c" py:attrs="{'selected':'selected'} if item and h==item.itemType else {}"/>
  				          	</select>
  				          </td>
  				          <td align="center" class="STYLE1 bottom_right" style="text-align:left">
  				          	<select name="npc_item_${i}">
  				          		<!-- <option py:if="item" value="${item.id}" py:content="item.itemCode" rmbprice="${item.rmbPrice}" hkprice="${item.hkPrice}"/> -->
  				          	   
  				          	  <option py:for="ir in itemRange" value="${ir.id}" py:content="ir.itemCode" rmbprice="${ir.rmbPrice}" hkprice="${ir.hkPrice}" py:attrs="{'selected':'selected'} if item==ir else {}"/>
  				          	</select>
  				          </td>
  				          <td rowspan="3" align="center" class="STYLE1 bottom_right"><input type="text" class="numeric" name="shipmentQty"  size="7" enterindex="${indexor.next()}"/></td>
  				          <td rowspan="3" align="center" class="STYLE1 bottom_right"><input type="text" class="numeric" name="wastageQty" size="7" enterindex="${indexor.next()}"/><b>%</b></td>
  				          <td align="center" valign="middle" bgcolor="#CCFFFF" class="STYLE1 bottom_right"><span class="totalQtyWithSampleWastage" py:content="header.totalQtyWithSampleWastage if not isStickerPreset else header.totalQtyWithoutRoundup"/></td>
  				          <td align="center" valign="middle" bgcolor="#CCFFFF" class="STYLE1 bottom_right">
  					          <span class="currency" py:content="u'&yen;' if defaultBillToInfo.get('currency',None)=='RMB' else 'HKD'"/>
  					          <span class="pcUnitPrice"><div py:if="item" py:strip="">${"%.6f" %item.rmbPrice if defaultBillToInfo.get('currency',None)=='RMB' else "%.6f" %item.hkPrice}</div></span>
  					        </td>
  				          <td align="center" valign="middle" bgcolor="#CCFFFF" class="STYLE1 bottom_right">
  				            <span class="currency" py:content="u'&yen;' if defaultBillToInfo.get('currency',None)=='RMB' else 'HKD'"/>
  				              <span class="pcAmt"><div py:if="item" py:strip="">${"%.6f" %((header.totalQtyWithSampleWastage if not isStickerPreset else header.totalQtyWithoutRoundup)*item.rmbPrice) if defaultBillToInfo.get('currency',None)=='RMB' else "%.6f" %((header.totalQtyWithSampleWastage if not isStickerPreset else header.totalQtyWithoutRoundup)*item.hkPrice)}</div></span>&nbsp;
  				          </td>
  			          </div>
			          
  	        	 	  <div py:if="i!=0" py:strip="">
  	        	 	  	<td align="center" class="STYLE1 bottom_right" >
  	        	 	  	  <select name="npc_cardType_${i}" enterindex="${indexor.next()}">
        								<option py:for="h,c in [('',''),('H','Hang Tag'),('W','Waist Card'),('ST','Sticker')]" value="${h}" py:content="c"/>
        							</select>
  				          </td>
  				          <td align="center" class="STYLE1 bottom_right" style="text-align:left"><select name="npc_item_${i}" enterindex="${indexor.next()}"><option></option></select></td>
  				          <td align="center" valign="middle" bgcolor="#CCFFFF" class="STYLE1 bottom_right"><span class="totalQtyWithSampleWastage" py:content="header.totalQtyWithSampleWastage if not isStickerPreset else header.totalQtyWithoutRoundup"/></td>
  				          <td align="center" valign="middle" bgcolor="#CCFFFF" class="STYLE1 bottom_right"><span class="currency"/><span class="pcUnitPrice"></span>&nbsp;</td>
  				          <td align="center" valign="middle" bgcolor="#CCFFFF" class="STYLE1 bottom_right"><span class="currency"/><span class="pcAmt"></span>&nbsp;</td>
  	        	 	  </div>
			          
		        </tr>  
		        
		        
		        <tr>
		          <td colspan="8" align="center" class="bottom_right color-000080"><span class="STYLE9">如需要 01HT80611101 系列的腰牌，必须填写下面项目的裤长(Length= In-seam)</span></td>
		        </tr>
		        
		      </table></td>
		  </tr>
		  <tr>
		    <td align="left" valign="top" class="color-FF9900">
		    	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		        <tr>
		          <td  colspan="2"><span class="STYLE19">所需条码牌／挂卡图样</span></td>
		        </tr>
		        <tr>
		          <td align="center" valign="middle" class="color-FF9900">&nbsp;</td>
		        </tr>
		        <tr>
			          <td align="center" valign="middle" bgcolor="#FF9900">   
			          <div><a href="#hangTagImgDIV" class="photo">
			                 <img py:if="item and item.itemType=='H'" class="hangTagImg" src="/static/images/bossini/${item.img}.jpg" width="80"/>
			                 <img py:if="not item or item.itemType!='H'" class="hangTagImg" src="/static/images/blank.png" width="80"/>
			               </a>
			          </div>
				        <div id="hangTagImgDIV">
				          <img py:if="item and item.itemType=='H'" src="/static/images/bossini/${item.img}.jpg"/>
				          <img py:if="not item or item.itemType!='H'" class="hangTagImg" src="/static/images/blank.png"/>
				        </div> 
			          </td>
		        		
		        	  <td align="center" valign="middle" bgcolor="#FF9900">
		        	  	<div><a href="#waistCardImgDIV" class="photo"><img class="waistCardImg" src="/static/images/blank.png" width="80"/></a></div>
				  		    <div id="waistCardImgDIV"><img class="waistCardImg" src="/static/images/blank.png"/></div>
		        	  </td>	
		        </tr>
		        <tr>
		          <td align="center" valign="middle" bgcolor="#FF9900">
		            <div><a href="#stickerImgDIV" class="photo">
		                  <img py:if="item and item.itemType=='ST'" class="stickerImg" src="/static/images/bossini/${item.img}.jpg" width="80"/>
		                  <img py:if="not item or item.itemType!='ST'" class="stickerImg" src="/static/images/blank.png" width="80"/>
		                 </a>
		            </div>
                <div id="stickerImgDIV">
                  <img py:if="item and item.itemType=='ST'" class="stickerImg" src="/static/images/bossini/${item.img}.jpg"/>
                  <img py:if="not item or item.itemType!='ST'" class="stickerImg" src="/static/images/blank.png"/>
                </div>
		          </td>
		          <td>&nbsp;</td>
		        </tr>
		        <tr>
		          <td align="center" valign="middle" class="color-FF9900">&nbsp;</td>
		        </tr>
		      </table></td>
		    <td align="left" valign="top">
		    	<table width="100%" border="0" cellspacing="0" cellpadding="0" id="detailTable">
		    		<thead>
				        <tr>
				          <td width="8%" align="center" class="top_bottom_right color-CCFFFF"><strong>bossini Order Qty</strong></td>
				          <td width="8%" align="center" class="top_bottom_right color-CCFFFF"><strong>Shipment Sample</strong></td>
				          <td width="6%" align="center" class="top_bottom_right color-CCFFFF"><strong>Wastage</strong></td>
				          <td width="6%" align="center" class="top_bottom_right color-CCFFFF"><strong>Total Qty</strong></td>
				          <td width="6%" align="center" class="top_bottom_right color-99CC00"><strong>Color code</strong></td>
				          <td width="10%" align="center" class="top_bottom_right color-99CC00"><strong>Color Name</strong></td>
				          <td width="8%" align="center" class="top_bottom_right color-99CC00"><strong>Size Range</strong></td>
				          <td width="6%" align="center" class="top_bottom_right color-99CC00"><strong>Size Code</strong></td>
				          <td width="6%" align="center" class="top_bottom_right color-99CC00"><strong>Size Name</strong></td>
				          <td width="8%" align="center" class="top_bottom_right"><strong class="STYLE3">裤长 <br />Length</strong></td>
				          <td width="8%" align="center" class="top_bottom_right color-99CC00"><strong>Net Price</strong></td>
				          <td align="center" class="top_bottom_right color-99CC00"><strong>EAN Code</strong></td>
				          <td width="6%" align="center" class="top_bottom_right color-99CC00"><strong>Collection<br />Code</strong></td>
				          <td width="6%" align="center" class="top_bottom_right color-99CC00"><strong>Launch<br />Month</strong></td>
				        </tr>
		    		</thead>
		    		<tbody>
				        <tr py:for="d in details" class="detailTR">
				          <td align="center" class="bottom_right color-CCFFFF"><span py:replace="d.qty"/>&nbsp;</td>
				          <td align="center" class="bottom_right"><span py:replace="d.shipSampleQty"/>&nbsp;</td>
				          <td align="center" class="bottom_right"><span py:replace="d.wastageQty"/>&nbsp;</td>
				          <td align="center" class="bottom_right color-FFFF00"><span py:replace="d.totalQty if not isStickerPreset else d.wastageQty"/>&nbsp;</td>
				          <td align="center" class="bottom_right"><span py:replace="d.recolorCode"/>&nbsp;</td>
				          <td align="center" valign="middle" class="bottom_right"><span py:replace="d.colorName"/>&nbsp;</td>
				          <td align="center" valign="middle" class="bottom_right"><span py:replace="d.resizeRange"/>&nbsp;</td>
				          <td align="center" valign="middle" class="bottom_right"><span py:replace="d.sizeCode"/>&nbsp;</td>
				          <td align="center" valign="middle" class="bottom_right"><span py:replace="d.sizeName"/>&nbsp;</td>
				          <td align="center" valign="middle" class="bottom_right"><input type="text" name="detail_length_${d.id}" value="" size="8" class="numeric" enterindex="${indexor.next()}"/>&nbsp;</td>
				          <td align="center" valign="middle" class="bottom_right"><span py:replace="XML(d.priceInHTML)"/>&nbsp;</td>
				          <td align="center" valign="middle" class="bottom_right"><span py:replace="d.eanCode"/>&nbsp;</td>
				          <td align="center" valign="middle" class="bottom_right"><span py:replace="d.collectionCode"/>&nbsp;</td>
				          <td align="center" valign="middle" class="bottom_right"><span py:replace="d.launchMonth"/>&nbsp;</td>
				        </tr>
				        <tr>
				        	<td align="center" class="bottom_right color-CCFFFF"><b><span py:replace="header.sortedSubChildren"/></b>&nbsp;</td>
				        	<td align="center" class="bottom_right">&nbsp;</td>
				        	<td align="center" class="bottom_right">&nbsp;</td>
				        	<td align="center" class="bottom_right color-FFFF00"><b><span class="totalQtyWithSampleWastage" py:content="header.totalQtyWithSampleWastage if not isStickerPreset else header.totalQtyWithoutRoundup"/></b>&nbsp;</td>
				        </tr>
		    		</tbody>
		      </table></td>
		  </tr>
		  <tr py:if="header.marketList=='CHN'">
		    <td height="40" colspan="2" align="left" valign="middle" class="color-99CC00"><span class="STYLE16">&nbsp;&nbsp;中国内销条码标签 内容确认表  CHINA MARKET  Bar Code Tag Details</span></td>
		  </tr>
		</table>
		
		<div py:if="header.marketList=='CHN'" py:strip="">
			<div class="templat_main_div3">
			  <table width="100%" border="0" cellspacing="0" cellpadding="0">
			    <tr>
			      <td width="200" class="STYLE16">商品标价签</td>
			      <td class="STYLE16">FRONT  正面</td>
			    </tr>
			  </table>
			  <table width="100%" border="1" cellpadding="0" cellspacing="0" bordercolor="#000000">
			    <tr>
			      <td class="color-000000"><table width="100%" border="0" cellspacing="1" cellpadding="0">
			          <tr>
			            <td class="STYLE16 color-CCFFCC">品名：</td>
			            <td class="STYLE19 color-FFFFFF">
							      <select name="typeName" style="width:250px" enterindex="${indexor.next()}">
			            		<option></option>
                      <option py:for="pn in getProductName()" py:content="pn.name" value="${pn.name}"/>
			            	</select>	
					    </td>
			          </tr>
			          <tr>
			            <td class="STYLE16 color-CCFFCC">规格/号型：</td>
			            <td class="STYLE19 color-FFFFFF"><input type="text" name="specification" value="详见耐久性标签"  style="width:250px" enterindex="${indexor.next()}"/></td>
			          </tr>
			          <tr>
			            <td class="STYLE16 color-CCFFCC">产地：</td>
			            <td class="STYLE19 color-FFFFFF">
							      <select name="prodcuingArea"  style="width:250px" enterindex="${indexor.next()}">
			            		<option></option>
			            		<option py:for="ca in getChinaArea()" py:content="ca.name" value="${ca.name}"/>
			            	</select>
						</td>
			          </tr>
			          <tr>
			            <td class="STYLE16 color-CCFFCC">单位 ：</td>
			            <td class="STYLE19 color-FFFFFF">
			               <select name="unit" style="width:250px" enterindex="${indexor.next()}">
			                 <option value="件">件</option>
			                 <option value="套">套</option>
			                 <option value="条">条</option>
							 <option value="包">包</option>
			               </select>
			            </td>
			          </tr>
			          <tr>
			            <td class="STYLE16 color-CCFFCC">物价员：</td>
			            <td class="STYLE19 color-CCFFCC">&nbsp;</td>
			          </tr>
			          <tr>
			            <td class="STYLE16 color-CCFFCC">价格举报电话：</td>
			            <td class="STYLE19 color-CCFFCC">12358</td>
			          </tr>
			          <tr>
			            <td width="200" class="STYLE16 color-CCFFCC">服务监督电话：</td>
			            <td class="STYLE19 color-CCFFCC">020-81371188</td>
			          </tr>
			        </table></td>
			    </tr>
			  </table>
			</div>
			
			
			<div class="templat_main_div3">
			  <table width="100%" border="0" cellspacing="0" cellpadding="0">
			    <tr>
			      <td width="200" class="STYLE16">合格证</td>
			      <td class="STYLE16">BACK  背面</td>
			    </tr>
			  </table>
			  <table width="100%" border="1" cellpadding="0" cellspacing="0" bordercolor="#000000">
			    <tr>
			      <td class="color-000000"><table width="100%" border="0" cellspacing="1" cellpadding="0">
			          <tr>
			            <td width="200" class="STYLE16 color-CCFFCC" id="show_name">产品名称：</td>
			            <td class="STYLE19 color-FFFFFF">
							      <select name="productName" style="width:250px" enterindex="${indexor.next()}">
			            	  <option></option>
			            	  <option py:for="pn in getProductName()" py:content="pn.name" value="${pn.name}"/>
			            	</select>
						</td>
			          </tr>
			          <tr>
			            <td class="STYLE16 color-CCFFCC" id="show_standard">产品标准：</td>
			            <td class="STYLE19 color-FFFFFF">
							     <select name="standard" style="width:250px" enterindex="${indexor.next()}">
                      <option value=""></option>							     
							        <option py:for="v in getChinaStandardCode()" py:content="v" value="${v}"/>
			            	</select>	
						      </td>
			          </tr>
					  <tr style="display:none;"><td class="STYLE19 color-FFFFFF" >&nbsp;</td>
			          	<td class="STYLE19 color-FFFFFF"  >
						<input type="text" name="standardExt" id="standardExt" /> 
			          	</td></tr>
			          <!--<tr style="display:true;" py:if="header.vendorCode=='WY'">-->
			          	<!--<td class="STYLE19 color-FFFFFF" >&nbsp;</td>-->
			          	<!--<td class="STYLE19 color-FFFFFF">-->
			          		<!--<select id="standardExt" name="standardExt" style="width:250px" enterindex="${indexor.next()}">-->
			          			<!--<option value=""></option><option value="水洗产品">水洗产品</option>-->
			          		<!--</select>-->
			          	<!--</td>-->
			          <!--</tr>-->
			          <tr>
			            <td class="STYLE16 color-CCFFCC" id="show_grade">产品等级：</td>
			            <td class="STYLE19 color-FFFFFF">
			               <select name="grade" style="width:250px" enterindex="${indexor.next()}">
			                 <option value="一等品">一等品</option>
			                 <option value="合格品">合格品</option>
			               </select>
			            </td>
			          </tr>
			          <tr>
			            <td class="STYLE16 color-CCFFCC">检验员：</td>
			            <td class="STYLE19 color-FFFFFF">
				          	<select name="checker" style="width:250px" enterindex="${indexor.next()}">
				          		<option value=""></option>
      								<option py:for="checker in getChinaChecker()" py:content="checker.name" value="${checker.name}"/>
				          	</select>
			          	</td>
			          </tr>
			          <tr>
			            <td class="STYLE16 color-CCFFCC">货品编号：</td>
			            <td class="STYLE19 color-CCFFCC"><span py:replace="header.printedLegacyCode"/></td>
			          </tr>
			          <tr>
			            <td colspan="2" class="STYLE16 color-CCFFCC">本产品符合安全技术类别：</td>
			          </tr>
			          <tr>
			            <td colspan="2" class="STYLE19 color-FFFFFF">
							<select name="technicalType" style="width:250px" enterindex="${indexor.next()}">
			            		<option py:for="v in ['','B类 直接接触皮肤的产品','C类 非直接接触皮肤的产品']" py:content="v" value="${v}"/>
			            	</select>	
						</td>
			          </tr>
					   
			          <tr>
			            <td colspan="2" class="STYLE16 color-CCFFCC">GB 18401-2003</td>
			          </tr>
					   <tr>
			            <td colspan="2" class="STYLE19 color-FFFFFF">
							<select name="processCompany" style="width:550px">
								<option  value=""></option>
			            		<option  value="受委托加工企业：汕头市德财毛织服装有限公司 高比例羊毛混纺标志执照号码:1359CH04B">受委托加工企业：汕头市德财毛织服装有限公司 高比例羊毛混纺标志执照号码:1359CH04B</option>
							
			            	</select>	
						</td>
			          </tr>
			        </table></td>
			    </tr>
			  </table>
			</div>
		</div>
		
		
		<!-- fiber content for YB sticker -->
    
    <div py:if="header.itemType!='WOVEN' and header.marketList != 'CHN'" id="fc_div" class="templat_main_div3" style="${'' if header.itemType!='WOVEN' and item and item.itemType=='ST' else 'display:none'}">
      <table width="100%" border="1" cellpadding="0" cellspacing="0" bordercolor="#000000">
          <tr>
            <td width="200" class="STYLE16">百分比</td>
            <td class="STYLE16">成份</td>
          </tr>
          <tr py:for="i in range(6)" class="layer">
            <td width="200" class="STYLE16 color-CCFFCC"><input type="text" name="percentage_${i}" class="numeric"  style="width:100px"/> %</td>
            <td width="200" class="STYLE16 color-CCFFCC">
              <select name="component_${i}" style="width:300px">
                <option value=""></option>
                <option py:for="v in getFiberContent()" py:content="'%s %s' %(v.HKSINEXP,v.TWN)" value="${v.id}"/>
              </select>
            </td>
          </tr>
        </table>
    </div>

		
	</form>		
	<!-- main content end -->
	
	</div>
</div>


</body>
</html>


