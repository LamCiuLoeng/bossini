from turbogears import widgets
from turbogears.widgets import Form
from ecrm.model import *
from turbogears.widgets.forms import Form,TextField
from turbogears import validators, expose


def search_group_options():
    return [("","")] + [(g.id,g.group_name) for g in Group.select(orderBy=[Group.q.group_name])]

def search_permissions_options():
    return [("","")] + [(p.id,p.permission_name) for p in Permission.select(orderBy=[Permission.q.permission_name])]

class AccessSearchFields(widgets.WidgetsList):
    user_name = widgets.TextField(label = "User name",attrs = { "style" : "width:250px;"})
    email_address = widgets.TextField(label = "E-mail",attrs = { "style" : "width:250px;"})
    groups = widgets.SingleSelectField(options = search_group_options,label = "Group")
    permissions = widgets.SingleSelectField(options = search_permissions_options,label = "Permission")


class AccessAddFields(widgets.WidgetsList):
    user_name = widgets.TextField(label = "User name",attrs = { "style" : "width:250px;"})
    display_name = widgets.TextField(label = "Display name",attrs = { "style" : "width:250px;"})
    password = widgets.TextField(label = "Password",attrs = { "style" : "width:250px;"})
    email_address = widgets.TextField(label = "E-mail",attrs = { "style" : "width:250px;"})
    submit = widgets.SubmitButton(default="Save User")
    reset = widgets.ResetButton(default="Reset")


class AccessGroupFields(widgets.WidgetsList):
    group_name = widgets.TextField(label = "Group name",attrs = { "style" : "width:250px;"})
    submit = widgets.SubmitButton(default="Save Group")
    reset = widgets.ResetButton(default="Reset")
    
class AccessPermissionFields(widgets.WidgetsList):
    permission_name = widgets.TextField(label = "Permission Name",attrs = { "style" : "width:250px;"})
    description = widgets.TextArea(label = "Permission description",cols = 30 , rows = 2)
    submit = widgets.SubmitButton(default="Save Permission")
    reset = widgets.ResetButton(default="Reset")

AccessSearch_form = widgets.TableForm(template="ecrm.templates.access.form_template_search",fields=AccessSearchFields(),attr={"id":"DataTable"},name="DataTable")

AccessAdd_form = widgets.TableForm(template="ecrm.templates.access.form_template",fields=AccessAddFields(),attr={"id":"DataTable"},name="userForm")

AccessRevise_form = widgets.TableForm(template="ecrm.templates.access.revise_template",fields=AccessAddFields(),attr={"id":"DataTable"},name="DataTable")

AccessAddGroup_form = widgets.TableForm(template="ecrm.templates.access.form_template",fields=AccessGroupFields(),attr={"id":"DataTable"},name="groupForm")

AccessAddPermission_form = widgets.TableForm(template="ecrm.templates.access.form_template",fields=AccessPermissionFields(),attr={"id":"DataTable"},name="permissionForm")