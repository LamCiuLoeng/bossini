# -*- coding: utf-8 -*-
import turbogears,math,datetime,logging,os,random,traceback,zipfile,shutil,re
from turbogears import controllers, expose, flash,redirect,paginate,identity,widgets
from cherrypy.lib.cptools import serveFile
from kid import Element
from ecrm.model import *
from ecrm.util.common import *
from ecrm.util.sql_helper import genCondition

class VendorController(controllers.Controller, identity.SecureResource):
    
    #require = identity.not_anonymous()
    require = identity.in_any_group("Admin")
       
    @expose(template="ecrm.templates.vendor.index")
    @paginate('items',limit=20)
    @tabFocus(tab_type="master")
    def index(self,**kw):
        if kw:
#            condition = True
#            conditions =[]
#            conditions.append(" v.active = 1 ")
#            conditions.append(genCondition('v.vendor_code', kw.get("vendorCode","")))
#            conditions.append(genCondition('b.bill_to', kw.get("billTo","")))
#            conditions.append(genCondition('s.ship_to', kw.get("shipTo","")))
#            conditions.append(genCondition('b.address', kw.get("billAddress","")))
#            conditions.append(genCondition('s.address', kw.get("shipAddress","")))
#            conditions.append(genCondition('b.contact', kw.get("billContact","")))
#            conditions.append(genCondition('s.contact', kw.get("shipContact","")))
#            _condition = ' AND '.join([c for c in conditions if c])
#            conn = Vendor._connection
#            sql = """select v.id,v.vendor_code,b.id,b.bill_to,s.id,s.ship_to,b.address,s.address,b.contact,s.contact from bossini_vendor v
#            left join bossini_vendor_billto_info b on b.vendor_id = v.id
#            left join bossini_vendor_shipto_info s on s.bill_to_id = b.id
#            where %s order by v.id,b.id,s.id 
#            """ % (_condition)
#            print sql
#            result = conn.queryAll(sql)

            if kw.get("vendorCode",False) :
                result = Vendor.select(LIKE(Vendor.vendorCode,"%%%s%%" %kw["vendorCode"]))
            else:
                result = Vendor.selectBy(active=1)
            
            
            def makeLink(dto):
                a = Element("a", attrib={"href":"/vendor/review?id=%d" %dto.id})
                a.text = dto.vendorCode
                return a
            
            fields = [("Vendor",makeLink,dict(width='50',height='25',align='center')),
                      ("Vendor Name","vendorName"),
                      ("Description","description"),
                      (u"Feedback E-mail","feedbackEmail"),
                      ("AE E-mail","aeEmail"),
                      ("Create Date","createDate")
                      ]
            return dict(items = result,
                        search_widget= SearchWidget_form,
                        values = kw,
                        submit_action = "/vendor/index",
                        result_widget=widgets.PaginateDataGrid(fields=fields,template = "ecrm.templates.common.paginateDataGrid"))
        else:
            return dict(items = [],
                        search_widget= SearchWidget_form,
                        values = kw,
                        submit_action = "/vendor/index",
                        )
        
    @expose(template="ecrm.templates.vendor.add")
    @tabFocus(tab_type="master")    
    def add(self,**kw):
        return {
                "fields_widget" : MainEdit_form,
                "submit_action" : "/vendor/saveNew",
                "values" : {},
                }

    
    @expose()
    def saveNew(self,**kw):
        if not kw.get("vendorCode",False) : 
            flash("The vendor's name must not be blank!")
            return {
                "tg_template" : "ecrm.templates.vendor.add",
                "fields_widget" : MainEdit_form,
                "submit_action" : "/vendor/saveNew",
                "values" : kw,
                }
        fields = ["vendorCode","vendorName"]
        params = self._getMainValues(kw, None)      
        params["active"] = 1
        v = Vendor(**params)
        #add history
#        history = v.history
#        hisContent = "Add new Vendor %s information in master" % v.vendorCode
#        his = updateHistory(actionUser=identity.current.user,actionKind="Add New Vendor",actionContent=hisContent)
#        v.set(history="%s|" %(his.id) )        
        flash("The new vendor's info has been saved successfully!")
        raise redirect("/vendor/review?id=%d" %v.id)
    
    
    @expose("ecrm.templates.vendor.view")
    @tabFocus(tab_type="master")    
    def review(self,**kw):
        try:

            v = Vendor.get(kw["id"])
            
            def makeCB(dto):
                cb = Element("input", attrib={"type":"checkbox","name":"bill_id","value":str(dto.id) })
                return cb
            
            def IsDefault(dto):
                cb = Element("span", attrib={"name":"isdefault","value":str(dto.flag) })
                cb.text = "Yes" if int(dto.flag)==1 else "No"
                return cb
            result = VendorBillToInfo.select(VendorBillToInfo.q.vendor == v)
            
            
            def makeLink(dto):
                link = Element("a", attrib={"href":"/vendor/address?bill_id=%s&vendor_id=%s" % (dto.id,kw["id"])})
                link.text = dto.id
                return link
            
            
            fields = [("",makeCB),
                      ("Id",makeLink),
                      ("Company Name","billTo",dict(width="200px",limit="20")),                      
                      ("Address","address",dict(width="300px",limit="10")),
                      ("Contact","contact",dict(width='80px',limit='10')),
                      ("Tel","tel",dict(width='100px',limit='10')),
                      ("Fax","fax",dict(width='80px',limit='10')),
                      ("Need VAT","needVAT",dict(width='200px',limit='10')),
                      ("Need Invoice","needInvoice",dict(width='20px',limit='10')),
                      ("Default",IsDefault),
                      ]
            
        except:
            traceback.print_exc()
            flash("The vendor doesn't exist!")
            raise redirect("/vendor/index")
        return {
                "fields_widget" : MainView_form,
                "values" : self._getMainValues(v, ""),
                "obj" : v,
                "vendor_id" : kw["id"],
                "poDetail_widget" : widgets.DataGrid(fields = fields,template = "ecrm.templates.common.dataGrid"),
                "items": result,
                }
        
    
    @expose("ecrm.templates.vendor.re_address")
    @tabFocus(tab_type="master")
    def address(self,**kw):
        try:
            
            def makeCB(dto):
                cb = Element("input", attrib={"type":"checkbox","name":"ship_id","value":str(dto.id) })
                return cb
            
            def IsDefault(dto):
                cb = Element("span", attrib={"name":"isdefault","value":str(dto.flag) })
                cb.text = "Yes" if int(dto.flag)==1 else "No"
                return cb
            result = []
            if kw.get("bill_id","") and kw.get("vendor_id",""):
                v = Vendor.get(kw["vendor_id"])
                b = VendorBillToInfo.get(kw["bill_id"])
                result = VendorShipToInfo.select(VendorShipToInfo.q.billTo == b)
                vendor_id = kw["vendor_id"]
                bill_id = kw["bill_id"]
            else:
                v = Vendor.get(kw["id"])
                b_list = VendorBillToInfo.select(VendorBillToInfo.q.vendorID==kw["id"])
                for b in b_list:
                    result.extend( list(VendorShipToInfo.select(VendorShipToInfo.q.billTo==b)) )
                vendor_id = kw["id"]
                bill_id = None
        
            fields = [("",makeCB),
                      ("Company Name","shipTo",{"width":"200px","limit":"10"}),
                      ("Address","address",{"width":"300px","limit":"10"}),
                      ("Contact","contact",{"width":"80px","limit":"10"}),
                      ("Tel","tel",{"width":"100px","limit":"10"}),
                      ("E-mail","email",{"width":"100px","limit":"10"}),\
                      ("Fax","fax",{"width":"80px","limit":"10"}),
                      ("sampleReceiver","sampleReceiver",{"width":"200px","limit":"10"}),
                      ("sampleSendAddress","sampleSendAddress",{"width":"20px","limit":"10"}),
                      ("IsDefault",IsDefault),
                      ]
        except:
            flash("The vendor doesn't exist!")
            raise redirect("/vendor/index")
        return dict(
            fields_widget = MainEdit_form,
            values = self._getMainValues(v,""),
            obj = v,
            vendor_id = vendor_id,
            poDetail_widget =  widgets.DataGrid(fields = fields,template = "ecrm.templates.common.dataGrid"),
            items = result,
            bill_id = bill_id,
            )
            
    
    @expose("ecrm.templates.vendor.revise")
    @tabFocus(tab_type="master")    
    def revise(self,**kw):
        try:
            v = Vendor.get(kw["id"])
        except:
            flash("The vendor doesn't exist!")
            raise redirect("/vendor/index")
        
        return {
                "fields_widget" : MainEdit_form,
                "submit_action" : "/vendor/saveRevise?id=%d" %v.id,
                "values" : self._getMainValues(v, ""),
                "obj" : v
                }
        
        
    @expose()
    def saveRevise(self,**kw):
        try:
            v = Vendor.get(kw["id"])
        except:
            traceback.print_exc()
            flash("The vendor doesn't exist!")
            raise redirect("/vendor/index")
        
        try:
            params = self._getMainValues(kw,None)
            v.set(**params)
            history = v.history
            hisContent = "Update Vendor %s information" % v.name
            his = updateHistory(actionUser=identity.current.user,actionKind="Update Vendor",actionContent=hisContent)
            v.set(history="%s|%s" %(his.id,history) )    
        except:
            flash("Error occur on the sever the side!")
            raise redirect("/vendor/index")
        else:
            flash("The change has been save successfully!")
            raise redirect("/vendor/review?id=%d" %v.id)

        
    @expose("ecrm.templates.vendor.update_address")
    @tabFocus(tab_type ="master")
    def updateAddress(self,**kw):
        try:
            v = VendorAddressInfo.get(kw['id'])
            
        except:
            traceback.print_exc()
            flash("Vendor hasn't this vendor information!")
            raise redirect("/vendor/index")
        return {
            "obj" : v,
            "vendor_id" : kw["vendor_id"],
            "can_edit" : True,
            
        }

    
    @expose("ecrm.templates.vendor.revised")
    @tabFocus(tab_type ="master")
    def addressRevise(self,**kw):
        
        try:
            v = VendorAddressInfo.get(kw['id'])
        except:
            traceback.print_exc()
            flash("Vendor hasn't this vendor information!")
            raise redirect("/vendor/index")
            
        return {
            "obj" : v,
            "vendor_id": kw["vendor_id"],
            "can_edit" : False,
        }
    
    
    @expose()    
    def saveAddress(self,**kw):
        try:
            params = {}
            fields = ["billTo","address","contact","tel","fax","needVAT","needInvoice","flag"]
            for f in fields : 
                if f == 'flag':
                    params[f] = int(kw.get(f,0))
                else:
                    params[f] = kw.get(f,None)
            
            v = params["vendor"] = Vendor.get(kw["vendor_id"])
            history = v.history
            if "update_type" in kw:
                va = VendorBillToInfo.get(kw["bill_id"])            
                va.set(**params)
                hisContent = "Update Vendor %s Address %s information in master" % (v.vendorCode,va.billTo)
                his = updateHistory(actionUser=identity.current.user,actionKind="Update Vendor Bill To Info",actionContent=hisContent)
                v.set(history="%s|%s" %(his.id,history) ) 
                
            else:
                va = VendorBillToInfo(**params)
                hisContent = "Add Vendor bill TO %s for vendor %s" % (va.billTo,v.vendorCode)
                his = updateHistory(actionUser=identity.current.user,actionKind="Add New Vendor Bill To Info",actionContent=hisContent)
                v.set(history= "%s|%s" %(his.id,history) if history else "%s|" %(his.id))  
        except:
            traceback.print_exc()
        flash("Save the Bill To information successfully!")
        raise redirect("/vendor/review?id=%s" %kw["vendor_id"])  
        
    @expose()
    def saveShipTo(self,**kw):
        params = {}
        fields = ["shipTo","address","contact","tel","fax","email","sampleReceiver","sampleSendAddress","flag"]
        for f in fields:
            if f == 'flag':
                params[f] = int(kw.get(f,0))
            else:
                params[f] = kw.get(f,None)
        if kw.get("bill_id",None):
            params["billTo"] = VendorBillToInfo.get(kw["bill_id"])
            v = Vendor.get(kw["vendor_id"])
            history = v.history
            va = VendorShipToInfo(**params)
            hisContent = "Add Vendor Ship TO %s for vendor %s" % (va.shipTo,v.vendorCode)
            his = updateHistory(actionUser=identity.current.user,actionKind="Add New Vendor Ship To Info",actionContent=hisContent)
            v.set(history= "%s|%s" %(his.id,history) if history else "%s|" %(his.id))
        else:
            flash("Please choice a Bill To at least")
            raise redirect("/vendor/review?id=%s" % kw["vendor_id"])
        flash("Save the Ship To information successfully!")
        raise redirect("/vendor/address?id=%s" %kw["vendor_id"])
    
    @expose()
    def updateShipTo(self,**kw):
        try:
            params = {}
            fields = ["shipTo","address","contact","tel","fax","email","sampleReceiver","sampleSendAddress","flag"]
            for f in fields:
                if f == 'flag':
                    params[f] = int(kw.get(f,0))
                else:
                    params[f] = kw.get(f,None)
            v = Vendor.get(kw["vendor_id"])
            history = v.history
            va = VendorShipToInfo.get(kw["ship_id"])
            va.set(**params)
            hisContent = "update Vendor Ship TO %s for vendor %s" % (va.shipTo,v.vendorCode)
            his = updateHistory(actionUser=identity.current.user,actionKind="Update Vendor Ship To Info",actionContent=hisContent)
            v.set(history= "%s|%s" %(his.id,history) if history else "%s|" %(his.id))
        except:
            flash("Please choice a ship To at least")
            raise redirect("/vendor/review?id=%s" % kw["vendor_id"])
        flash("Update the Ship To information successfully!")
        raise redirect("/vendor/address?id=%s" %kw["vendor_id"])
        
    def _getMainValues(self,obj,default=None):
        objectFields = ["vendorCode","vendorName"]
        values = {}
        
        if type(obj) == dict :
            for f in objectFields : values[f] = obj.get(f,default)
        elif type(obj)== Vendor : 
            for f in objectFields : values[f] = getattr(obj, f,default)
        return values
    
    @expose(template="ecrm.templates.vendor.history")
    @tabFocus(tab_type="master")
    def history(self,**kw):
        try:
            h = Vendor.get(id=kw["id"])
            
        except:
            flash("The record doesn't exist!")
            raise redirect("index")

        if h.history:  result =[updateHistory.get(id=int(i)) for i in h.history.split("|") if i]
        else : result = []
        
        fields = [("Time",lambda args:Date2Text(args.actionTime,FONTEND_DATE_TIME_FORMAT),dict(width="155")),
                    ("User","actionUser",dict(width="100")),("Action Kind","actionKind",dict(width="200")),("Content","actionContent",dict(width="500"))]
        
        return dict(
                    poDetail_widget =  widgets.DataGrid(fields = fields,template = "ecrm.templates.common.dataGrid"),
                    items = result,
                    POHeader = h,
                    can_edit = False,
                    vendor_id = kw["id"],
                    obj = h,
                    )
    def returnBillTo(self):
        rs = Vendor.select()
        billTo_list = []

    @expose(template="ecrm.templates.vendor.revise_bill_to")
    @tabFocus(tab_type="master")
    def reviseBillTo(self,**kw):
        try:
            h = VendorBillToInfo.get(id=kw['header_ids'])
        except:
            flash("The Bill To doesn't exist!")
        return dict(obj=h,
                    vendor_id = kw["vendor_id"],)
    

    @expose(template="ecrm.templates.vendor.revise_ship_to")
    @tabFocus(tab_type="master")
    def reviseShipTo(self,**kw):
        try:
            s = VendorShipToInfo.get(id=kw["header_ids"])
        except:
            flash("The Ship To doesn't exist!")
        return dict(obj = s,
                    vendor_id = kw["vendor_id"])
            
class SearchWidgetFields(widgets.WidgetsList):
    vendorCode = widgets.TextField(label = "Vendor",attrs = { "style" : "width:250px;"})
#    billTo = widgets.TextField(label = "Bill To",attrs = { "style" : "width:250px;"})
#    shipTo = widgets.TextField(label = "Ship To",attrs = { "style" : "width:250px;"})
#    billAddress = widgets.TextField(label = "Bill Address",attrs = { "style" : "width:250px;"})    
#    shipAddress = widgets.TextField(label = "Ship Address",attrs = { "style" : "width:250px;"})
#    billContact = widgets.TextField(label = "Bill Contact",attrs = { "style" : "width:250px;"})
#    shipContact = widgets.TextField(label = "Ship Contact",attrs = { "style" : "width:250px;"})

SearchWidget_form = widgets.TableForm(template="ecrm.templates.vendor.editTemplate",fields=SearchWidgetFields())


class MainWidgetFields(widgets.WidgetsList):
    vendorCode = widgets.TextField(label = "Vendor",attrs = { "style" : "width:250px;"})
    vendorName = widgets.TextField(label = "Vendor Name",attrs = { "style" : "width:250px;"})

    

MainView_form = widgets.TableForm(template="ecrm.templates.vendor.viewTemplate",fields=MainWidgetFields())
MainEdit_form = widgets.TableForm(template="ecrm.templates.vendor.editTemplate",fields=MainWidgetFields())  