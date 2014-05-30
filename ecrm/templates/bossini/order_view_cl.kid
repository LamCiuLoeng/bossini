<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#"
    py:extends="'../master.kid'">

<head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
    <title>r-pac - Bossini</title>
    
    <link rel="stylesheet" href="/static/css/custom/order.css" type="text/css" media="screen"/>
    <link rel="stylesheet" href="/static/css/jqui/ui.all.css" type="text/css" media="screen"/>
	<style type="text/css">
		.imgGroup {
			width : 55px;
			float : left;
		}

		.order_tabs{
			margin-left:10px;
			font-size:12px;
		}
		
		.order_tabs .ui-tabs-nav{
			border-width : 0px;
		}
		
		.STYLE22 {color: #FFFFFF}
		
		.STYLE21 {
			font-size: 16px;
			font-weight: bold;
		}
		.ui-tabs-panel{
			padding : 10px;
		}
  	</style>    

    
    <script src="/static/javascript/jquery-impromptu.1.5.js" language="javascript"></script>
    <script src="/static/javascript/jqui/jquery-ui-1.6.custom.min.js" language="javascript"></script>
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
	        
	        $("#tabs").tabs();
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
	from ecrm.util.common import rpacEncrypt
?>

<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
    <td width="36" valign="top" align="left"><img src="/static/images/images/menu_start.jpg"/></td>
    <td width="176" valign="top" align="left"><a href="/bossinipo/dispatch"><img src="/static/images/images/Bossini_PO_g.jpg"/></a></td>
    <div py:if="'BOSSINI_CANCEL_ORDER' in tg.identity.permissions and order.active==0" py:strip="">
    	<td width="176" valign="top" align="left"><a href="/bossinipo/cancelOrder?id=${order.id}" onclick="return toCancelOrder()"><img src="/static/images/images/menu_cancelorder_g.jpg"/></a></td>
    </div>
    <td width="176" valign="top" align="left"><a href="/bossinipo/vendorCareLabelOrder?code=${rpacEncrypt(order.id)}"><img src="/static/images/images/menu_vendor_pf_g.jpg"/></a></td> 
    <td width="64" valign="top" align="left"><a href="/bossinipo/getCareLabelProductionFile?id=${order.id}"><img src="/static/images/images/menu_export_g.jpg"/></a></td> 
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/static/images/images/menu_last.jpg"/></td>
    <td align="left" valign="top" background="/static/images/images/menu_end.jpg">&nbsp;</td>
  </tr>
</tbody></table>

</div>
<div class="nav-tree">Bossini&nbsp;&nbsp;&gt;&nbsp;&nbsp;Main&nbsp;&nbsp;&gt;&nbsp;&nbsp;Care Label (洗水唛)</div>
<div style="width:1300px;">
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
		
		<!-- part 2 -->
		<div class="order_tabs">
		<div id="tabs">
		<ul>
			<li><a href="#tabs-cl">Care Label (洗水唛)</a></li>
		</ul>
		<div id="tabs-cl">
		<table width="995" border="0" cellpadding="0" cellspacing="0">
    <tr>
	  <td align="center" valign="top">
	    <table width="970" border="0" cellspacing="0" cellpadding="0">
		  <tr>
		    <td width="400" align="left" valign="top">
			  <table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
				  <td>
					<div class="templat_main_div5" style="width:500px">
					  <table width="100%" border="1" cellpadding="0" cellspacing="0" bordercolor="#000000">
						<tr>
						  <td class="color-000000">
							<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#154C82">
							  <tr>
							  	<td align="center"><span class="STYLE21 STYLE22">基本信息</span></td>
							  </tr>
													</table>
													<table width="100%" border="0" cellspacing="1" cellpadding="0">
														<tr>
															<td width="200" height="28" align="right" class="STYLE18 color-CCFFCC">系统自动编号：</td>
															<td class="STYLE19 color-FFFFFF">&nbsp;${order.customerOrderNo}</td>
														</tr>
														<tr>
															<td height="28" align="right" class="STYLE18 color-CCFFCC">&nbsp;产品号码：</td>
															<td class="STYLE19 color-FFFFFF">
																&nbsp;${clInfo.item.itemCode}
															</td>
														</tr>
														<tr>
															<td height="28" align="right" class="STYLE18 color-CCFFCC">&nbsp;产地：</td>
															<td class="STYLE19 color-FFFFFF">
																&nbsp;${clInfo.origin.China}
															</td>
														</tr>
														<tr>
															<td height="28" align="right" class="STYLE18 color-CCFFCC">&nbsp;Reference Total Order Price (before VAT)<br/>参考税前单价（运费除外）：</td>
															<td class="STYLE19 color-FFFFFF">&nbsp;
																<?python
																	totalQty = sum([d.qty for d in clInfo.getDetail()])
																?>
															
																<div py:if="order.currency=='HKD'" py:strip="">
																$ ${clInfo.item.hkPrice} <b>X</b> ${totalQty} <b>=</b> $ ${"%.6f" %(clInfo.item.hkPrice*totalQty)}
																</div>
																<div py:if="order.currency=='RMB'"  py:strip="">
																￥ ${clInfo.item.rmbPrice} <b>X</b> ${totalQty} <b>=</b> ￥ ${"%.6f" %(clInfo.item.rmbPrice*totalQty)}
																</div>
															</td>
														</tr>
													</table>
												</td>
											</tr>
										</table>
									</div>
								</td>
							</tr>
							<tr>
								<td>
									<div class="templat_main_div5" style="width:500px">
										<table width="100%" border="1" cellpadding="0" cellspacing="0" bordercolor="#000000">
											<tr>
												<td class="color-000000">
													<table cellspacing="0" cellpadding="0" border="0" bgcolor="#154c82" width="100%">
													  <tbody>
													  <tr>
														<td height="30" align="center"><span class="STYLE21 STYLE22">这一个订单相关的 Bossini Legacy Codes</span></td>
													  </tr>
													  </tbody>
													</table>
							
													<table width="100%" border="0" cellspacing="1" cellpadding="0">
														<tr>
															<td height="28" align="left" class="color-FFFFFF">&nbsp;<b>Legacy Code</b></td>
						                                    <td align="left" class="color-FFFFFF">&nbsp;<b>Qty</b></td>
						                                    <td align="left" class="color-FFFFFF">&nbsp;<b>Customer PO</b></td>
														</tr>
														<tr py:for="d in clInfo.getDetail()">
						                                    <td height="28" align="left" class="color-FFFFFF">&nbsp;
						                                    	${d.legacyCode.legacyCode if d.legacyCode else ""}
						                                    </td>
						                                    <td align="left" class="color-FFFFFF">&nbsp;${d.qty} PCS</td>
						                                    <td align="left" class="color-FFFFFF">&nbsp;${d.customerOrderNo if d.customerOrderNo else ""}</td>
						                                </tr>
						                                <tr>
						                                	<td class="color-FFFFFF">&nbsp;</td><td colspan="2" class="color-FFFFFF">&nbsp;<b>Total ${totalQty} PCS</b></td>
						                                </tr>
						                                
													</table>
												</td>
											</tr>
										</table>
									</div>
								</td>
							</tr>
							<tr>
								<td>
									<div class="templat_main_div5" style="width:500px">
										<table width="100%" border="1" cellpadding="0" cellspacing="0" bordercolor="#000000">
											<tr>
												<td class="color-000000">
													<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#154C82">
														<tr>
															<td height="30" align="center">
																<span class="STYLE21 STYLE22">洗水符號及描述</span>
															</td>
														</tr>
													</table>

													<table width="100%" border="0" cellspacing="1" cellpadding="0">
														<tr>
															<td width="80" height="28" align="right" class="STYLE18 color-CCFFCC">&nbsp;洗水 ：</td>
															<td class="STYLE19 color-FFFFFF">
																&nbsp;${clInfo.washing.contentEn}&nbsp;
															</td>
															<td class="STYLE19 color-FFFFFF">
																<img src="/static/images/bossini/care_label/CHN/CHN_washing_${clInfo.washing.styleIndex}.jpg" width="35" height="35" id="washing_img"	align="absmiddle"/>
															
															</td>
														</tr>
														<tr>
															<td height="28" align="right" class="STYLE18 color-CCFFCC">&nbsp;漂白：</td>
															<td class="STYLE19 color-FFFFFF">
																&nbsp;${clInfo.bleaching.contentEn}&nbsp;
															</td>
															<td class="STYLE19 color-FFFFFF">
																<img src="/static/images/bossini/care_label/CHN/CHN_bleaching_${clInfo.bleaching.styleIndex}.jpg" width="35" height="35" id="bleaching_img" align="absmiddle"/>
															</td>
														</tr>
														<tr>
															<td height="28" align="right" class="STYLE18 color-CCFFCC">&nbsp;晾干：</td>
															<td class="STYLE19 color-FFFFFF">
																&nbsp;
																<div py:if="clInfo.drying" py:strip="">
																	${clInfo.drying.contentEn}&nbsp;
																</div>
															</td>
															<td class="STYLE19 color-FFFFFF">&nbsp;
																<div py:if="clInfo.drying" py:strip="">
																	<img src="/static/images/bossini/care_label/CHN/CHN_drying_${clInfo.drying.styleIndex}.jpg" width="35" height="35" id="drying_img" align="absmiddle"/>
																</div>
															</td>
														</tr>
														<tr>
															<td height="28" align="right" class="STYLE18 color-CCFFCC">&nbsp;其它晾干：</td>
															<td class="STYLE19 color-FFFFFF">
																&nbsp;
																<div py:if="clInfo.othersDrying" py:strip="">
																	${clInfo.othersDrying.contentEn}&nbsp;
																</div>
															</td>
															<td class="STYLE19 color-FFFFFF">&nbsp;
																<div py:if="clInfo.othersDrying" py:strip="">
																	<img src="/static/images/bossini/care_label/CHN/CHN_othersDrying_${clInfo.othersDrying.styleIndex}.jpg" width="35" height="35" id="othersDrying_img" align="absmiddle"/>
																</div>
															</td>
														</tr>
														<tr>
															<td height="28" align="right" class="STYLE18 color-CCFFCC">&nbsp;熨燙： </td>
															<td class="STYLE19 color-FFFFFF">
																&nbsp;${clInfo.ironing.contentEn}&nbsp;
															</td>
															<td class="STYLE19 color-FFFFFF">
																<img src="/static/images/bossini/care_label/CHN/CHN_ironing_${clInfo.ironing.styleIndex}.jpg" width="35" height="35" id="ironing_img" align="absmiddle"/>
															</td>
														</tr>
														<tr>
															<td height="28" align="right" class="STYLE18 color-CCFFCC">&nbsp;干洗：</td>
															<td class="STYLE19 color-FFFFFF">
																&nbsp;${clInfo.dryCleaning.contentEn}&nbsp;
															</td>
															<td class="STYLE19 color-FFFFFF">
																<img src="/static/images/bossini/care_label/CHN/CHN_dryCleaning_${clInfo.dryCleaning.styleIndex}.jpg" width="35" height="35" id="dryCleaning_img" align="absmiddle"/>
															</td>
														</tr>
													</table>
												</td>
											</tr>
										</table>
									</div>
								</td>
							</tr>
						</table>
					</td>
					<td align="center" valign="top" bgcolor="#C9D8FC" style="border:#000000 solid 2px;">
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td align="center">
									<table width="680" border="0" cellpadding="0" cellspacing="0" style="margin-top:15px">
									<?python
										count = 1
										components = clInfo.getComponents()
									?>
									<div  py:for="x in range(0,(components.count()-1)/2+1)" py:strip="">
										<tr>
											<td py:for="y in range(0,2)" valign="top">
												<div py:if="cmp(components.count(),x*2+y)" py:strip="">
													<table width="330" cellspacing="0" cellpadding="0" border="1" bgcolor="#ffffff">
														<tr><td height="25" colspan="3" bgcolor="#FFCC00" class="STYLE19">&nbsp;&nbsp;产品成份 ${count}</td></tr>
														<?python
															count += 1
															component = components[x*2+y]
														?>
														<tr>
															<td width="100" height="25" align="center" class="STYLE18 color-CCFFCC">&nbsp;产品名称 ：</td>
															<td width="184" class="STYLE19 color-FFFFFF" colspan="2">&nbsp;${"" if not component.name else component.name.content}</td>
														</tr>
														<tr>
															<td colspan="3">&nbsp;
																<span py:if="component.coating" py:strip="">加涂层</span>
																<span py:if="component.microelement" py:strip="">含微量其它纤维</span>
															</td>
														</tr>
														<tr>
															<td height="25" colspan="3">
																<table width="100%" border="0" cellpadding="0" cellspacing="0" style="margin:5px 0px 5px 0px">
																	<tr>
																		<td>&nbsp;</td>
																		<td align="center" class="STYLE1">成份</td>
																		<td align="center">&nbsp;</td>
																		<td>&nbsp;</td>
																		<td>&nbsp;</td>
																	</tr>
																	<tr py:for="d in component.getDetail()">
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
												<div py:if="cmp(x*2+y,components.count())"  py:strip="">&nbsp;</div>
											</td>
										</tr>
										<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>
									</div>
									</table>
								</td>
							</tr>
							<tr>
								<td>
									
									<div class="templat_main_div5" style="padding-left:5px;width:700px">
										<table width="100%" border="1" cellpadding="0" cellspacing="0" bordercolor="#000000">
											<tr>
												<td class="color-000000">
													<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#144C7F">
														<tr>
															<td width="30">&nbsp;</td>
															<td width="300" height="30" align="left">
																<span class="STYLE21">&nbsp;<span class="STYLE22">补充說明：</span></span>
															</td>
														</tr>
													</table>
													<table width="100%" cellspacing="1" cellpadding="0" border="0">
														<tr py:for="index,appendix in enumerate(appendixList)">
															<td width="80" height="28" align="right" class="STYLE18 color-CCFFCC">&nbsp;注意&nbsp;${index+1}：</td>
															<td class="STYLE19 color-FFFFFF">&nbsp;${appendix.contentSC}<span py:if="appendix.contentEn" py:strip="">&nbsp;&nbsp;(${appendix.contentEn})</span></td>
														</tr>
													</table>
												</td>
											</tr>
										</table>
									</div>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</div>
</div>
</div>

	<!-- main content end -->
	
	</div>
</div>


</body>
</html>


