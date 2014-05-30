<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#"
    py:extends="'../master.kid'">

<head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
    <title>r-pac - Kohl's</title>

    <link rel="stylesheet" href="/static/css/custom/show_difference.css" type="text/css" media="screen"/>
    <script src="/static/javascript/jquery-impromptu.1.5.js" language="javascript"></script>

	<script language="JavaScript" type="text/javascript" py:if="tg_flash">
	//<![CDATA[
	    $(document).ready(function(){
	        $.prompt("${tg_flash}",{opacity: 0.6,prefix:'cleanblue',show:'slideDown'});
	    });
	//]]>
	</script>
	
	<script src="/static/javascript/custom/kohls_diff.js" language="javascript"></script>
	
<style>
	.diffsource{
		color:white;
		background:green;
	}

	.difftarget{
		color:white;
		background:red;
	}

</style>
	
	
</head>

<body>

<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
    <td width="36" valign="top" align="left"><img src="/static/images/images/menu_start.jpg"/></td>
    <td width="176" valign="top" align="left"><a href="/kohlspo/index"><img src="/static/images/images/menu_kohls_g.jpg"/></a></td>

    <!--td width="64" valign="top" align="left"><a href="javascript:toSearch()"><img src="/static/images/images/menu_search_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="#" onclick="resetForm();"><img src="/static/images/images/menu_reset_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="javascript:exportBatch()"><img src="/static/images/images/menu_export_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="javascript:addSO()"><img src="/static/images/images/menu_addso_g.jpg"/></a></td>  
    
    <td width="64" valign="top" align="left"><a href="javascript:toSave()"><img src="/static/images/images/menu_save_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="javascript:toCancel()"><img src="/static/images/images/menu_cancel_g.jpg"/></a></td-->

    <td width="23" valign="top" align="left"><img height="21" width="23" src="/static/images/images/menu_last.jpg"/></td>
    <td align="left" valign="top" background="/static/images/images/menu_end.jpg">&nbsp;</td>
  </tr>
</tbody></table>

</div>
		<div py:def="displayPO(po)" py:strip="">

			<?python
			
				poheader_attrs = ["poNo","poDate","orderDept","manufacture","poType","poPurposeCode","cancelAfter","shipNotBefore", \
									"exitFtyStartDate","exitFtyEndDate","soNo","soDate","importDate","ediFileDate"]
			
				header_labels = ["PO No","PO Date","DEPT","Vendor","PO Type","Item#","Cancel After Date","Ship Not Before", \
								"Exit Factory Start Date","Exit Factory End Date","SO No","SO Date","Import Date","EDI File Date"]
				
				po1_attrs = ["hangtag","styleNo","colorCode","colorDesc","deptNo","classNo","subclassNo","upc","sizeCode","retailPrice", \
								"size","sizeDesc","poQty","pcSet","measurementCode","productDesc"]
				po1_labels = ["Hang Tag","Style No","Color Code","Color Desc","DEPT","Class No","Subclass No","UPC","Size Code","Retail Price", \
								"Size","Size Desc","PO Qty","PC Set","Measurement Code","Product Desc"]
				
				sln_attrs = ["styleNo","colorCode","colorDesc","sizeCode","upc","retailPrice","size","qty","productDesc","sizeDesc", \
								"deptNo","classNo","subclassNo"]
				sln_labels = ["Style No","Color Code","Color Desc","Size Code","UP","Retail Price","Size","Qty","Product Desc","Size Desc", \
								"DEPT","Class No","Subclass No"]
			?>

			
			<ul>
				<li py:for="index,header_attr in enumerate(poheader_attrs)">
					<label py:content="header_labels[index]"></label> <span py:content="getattr(po,header_attr,'')" checkpoint="${'HEADER_%s' %header_attr}"></span>
				</li>
				
				<li py:for="item_no,item in enumerate(sorted(po.items,key=lambda d:d.upc))" objectType="PO1" UPC="${item.upc}">
					<ul class="in-one">
						<li py:for="index2,po1_attr in enumerate(po1_attrs)">
							<label py:content="po1_labels[index2]"></label> <span py:content="getattr(item,po1_attr,'')" checkpoint="${'PO1_%s_%s' %(item.upc,po1_attr)}"></span>
						</li>
						<li py:for="sln_no,sln in enumerate(sorted(item.slns,key=lambda s:s.upc))" objectType="SLN" UPC="${sln.upc}">
							<ul class="in-two">
								<li py:for="index3,sln_attr in enumerate(sln_attrs)">
										<label py:content="sln_labels[index3]"></label>
										<span py:content="getattr(sln,sln_attr,'')" checkpoint="${'SLN_%s_%s_%s' %(item.upc,sln.upc,sln_attr)}"></span>
								</li>
							</ul>
						</li>
					</ul>
				</li>
			</ul>
			

		</div>
	

		<div style="width:1200px;">
			<div style="overflow:hidden;margin:10px 0px 10px 0px">   

				<div id="source" style="float:left;width:450px;" class="dif-div" py:content="displayPO(source)">
					
				</div>
				
				<div id="target" style="float:left;width:450px;" class="dif-div" py:content="displayPO(target)"> 
				
				</div>
				
				<div class="dif-div" style="float:left;width:100px;">
					<p><a href="#" onclick="showDiffOnly();">&gt;&gt;Difference Only</a></p>
					<br />
					<p><a href="#" onclick="showAll();">&gt;&gt;Show All</a></p>
				</div>

			</div>
		</div>
		
		
		
</body>
</html>


