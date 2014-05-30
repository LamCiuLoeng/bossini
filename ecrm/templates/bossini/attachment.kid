<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#"
    py:extends="'../master.kid'">

<head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
    <title>r-pac - Bossini</title>
    
    <script src="/static/javascript/jquery-impromptu.1.5.js" language="javascript"></script>
    <script language="JavaScript" type="text/javascript">
    //<![CDATA[

        function deleteConfirm(){
            if ( confirm("The record will be deleted from DB ,are you sure to continue ?") ){
                    return true;
            }else{
                return false;
            }
        }
        
        function getFileName(obj){
		    var tmp = $(obj);
			var path = tmp.val();
			if( path && path.length > 0){
				var location = path.lastIndexOf("\\") > -1 ?path.lastIndexOf("\\") + 1 : 0;
				var fn = path.substr( location,path.length-location );	
				$("#fileName").val(fn);
			}
		}
		
		function deleteAttachment(id,fn){
			if(!confirm("Are you sure to delete the attachment?")){
				return false;
			}
		
			$.getJSON(
				"/bossinipo/deleteDownload",
				{"id":id,"fn":fn},
				function(data){
					if(data.flag=='0'){ $("#"+fn).remove(); }
					alert(data.tg_flash);
				}
			);
		}
		
		$(document).ready(function(){
			$("form").submit(function(){
				if(!$("input[name='filePath']").val()){
					alert("Please select one file to upload!");
					return false;
				}
			});
		});
        
    //]]>
    </script>
    
    <script language="JavaScript" type="text/javascript" py:if="tg_flash">
    //<![CDATA[
        $(document).ready(function(){
            $.prompt("${tg_flash}",{opacity: 0.6,prefix:'cleanblue',show:'slideDown'});
        });
    //]]>
    </script>    
</head>

<body>

<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
    <td width="36" valign="top" align="left"><img src="/static/images/images/menu_start.jpg"/></td>
    <td width="176" valign="top" align="left"><a href="/bossinipo/index"><img src="/static/images/images/Bossini_PO_g.jpg"/></a></td>

	<!--
	    <td width="64" valign="top" align="left"><a href="/bossinipo/reviseOrder?id=${header.id}"><img src="/static/images/images/menu_revise_g.jpg"/></a></td>
	-->
    
    <td width="64" valign="top" align="left"><a href="/bossinipo/detail?id=${header.id}"><img src="/static/images/images/menu_detail_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="${'/bossinipo/versions?id=%d' %header.id}"><img src="/static/images/images/menu_versions_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="/bossinipo/history?id=${header.id}"><img src="/static/images/images/menu_history_g.jpg"/></a></td>

    <td width="23" valign="top" align="left"><img height="21" width="23" src="/static/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/static/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>

</div>

<div class="nav-tree">Bossini&nbsp;&nbsp;&gt;&nbsp;&nbsp;Main<span>&nbsp;&nbsp;&gt;&nbsp;&nbsp;Attachment</span></div>

  <div style="margin: 0px 0px 0px 0px; overflow: hidden;">
  	<div style="margin:10px 0px 0px 0px; overflow: hidden;">
		<form action="/bossinipo/uploadAttachment/${header.id}" enctype="multipart/form-data" method="POST">    	
			<!--label for="fileName">File Name : </label><input type="text" name="fileName" id="fileName"/>
			<label for="filePath">File Path : </label><input size="60" type="file" name="filePath" id="filePath" onchange="getFileName(this);"/>
			<input type="submit" value="upload"/-->
		
		<div class="case-list-one">
			<ul style="width:750px">
				<li class="label"><label for="fileName">File Name : </label></li>
				<li><input type="text" name="fileName" id="fileName" style="width: 250px;"/></li>
			</ul>
			<ul style="width:750px">
				<li class="label"><label for="filePath">File Path : </label></li>
				<li><input type="file" name="filePath" id="filePath" onchange="getFileName(this);" size="60"/>&nbsp;&nbsp;<input type="Submit" value="Upload"/></li>
			</ul>
		</div>
		</form>
		
	</div>

	<div style="clear:both;"></div>
    <div style="margin:10px 0px 0px 10px;">
      <table class="gridTable"  cellpadding="0" cellspacing="0">
      		<thead>
      			<th width="150px">Upload Time</th>
      			<th width="100px">Upload User</th>
      			<th width="500px">File Name</th>
      			<th width="100px">Download</th>
      			<th width="100px">Delete</th>
      		</thead>
      		<tbody>
      			<div py:for="obj in attachments" py:strip="">
	      			<tr id="${obj.id}">
	      				<td py:content="obj.createTime" style="border-left:1px solid #ccc"/>
	      				<td py:content="obj.issuedBy"/>
	      				<td py:content="obj.name"/>
	      				<td><a href="/bossinipo/download?fn=${obj.id}">Download</a></td>
	      				<td><a href="#" onclick="deleteAttachment(${header.id},${obj.id});return false;">Delete</a></td>
	      			</tr>
      			</div>
      		</tbody>
      </table>
      </div>
      
  </div>

  
</body>
</html>
