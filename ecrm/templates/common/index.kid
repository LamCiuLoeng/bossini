<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#"
    py:extends="'../master.kid'">

<head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
    <title>r-pac - r-track</title>
    <script src="/static/javascript/ui.datepicker.js" type="text/javascript"></script>
    <script type="text/javascript" src="/static/javascript/jquery.columnfilters.js"></script>
    <link rel="stylesheet" href="/static/css/flora.datepicker.css" type="text/css" media="screen"/>

	<script src="/static/javascript/jquery-impromptu.1.5.js" language="javascript"></script>
    <link rel="stylesheet" href="/static/css/jquery.autocomplete.css" type="text/css" />
    <script type="text/javascript" src="/static/javascript/jquery.autocomplete.pack.js"></script>
    <script type="text/javascript" src="/static/javascript/pls_ac.js"></script>

    <style type="text/css" py:if="function_url in ['plsv','plsb','plsd','plsr','plsc','region']">
        .dataTD{
            width: 400px;
        }
    </style>



<script language="JavaScript" type="text/javascript">
//<![CDATA[
         function toSearch(){
            $(".tableform").submit()
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

<?python
    from cherrypy import request
    import re
?>



<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
    <td width="36" valign="top" align="left"><img src="/static/images/images/menu_start.jpg"/></td>
    <td width="1" valign="top" align="left"><a href="/${function_url}/index"><img src="/static/images/images/menu_${function_url}_g.jpg"/></a></td>
    <td width="64" valign="top" align="left"><a href="javascript:toSearch()"><img src="/static/images/images/menu_search_g.jpg"/></a></td>

    <td py:if="'RTRACK_MASTER' in tg.identity.permissions and not re.search('/add',request.path_info)" width="64" valign="top" align="left">
        <a href="/${function_url}/add"><img src="/static/images/images/menu_new_g.jpg"/></a>
    </td>
    <td width="64" valign="top" align="left"><a href="#" onclick="resetForm();"><img src="/static/images/images/menu_reset_g.jpg"/></a></td>
    <td width="56" valign="top" align="left"><a href="#" onclick="historyBack()"><img height="21" width="54" src="/static/images/images/menu_back_g.jpg"/></a></td>
    <td width="56" valign="top" align="left"><a href="#" onclick="historyGo()"><img height="21" width="54" src="/static/images/images/menu_go_g.jpg"/></a></td>

    <td width="23" valign="top" align="left"><img height="21" width="23" src="/static/images/images/menu_last.jpg"/></td>
    <td valign="top" style="background:url(/static/images/images/menu_end.jpg) repeat-x;width:100%"></td>
  </tr>
</tbody></table>

</div>


	<div style="width:1200px;">
			<div style="overflow:hidden;margin:10px 0px 10px 0px">
					${search_widget(action=submit_action,column_num=column_num)}
			</div>
		</div>


  <div id="recordsArea" py:if="items">

      ${result_widget.display(items)}


    <div style="clear:both"><br /></div>
    <div py:if="function_url=='pls'" style="margin-left: 700px;">
        <form action="updateBatch/" method="post" class="batchEditForm">
            <input type="hidden" name="batchUpdateIDs" value="|"/>
            <a href="#" onclick="selectAll()"><img src="/static/images/images/search-bt_11.jpg" width="87" height="24"  onmouseover="this.src='/static/images/images/search-bt2_11.jpg'" onmouseout="this.src='/static/images/images/search-bt_11.jpg'"/></a>
            <a href="#" onclick="selectNone()"><img src="/static/images/images/search-bt_07.jpg" width="87" height="24"  onmouseover="this.src='/static/images/images/search-bt2_07.jpg'" onmouseout="this.src='/static/images/images/search-bt_07.jpg'"/></a>
            <input type="image"  src="/static/images/images/search-bt_09.jpg" width="87" height="24"  onmouseover="this.src='/static/images/images/search-bt2_09.jpg'" onmouseout="this.src='/static/images/images/search-bt_09.jpg'"/>
        </form>
    </div>

  </div>

  <div style="clear:both"><br /></div>




</body>
</html>


