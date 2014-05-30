import turbogears as tg
from cherrypy import request, response
from turbogears import controllers, expose, flash,redirect,paginate,widgets
from ecrm.model import *
from ecrm.widgets.Widget_access import *
from ecrm.util.common import *
from kid import Element
from sqlobject.sqlbuilder import *

import traceback

class AccountController(controllers.Controller,identity.SecureResource):
    require = identity.in_any_group('Admin')

    @expose(template="ecrm.templates.access.index")
    @paginate('items',limit=50)
    @tabFocus(tab_type="access")
    def index(self,**kw):
        if not kw:
            result = []
        else:
            whereClause = AND(User.q.id > 0 )
            if kw.get("user_name",False):
                whereClause = whereClause & LIKE(User.q.user_name ,"%%%s%%" % kw["user_name"])

            if kw.get("email_address",False):
                whereClause = whereClause & LIKE(User.q.email_address ,"%%%s%%" % kw["email_address"])

            result = User.select( whereClause,orderBy=[User.q.user_name] )

            if kw.get("groups",False):
                g = Group.get(kw["groups"])
                result = [u  for u in result if g in u.groups]
            if kw.get("permissions",False):
                p = Permission.get(kw["permissions"])
                result = [u for u in result if p in u.permissions]

        def makeReviewLink(u):
            link = Element('a',href='/account/updateUser/%d' % u.id,attrib={"class":"link-text"})
            link.text = str(u)
            return link

        AccessSearchFields = [("User Name",makeReviewLink),
                              ("E-mail","email_address"),("Group",lambda u:u.show_groups),("Permission",lambda u:u.show_permissions)
                              ]

        return dict(
                    items = result,
                    result_widget=widgets.PaginateDataGrid(fields=AccessSearchFields,template = "ecrm.templates.common.paginate"),
                    search_widget=AccessSearch_form,
                    submit_action="index",
                    values = kw
                    )


    @expose(template="ecrm.templates.access.new")
    @tabFocus(tab_type="access")
    def add(self,**kw):
        return dict(
                userWidget = AccessAdd_form,
                groupWidget = AccessAddGroup_form,
                permissionWidget = AccessAddPermission_form,
                )

    @expose()
    def saveNewUser(self,**kw):
        us = User.select(User.q.user_name==kw["user_name"])
        if us.count() > 0:
            flash("[Warning]The user with the same name has been existed!")
            raise redirect("/account/add")
        u = User(user_name=kw["user_name"],password=kw["password"],display_name=kw["display_name"],email_address=kw["email_address"])
        flash("The user has been created successfully!")
        raise redirect("/account/updateUser/%s" %u.id)

    @expose()
    def saveNewGroup(self,**kw):
        gn = kw["group_name"]
        gs = Group.select(Group.q.group_name==kw["group_name"])
        if gs.count() > 0:
            flash("[Warning]The group with the same name has been existed!")
            raise redirect("add")

        g = Group(group_name=gn)
        flash("The group has been created successfully!")
        raise redirect("/account/updateGroup/%s" %g.id)

    @expose()
    def saveNewPermission(self,**kw):
        pn = kw["permission_name"]
        ps = Permission.select(Permission.q.permission_name==kw["permission_name"])
        if ps.count() > 0:
            flash("[Warning]The permission with the same name has been existed!")
            raise redirect("add")

        p = Permission(permission_name=pn,description=kw["description"])
        adgs = Group.select(Group.q.group_name=="Admin")
        #add the new Permission to each one in the 'Admin' group
        if adgs.count() > 0:
            adgs[0].addPermission(p)
        flash("The permission has been created successfully!")
        raise redirect("/account/updatePermission/%s" %p.id)


    #--------------------------new-------------------------

    @expose("ecrm.templates.access.updateug")
    @tabFocus(tab_type="access")
    def updateUser(self,id,**kw):
        try:
            u = User.get(id)
        except:
            traceback.print_exc()
            flash("The user doesn't exist!")
            raise redirect("/account/index")

        iG = sorted(u.groups,key=operator.attrgetter("group_name"))
        oG = sorted([g for g in Group.select() if u not in g.users],key=operator.attrgetter("group_name"))
        return dict(user=u,inGroup=iG,outGroup=oG)


    @expose()
    def saveUser(self,**kw):
        try:
            u = User.get(kw["uid"])
        except:
            traceback.print_exc()
            flash("The user doesn't exist!")
            raise redirect("/account/index")

        try:
            params = {}
            if kw.get("display_name",None) : params["display_name"] = kw["display_name"]
            if kw.get("password",None) : params["password"] = kw["password"]
            if kw.get("email_address",None) : params["email_address"] = kw["email_address"]
            #if kw.get("phone",None) : params["phone"] = kw["phone"]
            #if kw.get("fax",None) : params["fax"] = kw["fax"]
            u.set(**params)

            if kw.get("igs",None):
                for gid in kw["igs"].split("|"):
                    g = Group.get(gid)
                    if u not in g.users : g.addUser(u)

            if kw.get("ogs",None):
                for gid in kw["ogs"].split("|"):
                    g = Group.get(gid)
                    if u in g.users : g.removeUser(u)

        except:
            traceback.print_exc()
            flash("Error occur on the server side!")
            raise redirect("/account/index")

        flash("Update successfully!")
        raise redirect("/account/index")


    @expose("ecrm.templates.access.updatepg")
    @tabFocus(tab_type="access")
    def updatePermission(self,id,**kw):
        try:
            p = Permission.get(id)
        except:
            traceback.print_exc()
            flash("The permission doesn't exist!")
            raise redirect("/account/index")

        iG = sorted(p.groups,key=operator.attrgetter("group_name"))
        oG = sorted([g for g in Group.select() if p not in g.permissions],key=operator.attrgetter("group_name"))
        return dict(permission=p,inGroup=iG,outGroup=oG)


    @expose()
    def savePermission(self,**kw):
        try:
            p = Permission.get(kw["pid"])
        except:
            traceback.print_exc()
            flash("The permission doesn't exist!")
            raise redirect("/account/index")

        try:
            if kw.get("igs",None):
                for gid in kw["igs"].split("|"):
                    g = Group.get(gid)
                    if p not in g.permissions : g.addPermission(p)

            if kw.get("ogs",None):
                for gid in kw["ogs"].split("|"):
                    g = Group.get(gid)
                    if p in g.permissions : g.removePermission(p)
        except:
            traceback.print_exc()
            flash("Error occur on the server side!")
            raise redirect("/account/index")

        flash("Update successfully!")
        raise redirect("/account/index")


    @expose("ecrm.templates.access.updateg")
    @tabFocus(tab_type="access")
    def updateGroup(self,id,**kw):
        try:
            g = Group.get(id)
        except:
            traceback.print_exc()
            flash("The group doesn't exist!")
            raise redirect("/account/index")

        uiG = sorted(g.users,key=operator.attrgetter("user_name"))
        uoG = sorted([u for u in User.select() if u not in uiG],key=operator.attrgetter("user_name"))

        piG = sorted(g.permissions,key=operator.attrgetter("permission_name"))
        poG = sorted([p for p in Permission.select() if p not in piG],key=operator.attrgetter("permission_name"))

        #add by Ray July 9 2010
        region = KsRegion.select(orderBy=[KsRegion.q.name])
        rs = [("","",g.region in region)]
        for r in region:
            rs.append((r.id,r.name,r==g.region))
        return dict(group=g,userInGroup=uiG,userOutGroup=uoG,permissionInGroup=piG,permissionOutGroup=poG,regions=rs)


    @expose()
    def saveGroup(self,**kw):
        try:
            g = Group.get(kw["gid"])
        except:
            traceback.print_exc()
            flash("The group doesn't exist!")
            raise redirect("/account/index")

        try:
            if kw.get("uigs",None):
                for uid in kw["uigs"].split("|"):
                    u = User.get(uid)
                    if u not in g.users : g.addUser(u)

            if kw.get("uogs",None):
                for uid in kw["uogs"].split("|"):
                    u = User.get(uid)
                    if u in g.users : g.removeUser(u)

            if kw.get("pigs",None):
                for pid in kw["pigs"].split("|"):
                    p = Permission.get(pid)
                    if p not in g.permissions : g.addPermission(p)

            if kw.get("pogs",None):
                for pid in kw["pogs"].split("|"):
                    p = Permission.get(pid)
                    if p in g.permissions : g.removePermission(p)

            if kw.get("region",None):
                g.region = KsRegion.get(kw["region"])
            else:
                g.region = None
        except:
            traceback.print_exc()
            flash("Error occur on the server side!")
            raise redirect("/account/index")

        flash("Update successfully!")
        raise redirect("/account/index")


