<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<?python import sitetemplate ?>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#"
    py:extends="sitetemplate">

<head py:match="item.tag=='{http://www.w3.org/1999/xhtml}head'" py:attrs="item.items()">
    <meta content="text/html; charset=UTF-8" http-equiv="content-type" py:replace="''"/>
    <title py:replace="''">Your title goes here</title>

    <link rel="stylesheet" type="text/css" media="screen" href="/static/css/all.css"/>
    <link rel="stylesheet" type="text/css" media="screen" href="/static/css/screen.css"/>
    <link rel="stylesheet" type="text/css" media="screen" href="/static/css/screen-jerry.css"/>
    <link rel="stylesheet" type="text/css" media="screen" href="/static/css/tg_css_fix.css"/>

    <script src="/static/javascript/jquery-1.2.6.js" type="text/javascript"></script>
    <script src="/static/javascript/menu.js" type="text/javascript"></script>

    <meta py:replace="item[:]" name="description" content="master template"/>
</head>

<body py:match="item.tag=='{http://www.w3.org/1999/xhtml}body'" py:attrs="item.items()">

<div>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="200" align="left" valign="middle"><img src="/static/images/logo.jpg" width="737" height="72" /></td>
    <td align="left" valign="middle" bgcolor="#EDF6FF">
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td><div py:if="tg.config('identity.on') and not defined('logging_in')" id="pageLogin"> <span py:if="tg.identity.anonymous"> <a href="${tg.url('/login')}">Login</a> </span> <span py:if="not tg.identity.anonymous"> <span class="welcome">Welcome :</span> ${tg.identity.user.display_name or tg.identity.user.user_name}
          <label>|</label>
                  <a href="${tg.url('/')}">Home</a>
                  <label>|</label>
              <a href="${tg.url('/logout')}">Logout</a> </span> </div></td>
        <td width="50">&nbsp;</td>
      </tr>
      <tr>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
    </table></td>
  </tr>
</table>
</div>

<div class="menu-tab">
    <ul>
        <li class="${'highlight' if tab_focus=='main' else ''}"><a href="/index">Main</a></li>
        <li class="${'highlight' if tab_focus=='report' else ''}" py:if="'REPORT' in tg.identity.groups"><a href="/report">Report</a></li>
        <li class="${'highlight' if tab_focus=='master' else ''}" py:if="'MASTER' in tg.identity.groups"><a href="/master">Master</a></li>
        <li py:if="'Admin' in tg.identity.groups" class="${'highlight' if tab_focus=='access' else ''}"><a href="/access">Access</a></li>
    </ul>
</div>

<div style="clear:both"></div>

    <!--div id="main_content"-->
    <div>
        <div py:replace="[item.text]+item[:]">page content</div>
    </div>

    <div id="footer">
Copyright r-pac International Corp.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div>
</body>

</html>
