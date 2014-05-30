<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#"
    py:extends="'../master.kid'">

<head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
    <title>r-pac - r-track</title>
    
    <script language="JavaScript" type="text/javascript">
    //<![CDATA[

        function deleteConfirm(){
            if ( confirm("The record will be deleted from DB ,are you sure to continue ?") ){
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
    <td width="176" valign="top" align="left"><a href="/kohlspo/index"><img src="/static/images/images/menu_kohls_g.jpg"/></a></td>
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/static/images/images/menu_last.jpg"/></td>
    <td align="left" valign="top" background="/static/images/images/menu_end.jpg">&nbsp;</td>
  </tr>
</tbody></table>

</div>
<div style="width:1200px;">
	<div style="overflow:hidden;margin:10px 0px 10px 0px">   
	
		<form action="" method="post" name="dataForm">
			<div py:replace="showLatest(po[0])">
			    
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
	
	<div class="log-one"><input type="hidden" name="source_id" value="${po.id}"/>PO# History</div>
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
<div style="margin:10px 10px 0;">
    ${result_widget.display(items)}
</div>

<div><br /></div>
</body>
</html>
