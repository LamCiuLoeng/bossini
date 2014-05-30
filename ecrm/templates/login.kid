<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml"
    xmlns:py="http://purl.org/kid/ns#">

<head>
    <meta content="text/html; charset=UTF-8" http-equiv="content-type" py:replace="''"/>
    <title>r-pac - Login</title>
    <link rel="shortcut icon" type="images/x-icon" href="../static/images/favicon.ico"  py:attrs="href=tg.url('/static/images/favicon.ico')"/>
    <link rel="stylesheet" type="text/css" media="screen" py:attrs="href=tg.url('/static/css/screen.css')"/>
    <script src="/static/javascript/jquery-1.2.6.js" type="text/javascript"></script>
    <script language="JavaScript" type="text/javascript">
	//<![CDATA[
	    $(document).ready(function(){
	        if ($.browser.msie && $.browser.version <'7.0' ) {
			   $("#contenulogin").append("<div style='margin-top:30px;'>*You are using IE 6,it's recommended to upgrade your browser to IE 7 or higher to get the better view.</div>");
			} 
	    });
	//]]>
	</script>
</head>

<body onload="document.getElementById('login_name').focus()">
    <div id="contenulogin">
        <div id="logo-login"></div>
        <div id="boxlogin">
            <form action="${previous_url}" method="POST">
                <fieldset>
                    <legend>r-pac authentication</legend>
                        <p><label for="login_name">Login :  </label><input name="user_name" id="login_name" type="text" style="width:150px"/></p>
                        <p><label for="login_password">Password : </label><input name="password" id="login_password" type="password" style="width:150px"/></p>
                		<p style="text-align:center"><input name="login" value="Login" class="submit" type="submit" /></p>
		                <p>${message}</p>
                </fieldset>
				<input py:if="forward_url" type="hidden" name="forward_url"   value="${forward_url}"/>
				<div py:for="name,values in original_parameters.items()" py:strip="">
		            <input py:for="value in isinstance(values, list) and values or [values]"  type="hidden" name="${name}" value="${value}"/>
        	    </div>
            </form>
        </div>        
    </div>
</body>
</html>
