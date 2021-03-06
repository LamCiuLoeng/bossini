<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#"
    py:extends="'../master.kid'">

<head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
    <title>r-pac - Bossini</title>
    <link rel="stylesheet" href="/static/css/flora.datepicker.css" type="text/css" media="screen"/>
    <link rel="stylesheet" href="/static/css/custom/order.css" type="text/css" media="screen"/>
    
    
    <script src="/static/javascript/ui.datepicker.js" language="javascript"></script>
    <script src="/static/javascript/jquery-impromptu.1.5.js" language="javascript"></script>
    
    <link rel="stylesheet" href="/static/css/jquery.autocomplete.css" type="text/css" />
    
    <script type="text/javascript" src="/static/javascript/jquery.bgiframe.pack.js"></script>
    <script type="text/javascript" src="/static/javascript/jquery.autocomplete.pack.js"></script>
   
   
   <style type="text/css">
	<!--
   	div.cleanblue .cleanbluebuttons{
   		text-align : center;
   	}

	.STYLE3 {
		font-family: Arial, Helvetica, sans-serif;
		color: #630063;
		font-weight: bold;
		font-size: 18px;
	} 
	
	 .case-960-one {
	  border:#cccccc 1px solid;
	     float:left;
	    width:960px;
	    background-color:#ffffff;
	    margin:10px 10px 0px 10px;
	
	     font-family: Verdana, Arial, Helvetica, sans-serif;
	    font-size: 18px;
	    line-height: normal;
	    color: #000000;
	    text-decoration: none;
	    overflow: hidden;
	    padding-bottom: 15px;
	}
	 .case-list-new {
	     float:left;
	    width:490px;
	    margin-top:5px;
	
	     font-family:Arial, Helvetica, sans-serif;
	    font-size: 11px;
	    line-height: 25px;
	    color: #000000;
	    text-decoration: none;
	}
	 .case-list-new ul{
	 float:left;
	 width:700px;
	 padding-left:0px;
	 border-top:#eee solid 1px;
	 border-bottom:#eee solid 1px;
	 border-left:#eee solid 1px;
	 border-right:#eee solid 1px;
	 margin-top:0px;
	 margin-bottom:5px;
	 margin-left:10px;
	 margin-right:0px;
	}
	.case-list-new ul li{
	float:left;
	font-size: 14px;
	    padding-left:5px;
	    margin:0px;
	    list-style:none;
	
	
	}
	.case-list-new ul li.label{
	text-align:right;
	 width:390px;
	    background-color:#E8F3F7;
	    font-weight: bold;
	}
	 .log-one{
	 border-bottom:1px #CCCCCC solid;
	 float:left;
	 margin:0px;
	 width:945px;
	 line-height:25px;
	 background-image:url(../images/images/bg-2_03.jpg);
	 padding:0px 0px 0px 15px;
	 margin:0px 0px 0px 0px;
	     font-family: Verdana, Arial, Helvetica, sans-serif;
	    font-size: 12px;
	
	    color: #000000;
	    text-decoration: none;
	font-weight: bold;
	
	 }
	-->
	</style>

   

	<script language="JavaScript" type="text/javascript" py:if="tg_flash">
	//<![CDATA[
	    $(document).ready(function(){
	        $.prompt("${tg_flash}",{
	        			opacity: 0.6,
	        			prefix:'cleanblue',
	        			show:'slideDown',
	        			buttons:{'Acknowledge and Go back to Main Manual<br />明白，返回总页面':true}
	        			});
	    });
	//]]>
	</script>


	<script language="JavaScript" type="text/javascript">
	//<![CDATA[
	    $(document).ready(function(){
	       $("#orderType").change(cardTypeChange);
	       
	       $("#marketList").change(marketChange);
	    });
	    
	    
	    function cardTypeChange(){
	    	var e = $(this);
	    	var p = $("#poInfo");
    		p.html("<option></option>");
    		
	    	if(e.val()=="H"){
	    		$("#marketList").removeAttr("disabled");
	    	}else if(e.val()=="WOV"){
	    		$("#marketList").attr("disabled","disabled");
	    		
	    		$.getJSON("/bossinipo/ajaxPOInfo",
	    				  {"vendorCode":$("#vendorCode").val(),"orderType":e.val()},
	    				  function(data){
	    				  	var str = "";
		    				for(n in data.result){
		    					var k = data.result[n];
		    					str += "<option value='"+k.id+"'>"+k.info+"</option>"
		    				}
		    				p.append(str);
	    		});
	    	}
	    }
	    
	    
	    function marketChange(){
	    	var o = $("#orderType").val();
       		var m = $("#marketList").val();
       		var p = $("#poInfo");
    		p.html("<option></option>");
	    	$.getJSON("/bossinipo/ajaxPOInfo",
    			{"marketList":m,"vendorCode":$("#vendorCode").val(),"orderType":o,"timestamp":(new Date()).getTime()},
    			function(data){
    				var str = "";
    				for(n in data.result){
    					var k = data.result[n];
    					str += "<option value='"+k.id+"'>"+k.info+"</option>"
    				}
    				p.append(str);
    			}
    		);
	    }
	    
	        
		function go2input(){
			$("form").submit()
		}
	//]]>
	</script>
</head>




<body>



<div id="function-menu">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tbody><tr>
    <td width="36" valign="top" align="left"><img src="/static/images/images/menu_start.jpg"/></td>
    <td width="176" valign="top" align="left"><a href="/bossinipo/vendor_index"><img src="/static/images/images/Bossini_PO_g.jpg"/></a></td>
    
    <td width="23" valign="top" align="left"><img height="21" width="23" src="/static/images/images/menu_last.jpg"/></td>
    <td align="left" valign="top" background="/static/images/images/menu_end.jpg">&nbsp;</td>
  </tr>
</tbody></table>

</div>
<div class="nav-tree">Bossini&nbsp;&nbsp;&gt;&nbsp;&nbsp;Main&nbsp;&nbsp;&gt;&nbsp;&nbsp;Place NEW Order</div>
<div style="width:1200px;">
	<div style="overflow:hidden;margin:5px 0px 10px 0px">
		
			<form action="/bossinipo/vendor_input" method="POST">
			<input type="hidden" id="vendorCode" name="vendorCode" value="${vendorCode}"/>
			<p class="STYLE3" style="margin-left:10px">Welcome, <b>${vendorCode}</b> user 欢迎您进入 r-pac 订单确认和查询系统 :</p>
			
			<div class="case-list-new">
		      <ul>
		        <li class="label">Hang Tag or Woven Label 印刷挂牌 或者 织唛 :</li>
		        <li>
		          <select name="orderType" style="width:250px" id="orderType">
						<option></option>
						<option value="H">Hang Tag &amp; Waist Card</option>
						<option value="WOV">Woven Label</option>
					</select>
		        </li>
		
		      </ul>
		      <ul>
		        <li class="label">Market 市场 :</li>
		        <li>
		          <select name="marketList" id="marketList" style="width:250px">
					<option py:for="o in ['','HKM','CHN','TWN','SIN','MYS','EXP']" value="${o}" py:content="o"/>
				</select>
		        </li>
		      </ul>
		      <ul>
		        <li class="label">Legacy Code &amp; bossini PO# 堡狮龙的订单号码和条码 :</li>
		        <li>
		          <select name="poInfo" id="poInfo" style="width:250px"  onchange="go2input();">
						<option></option>
					</select>
		        </li>
		
		      </ul>
		    </div>
				
			</form>
	</div>
</div>


</body>
</html>


