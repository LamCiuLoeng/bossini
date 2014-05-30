<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#"
    py:extends="'../master.kid'">

<head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
    <title>r-pac - Bossini</title>
    
    <link rel="stylesheet" href="/static/css/custom/order.css" type="text/css" media="screen"/>
	<style type="text/css">
		.box{
			width: 400px; 
			margin-left: 15px;
			margin-right: 5px;
			margin-bottom:10px;
			padding:5px;
			display : none;	
		}
    </style>    


    <script src="/static/javascript/jquery-impromptu.1.5.js" language="javascript"></script>
    <script src="/static/javascript/numeric.js" language="javascript"></script>
    <script src="/static/javascript/fancyzoom.js" language="javascript"></script>
    <script src="/static/javascript/jquery.enter2Tab.js" language="javascript"></script>
    <script src="/static/javascript/util/common.js" language="javascript"></script>
    <script src="/static/javascript/custom/bossini_input_d.js" language="javascript"></script>
    
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
				needChangeFactory:"%s",VATInfo:"%s",invoiceInfo:"%s",accountContact:"%s",currency:"%s",needChangeFactory:"%s",shipmentInstruction:"%s",payterm:"%s"  }
		''' %(b.id,null2blank(b.address),null2blank(b.contact),null2blank(b.tel),null2blank(b.fax),null2blank(b.needChangeFactory)
				,null2blank(b.needVAT),null2blank(b.needInvoice),null2blank(b.account),null2blank(b.currency),null2blank(b.needChangeFactory),null2blank(b.haulage),null2blank(b.payterm)) for b in vendor.billTo])
				
		js = '''
			var currentBillTo = null;
			var billToInfo = %s;
			var shipToInfo = %s;
			var currency = '%s';
		''' % ( billToStr,shipTostr,defaultBillToInfo['currency'],)	
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
<div class="nav-tree">Bossini&nbsp;&nbsp;&gt;&nbsp;&nbsp;Main&nbsp;&nbsp;&gt;&nbsp;&nbsp;Down Jacket Label 羽绒服成分唛</div>
<div style="width:1200px;">
	<div style="overflow:hidden;margin:5px 0px 10px 10px">
			
	<!--  main content begin -->	
	<form action="/bossinipo/saveDownJacketOrder" method="POST">
		<input type="hidden" name="orderType" value="D"/>
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
		
	
		
		          
		
		<!-- part 2 -->
		
		<div class="templat_main_div4">
		  <table width="100%" cellspacing="0" cellpadding="0" bordercolor="#000000" border="1">
		    <tbody><tr>
		      <td class="color-000000"><table width="100%" cellspacing="1" cellpadding="0" border="0">
		        <tbody>
		        <tr>
		          <td class="STYLE18 color-CCFFCC" colspan="2" align="center">Down Jacket Label 羽绒服成分唛</td>
		        </tr>
		        <tr>
		          <td class="STYLE18 color-CCFFCC">Customer Order No.客户订单号 ：</td>
		          <td width="450" class="STYLE19 color-FFFFFF"><input type="text" name="customerOrderNo" id="customerOrderNo" style="width:300px"/></td>
		        </tr>
		        <tr>
		          <td class="STYLE18 color-CCFFCC">Please Select Item Code 请选择产品号：</td>
		          <td class="STYLE19 color-FFFFFF">
					<select name="item" id="item"  style="width:300px">
						<option value=""></option>
						<option py:for="item in items" value="${item.id}" rmbprice="${item.rmbPrice}" hkprice="${item.hkPrice}" itemCode="${item.itemCode}" component="${item.component}">${item.itemCode}(${item.component})</option>
					</select>
				  </td>
		        </tr>
		        <tr>
		          <td class="STYLE18 color-CCFFCC">Total this order Quantity (pieces) 这一个订单贵司需要采购的个数：</td>
		          <td class="STYLE19 color-FFFFFF"><input type="text" name="qty" class="numeric" id="qty"  style="width:300px"/></td>
		        </tr>
		        <tr>
		        	<td class="STYLE18 color-CCFFCC">Reference Total Order Price (before VAT)参考税前单价（运费除外）</td>
		        	<td class="STYLE19 color-FFFFFF"><div id="amt_div" style="display:none">&nbsp;<span class="currenty_flag"></span><span id="unitPrice"></span> <b>X</b> <span id="qty_show"></span> <b>=</b> <span class="currenty_flag"></span><span id="amt"></span></div></td>
		        </tr>
		        <tr>
		          <td class="STYLE18 color-CCFFCC">Down content 含绒量：</td>
		          <td class="STYLE19 color-FFFFFF"><input type="text" name="downContent" class="numeric" id="downContent"  style="width:300px"/><b>%</b></td>
		        </tr>
		        <tr>
		          <td class="STYLE18 color-CCFFCC" valign="top">Filling 充绒量：</td>
		          <td class="STYLE19 color-FFFFFF">
		          
		          
		          <fieldset class="box Nylon">
					<legend>普通尺码</legend>
		          	<table cellspacing="0" cellpadding="0" border="0">
		          		<tr>
		          			<td width="60"><label for="filling165">165/80B</label></td>
		          			<td><input type="text" name="filling165" class="numeric" id="filling165"  style="width:100px"/>g</td>
		          			<td width="50">&nbsp;</td>
		          			<td width="60"><label for="filling170">170/84B</label></td>
		          			<td><input type="text" name="filling170" class="numeric" id="filling170"  style="width:100px"/>g</td>
		          		</tr>
		          		<tr>
		          			<td><label for="filling175">175/92B</label></td>
		          			<td><input type="text" name="filling175" class="numeric" id="filling175"  style="width:100px"/>g</td>
		          			<td width="50">&nbsp;</td>
		          			<td><label for="filling180">180/96B</label></td>
		          			<td><input type="text" name="filling180" class="numeric" id="filling180"  style="width:100px"/>g</td>
		          		</tr>
		          		<tr>
		          			<td><label for="filling185">185/100B</label></td>
		          			<td><input type="text" name="filling185" class="numeric" id="filling185"  style="width:100px"/>g</td>
		          			<td width="50">&nbsp;</td>
		          			<td>&nbsp;</td>
		          		</tr>
		          	</table>
		 		</fieldset>
		 		
		 		<fieldset class="box Nylon">
					<legend>女裝上裝</legend>
		          	<table cellspacing="0" cellpadding="0" border="0">
		          		<tr>
		          			<td width="60"><label for="filling165">160/80Y</label></td>
		          			<td><input type="text" name="fillingW160" class="numeric" id="fillingW160"  style="width:100px"/>g</td>
		          			<td width="50">&nbsp;</td>
		          			<td width="60"><label for="filling170">165/84Y</label></td>
		          			<td><input type="text" name="fillingW165" class="numeric" id="fillingW165"  style="width:100px"/>g</td>
		          		</tr>
		          		<tr>
		          			<td><label for="filling175">170/88Y</label></td>
		          			<td><input type="text" name="fillingW170" class="numeric" id="fillingW170"  style="width:100px"/>g</td>
		          			<td width="50">&nbsp;</td>
		          			<td><label for="filling180">175/92Y</label></td>
		          			<td><input type="text" name="fillingW17592Y" class="numeric" id="fillingW17592Y"  style="width:100px"/>g</td>
		          		</tr>
		          		<tr>
		          			<td><label for="filling185">175/92A</label></td>
		          			<td><input type="text" name="fillingW17592A" class="numeric" id="fillingW17592A"  style="width:100px"/>g</td>
		          			<td width="50">&nbsp;</td>
		          			<td><label for="filling180">175/96A</label></td>
		          			<td><input type="text" name="fillingW17596A" class="numeric" id="fillingW17596A"  style="width:100px"/>g</td>
		          		</tr>
		          	</table>
		 		</fieldset> 	
		          	
		          	
		         
		         <fieldset class="box Satin">
					<legend>小童尺码</legend>
				    <table cellspacing="0" cellpadding="0" border="0">
		          		<tr>
		          			<td width="60"><label for="fillingC100">100/56</label></td>
		          			<td><input type="text" name="fillingC100" class="numeric" id="fillingC100"  style="width:100px"/>g</td>
		          			<td width="50">&nbsp;</td>
		          			<td width="60"><label for="fillingC110">110/60</label></td>
		          			<td><input type="text" name="fillingC110" class="numeric" id="fillingC110"  style="width:100px"/>g</td>
		          		</tr>
		          		<tr>
		          			<td><label for="fillingC120">120/64</label></td>
		          			<td><input type="text" name="fillingC120" class="numeric" id="fillingC120"  style="width:100px"/>g</td>
		          			<td width="50">&nbsp;</td>
		          			<td><label for="fillingC130">130/68</label></td>
		          			<td><input type="text" name="fillingC130" class="numeric" id="fillingC130"  style="width:100px"/>g</td>
		          		</tr>
		          		<tr>
		          			<td><label for="fillingC140">140/72</label></td>
		          			<td><input type="text" name="fillingC140" class="numeric" id="fillingC140"  style="width:100px"/>g</td>
                            <td width="50">&nbsp;</td>
		          			<td><label for="fillingC150">150/76</label></td>
		          			<td><input type="text" name="fillingC150" class="numeric" id="fillingC150"  style="width:100px"/>g</td>
		          		</tr>
                        <tr>
		          			<td><label for="fillingC160">160/80</label></td>
		          			<td><input type="text" name="fillingC160" class="numeric skip" id="fillingC160"  style="width:100px"/>g</td>
                            <td width="50">&nbsp;</td>
		          			<td><label for="fillingC170">170/84</label></td>
		          			<td><input type="text" name="fillingC170" class="numeric skip" id="fillingC170"  style="width:100px"/>g</td>
		          		</tr>
		          	</table>
				</fieldset> 	
		            	
		         <fieldset class="box Satin">
					<legend>BB尺码</legend>
				    <table cellspacing="0" cellpadding="0" border="0">
		          		<tr>
		          			<td width="60"><label for="fillingB6">6-12M</label></td>
		          			<td><input type="text" name="fillingB6" class="numeric" id="fillingB6"  style="width:100px"/>g</td>
		          			<td width="50">&nbsp;</td>
		          			<td width="60"><label for="fillingB12">12-18M</label></td>
		          			<td><input type="text" name="fillingB12" class="numeric" id="fillingB12"  style="width:100px"/>g</td>
		          		</tr>
		          		<tr>
		          			<td><label for="fillingB18">18-24M</label></td>
		          			<td><input type="text" name="fillingB18" class="numeric" id="fillingB18"  style="width:100px"/>g</td>
		          			<td width="50">&nbsp;</td>
		          			<td><label for="fillingB90">90CM</label></td>
		          			<td><input type="text" name="fillingB90" class="numeric" id="fillingB90"  style="width:100px"/>g</td>
		          		</tr>
		          		<tr>
		          			<td><label for="fillingB100">100CM</label></td>
		          			<td><input type="text" name="fillingB100" class="numeric" id="fillingB100"  style="width:100px"/>g</td>
		          			<td width="50">&nbsp;</td>
		          			<td>&nbsp;</td>
		          		</tr>
		          	</table>
				</fieldset>
		          	
		        	
		          	
		          	
		          	
		          </td>
		        </tr>
		        <tr>
		          <td class="STYLE18 color-CCFFCC" rowspan="5" valign="top">Please INPUT Relevant Legacy Codes<br />请提供所有这一个订单相关的Bossini Legacy Codes： </td>
		          <td class="STYLE19 color-FFFFFF">
					<table cellspacing="0" cellpadding="0" border="0">
		        			<tr py:for="i in range(10,25)">
					          <td class="STYLE19 color-FFFFFF">
					          	<select name="legacyCode0${i}" id="legacyCode0${i}" style="width:300px" class="legacy-code">
					          		<option value=""></option>
					          		<option py:for="o in legacyCodes" value="${o}">${o}</option>
					          	</select>
					          </td>
					          <td>&nbsp;</td>
		        			</tr>
							<tr>
					        	<td class="STYLE19 color-FFFFFF">
					        		<input name="legacyCode31" value="" style="width:300px" class="legacy-code"/>
					        	</td>
					        	<td>
					        		<input type="button" value="+" onclick="addLegacy(this)"/>
					        		<input type="button" value="-" onclick="removeLegacy(this)"/>					        	
					        	</td>
					        </tr>
		        		</table>
				  </td>
		        </tr>
		        
		        
		      </tbody></table></td>
		    </tr>
		  </tbody></table>
		</div>
		
		
		<div style="float:left;width:200px;margin-left:50px;margin-top:15px">
			<div><a href="#itemImg" class="photo"><img class="hangTagImg" src="/static/images/blank.png" width="200"/></a></div>
			<div id="itemImg"><img class="hangTagImg" src=""/></div>
		</div>
		
		<!-- part 2 end -->
		
	</form>		
	<!-- main content end -->
	
	</div>
</div>


</body>
</html>


