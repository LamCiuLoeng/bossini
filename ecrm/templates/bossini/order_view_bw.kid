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
<div class="nav-tree">Bossini&nbsp;&nbsp;&gt;&nbsp;&nbsp;Main&nbsp;&nbsp;&gt;&nbsp;&nbsp;Body Wear Label</div>
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
		          <td colspan="8" class="bottom_right color-0000FF"><div align="center" class="STYLE7">bossini Body Wear Label</div></td>
		        </tr>
		        <tr>
		          <td width="15%" height="55" align="center" class="bottom_right color-0000FF"><span class="STYLE8">Customer Order No.<br />客户订单号</span></td>
		          <td width="11%" align="center" class="bottom_right color-0000FF"><span class="STYLE8">Card Type<br />类别</span> </td>
		          <td width="13%" align="center" class="bottom_right color-0000FF"><span class="STYLE8">Item Code<br />产品号码</span></td>
		          <td width="15%" align="center" class="bottom_right color-0000FF"><span class="STYLE8">Shipping Samples<br />船头办需要的数量</span></td>
		          <td width="14%" align="center" class="bottom_right color-0000FF"><span class="STYLE8">Total Order Quantity<br />订购总数量</span></td>
		          <td width="9%" align="center" class="bottom_right color-0000FF"><span class="STYLE8">Unit Price<br />单价</span></td>
		          <td align="center" class="bottom_right color-0000FF"><span class="STYLE8">Reference Total Order Price (before VAT)<br/>参考税前单价（运费除外）</span></td>
		        </tr>
		        
		        <tr>
                            <td height="70" align="center" class="STYLE1 bottom_right" >${order.customerOrderNo}&nbsp;</td>
                            <td align="center" class="STYLE1 bottom_right">${bwInfo.item.showItemType}&nbsp;</td>
                            <td align="center" class="STYLE1 bottom_right">${bwInfo.item.itemCode}&nbsp;</td>
                            <td align="center" class="STYLE1 bottom_right">${header.shipmentQty}&nbsp;</td>
                            <td align="center" valign="middle" bgcolor="#CCFFFF" class="STYLE1 bottom_right">${header.totalQtyWithSample}&nbsp;</td>
                            <td align="center" valign="middle" bgcolor="#CCFFFF" class="STYLE1 bottom_right">
                                <span class="currency" py:content="u'&yen;' if order.currency=='RMB' else '$'"/><span class="pcUnitPrice">${"%.6f" %bwInfo.item.rmbPrice if order.currency=='RMB' else "%.6f" %bwInfo.item.hkPrice}</span>
                            </td>
                            <td align="center" valign="middle" bgcolor="#CCFFFF" class="STYLE1 bottom_right">
                                <span class="currency" py:content="u'&yen;' if order.currency=='RMB' else '$'"/><span class="pcAmt">${"%.6f" %(header.totalQtyWithSample*bwInfo.item.rmbPrice) if order.currency=='RMB' else "%.6f" %(header.totalQtyWithSample*bwInfo.item.hkPrice)}</span>&nbsp;
                            </td>
		        </tr>  
		        
		        
		        <tr>
		          <td colspan="8" align="center" class="bottom_right color-000080">&nbsp;</td>
		        </tr>
		        
		      </table></td>
		  </tr>
		  <tr>
		    <td align="left" valign="top" class="color-FF9900">
		    	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		        <tr>
		          <td  colspan="2"><span class="STYLE19">所需BodyWearLabel图样</span></td>
		        </tr>
		        <tr>
		          <td align="center" valign="middle" class="color-FF9900">&nbsp;</td>
		        </tr>

		        <tr py:if="image">		        
			        <td align="center" valign="middle" bgcolor="#FF9900">
                                    <div><a href="#hangTagImgDIV" class="photo"><img src="/static/images/bossini/${image}.jpg" width="180"/></a></div>
				<div id="hangTagImgDIV"><img class="hangTagImg" src="/static/images/bossini/${image}.jpg"/></div>
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
				          <td width="6%" align="center" class="top_bottom_right color-CCFFFF"><strong>Total Qty</strong></td>
				          <td width="6%" align="center" class="top_bottom_right color-99CC00"><strong>Color code</strong></td>
				          <td width="10%" align="center" class="top_bottom_right color-99CC00"><strong>Color Name</strong></td>
				          <td width="6%" align="center" class="top_bottom_right color-99CC00"><strong>Size Range</strong></td>
				          <td width="6%" align="center" class="top_bottom_right color-99CC00"><strong>Size Name</strong></td>
				          <td width="8%" align="center" class="top_bottom_right color-99CC00"><strong>Size code</strong></td>
				          <td width="8%" align="center" class="top_bottom_right"><strong class="STYLE3">Size (no.)</strong></td>
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
				          <td align="center" class="bottom_right color-FFFF00"><span py:replace="d.shipSampleQty"/>&nbsp;</td>
				          <td align="center" class="bottom_right"><span py:replace="d.recolorCode"/>&nbsp;</td>
				          <td align="center" valign="middle" class="bottom_right"><span py:replace="d.colorName"/>&nbsp;</td>
				          <td align="center" valign="middle" class="bottom_right"><span py:replace="d.resizeRange"/>&nbsp;</td>
				          <td align="center" valign="middle" class="bottom_right"><span py:replace="d.sizeCode"/>&nbsp;</td>
				          <td align="center" valign="middle" class="bottom_right"><span py:replace="d.sizeName"/>&nbsp;</td>
				          <td align="center" valign="middle" class="bottom_right"><span py:replace="bwDetail[d.id]"/>&nbsp;</td>
				          <td align="center" valign="middle" class="bottom_right"><span py:replace="XML(d.priceInHTML)"/>&nbsp;</td>
				          <td align="center" valign="middle" class="bottom_right"><span py:replace="d.eanCode"/>&nbsp;</td>
				          <td align="center" valign="middle" class="bottom_right"><span py:replace="d.collectionCode"/>&nbsp;</td>
                                          <td align="center" valign="middle" class="bottom_right"><span py:replace="d.launchMonth"/>&nbsp;</td>
				        </tr>
				        <tr>
				        	<td align="center" class="bottom_right"><b><span py:replace="header.sortedSubChildren"/></b>&nbsp;</td>
				        	<td align="center" class="bottom_right">&nbsp;</td>
				        	<td align="center" class="bottom_right"><b><span class="totalQtyWithSampleWastage" py:content="header.totalQtyWithSample"/></b>&nbsp;</td>
				        </tr>
		    		</tbody>
		      </table></td>
		  </tr>
		</table>
		
		<div class="templat_main_div3">
			  <table width="100%" border="0" cellspacing="0" cellpadding="0">
			    <tr>
			      <td width="200" class="STYLE16" align="center">洗水符號及描述</td>
			    </tr>
			  </table>
			  <table width="100%" border="1" cellpadding="0" cellspacing="0" bordercolor="#000000">
			    <tr>
			      <td class="color-000000"><table width="100%" border="0" cellspacing="1" cellpadding="0">
			          <tr>
			            <td class="STYLE18 color-CCFFCC" align="right">&nbsp;洗水 ：</td>
                                    <td class="STYLE19 color-FFFFFF">
                                        &nbsp;${bwInfo.washing.contentEn}&nbsp;
                                    </td>
                                    <td class="STYLE19 color-FFFFFF">
                                        <img src="/static/images/bossini/care_label/EXP/EXP_washing_${bwInfo.washing.styleIndex}.jpg" width="35" height="35" id="washing_img"	align="absmiddle"/>

                                    </td>
			          </tr>
			          <tr>
			            <td class="STYLE18 color-CCFFCC" align="right">&nbsp;漂白：</td>
                                    <td class="STYLE19 color-FFFFFF">
                                        &nbsp;${bwInfo.bleaching.contentEn}&nbsp;
                                    </td>
                                    <td class="STYLE19 color-FFFFFF">
                                        <img src="/static/images/bossini/care_label/EXP/EXP_bleaching_${bwInfo.bleaching.styleIndex}.jpg" width="35" height="35" id="bleaching_img" align="absmiddle"/>
                                    </td>
			          </tr>
			          <tr>
			            <td class="STYLE18 color-CCFFCC" align="right">&nbsp;晾干：</td>
                                    <td class="STYLE19 color-FFFFFF">
                                        &nbsp;
                                        <div py:if="bwInfo.drying" py:strip="">
					${bwInfo.drying.contentEn}&nbsp;
                                        </div>
                                    </td>
                                    <td class="STYLE19 color-FFFFFF">&nbsp;
                                        <div py:if="bwInfo.drying" py:strip="">
                                            <img src="/static/images/bossini/care_label/EXP/EXP_drying_${bwInfo.drying.styleIndex}.jpg" width="35" height="35" id="drying_img" align="absmiddle"/>
                                        </div>
                                    </td>
			          </tr>
                                  <tr>
			            <td class="STYLE18 color-CCFFCC" align="right">&nbsp;其它晾干：</td>
                                    <td class="STYLE19 color-FFFFFF">
                                        &nbsp;
                                        <div py:if="bwInfo.othersDrying" py:strip="">
					${bwInfo.othersDrying.contentEn}&nbsp;
                                        </div>
                                    </td>
                                    <td class="STYLE19 color-FFFFFF">&nbsp;
                                        <div py:if="bwInfo.othersDrying" py:strip="">
                                            <img src="/static/images/bossini/care_label/EXP/EXP_othersDrying_${bwInfo.othersDrying.styleIndex}.jpg" width="35" height="35" id="othersDrying_img" align="absmiddle"/>
                                        </div>
                                    </td>
			          </tr>
                                  <tr>
			            <td class="STYLE18 color-CCFFCC" align="right">&nbsp;熨燙：</td>
                                    <td class="STYLE19 color-FFFFFF">
                                        &nbsp;${bwInfo.ironing.contentEn}&nbsp;
                                    </td>
                                    <td class="STYLE19 color-FFFFFF">
                                        <img src="/static/images/bossini/care_label/EXP/EXP_ironing_${bwInfo.ironing.styleIndex}.jpg" width="35" height="35" id="ironing_img" align="absmiddle"/>
                                    </td>
			          </tr>
                                  <tr>
			            <td class="STYLE18 color-CCFFCC" align="right">&nbsp;干洗：</td>
                                    <td class="STYLE19 color-FFFFFF">
                                        &nbsp;${bwInfo.dryCleaning.contentEn}&nbsp;
                                    </td>
                                    <td class="STYLE19 color-FFFFFF">
                                        <img src="/static/images/bossini/care_label/EXP/EXP_dryCleaning_${bwInfo.dryCleaning.styleIndex}.jpg" width="35" height="35" id="dryCleaning_img" align="absmiddle"/>
                                    </td>
			          </tr>
			        </table></td>
			    </tr>
			  </table>
			</div>


			<div class="templat_main_div3">
			  <table width="90%" border="0" cellspacing="0" cellpadding="0">
			    <tr>
			      <td width="200" class="STYLE16" align="center">成份</td>
			    </tr>
			  </table>
			  <table width="90%" border="1" cellpadding="0" cellspacing="0" bordercolor="#000000">
                              <tr>
                              <td>
                                  <table width="100%" border="0" cellspacing="1" cellpadding="0">
                                      <tr py:for="d in components">
                                          <td width="10">&nbsp;</td>
                                          <td width="80" align="center">${d.percentage}</td>
                                          <td width="15" align="center"><b>%</b></td>
                                          <td align="center">
                                              <span class="STYLE19 color-FFFFFF">${d.component.HKSINEXP}</span>
                                          </td>
                                          <td width="5">&nbsp;</td>
                                      </tr>
                                  </table>
                              </td>
                            </tr>
			  </table>
			</div>


	<!-- main content end -->
	
	</div>
</div>


</body>
</html>


