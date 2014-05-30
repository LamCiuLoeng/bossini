<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#"
    py:extends="'../master.kid'">

<head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
    <title>r-track</title>
</head>

<body>

<?python
    import re
    from cherrypy import request
?>

<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
    <td width="36" valign="top" align="left"><img src="/static/images/images/menu_start.jpg"/></td>
    <td width="1" valign="top" align="left"><a href="/${function_url}/index"><img src="/static/images/images/menu_${function_url}_g.jpg"/></a></td>
    <td py:if="'RTRACK_MASTER' in tg.identity.permissions and not re.search('/add',request.path_info)" width="64" valign="top" align="left">
        <a href="/${function_url}/add"><img src="/static/images/images/menu_new_g.jpg"/></a>
    </td>

    <td py:if="'RTRACK_MASTER' in tg.identity.permissions and defined('record_id') and not re.search('/update/',request.path_info)" width="64" valign="top" align="left">
        <a href="/${function_url}/update/${record_id}"><img src="/static/images/images/menu_revise_g.jpg"/></a>
    </td>

    <td py:if="'RTRACK_MASTER' in tg.identity.permissions and defined('record_id')" width="64" valign="top" align="left">
        <a href="/${function_url}/delete/${record_id}" onClick="return deleteConfirm()"><img src="/static/images/images/menu_delete_g.jpg"/></a>
    </td>

    <td width="56" valign="top" align="left"><a href="#" onclick="historyBack()"><img height="21" width="54" src="/static/images/images/menu_back_g.jpg"/></a></td>
    <td width="56" valign="top" align="left"><a href="#" onclick="historyGo()"><img height="21" width="54" src="/static/images/images/menu_go_g.jpg"/></a></td>

    <td width="23" valign="top" align="left"><img height="21" width="23" src="/static/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/static/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>

</div>

    <div><br /></div>

  <div>
      ${result_widget.display(items)}
  </div>
</body>
</html>
