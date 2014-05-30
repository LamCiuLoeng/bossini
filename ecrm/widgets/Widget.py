from turbogears import widgets
from turbogears.widgets import Form
from ecrm.model import *
from turbogears.widgets.base import CoreWD
from turbogears.widgets.forms import Form,TextField,HiddenField,RadioButtonList,SingleSelectField
from turbogears import validators, expose
import operator

DATE_FORMAT = "%Y-%m-%d"
CalendarDatePicker_TEMPLATE = "ecrm.widgets.CalendarDatePicker"


RPACRadioButtonListTemplate = """
        <span py:for="value, desc, attrs in options" py:strip="" xmlns:py="http://purl.org/kid/ns#">
            <input type="radio" name="${name}"  id="${field_id}_${value}"  value="${value}"  py:attrs="attrs" />
            <label for="${field_id}_${value}" py:content="desc" />
            &nbsp;&nbsp;
        </span>
    """

class RPACCalendarDatePicker(TextField):
    field_class = "datePicker v_is_date"
    attrs = { "style" : "width:250px;"}


class RPACRequiredMixin():
    params = ["attrs","isRequired"]

class RPACRequiredTextField(RPACRequiredMixin,TextField):
    pass

class RPACRequiredSingleSelectField(RPACRequiredMixin,SingleSelectField):
    pass



# to solove the problem for the <select> in the widgets.
sc = selectConvert()


################################################################################


class HistoryFields(widgets.WidgetsList):
    actionTime = widgets.TextField()
    actionUser = widgets.TextField()
    actionKind = widgets.TextField()
    actionContent = widgets.TextField()


def search_option(dbObj):
    def fun():
        return [("","")] + [(v.id,v.name) for v in dbObj.select(orderBy="name") if v.status==0]
    return fun