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
	        	var uigs = new Array();
	        	$("option","#userInGroup").each(function(){
	        		uigs.push( $(this).val() );
	        	});

	        	var uogs = new Array();
	        	$("option","#userOutGroup").each(function(){
	        		uogs.push( $(this).val() );
	        	});

	        	$(this).append("<input type='hidden' name='uigs' value='"+uigs.join("|")+"'/>");
	        	$(this).append("<input type='hidden' name='uogs' value='"+uogs.join("|")+"'/>");


	        	var pigs = new Array();
	        	$("option","#permissionInGroup").each(function(){
	        		pigs.push( $(this).val() );
	        	});

	        	var pogs = new Array();
	        	$("option","#permissionOutGroup").each(function(){
	        		pogs.push( $(this).val() );
	        	});

	        	$(this).append("<input type='hidden' name='pigs' value='"+pigs.join("|")+"'/>");
	        	$(this).append("<input type='hidden' name='pogs' value='"+pogs.join("|")+"'/>");

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
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/static/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/static/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>

</div>

	<div style="overflow:hidden;margin:10px 0px 10px 0px">
		<div style="width:560px">
			<form action="/account/saveGroup" method="POST">
				<input type="hidden" value="${group.id}" name="gid"/>

				<div class="case-list-one">
                <ul>
                    <li class="label"><label>Group Name : </label></li>
                    <li><span py:content="group.group_name"/></li>
                </ul>
                <ul>
                    <li class="label"><label>Region Master</label></li>
                    <li>
                    	<select id="region" name="region">
                    		<option py:for="r in regions" value="${r[0]}" py:content="r[1]" py:attrs="{'selected':'true'} if r[2] else {}"/>
                    	</select>
                    </li>
                </ul>
            </div>

			<div style="clear:both;"><br /></div>


				<div style="overflow:auto;width : 1300px;">

				<div class="s_m_div" style="float:left;">
					<div class="select_div">
						<ul>
							<li><label for="userInGroup">Include the users:</label></li>
							<li>
								<select id="userInGroup" name="userInGroup" multiple="true">
									<option py:for="u in userInGroup" value="${u.id}" py:content="u.user_name"/>
								</select>
							</li>
						</ul>
					</div>

					<div class="bt_div">
						<input type="image" src="/static/images/images/right2left.jpg" value="Add" onclick="addOption('userOutGroup','userInGroup');return false;"/>
						<br /><br />
						<input type="image" src="/static/images/images/left2right.jpg" value="Delete" onclick="addOption('userInGroup','userOutGroup');return false;"/>
					</div>

					<div class="select_div">
						<ul>
							<li><label for="userOutGroup">Exclude get the users:</label></li>
							<li>
								<select id="userOutGroup" name="userOutGroup" multiple="true">
									<option py:for="u in userOutGroup" value="${u.id}" py:content="u.user_name"/>
								</select>
							</li>
						</ul>
					</div>
				</div>



				<div class="s_m_div">
					<div class="select_div">
						<ul>
							<li><label for="permissionInGroup">Get the permissions:</label></li>
							<li>
								<select id="permissionInGroup" name="permissionInGroup" multiple="true">
									<option py:for="p in permissionInGroup" value="${p.id}" py:content="p.permission_name"/>
								</select>
							</li>
						</ul>
					</div>

					<div class="bt_div">
						<input type="image" src="/static/images/images/right2left.jpg" value="Add" onclick="addOption('permissionOutGroup','permissionInGroup');return false;"/>
						<br /><br />
						<input type="image" src="/static/images/images/left2right.jpg" value="Delete" onclick="addOption('permissionInGroup','permissionOutGroup');return false;"/>
					</div>

					<div class="select_div">
						<ul>
							<li><label for="permissionOutGroup">Don't get the permissions:</label></li>
							<li>
								<select id="permissionOutGroup" name="permissionOutGroup" multiple="true">
									<option py:for="p in permissionOutGroup" value="${p.id}" py:content="p.permission_name"/>
								</select>
							</li>
						</ul>
					</div>
				</div>

				</div>
			</form>
		</div>
	</div>

</body>
</html>


