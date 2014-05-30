<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#"
    py:extends="'../master.kid'">

<head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
    <title>r-pac - Bossini</title>
    <link rel="stylesheet" href="/static/css/flora.datepicker.css" type="text/css" media="screen"/>
    <link rel="stylesheet" href="/static/css/custom/show_difference.css" type="text/css" media="screen"/>
    <script src="/static/javascript/ui.datepicker.js" language="javascript"></script>
    <script src="/static/javascript/jquery-impromptu.1.5.js" language="javascript"></script>
    <script src="/static/javascript/custom/version_diff.js" language="javascript"></script>
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
	
	<script language="JavaScript" type="text/javascript" py:if="tg_flash">
	//<![CDATA[
	    $(document).ready(function(){
	        $.prompt("${tg_flash}",{opacity: 0.6,prefix:'cleanblue',show:'slideDown'});
	    });
	//]]>
	</script>
	
	<script language="JavaScript" type="text/javascript">
	//<![CDATA[
	    var header = new Array("poNo","lotNum","versions","season","styleNo","legacyCode","marketList","collection","vendorCode","priceCurrency","netPrice","blankPrice","orderType","subCat","status","hangTagType","itemType","importdate");
	    var header_label = new Array("PO#","Lot Num","Version","Season","Style#","Legacy Code","Market List","Collection","Vendor Code","Price Currency","Net Price","Blank Price","Order Type","SubCat","Status","HangTag Type","Item Type","Import Date");
	    var detail = new Array("recolorCode","colorName","sizeCode","sizeName","qty","eanCode","length","resizeRange");
	    var detail_label = new Array("Color Code","Color Name","Size Code","Size Name","Qty","Ean Code","Length","Size Range");
	
	    $(document).ready(function(){
	        
	    });
	    function comparepo(id){
		var div = "div_" + id;
		$("#" + div).show();
		$.getJSON("/bossinipo/comparePo",
			 {"header_id":id},
			 function(data){
			 
			     targetHeader = data.target[0]; //python-dict
			     targetDetail = data.target[1]; //python-list
			     sourceHeader = data.source[0];
			     sourceDetail = data.source[1];
			     /////////////////////--------------------left
			     var begin_left = "<div style='float:left;width:400px;' class='dif-div target'>";
			     var end_left = "</div>";
			     var li = '';
			     for(i=0;i<header.length;i++){
				li += "<li><label>" + header_label[i] + "</label>";
				li += " <span checkpoint='HEADER_" + header[i] + id + "'>" + targetHeader[header[i]] + "</span></li>";
			     }
			     
			     for(i=0;i<targetDetail.length;i++){
				li += "<li><ul class='in-one'>";
				for(j=0;j<detail.length;j++){
				    li += "<li><label>" + detail_label[j] + "</label>";
				    li += "<span checkpoint='Detail_" + detail[j] + i + id + "'>" + targetDetail[i][detail[j]] + "</span></li>";
				}
				li += "</ul></li>";
			     }
			     var left = begin_left + "<ul>" + li + "</ul>" + end_left;
			     
			     //////////////////////-------------------right
			     
			     var begin_right = "<div style='float:left;width:400px;' class='dif-div source'>";
			     var end_right = "</div>";
			     var li = '';
			     for(i=0;i<header.length;i++){
				li += "<li><label>" + header_label[i] + "</label>";
				li += " <span checkpoint='HEADER_" + header[i] + id + "'>" + sourceHeader[header[i]] + "</span></li>";
			     }
			     
			     for(i=0;i<sourceDetail.length;i++){
				li += "<li><ul class='in-one'>";
				for(j=0;j<detail.length;j++){
				    li += "<li><label>" + detail_label[j] + "</label>";
				    li += "<span checkpoint='Detail_" + detail[j] + i + id + "'>" + sourceDetail[i][detail[j]] + "</span></li>";
				}
				li += "</ul></li>";
			     }
			     var right = begin_right + "<ul>" + li + "</ul>" + end_right;
			     
			     $("#" + div).html(left + right);
			     checkAfter(div);
			 });
		   
	    }	    
	    function cancelpo(id){
		var div = "div_" + id;
		$("#" + div).html();
		$("#" + div).hide();
	    }
	    function showDiff(){
	    	var flag = false;
	    	$(":radio").each(function(){
	    		var tmp = $(this);
	    		if(tmp.attr("checked")){
	    			flag = true;
	    		}
	    	});	    
	    	if( !flag ){
	    		alert("Please select one previous version PO first!");
	    		return false;
	    	}
	    	else{
	    		$("form").attr("action","/bossinipo/showDifference");
	    		$("form").submit();
	    	}
	    }
	    
	    function overwrite(){
	    	var flag = false;
	    	$(":radio").each(function(){
	    		var tmp = $(this);
	    		if(tmp.attr("checked")){
	    			flag = true;
	    		}
	    	});	    
	    	if( !flag ){
	    		alert("Please select one other version PO first!");
	    		return false;
	    	}
	    	else{
	    		if(confirm("Are you sure to overwrite the PO with other version ?")){
		    		$("form").attr("action","/bossinipo/overWrite");
		    		$("form").submit();   		
	    		}else{
	    			return false;
	    		}
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
    <td width="176" valign="top" align="left"><a href="/bossinipo/index"><img src="/static/images/images/Bossini_PO_g.jpg"/></a></td>	
	<td width="64" valign="top" align="left"><a href="${'/bossinipo/detail?id=%d' %POHeader.id}" ><img src="/static/images/images/menu_detail_g.jpg"/></a></td>
    <!--
    <td width="64" valign="top" align="left"><a href="/bossinipo/reviseOrder?id=${POHeader.id}"><img src="/static/images/images/menu_revise_g.jpg"/></a></td>
    -->
    
    <td width="64" valign="top" align="left"><a href="/bossinipo/viewAttachment?id=${POHeader.id}"><img src="/static/images/images/menu_attach_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="${'/bossinipo/history?id=%d' %POHeader.id}"><img src="/static/images/images/menu_history_g.jpg"/></a></td>  
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/static/images/images/menu_last.jpg"/></td>
    <td align="left" valign="top" background="/static/images/images/menu_end.jpg">&nbsp;</td>
    
  </tr>
</tbody></table>

</div>
<div class="nav-tree">Bossini&nbsp;&nbsp;&gt;&nbsp;&nbsp;Main&nbsp;&nbsp;&gt;&nbsp;&nbsp;Version</div>

		<div style="width:1200px;">
			<div style="overflow:hidden;margin:10px 0px 10px 0px">   
			
				<form action="" method="post" name="dataForm">
					<div py:for="po in pos" py:replace="showLatest(po) if po.latestFlag > 0 else showOld(po)">
					    
					</div>
				</form>
				
			</div>
		</div>
		
		
		
		<!-- show the latest PO -->
		<div py:def="showLatest(po)" class="case-960-one">
			<?python
				attrs1 = ["poNo","styleNo","legacyCode","marketList","vendorCode","importdate"]
				labels1 = ["PO#","Style#","Legacy Code","Market List","Vendor Code","Import Date"]
				
				attrs2 = ["collection","orderType","subCat","hangTagType","itemType","versions"]
				labels2 = ["Collection","Order Type","Sub Cat","HangTag Type","Item Type","Version"]
			?>
			
			<div class="log-one">
			<input type="hidden" name="source_id" value="${po.id}" /><span style="color:#659900;">Latest version [${po.versions}]</span></div>
		    <div class="case-list-one">
		        <ul py:for="index,value in enumerate(attrs1)">
		            <li class="label"><label py:content="labels1[index]" /></li>
		            <li>
		            	<a href="${'/bossinipo/detail?id=%d' %po.id}" py:strip="value!='poNo'">

					<span py:replace="getattr(po,value,'')" />

		            	</a>
		            </li>
		        </ul>
		    </div>
		    <div class="case-list-one">
		        <ul py:for="index,value in enumerate(attrs2)">
		            <li class="label"><label py:content="labels2[index]" /></li>
		            <li><span py:replace="getattr(po,value,'')" /></li>
		        </ul>
		    </div>
		</div>
		
		<!-- show the old PO -->
		<div py:def="showOld(po)" class="case-960-five">
			<?python
				attrs1 = ["poNo","importdate"]
				labels1 = ["PO#","Import Date"]
				
				attrs2 = ["legacyCode","marketList",]
				labels2 = ["Legacy Code","Market List"]
			?>
		
			<div class="log-five">
			<label for="${po.id}" style="color:red;">version ${po.versions}</label>
			<label> ${po.importdate}</label>
			<img src="/static/images/images/compare_g.jpg" onclick="comparepo(${po.id})"  style="padding:5px 0px 0px 0px;"/>
			<img src="/static/images/images/cancel_g.jpg" onclick="cancelpo(${po.id})" />
			</div>
			<div class="case-900-five" id ="div_${po.id}" style="display:none">
			</div>
	    </div>
</body>
</html>


