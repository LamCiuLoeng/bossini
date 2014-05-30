<table xmlns:py="http://purl.org/kid/ns#" id="${name}" class="gridTable" cellpadding="0" cellspacing="0" border="0">

<script language="JavaScript" type="text/javascript" py:if="defined('checkBoxFunction') and checkBoxFunction">
    //<![CDATA[
	function _selectCB(header_cb){
		var hcb = $(header_cb);
		if(hcb.attr("checked")){
			$(".gridTable tbody input[@type='checkbox']").attr("checked",true);
		}else{
			$(".gridTable tbody input[@type='checkbox']").attr("checked",false);
		}
	}
    //]]>
</script>


<thead py:if="columns">
	<tr py:if="columns" height="25px">  
	    <th py:for="i, col in enumerate(columns)" py:attrs="col.options">
	    	<input py:if="i==0 and defined('checkBoxFunction') and checkBoxFunction" type="checkbox" onclick="javascript:_selectCB(this);"/>
	    	<span py:if="i>0 or not defined('checkBoxFunction') or not checkBoxFunction" py:replace="col.title"></span>
	    </th>
	</tr>
</thead>
<tbody>
  <tr py:for="i, row in enumerate(value)" class="${i%2 and 'odd' or 'even'}" height="25px">
 <!--   <td py:for="col in columns" align="${col.get_option('align',None)}"
        class="dataTD" width="${col.get_option('width',None)}"><span py:replace="col.get_field(row)"></span>&nbsp;</td>  -->
	
	<td py:for="col in columns" class="dataTD" py:attrs="col.options"><span py:replace="col.get_field(row)"></span>&nbsp;</td>
	
  </tr>
</tbody>
</table>



