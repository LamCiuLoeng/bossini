<div class="case-960" xmlns:py="http://purl.org/kid/ns#">
<?python
    from turbogears.widgets.forms import *
    groups = [ [] for i in range(column_num) ]
    buttons = []
    for i, item in enumerate(fields):
        if isinstance(item,Button):
            buttons.append(item)
        else:
            groups[ i%column_num ].append(item)
?>

    <div class="case-list" py:for="group in groups" py:attrs="table_attrs">
        <ul py:for="field in group">
            <li class="label"><span py:replace="field.label" /></li>

            <li><span py:replace="value_for(field)" />&nbsp;</li>
        </ul>
    </div>


</div>
