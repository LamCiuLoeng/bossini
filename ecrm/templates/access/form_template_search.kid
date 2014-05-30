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
            column_num = 2
            from turbogears.widgets.forms import *
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
                    <label class="fieldlabel" for="${field.field_id}" py:content="field.label" />
                    </li>
                    <!--li>
                    <span py:replace="field.display(value_for(field), **params_for(field))" />
                    </li-->
                    <div py:if="field.name=='region' and 'RTRACK_VIEW_ALL_REGION' not in tg.identity.permissions" py:strip="">
                    	<li py:content="tg.identity.user.getUserRegion()"/>
                    </div>
                    <div py:if="field.name!='region' or 'RTRACK_VIEW_ALL_REGION' in tg.identity.permissions" py:strip="">
                    	<li><span py:replace="field.display(value_for(field), **params_for(field))" /></li>
                    </div>
                </ul>
            </div>
        
        </div>
</form>