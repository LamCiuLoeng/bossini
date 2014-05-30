from turbogears import widgets
from turbogears.widgets import Form
from ecrm.model import *
from turbogears.widgets.base import CoreWD
from turbogears.widgets.forms import Form,TextField,HiddenField,SingleSelectField
from turbogears import validators, expose
import operator

class RPACCalendarDatePicker(TextField):
    field_class = "datePicker v_is_date"
    attrs = { "style" : "width:250px;"}

class SearchWidgetFields(widgets.WidgetsList):
    poNo = widgets.TextField(label = "PO NO",attrs = { "style" : "width:250px;"})
    hangTag = widgets.TextField(label = "Hang Tag",attrs = { "style" : "width:250px;"})
    styleNo = widgets.TextField(label = "Style No",attrs = { "style" : "width:250px;"})
    manufacture = widgets.TextField(label = "Vendor",attrs = { "style" : "width:250px;"})
    poDateBegin = RPACCalendarDatePicker(label = "Edi Date Begin")
    poDateEnd = RPACCalendarDatePicker(label = "Edi Date End")
    soNo = widgets.TextField(label="SO NO",attrs = {"style":"width:250px;"})
    options_list = [('','Please Select Latest PO'),
                    ('C','To Be Cancel'),
                    ('R','To Be Revise'),
                    ('D','RePrint Version'),
                    ('P','Pending Update'),
                    ('Missing','Missing PO'),
                    ('A','All PO'),
                    ]

    status = widgets.SingleSelectField(label = "PO Status" ,options = options_list,attrs = { "style" : "width:200px;"})

class SearchWidgetFields_User(widgets.WidgetsList):
    poNo = widgets.TextField(label = "PO NO",attrs = { "style" : "width:250px;"})
    hangTag = widgets.TextField(label = "Hang Tag",attrs = { "style" : "width:250px;"})
    styleNo = widgets.TextField(label = "Style No",attrs = { "style" : "width:250px;"})
    manufacture = widgets.TextField(label = "Vendor",attrs = { "style" : "width:250px;"})
    poDateBegin = RPACCalendarDatePicker(label = "Edi Date Begin")
    poDateEnd = RPACCalendarDatePicker(label = "Edi Date End")
    soNo = widgets.TextField(label="SO NO",attrs = {"style":"width:250px;"})
    options_list = [('','Please Select Latest PO'),
                    ('C','To Be Cancel'),
                    ('R','To Be Revise'),
                    ('D','RePrint Version'),
                    ('P','Pending Update'),
                    ('Missing','Missing PO'),
                    ]
    status = widgets.SingleSelectField(label = "PO Status" ,options = options_list,attrs = { "style" : "width:200px;"})

class RegionSearchWidgetFields(widgets.WidgetsList):
    poNo = widgets.TextField(label = "PO NO",attrs = { "style" : "width:250px;"})

SearchWidget_form = widgets.TableForm(template="ecrm.templates.common.FormTemplate",fields=SearchWidgetFields())
SearchWidget_form_user = widgets.TableForm(template="ecrm.templates.common.FormTemplate",fields=SearchWidgetFields_User())
RegionSearchWidget_form = widgets.TableForm(template="ecrm.templates.common.FormTemplate",fields=RegionSearchWidgetFields())
