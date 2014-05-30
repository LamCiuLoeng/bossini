<div xmlns:py="http://purl.org/kid/ns#" id="${name}" py:strip="">
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
<style type="text/css">
      .highlight{
        color:white;
        background-color:green;
      }
</style>
<script language="JavaScript" type="text/javascript">
     $(document).ready(function(){
        $(".gridTable tbody td").click(function() {
		    chk = $(":checkbox",$(this).parents('tr'));
		    if($(chk).attr("checked")){
				$(":checkbox",$(this).parents('tr')).attr("checked",false);
			    var sid = $(this).parents('tr').attr("sid");
			    sid = parseInt(sid);
			    if(sid%2==0){
		    	      $(this).parents('tr').removeClass();
			      $(this).parents('tr').addClass('odd');
			    }else{
			      $(this).parents('tr').removeClass('highlight');
			    }
		    }else{
		    	$(":checkbox",$(this).parents('tr')).attr("checked",true);
		    	$(this).parents('tr').removeClass();
		    	$(this).parents('tr').addClass('highlight');
		    }
        });
      });

</script>


<table class="gridTable" cellpadding="0" cellspacing="0" border="0" width="130%">
<thead>
  <tr>
    <td style="text-align:right;border-right:0px;"  colspan="${len(columns) or None}">
        <span  py:if="getattr(tg, 'paginate', False) and tg.paginate.page_count > 1">
            <a py:strip="not tg.paginate.href_first"
                href="${tg.paginate.href_first}"><span
                >&lt;&lt;</span></a>

              &#160;<span py:for="page in tg.paginate.pages" py:strip="True">
              <a py:strip="page == tg.paginate.current_page"
                href="${tg.paginate.get_href(page)}"><span
                 py:content="page"/></a>
              </span>&#160;

              <a py:strip="not tg.paginate.href_last"
                href="${tg.paginate.href_last}"><span
                >&gt;&gt;</span></a> ,
        </span>
        <span>${tg.paginate.first_item} - ${tg.paginate.last_item},&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;${tg.paginate.row_count} records</span>
    </td>
  </tr>
  <tr py:if="columns">


    <th py:for="i, col in enumerate(columns)" width="${'15px' if i==0 and defined('checkBoxFunction') and checkBoxFunction else '0px'}">
    	<input py:if="i==0 and defined('checkBoxFunction') and checkBoxFunction" type="checkbox" onclick="javascript:_selectCB(this);"/>
    	<span py:if="i>0 or not defined('checkBoxFunction') or not checkBoxFunction" py:replace="col.title"></span>
    </th>


  </tr>
</thead>
<tbody>
  <tr py:for="i, row in enumerate(value)" class="${i%2 and 'odd' or 'even'}" sid="${i+1}">
    <td py:for="col in columns" align="center"
        class="dataTD"><span py:replace="col.get_field(row)"></span>&nbsp;</td>
  </tr>


  <tr>
    <td style="text-align:right;border-right:0px;border-bottom:0px"  colspan="${len(columns) or None}">
        <span  py:if="getattr(tg, 'paginate', False) and tg.paginate.page_count > 1">
            <a py:strip="not tg.paginate.href_first"
                href="${tg.paginate.href_first}"><span
                >&lt;&lt;</span></a>

              &#160;<span py:for="page in tg.paginate.pages" py:strip="True">
              <a py:strip="page == tg.paginate.current_page"
                href="${tg.paginate.get_href(page)}"><span
                 py:content="page"/></a>
              </span>&#160;

              <a py:strip="not tg.paginate.href_last"
                href="${tg.paginate.href_last}"><span
                >&gt;&gt;</span></a> ,
        </span>
        <span>${tg.paginate.first_item} - ${tg.paginate.last_item},&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;${tg.paginate.row_count} records</span>
    </td>
  </tr>

</tbody>
</table>

</div>
