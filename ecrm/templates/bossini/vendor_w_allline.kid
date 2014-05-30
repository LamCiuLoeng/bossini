<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#"
    py:extends="'../master.kid'">
<head>
	<meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
	<title>r-pac - Bossini</title>

	<link rel="stylesheet" href="/static/css/custom/order.css" type="text/css" media="screen"/>
	<style type="text/css">
    <!--
    div.cleanblue .cleanbluebuttons{
        text-align : center;
      }
      
    .STYLE2 {
      font-size: 18px;
      font-weight: bold;
      font-family: Arial, Helvetica, sans-serif;
    }
    .STYLE3 {
      font-family: Arial, Helvetica, sans-serif;
      color: #630063;
      font-weight: bold;
      font-size: 18px;
    }
    .STYLE4 {
      font-family: Arial, Helvetica, sans-serif;
      color: #006100;
      font-weight: bold;
      font-size: 18px;
    }
    .TSTYLE {
      font-family: Arial, Helvetica, sans-serif;
      color: #ff0000;
      font-weight: bold;
      font-size: 18px;
    }
    -->
   </style>
	
	
	
	
	
	<script src="/static/javascript/jquery-impromptu.1.5.js" language="javascript"></script>
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
    <tbody>
      <tr>
        <td width="36" valign="top" align="left"><img src="/static/images/images/menu_start.jpg"/></td>
        <td width="176" valign="top" align="left"><a href="/bossinipo/vendor_index"><img src="/static/images/images/Bossini_PO_g.jpg"/></a></td>
        <td width="54" valign="top" align="left"><a href="/bossinipo/vendor_new_order"><img src="/static/images/images/menu_back_g.jpg"/></a></td>
        <td width="23" valign="top" align="left"><img height="21" width="23" src="/static/images/images/menu_last.jpg"/></td>
        <td align="left" valign="top" background="/static/images/images/menu_end.jpg">&nbsp;</td>
      </tr>
    </tbody>
  </table>
</div>
<div class="nav-tree">Bossini&nbsp;&nbsp;&gt;&nbsp;&nbsp;Main&nbsp;&nbsp;&gt;&nbsp;&nbsp;Woven Label (织唛)</div>
<div style="width:1200px;">
  <div style="overflow:hidden;margin:5px 0px 10px 10px">
    <!--  main content begin -->
    <p class="STYLE2">Please select order type 请选择订单类型:</p>
    <p><a href="/bossinipo/vendor_w_order?line=men" class="STYLE2" style="color:black">1.Bossini Men (男装)</a></p>
    <p><a href="/bossinipo/vendor_w_order?line=ladies" class="STYLE2" style="color:red">2.Bossini Ladies (女装)</a></p>
    <!-- main content end -->
  </div>
</div>
</body>
</html>
