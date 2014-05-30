import turbogears as tg
from cherrypy import request, response
from turbogears import controllers, expose, flash,redirect,paginate
from turbogears import widgets
from ecrm.model import *
from ecrm.widgets.Widget import *
from ecrm.util.common import *
from kid import Element
from sqlobject.main import SQLObjectIntegrityError
from ecrm.util.common import *
from sqlobject.sqlbuilder import *

LIKE.op = "ILIKE"

__all__ = ["RegionController"]


class HardlineList(widgets.WidgetsList):
    name = RPACRequiredTextField(label = "Region",attrs = {"class" : "v_not_empty","style" : "width:250px;"})
    email_address = RPACRequiredTextField(label = "E-mail address",attrs = {"class" : "v_not_empty","style" : "width:250px;"})
    description = widgets.TextArea(label = "Description" , cols = 20)
    departmentFlag = widgets.HiddenField()

hForm =  widgets.TableForm(template="ecrm.templates.common.FormTemplate",fields=HardlineList())
hForm.member_widgets = ["fields", "hidden_fields","column_num"]

class SoftlineList(widgets.WidgetsList):
    name = RPACRequiredTextField(label = "Region",attrs = {"class" : "v_not_empty","style" : "width:250px;"})
#    email_address = widgets.TextField(label = "E-mail address",attrs = {"style" : "width:250px;"})
    description = widgets.TextArea(label = "Description" , cols = 20)
    departmentFlag = widgets.HiddenField()

sForm = widgets.TableForm(template="ecrm.templates.common.FormTemplate",fields=SoftlineList())
sForm.member_widgets = ["fields", "hidden_fields","column_num"]


class BothList(widgets.WidgetsList):
    name = RPACRequiredTextField(label = "Region",attrs = {"class" : "v_not_empty","style" : "width:250px;"})
    email_address = widgets.TextField(label = "E-mail address",attrs = {"style" : "width:250px;"})
    departmentFlag = widgets.RadioButtonList(label="For Department",options=[(1,"Hardline"),(2,"Softline")],template=RPACRadioButtonListTemplate)
    description = widgets.TextArea(label = "Description" , cols = 20)

bForm = widgets.TableForm(template="ecrm.templates.common.FormTemplate",fields=BothList())
bForm.member_widgets = ["fields", "hidden_fields","column_num"]

class RegionSearchList(widgets.WidgetsList):
    name = widgets.SingleSelectField(label = "Region" ,options = search_option(KsRegion))

searchForm = widgets.TableForm(template="ecrm.templates.common.FormTemplate",fields=RegionSearchList())
searchForm.member_widgets = ["fields", "hidden_fields","column_num"]





class RegionController(controllers.Controller, identity.SecureResource):

    require = identity.not_anonymous()

    @expose(template="ecrm.templates.common.index")
    @paginate('items',limit=25)
    @tabFocus(tab_type="master")
    def index(self,**kw):
        whereClause = AND(KsRegion.q.id > 0 )
        if not "Admin" in identity.current.groups:
            whereClause = whereClause & (KsRegion.q.status == 0)

        if kw and kw.get("name",False):
            whereClause = whereClause & (KsRegion.q.id==kw["name"].strip())

        result = KsRegion.select(whereClause,orderBy=[KsRegion.q.name,] )

        def makeEditLink(obj):
            link = Element('a',href='update/%d' % obj.id)
            link.text = obj.name
            return link

#        def dep(obj):
#            if obj.departmentFlag == 1 : return "Hardline"
#            elif obj.departmentFlag == 2 : return "Softline"
#            return ""

        plsr_fields = [("Name",makeEditLink), ("Description","description")]
        return dict(
                    items = result,
                    result_widget=widgets.PaginateDataGrid(fields=plsr_fields,template = "ecrm.templates.common.PaginateDataGrid"),
                    search_widget=searchForm,
                    submit_action="/region/index",
                    function_url = "region",
                    column_num = 1
                    )

    @expose(template="ecrm.templates.common.form")
    @tabFocus(tab_type="master")
    def add(self, *args, **kw):
        values = {}
        if identity.has_all_permissions("RTRACK_MASTER","RTRACK_SOFTLINE_MASTER"):
            form = bForm
        elif identity.has_permission("RTRACK_MASTER"):
            form = hForm
            values["departmentFlag"] = "1"
        elif identity.has_permission("RTRACK_SOFTLINE_MASTER"):
            form = sForm
            values["departmentFlag"] = "2"

        return dict(
                    form=form,
                    values=values,
                    action="/region/save/0",
                    function_url = "region",
                    column_num = 1,
                    disabled_fields = ["createTime","lastModifyTime","issuedBy"]
                    )

    @expose(template="ecrm.templates.common.form")
    @tabFocus(tab_type="master")
    def update(self, *args, **kw):
        try:
            p = KsRegion.get(args[0])
        except:
            flash("The record doesn't exist!")
            raise redirect("/region/index")

        values = { "name" : p.name , "description" : p.description ,"email_address" : p.email_address }
        if identity.has_all_permissions("RTRACK_MASTER","RTRACK_SOFTLINE_MASTER"):
            form = bForm
            values["departmentFlag"] = p.departmentFlag
        elif identity.has_permission("RTRACK_MASTER"):
            form = hForm
            values["departmentFlag"] = "1"
        elif identity.has_permission("RTRACK_SOFTLINE_MASTER"):
            form = sForm
            values["departmentFlag"] = "2"

        return dict(
                    form=form,
                    values=values,
                    action="/region/save/%s" %args[0],
                    function_url = "region",
                    column_num = 1,
                    record_id = args[0],
                    disabled_fields = ["createTime","lastModifyTime","issuedBy"]
                    )


    @expose()
    def delete(self, *args):
        try:
            p = KsRegion.get(args[0])
        except:
            flash("The record doesn't exist!")
            raise redirect("/region/index")

        p.set( status = 1 )
        flash("Delete the item (%d) sucessfully!" % p.id )
        raise redirect("/region/index")

    @expose()
    def save(self,*args,**kw):
        try:
            p = KsRegion.get(args[0])
            ref = p.histroty
            if kw.has_key("updatedFields") and kw["updatedFields"]:
                updatedFields = kw["updatedFields"].split("|")
                actionContent = ",".join(["change %s's value from %s to %s" %(field,getattr(p,field),kw[field])  for field in updatedFields])
                history = updateHistory(actionUser = identity.current.user,actionKind = "Modify",actionContent = actionContent)
                ref = "%s|%s" %(history.id,ref)

            p.set( name = kw["name"].strip() ,
                   email_address = kw.get("email_address",None),
                   description = kw["description"].strip() ,
                   departmentFlag = int(kw["departmentFlag"]) if kw.has_key("departmentFlag") else None,
                   lastModifyTime = datetime.now(),
                   issuedBy = identity.current.user,
                   histroty = ref,
                   lastModifyBy = identity.current.user
                )
            flash("The master has been saved succefully!")
        except SQLObjectNotFound:
            name = kw["name"].strip()
            departmentFlag = int(kw["departmentFlag"]) if kw.has_key("departmentFlag") else None
            if KsRegion.select( LIKE(KsRegion.q.name,name) & (KsRegion.q.status==0) & (KsRegion.q.departmentFlag==departmentFlag) ).count() > 0:
                flash("The master [%s] is already exist!" %name)
                raise redirect("/region/index")
            history = updateHistory(actionUser = identity.current.user,actionKind = "Create",actionContent = "")
            p = KsRegion(name = name,
                                    email_address = kw.get("email_address",None),
                                    description = kw["description"],
                                    departmentFlag = int(kw["departmentFlag"]) if kw.has_key("departmentFlag") else None,
                                    lastModifyTime = datetime.now(),
                                    issuedBy = identity.current.user,
                                    histroty = str(history.id),
                                    lastModifyBy = identity.current.user
                                    )
            flash("The master has been saved succefully!")
        raise redirect("/region/index")

    @expose(template="ecrm.templates.common.history")
    @tabFocus(tab_type="master")
    def history(self, id):
        try:
            p = KsRegion.get(id)
            values = {
                      "name":p.name,
                      "description":p.description,
                      }

            histroty = p.histroty.split("|")
            result = [updateHistory.get(hid)  for hid in histroty if hid]

            plsr_fields = [("Time","actionTime"),("User","actionUser"),("Action Kind","actionKind"),
                           ("Content","actionContent")]
            return dict(
                        form=PlsReview_form,
                        action="",
                        values=values,
                        column_num = 3,
                        disabled_fields = ["bSave","bReset"],
                        result_widget=widgets.PaginateDataGrid(fields=plsr_fields),
                        items = result,
                        function_url = "region",
                        record_id = id,
                        )
        except SQLObjectNotFound:
            pass






