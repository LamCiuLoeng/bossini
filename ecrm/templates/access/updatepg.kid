<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#"
    py:extends="'../master.kid'">

<head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
    <title>r-pac - Account Management</title>
    <link rel="stylesheet" href="/static/css/custom/access.css" type="text/css" media="screen"/>
    <script src="/static/javascript/jquery-impromptu.1.5.js" language="javascript"></script>
    
    <script language="JavaScript" type="text/javascript">
	//<![CDATA[
	    $(document).ready(function(){
	        $("form").submit(function(){
	        	var igs = new Array();
	        	$("option","#inGroup").each(function(){
	        		igs.push( $(this).val() );
	        	});
	        	
	        	var ogs = new Array();
	        	$("option","#outGroup").each(function(){
	        		ogs.push( $(this).val() );
	        	});
	        	
	        	$(this).append("<input type='hidden' name='igs' value='"+igs.join("|")+"'/>");
	        	$(this).append("<input type='hidden' name='ogs' value='"+ogs.join("|")+"'/>");
	        	
	        });
	    });
	    	    
	    function toSave(){
	    	$("form").submit();
	    }
	    
	    function addOption(d1,d2){
	    	var div1 = $("#"+d1);
	    	var div2 = $("#"+d2);
	    	$(":selected",div1).each(function(){
	    		div2.append(this);
	    	});
	    }
	    	    
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
    <td width="176" valign="top" align="left"><a href="/account/index"><img src="/static/images/images/menu_am_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="/account/add"><img src="/static/images/images/menu_new_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="#" onclick="javascript:toSave();"><img src="/static/images/images/menu_save_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="javascript:toReset();"><img src="/static/images/images/menu_reset_g.jpg"/></a></td>
    
    <td width="64" valign="top" align="left"><a href="#" onclick=""><img src="/static/images/images/menu_detail_g.jpg"/></a></td>
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/static/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/static/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>

</div>

	<div style="overflow:hidden;margin:10px 0px 10px 0px">
		<div style="width:560px">
			<form action="/account/savePermission" method="POST">
				<input type="hidden" value="${permission.id}" name="pid"/>				
				<div class="case-list-one">
	                <ul>
	                    <li class="label"><label>Permission Name : </label></li>
	                    <li><span py:content="permission.permission_name"/></li>
	                </ul>
	            </div>
				<div style="clear:both"><br /></div>
				<div class="s_m_div">
					<div class="select_div">
						<ul>
							<li><label for="inGroup">Groups with permission:</label></li>
							<li>
								<select id="inGroup" name="inGroup" multiple="true">
									<option py:for="g in inGroup" value="${g.id}" py:content="g.group_name"/>
								</select>
							</li>
						</ul>			
					</div>
								
					<div class="bt_div">
						<input type="image" src="/static/images/images/right2left.jpg" value="Add" onclick="addOption('outGroup','inGroup');return false;"/>
						<br /><br />
						<input type="image" src="/static/images/images/left2right.jpg" value="Delete" onclick="addOption('inGroup','outGroup');return false;"/>
					</div>
									
					<div class="select_div">
						<ul>
							<li><label for="inGroup">Groups without permission:</label></li>
							<li><select id="outGroup" name="outGroup" multiple="true">
									<option py:for="g in outGroup" value="${g.id}" py:content="g.group_name"/>
								</select>
							</li>
						</ul>
					</div>
				</div>				
			</form>
		</div>
	</div>

</body>
</html>


