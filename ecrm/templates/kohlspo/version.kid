<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#"
    py:extends="'../master.kid'">

<head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
    <title>r-pac - Kohl's</title>
    <link rel="stylesheet" href="/static/css/flora.datepicker.css" type="text/css" media="screen"/>
    <script src="/static/javascript/ui.datepicker.js" language="javascript"></script>
    <script src="/static/javascript/jquery-impromptu.1.5.js" language="javascript"></script>
    
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
	        
	    });
	    
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
	    		$("form").attr("action","/kohlspo/showDifference");
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
		    		$("form").attr("action","/kohlspo/overWrite");
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
    <td width="176" valign="top" align="left"><a href="/kohlspo/index"><img src="/static/images/images/menu_kohls_g.jpg"/></a></td>

    <td width="64" valign="top" align="left"><a href="#" onclick="javascript:showDiff();"><img src="/static/images/images/menu_diff_g.jpg"/></a></td>
    <td width="64" valign="top" align="left" py:if="'KOHLS_EDIT' in tg.identity.permissions"><a href="#" onclick="javascript:overwrite();"><img src="/static/images/images/menu_overwrite_g.jpg"/></a></td>
    
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/static/images/images/menu_last.jpg"/></td>
    <td align="left" valign="top" background="/static/images/images/menu_end.jpg">&nbsp;</td>
  </tr>
</tbody></table>

</div>



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
				attrs1 = ["poNo","poDate","ediFileDate","soNo","poType"]
				labels1 = ["PO No","PO Date","EDI File Date","SO No","PO Type"]
				
				attrs2 = ["soDate","manufacture","importDate","remark"]
				labels2 = ["SO Date","Vendor Name","System Date","Remark"]
			?>
			
			<div class="log-one"><input type="hidden" name="source_id" value="${po.id}"/>Latest PO Summary</div>
		    <div class="case-list-one">
		        <ul py:for="index,value in enumerate(attrs1)">
		            <li class="label"><label py:content="labels1[index]" /></li>
		            <li>
		            	<a href="${'/kohlspo/detail?id=%d' %po.id}" py:strip="value!='poNo'">
		            		<font color='red' py:strip="value!='poType' or getattr(po,value,'')!='TR'">
		            			<span py:replace="getattr(po,value,'')" />
		            		</font>
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
				attrs1 = ["poNo","poDate","ediFileDate","soNo","poType"]
				labels1 = ["PO No","PO Date","EDI File Date","SO No","PO Type"]
				
				attrs2 = ["soDate","manufacture","importDate","remark"]
				labels2 = ["SO Date","Vendor Name","System Date","Remark"]
			?>
		
			<div class="log-five"><input type="radio" name="target_id" value="${po.id}" id="${po.id}"/><label for="${po.id}">Previous PO Summary</label></div>
		    <div class="case-list-five">
		        <ul py:for="index,value in enumerate(attrs1)">
		            <li class="label"><label py:content="labels1[index]" /></li>
		            <li>
		            	<a href="${'/kohlspo/detail?id=%d' %po.id}" py:strip="value!='poNo'">
		            		<font color='red' py:strip="value!='poType' or getattr(po,value,'')!='TR'">
		            			<span py:replace="getattr(po,value,'')" />
		            		</font>
		            	</a>
		            </li>
		        </ul>
		    </div>
		    <div class="case-list-five">
		        <ul py:for="index,value in enumerate(attrs2)">
		            <li class="label"><label py:content="labels2[index]" /></li>
		            <li><span py:replace="getattr(po,value,'')" /></li>
		        </ul>
		    </div>
		</div>
</body>
</html>


