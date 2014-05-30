import turbogears as tg
from turbogears import controllers, expose, flash
from turbogears import identity, redirect
from cherrypy import request, response
from ecrm import model
import logging
from ecrm.util.common import *
from subcontrollers.Account import *
from subcontrollers.KohlsPO import *
from subcontrollers.BossiniPO import *
from subcontrollers.Polartec import *
from subcontrollers.Vendor import *
from subcontrollers.Region import *
#add by cz@2010-10-22
from subcontrollers.Disney import *

# from ecrm import json
log = logging.getLogger("ecrm.controllers")

class Root(controllers.RootController):
    #-------------- CLASS ATTRIBUTE-------------------
   # plsr = PLSRegionController()
    account = AccountController()
    kohlspo = KohlsPOController()
#    bossinipo = BossiniPOController()
    polartec = PolartecController()
    vendor = VendorController()
    region = RegionController()
    #add by cz@2010-10-22
    disney = DisneyController()
    #-------------  CLASS FUNCTION ------------------

    @expose(template = "ecrm.templates.page_main")
    @identity.require(identity.not_anonymous())
    @tabFocus(tab_type = "main")
    def index(self, **kw):
        return {}

    @expose(template = "ecrm.templates.page_master")
    @identity.require(identity.not_anonymous())
    @tabFocus(tab_type = "master")
    def master(self):
        return {}

    @expose(template = "ecrm.templates.page_report")
    @identity.require(identity.not_anonymous())
    #@identity.require(identity.in_any_group("Admin","KOHLS_TEAM"))
    @tabFocus(tab_type = "report")
    def report(self):
        return {}

    @expose(template = "ecrm.templates.page_access")
    @identity.require(identity.not_anonymous())
    @tabFocus(tab_type = "access")
    def access(self):
        return {}

    @expose(template = "ecrm.templates.login")
    def login(self, forward_url = None, previous_url = None, *args, **kw):

        if not identity.current.anonymous and identity.was_login_attempted() \
                and not identity.get_identity_errors():
            redirect(tg.url(forward_url or previous_url or '/', kw))

#        forward_url = None
#        previous_url = '/'

        if identity.was_login_attempted():
            msg = _("The credentials you supplied were not correct or "
                   "did not grant access to this resource.")
        elif identity.get_identity_errors():
            msg = _("You must provide your credentials before accessing "
                   "this resource.")
        else:
            msg = _("Please log in.")
            forward_url = request.headers.get("Referer", "/")

        response.status = 403
        return dict(message = msg, previous_url = previous_url, logging_in = True,
            original_parameters = request.params, forward_url = forward_url)

    @expose()
    def logout(self):
        identity.current.logout()
        redirect("/")
