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
    <script src="/static/javascript/numeric.js" language="javascript"></script>
    <script src="/static/javascript/jqui/jquery-ui-1.6.custom.min.js" language="javascript"></script>
    <script src="/static/javascript/fancyzoom.js" language="javascript"></script>
    <script src="/static/javascript/jquery.joverlay.pack.js" language="javascript"></script>
    
    <script src="/static/javascript/jquery.enter2Tab.js" language="javascript"></script>
    <script src="/static/javascript/util/common.js" language="javascript"></script>
    <script src="/static/javascript/custom/bossini_input_cl.js" language="javascript"></script>
    
	<script language="JavaScript" type="text/javascript" py:if="tg_flash">
	//<![CDATA[
	    $(document).ready(function(){    	
	        $.prompt("${tg_flash}",{opacity: 0.6,prefix:'cleanblue',show:'slideDown'});
	    });
	//]]>
	</script>


	
	<?python
		from datetime import datetime as dt
		from ecrm.util.bossini_helper import mapSizeNo,getCO,getWashing,getBleaching,getIroning,\
			getDryCleaning,getDrying,getOthersDrying,getAppendix,getPart,getFiberContent
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
			
			
		if defaultPatterns :
			patternList = []
			for dp in defaultPatterns:
				
                componentList = []
                for component in dp.getComponents():
					
                    detailStr = ",".join(["{'percentage':%s,'fibercontent':%d}" %(d.percentage,d.component.id) for d in component.getDetail()])
					
                    componentStr = "{'name':%d,coating:'%s','details':[%s]}" % ( (-1 if not component.name else component.name.id),
																  ('' if not component.coating else component.coating),detailStr)
                    componentList.append(componentStr)
                    
                patternList.append('''%d:{'origin':%d,'washing':%d,'bleaching':%d,'drying':%d,'othersDrying':%d,'ironing':%d,'dryCleaning':%d,'appendix':'%s','componentList':[%s]}'''  
                                    %(dp.id,dp.origin.id,dp.washing.id,dp.bleaching.id,(-1 if not dp.drying else dp.drying.id),(-1 if not dp.othersDrying else dp.othersDrying.id),
                                    dp.ironing.id,dp.dryCleaning.id,dp.appendix,','.join(componentList)))				
			patterns = "{%s}" % (",".join(patternList))
		
		
		js = '''
			var currentBillTo = null;
			var billToInfo = %s;
			var shipToInfo = %s;
			var currency = '%s';
			
		''' % ( billToStr,shipTostr,defaultBillToInfo['currency'],)	
		
		if defaultPatterns : js += "var defaultSetting = %s;" % patterns
		
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
    <td width="64" valign="top" align="left"><a id="clPreview" href="#" rel="external" onclick="preview()"><img src="/static/images/images/menu_preview_g.jpg"/></a></td>
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/static/images/images/menu_last.jpg"/></td>
    <td align="left" valign="top" background="/static/images/images/menu_end.jpg">&nbsp;</td>
  </tr>
</tbody></table>

</div>
<div class="nav-tree">Bossini&nbsp;&nbsp;&gt;&nbsp;&nbsp;Main&nbsp;&nbsp;&gt;&nbsp;&nbsp;Care Label (洗水唛)</div>
<div style="width:1300px;">
	<div style="overflow:hidden;margin:5px 0px 10px 10px">
			
	<!--  main content begin -->	
	<form action="/bossinipo/saveCareLabelOrder" method="POST">
		<input type="hidden" name="orderType" value="C"/>
		<input type="hidden" name="vendorCode" value="${vendor.vendorCode}"/>
		<input type="hidden" name="token" value="${token}"/>
		
		<div class="templat_main_div1">
		  <table width="100%" border="0" cellspacing="0" cellpadding="0">
		    <tr>
		      <td width="10">&nbsp;</td>
		      <td width="170"><span class="STYLE1">Vendor's Code :</span></td>
		      <td colspan="3" class="bottom_border"><b>${vendor.vendorCode}</b>&nbsp;</td>
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
		       </td>
		    </tr>
		    <tr py:if="vendor.vendorCode=='LWF'">
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
		    <tr py:if="vendor.vendorCode!='LWF'">
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
		
		<div><br class="clear"/></div>

		<!-- part 2 -->
		<?python
			fcList = getFiberContent()
			appendixList = getAppendix()
		?>
		
		<div class="order_tabs">
		<div id="tabs">
		<ul>
			<li><a href="#tabs-cl">Care Label (洗水唛)</a></li>
		</ul>
		<div id="tabs-cl">
		<table width="995" border="0" cellpadding="0" cellspacing="0">
    <tr>
	  <td align="center" valign="top">
	    <table width="1200" border="0" cellspacing="0" cellpadding="0">
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
														<!--tr>
															<td width="200" height="28" align="right" class="STYLE18 color-CCFFCC">&nbsp;客户订单号：</td>
															<td class="STYLE19 color-FFFFFF">
																&nbsp;
																<input type="text" name="customerOrderNo" id="customerOrderNo" style="width:250px"
																class="required_input"/>
															</td>
														</tr-->
														<tr>
															<td height="28" align="right" class="STYLE18 color-CCFFCC">&nbsp;产品号码：</td>
															<td class="STYLE19 color-FFFFFF">
																&nbsp;
																<select name="itemCode" id="itemCode" style="width:250px"  class="required_input">
																	<option value=""></option>
																	<option py:for="item in items" value="${item.id}" rmbprice="${item.rmbPrice}" hkprice="${item.hkPrice}">${item.itemCode}  (${item.component})</option>
																</select>
															</td>
														</tr>
														<tr>
															<td height="28" align="right" class="STYLE18 color-CCFFCC">&nbsp;产地：</td>
															<td class="STYLE19 color-FFFFFF">
																&nbsp;
																<select name="origin" id="origin" style="width:250px"  class="required_input">
																	<option value=""></option>
																	<option py:for="c in getCO()" value="${c.id}">${c.China}</option>
																</select>
															</td>
														</tr>
														<tr>
															<td height="28" align="right" class="STYLE18 color-CCFFCC">Reference Total Order Price (before VAT)<br/>参考税前单价（运费除外）：</td>
															<td class="STYLE19 color-FFFFFF">
																<div id="amt_div" style="display:none">&nbsp;<span class="currenty_flag"></span><span id="unitPrice"></span> <b>X</b> <span id="qty_show"></span> <b>=</b> <span class="currenty_flag"></span><span id="amt"></span></div>
															</td>
														</tr>
														<tr py:if="defaultPatterns">
															<td height="28" align="right" class="STYLE18 color-CCFFCC">基本定式:</td>
															<td class="STYLE19 color-FFFFFF">
																&nbsp;
																<select style="width: 250px;" onchange="changePattern(this)">
																	<option></option>
																	<option py:for="dp in defaultPatterns" value="${dp.id}">${dp.name}</option>
																</select>
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
						                                    <td height="28" align="center" class="color-FFFFFF">&nbsp;<b>Legacy Code</b></td>
						                                    <td align="center" class="color-FFFFFF">&nbsp;<b>Qty</b></td>
						                                    <td class="color-FFFFFF" colspan="2">&nbsp;<b>Customer PO</b></td>
						                                </tr>
														<tr py:for="i in range(10,21)" class="lc-qty-po">
						                                    <td height="28" align="left" class="color-FFFFFF">&nbsp;
						                                    	<select name="legacyCode${i}" style="width:130px" class="legacy-code">
						                                    		<option></option>
						                                    		<option py:for="o in legacyCodes" value="${o}">${o}</option>
						                                    	</select>
						                                    </td>
						                                    <td align="left" class="color-FFFFFF">
						                                      <input type="text" name="qty${i}" style="width:100px" class="numeric"/><b>PCS</b>
						                                    </td>
						                                    <td class="color-FFFFFF" colspan="2">
						                                      <input type="text" name="customerOrderNo${i}" style="width:120px"/>
						                                    </td>
						                                </tr>
						                                <tr class="lc-qty-po">
						                                	<td height="28" align="left" class="color-FFFFFF">&nbsp;
						                                      <input type="text" name="legacyCode30" style="width:130px" class="legacy-code"/></td>
						                                    <td align="left" class="color-FFFFFF">
						                                      <input type="text" name="qty30" style="width:100px" class="numeric"/><b>PCS</b></td>
						                                    <td align="left" class="color-FFFFFF">
						                                      <input type="text" name="customerOrderNo30" style="width:120px"/></td>
						                                    <td class="color-FFFFFF">
						                                    	<input type="button" value="+" onclick="addLegacy(this)"/>&nbsp;<input type="button" value="-" onclick="removeLegacy(this)"/>
						                                    </td>
						                                </tr>
						                                <tr>
						                                	<td class="color-FFFFFF">&nbsp;</td><td colspan="3" class="color-FFFFFF"><b>Total <span id="totalQty">0</span> PCS</b></td>
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
															<td width="150" height="28" align="right" class="STYLE18 color-CCFFCC">&nbsp;洗水 ：</td>
															<td class="STYLE19 color-FFFFFF">
																&nbsp;
																<select name="washing" id="washing" style="width:230px"
																class="required_input img_show">
																	<option value=""></option>
																	<option py:for="w in getWashing()" value="${w.id}" styleid="${w.styleIndex}">${w.contentEn}</option>
																</select>
																&nbsp;
																<img src="/static/images/blank.png" width="35" height="35" id="washing_img"	align="absmiddle"/>
															</td>
														</tr>
														<tr>
															<td height="28" align="right" class="STYLE18 color-CCFFCC">&nbsp;漂白：</td>
															<td class="STYLE19 color-FFFFFF">
																&nbsp;
																<select name="bleaching" id="bleaching" style="width:230px"
																class="required_input img_show">
																	<option value=""></option>
																	<option py:for="b in getBleaching()" value="${b.id}" styleID="${b.styleIndex}">${b.contentEn}</option>
																</select>
																&nbsp;
																<img src="/static/images/blank.png" width="35" height="35" id="bleaching_img" align="absmiddle"/>
															</td>
														</tr>
														<tr>
															<td height="28" align="right" class="STYLE18 color-CCFFCC">&nbsp;晾干：</td>
															<td class="STYLE19 color-FFFFFF">
																&nbsp;
																<select name="drying" id="drying" style="width:230px"  class="required_input img_show">
																	<option value=""></option>
																	<option py:for="d in getDrying()" value="${d.id}" styleID="${d.styleIndex}">${d.contentEn}</option>
																</select>
																&nbsp;
																<img src="/static/images/blank.png" width="35" height="35" id="drying_img" align="absmiddle"/>
															</td>
														</tr>
														<tr>
															<td height="28" align="right" class="STYLE18 color-CCFFCC">&nbsp;其它晾干：</td>
															<td class="STYLE19 color-FFFFFF">
																&nbsp;
																<select name="othersDrying" id="othersDrying" style="width:230px" class="img_show">
																	<option value=""></option>
																	<option py:for="o in getOthersDrying()" value="${o.id}" styleID="${o.styleIndex}">${o.contentEn}</option>
																</select>
																&nbsp;
																<img src="/static/images/blank.png" width="35" height="35" id="othersDrying_img" align="absmiddle"/>
															</td>
														</tr>
														<tr>
															<td height="28" align="right" class="STYLE18 color-CCFFCC">&nbsp;熨燙： </td>
															<td class="STYLE19 color-FFFFFF">
																&nbsp;
																<select name="ironing" id="ironing" style="width:230px"
																class="required_input img_show">
																	<option value=""></option>
																	<option py:for="i in getIroning()" value="${i.id}" styleid="${i.styleIndex}">${i.contentEn}</option>
																</select>
																&nbsp;
																<img src="/static/images/blank.png" width="35" height="35" id="ironing_img" align="absmiddle"/>
															</td>
														</tr>
														<tr>
															<td height="28" align="right" class="STYLE18 color-CCFFCC">&nbsp;干洗：</td>
															<td class="STYLE19 color-FFFFFF">
																&nbsp;
																<select name="dryCleaning" id="dryCleaning" style="width:230px"  class="required_input img_show">
																	<option value=""></option>
																	<option py:for="d in getDryCleaning()" value="${d.id}" styleID="${d.styleIndex}">${d.contentEn}</option>
																</select>
																&nbsp;
																<img src="/static/images/blank.png" width="35" height="35" id="dryCleaning_img"
																align="absmiddle"/>
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
									?>
									<div  py:for="x in range(0,3)" py:strip="">
										<tr>
											<td py:for="y in range(0,2)">
												<table width="330" cellspacing="0" cellpadding="0" border="1" bgcolor="#ffffff" class="component-table">
													<tr><td height="25" colspan="3" bgcolor="#FFCC00" class="STYLE19">&nbsp;&nbsp;产品成份 ${count}</td></tr>
													<?python
														count += 1
													?>
													<tr>
														<td width="100" height="25" align="center" class="STYLE18 color-CCFFCC">&nbsp;产品名称 ：</td>
														<td width="230" class="STYLE19 color-FFFFFF" colspan="2">
															&nbsp;
															<select name="part_${x}_${y}" id="part_${x}_${y}" style="width: 200px;">
																<option value=""></option>
																<option py:for="p in getPart()" value="${p.id}" need_coating="${p.needCoating}">${p.content}</option>
															</select>
														</td>
													</tr>
													<tr>
														<td colspan="3">
														<input type="checkbox" name="coating_${x}_${y}" value="Y" id="coating_${x}_${y}"/><label for="coating_${x}_${y}">加涂层</label>&nbsp;&nbsp;&nbsp;
														<input type="checkbox" name="microelement_${x}_${y}" value="Y" id="microelement_${x}_${y}"/><label for="microelement_${x}_${y}">含微量其它纤维</label>
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
																<tr py:for="z in range(0,6)">
																	<td width="10">&nbsp;</td>
																	<td width="80">
																		<input type="text" name="percentage_${x}_${y}_${z}" id="percentage_${x}_${y}_${z}" class="numeric" size="10"/>
																	</td>
																	<td width="15" align="center"><b>%</b></td>
																	<td>
																		<span class="STYLE19 color-FFFFFF">
																			<select name="fibercontent_${x}_${y}_${z}" id="fibercontent_${x}_${y}_${z}" style="width: 200px;">
																				<option value=""></option>
																				<option py:for="f in fcList" value="${f.id}">${f.HKSINEXP}</option>
																			</select>
																		</span>
																	</td>
																	<td width="5">&nbsp;</td>
																</tr>
															</table>
														</td>
													</tr>
												</table>
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
														<tr py:for="i in range(1,11)">
															<td width="80" height="28" align="right" class="STYLE18 color-CCFFCC">&nbsp;注意&nbsp;${i}：</td>
															<td class="STYLE19 color-FFFFFF">
																&nbsp;
																<select name="appendix${i}" id="appendix${i}" style="width: 530px;">
																	<option value=""></option>
																	<option py:for="appendix in appendixList" value="${appendix.id}" bindFor="${appendix.bindFor}">${appendix.contentSC}<span py:if="appendix.contentEn" py:strip="">&nbsp;&nbsp;(${appendix.contentEn})</span></option>
																</select>
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
				</tr>
			</table>
		</td>
	</tr>
</table>
</div>
</div>
</div>
    
	
	</form>		
	<div id="kk"></div>
	<!-- main content end -->
	
	</div>
</div>


</body>
</html>


