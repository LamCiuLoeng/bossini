from turbogears import widgets, identity
from turbogears.widgets import Form
from ecrm.model import *
from turbogears.widgets.base import CoreWD
from turbogears.widgets.forms import Form, TextField, HiddenField, SingleSelectField
from turbogears import validators, expose
import operator

from ecrm.widgets.Widget import sc

def marketListOptions():
    options = ['', 'CHN', 'EXP', 'HKM', 'MYS', 'SIN', 'TWN']
    return options

def vendorOptions():
    options = Vendor.select(Vendor.q.active == 1, orderBy = [Vendor.q.vendorCode])
    return ['', ] + [o.vendorCode for o in options]


def vendorOptionByID():
    options = Vendor.select(Vendor.q.active == 1, orderBy = [Vendor.q.vendorCode])
    return [("", ""), ] + [(option.id, option.vendorCode) for option in options]



class RPACCalendarDatePicker(TextField):
    field_class = "datePicker v_is_date"
    attrs = { "style" : "width:250px;"}

class SearchWidgetFields(widgets.WidgetsList):
    poNo = widgets.TextField(label = "PO NO", attrs = { "style" : "width:250px;", "class":"ajaxSearchField", "fieldName":"po_no"})
    legacyCode = widgets.TextField(label = "Legacy Code", attrs = { "style" : "width:250px;", "class":"ajaxSearchField", "fieldName":"legacy_code"})
    marketList = widgets.SingleSelectField(label = "Market List" , options = marketListOptions, attrs = { "style" : "width:250px;"})
    hangTagType = widgets.SingleSelectField(label = "Hang Tag Type" , options = [('', ''), ('H', "H    (Hang Tag)"), ('W', "W    (Waist Card)"), ('ST', "ST    (Stickers)")], attrs = { "style" : "width:250px;"})
#    styleNo = widgets.TextField(label = "Style Code",attrs = { "style" : "width:250px;","class":"ajaxSearchField","fieldName":"style_no"})
    poDateBegin = RPACCalendarDatePicker(label = "In-Store Date Begin")
    poDateEnd = RPACCalendarDatePicker(label = "In-Store Date End")
    importDateBegin = RPACCalendarDatePicker(label = "Import Date Begin")
    importDateEnd = RPACCalendarDatePicker(label = "Import Date End")
    collection = widgets.SingleSelectField(label = "Collection" , options = ["", "LEISURE", "CASUAL", "SPORTS"], attrs = { "style" : "width:250px;"})
#    orderStatus = widgets.SingleSelectField(label="Order Status",options = ["","New","Submit","Confirm"],attrs = {"style":"width:250px;"})

class SearchWidgetFields_Vendor(widgets.WidgetsList):
    poNo = widgets.TextField(label = "PO NO", attrs = { "style" : "width:250px;", "class":"ajaxSearchField", "fieldName":"po_no"})
    legacyCode = widgets.TextField(label = "Legacy Code", attrs = { "style" : "width:250px;", "class":"ajaxSearchField", "fieldName":"legacy_code"})
    marketList = widgets.SingleSelectField(label = "Market List" , options = marketListOptions, attrs = { "style" : "width:250px;"})
    hangTagType = widgets.SingleSelectField(label = "Hang Tag Type" , options = [('', ''), ('H', "H    (Hang Tag)"), ('W', "W    (Waist Card)")], attrs = { "style" : "width:250px;"})
    #orderStatus = widgets.SingleSelectField(label="Order Status",options = ["","New","Submit","Confirm"],attrs = {"style":"width:250px;"})


class SearchWidgetFields_User(widgets.WidgetsList):
    poNo = widgets.TextField(label = "PO NO", attrs = { "style" : "width:250px;"})
    hangTag = widgets.TextField(label = "Hang Tag", attrs = { "style" : "width:250px;"})
    styleNo = widgets.TextField(label = "Style No", attrs = { "style" : "width:250px;"})
    manufacture = widgets.TextField(label = "Vendor", attrs = { "style" : "width:250px;"})
    poDateBegin = RPACCalendarDatePicker(label = "Edi Date Begin")
    poDateEnd = RPACCalendarDatePicker(label = "Edi Date End")
    soNo = widgets.TextField(label = "SO NO", attrs = {"style":"width:250px;"})
    options_list = [('', 'Please Select Latest PO'),
                    ('C', 'To Be Cancel'),
                    ('R', 'To Be Revise'),
                    ('D', 'RePrint Version'),
                    ('P', 'Pending Update'),
                    ('Missing', 'Missing PO'),
                    ]
    status = widgets.SingleSelectField(label = "PO Status" , options = options_list, attrs = { "style" : "width:200px;"})


SearchWidget_form_user = widgets.TableForm(template = "ecrm.templates.common.FormTemplate", fields = SearchWidgetFields_User())

def CustomSearchWidget_form(vendor):
    if vendor == 'admin':
        vendorCode = widgets.SingleSelectField("vendorCode", label = "Vendor Code", options = vendorOptions, attrs = { "style" : "width:250px;"})
        SearchWidget_form = widgets.TableForm(template = "ecrm.templates.common.FormTemplate", fields = SearchWidgetFields(vendorCode))
    else:
        vendorCode = widgets.HiddenField("vendorCode", default = vendor)
        SearchWidget_form = widgets.TableForm(template = "ecrm.templates.common.FormTemplate", fields = SearchWidgetFields_Vendor(vendorCode))
        #vendorCode = widgets.SingleSelectField("vendorCode",label="Vendor Code",options = [vendor],attrs = { "style" : "width:250px;"})

    return SearchWidget_form

class AESearchWidgetFields_Vendor(widgets.WidgetsList):
    orderType = widgets.SingleSelectField(label = "Order Type" ,
                                            options = [('', ''), ('H', "Hang Tag"), ('WOV', "Woven Label"), ("F", "Function Card"),
                                                       ("C", "Care Label"), ("CO", "Country of Origin"), ("S", "Style Printed Label"),
                                                       ("D", "Down Jacket Care Label"), ("BW", "Bodywear"), ("ST", "Sticker")],
                                            attrs = { "style" : "width:250px;"})
    vendorCode = widgets.SingleSelectField("vendorCode", label = "Vendor Code", options = vendorOptionByID, validator = sc, attrs = { "style" : "width:250px;"})
    marketList = widgets.SingleSelectField(label = "Market List" , options = marketListOptions, attrs = { "style" : "width:250px;"})
    iscomplete = widgets.SingleSelectField(label = "Status" , options = [("", ""), ('1', "Confirmed"), ('0', "Pending")], attrs = { "style" : "width:250px;"})
    confirmDateBegin = RPACCalendarDatePicker(label = "Confirm Date Begin")
    confirmDateEnd = RPACCalendarDatePicker(label = "Confirm Date End")
    poNo = widgets.TextField(label = "PO NO", attrs = { "style" : "width:250px;", "class":"ajaxSearchField", "fieldName":"po_no"})
    legacyCode = widgets.TextField(label = "Legacy Code", attrs = { "style" : "width:250px;", "class":"ajaxSearchField", "fieldName":"legacy_code"})
    customerOrderNo = widgets.TextField(label = "Customer No", attrs = {"style":"width:250px;"})

SearchWidget_form = widgets.TableForm(template = "ecrm.templates.common.FormTemplate", fields = AESearchWidgetFields_Vendor())


class SearchHangType_Vendor(widgets.WidgetsList):
    orderType = widgets.SingleSelectField(label = "Order Type" , options = [('', ''), ('H', "Hang Tag"),
                                                                         ('WOV_M', "Woven Label(Main Label)"),
                                                                         ('WOV', "Woven Label(Size Label)"),
                                                                         ('F', "Formatted Grey Cards,Color Cards & Others"),
                                                                         ('C', "Care Label"), ('S', "Style Printed Label"),
                                                                         ('CO', "Country of Origin"), ('D', "Down Jacket Care Label"),
                                                                         ("BW", "Bodywear"), ("ST", "Sticker")],
                                                                          attrs = { "style" : "width:250px;"})

SearchHangType_form = widgets.TableForm(template = "ecrm.templates.common.FormTemplate", fields = SearchHangType_Vendor())



