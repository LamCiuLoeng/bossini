<div xmlns:py="http://purl.org/kid/ns#">
        <?python
            from turbogears.widgets.forms import *
            
            column_num = 2
            
            groups = [ [] for i in range(column_num) ]
            buttons = []

            index = 0
            for item in fields:
                if isinstance(item,Button):
                    buttons.append(item)
                else:
                    groups[ index % column_num ].append(item)
                    index += 1
        ?>
        <div class="case-list-one" py:for="group in groups" py:attrs="table_attrs">
            <ul py:for="field in group">
                <li class="label">
                <label for="${field.field_id}" py:content="field.label" py:attrs="{'class':'required' if hasattr(field,'isRequired') else ''}"/>
                </li>
                <li><span py:replace="value_for(field)" />&nbsp;</li>
            </ul>
        </div>
    </div>
