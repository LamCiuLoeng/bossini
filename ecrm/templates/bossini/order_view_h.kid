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
<?python
  isStickerOnly = True
  for oneItem in items :
    if oneItem.item.itemType != 'ST' : isStickerOnly = False
?>

<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
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
</tbody></table>

</div>
<div class="nav-tree">Bossini&nbsp;&nbsp;&gt;&nbsp;&nbsp;Main&nbsp;&nbsp;&gt;&nbsp;&nbsp;Bar Code Hang Tag or Waist Card 条码吊牌/腰卡</div>
<div style="width:1400px;">
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
		        
		        <tr py:for="i,item in enumerate(items)">
				  	  <td py:if="i==0" rowspan="${items.count()}" align="center" class="STYLE1 bottom_right" >${order.customerOrderNo}&nbsp;</td>
				  	  
			          <td align="center" class="STYLE1 bottom_right">${item.item.showItemType}&nbsp;</td>
			          <td align="center" class="STYLE1 bottom_right">${item.item.itemCode}&nbsp;</td>
			          
			          <td py:if="i==0" rowspan="${items.count()}" align="center" class="STYLE1 bottom_right">${header.shipmentQty}&nbsp;</td>
			          <td py:if="i==0" rowspan="${items.count()}" align="center" class="STYLE1 bottom_right">${header.wastageQty}<b>%</b>&nbsp;</td>
			          
			          <td align="center" valign="middle" bgcolor="#CCFFFF" class="STYLE1 bottom_right">${header.totalQtyWithSampleWastage if not isStickerOnly else header.totalQtyWithoutRoundup}&nbsp;</td>
					      <td align="center" valign="middle" bgcolor="#CCFFFF" class="STYLE1 bottom_right">
				          <span class="currency" py:content="u'&yen;' if order.currency=='RMB' else '$'"/><span class="pcUnitPrice">${"%.6f" %item.item.rmbPrice if order.currency=='RMB' else "%.6f" %item.item.hkPrice}</span>
				        </td>
			          <td align="center" valign="middle" bgcolor="#CCFFFF" class="STYLE1 bottom_right">
			             <span class="currency" py:content="u'&yen;' if order.currency=='RMB' else '$'"/><span class="pcAmt">${"%.6f" %((header.totalQtyWithSampleWastage if not isStickerOnly else header.totalQtyWithoutRoundup)*item.item.rmbPrice) if order.currency=='RMB' else "%.6f" %((header.totalQtyWithSampleWastage if not isStickerOnly else header.totalQtyWithoutRoundup)*item.item.hkPrice)}</span>&nbsp;
			          </td> 
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
			          <div py:for="index,oneRecord in enumerate(items)" py:if="oneRecord.item.itemType in ['H','W']" style="float:left">
  			        	<div><a href="#hangTagImgDIV${index}" class="photo"><img src="/static/images/bossini/${oneRecord.item.img}.jpg" height="300"/></a></div>
  				      	<div id="hangTagImgDIV${index}"><img class="hangTagImg" src="/static/images/bossini/${oneRecord.item.img}.jpg"/></div> 
			          </div>
			        </td>
		        </tr>
		        <tr>
		          <td align="center" valign="middle" bgcolor="#FF9900">
		            <div py:for="index,oneRecord in enumerate(items)" py:if="oneRecord.item.itemType in ['ST',]" py:strip="">
                  <div><a href="#hangTagImgDIV${index}" class="photo"><img src="/static/images/bossini/${oneRecord.item.img}${'' if header.itemType=='KNIT' else 'NC'}.jpg" height="300"/></a></div>
                  <div id="hangTagImgDIV${index}"><img class="hangTagImg" src="/static/images/bossini/${oneRecord.item.img}${'' if header.itemType=='KNIT' else 'NC'}.jpg"/></div> 
                </div>
		          </td>
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
				          <td width="6%" align="center" class="top_bottom_right color-99CC00"><strong>Size Range</strong></td>
				          <td width="6%" align="center" class="top_bottom_right color-99CC00"><strong>Size Name</strong></td>
				          <td width="8%" align="center" class="top_bottom_right color-99CC00"><strong>Size code</strong></td>
				          <td width="8%" align="center" class="top_bottom_right"><strong class="STYLE3">裤长 <br />
				            Length</strong></td>
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
				          <td align="center" class="bottom_right color-FFFF00"><span py:replace="d.totalQty if not isStickerOnly else d.wastageQty"/>&nbsp;</td>
				          <td align="center" class="bottom_right"><span py:replace="d.recolorCode"/>&nbsp;</td>
				          <td align="center" valign="middle" class="bottom_right"><span py:replace="d.colorName"/>&nbsp;</td>
				          <td align="center" valign="middle" class="bottom_right"><span py:replace="d.resizeRange"/>&nbsp;</td>
				          <td align="center" valign="middle" class="bottom_right"><span py:replace="d.sizeCode"/>&nbsp;</td>
				          <td align="center" valign="middle" class="bottom_right"><span py:replace="d.sizeName"/>&nbsp;</td>
				          <td align="center" valign="middle" class="bottom_right"><span py:replace="d.length"/>&nbsp;</td>
				          <td align="center" valign="middle" class="bottom_right"><span py:replace="XML(d.priceInHTML)"/>&nbsp;</td>
				          <td align="center" valign="middle" class="bottom_right"><span py:replace="d.eanCode"/>&nbsp;</td>
				          <td align="center" valign="middle" class="bottom_right"><span py:replace="d.collectionCode"/>&nbsp;</td>
                  <td align="center" valign="middle" class="bottom_right"><span py:replace="d.launchMonth"/>&nbsp;</td>
				        </tr>
				        <tr>
				        	<td align="center" class="bottom_right"><b><span py:replace="header.sortedSubChildren"/></b>&nbsp;</td>
				        	<td align="center" class="bottom_right">&nbsp;</td>
				        	<td align="center" class="bottom_right">&nbsp;</td>
				        	<td align="center" class="bottom_right"><b><span class="totalQtyWithSampleWastage" py:content="header.totalQtyWithSampleWastage if not isStickerOnly else header.totalQtyWithoutRoundup"/></b>&nbsp;</td>
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
			            <td class="STYLE19 color-FFFFFF">${order.typeName}&nbsp;</td>
			          </tr>
			          <tr>
			            <td class="STYLE16 color-CCFFCC">规格/号型：</td>
			            <td class="STYLE19 color-FFFFFF">${order.specification}&nbsp;</td>
			          </tr>
			          <tr>
			            <td class="STYLE16 color-CCFFCC">产地：</td>
			            <td class="STYLE19 color-FFFFFF">${order.prodcuingArea}&nbsp;</td>
			          </tr>
			          <tr>
			            <td class="STYLE16 color-CCFFCC">单位 ：</td>
			            <td class="STYLE19 color-FFFFFF">${order.unit}&nbsp;</td>
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
			  <?python
			  ACC_YB=False
			  for item in items:
			      if item.item.itemCode in ['06BC75620902','06BC75630902','06BC75640902','06BC75770902']:
				      ACC_YB=True
			  ?>
			  
			  <table width="100%" border="1" cellpadding="0" cellspacing="0" bordercolor="#000000">
			    <tr>
			      <td class="color-000000"><table width="100%" border="0" cellspacing="1" cellpadding="0">
			          <tr>
			            <td width="200" class="STYLE16 color-CCFFCC" py:content="'货品名称：' if ACC_YB else '产品名称：'">产品名称：</td>
			            <td class="STYLE19 color-FFFFFF">${order.productName}&nbsp;</td>
			          </tr>
			          <tr>
			            <td class="STYLE16 color-CCFFCC" py:content="'执行标准：' if ACC_YB else '产品标准：'">产品标准：</td>
			            <td class="STYLE19 color-FFFFFF">${order.standard}&nbsp;</td>
			          </tr>
			           <tr py:if="order.standardExt">
			            <td class="STYLE19 color-FFFFFF">&nbsp;</td>
			            <td class="STYLE19 color-FFFFFF">${order.standardExt}&nbsp;</td>
			          </tr>
			          <tr>
			            <td class="STYLE16 color-CCFFCC" py:content="'等级：' if ACC_YB else '产品等级：'">产品等级：</td>
			            <td class="STYLE19 color-FFFFFF">${order.grade}&nbsp;</td>
			          </tr>
			          <tr>
			            <td class="STYLE16 color-CCFFCC">检验员：</td>
			            <td class="STYLE19 color-FFFFFF">${order.checker}&nbsp;</td>
			          </tr>
			          <tr>
			            <td class="STYLE16 color-CCFFCC">货品编号：</td>
			            <td class="STYLE19 color-CCFFCC">${header.printedLegacyCode}&nbsp;</td>
			          </tr>
			          <tr>
			            <td colspan="2" class="STYLE16 color-CCFFCC">本产品符合安全技术类别：</td>
			          </tr>
			          <tr>
			            <td colspan="2" class="STYLE19 color-FFFFFF">${order.technicalType}&nbsp;</td>
			          </tr>
			          <tr>
			            <td colspan="2" class="STYLE16 color-CCFFCC">ＧＢ 18401-2003</td>
			          </tr>
					  <tr py:if="order.processCompany">
			            <td colspan="2" class="STYLE16 color-CCFFCC">${order.processCompany}</td>
			          </tr>
			        </table></td>
			    </tr>
			  </table>
			</div>
		</div>
		
		
		<div py:if="len(layers)>0" id="fc_div" class="templat_main_div3">
		  <table width="100%" border="1" cellpadding="0" cellspacing="0" bordercolor="#000000">
          <tr>
            <td width="200" class="STYLE16">百分比</td>
            <td class="STYLE16">成份</td>
          </tr>
          <tr py:for="layer in layers">
            <td width="200" class="STYLE16 color-CCFFCC">${layer.percentage} %</td>
            <td width="200" class="STYLE16 color-CCFFCC">${"%s %s" % (layer.component.HKSINEXP,layer.component.TWN)}</td>
          </tr>
        </table>
		</div>

	<!-- main content end -->
	
	</div>
</div>


</body>
</html>


