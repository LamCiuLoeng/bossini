<table xmlns:py="http://purl.org/kid/ns#" id="${name}"
  class="gridTable" cellpadding="0" cellspacing="0" border="0">
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
        <span>${tg.paginate.first_item} - ${tg.paginate.last_item}, ${tg.paginate.row_count} records</span>
    </td>
  </tr>
  <tr py:if="columns">
    <th py:for="i, col in enumerate(columns)" class="col_${i}" py:attrs="col.options">
      <a py:strip="not getattr(
          tg, 'paginate', False) or not col.get_option('sortable', False)"
        href="${tg.paginate.get_href(1, col.getter.__dict__.get(
          'name', col.name), col.get_option('reverse_order', False))}"
        py:content="col.title"/>
    </th>
  </tr>
</thead>
<tbody>
  <tr py:for="i, row in enumerate(value)" class="${i%2 and 'odd' or 'even'}">
    <td py:for="col in columns" py:attrs="col.options" 
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
        <span>${tg.paginate.first_item} - ${tg.paginate.last_item}, ${tg.paginate.row_count} records</span>
    </td>
  </tr>
</tbody>
</table>
