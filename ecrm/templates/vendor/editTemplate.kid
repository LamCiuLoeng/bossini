<form xmlns:py="http://purl.org/kid/ns#"
        name="${name}"
        action="${action}"
        method="${method}"
        class="tableform"
        py:attrs="form_attrs"
    >
        <div py:for="field in hidden_fields"
            py:replace="field.display(value_for(field), **params_for(field))"
        />

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
        <div>
            <div class="case-list-one" py:for="group in groups" py:attrs="table_attrs">
                <ul py:for="field in group">
                    <li class="label">
                    <label for="${field.field_id}" py:content="field.label" py:attrs="{'class':'required' if hasattr(field,'isRequired') else ''}"/>
                    </li>
                    <li>
                    <span py:replace="field.display(value_for(field), **params_for(field))" />
                    </li>
                </ul>
            </div>
        </div>
</form>