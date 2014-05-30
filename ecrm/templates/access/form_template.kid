<form xmlns:py="http://purl.org/kid/ns#"
        name="${name}"
        action="${action}"
        method="${method}"
        class="tableform"
        py:attrs="form_attrs"
    >


    <?python
        from turbogears.widgets.forms import *
    ?>

        <div py:for="field in hidden_fields"
            py:replace="field.display(value_for(field), **params_for(field))"
        />
        <div class="case-list-one">
            <div class="case-list">
                <ul py:for="field in fields" py:if="not isinstance(field,Button)">               
                        <li class="label">
                        <label class="fieldlabel" for="${field.field_id}" py:content="field.label" />
                        </li>
                        <li>
                        <span py:replace="field.display(value_for(field), **params_for(field))" />
                        </li>
                </ul>
            </div>
        </div>
        <div class="case-list-one">
            <div class="case-list">
            
	            <div py:for="field in fields" py:if="isinstance(field,Button)" py:strip="">
	            	<span py:replace="field.display(value_for(field), **params_for(field))" />
	            </div>
            
            </div>
        </div>   
        
        <div style="clear:both"><br /></div>
</form>