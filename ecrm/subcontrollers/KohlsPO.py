# -*- coding: utf-8 -*-
import turbogears
from turbogears import controllers, expose, flash,redirect,paginate,identity,widgets
from sqlobject.sqlbuilder import *
from kid import Element
from cherrypy.lib.cptools import serveFile
from ecrm.widgets.Widget_kohlspo import *
from ecrm.util.excel_helper import *
from ecrm.util.sql_helper import genCondition
from ecrm.util.oracle_helper import *

import ecrm.model as dbmodel
import datetime,logging,os,random,traceback,zipfile,shutil
import re
from ecrm.util.common import *


from ecrm.util.export_model import export,exportBatch,productExport

FORMAT = "%(asctime)-15s ------ %(message)s"
logging.basicConfig(format=FORMAT,level=logging.DEBUG,filename="po.log")
LATEST_FLAG = 999

class KohlsPOController(controllers.Controller, identity.SecureResource):

    require = identity.in_any_group("KOHLS_TEAM","KOHLS_VIEW","Admin")

    @expose(template="ecrm.templates.kohlspo.index")
    @paginate('items',limit=25)
    @tabFocus(tab_type="main")
    def index(self,**kw):
        userRegion = identity.current.user.getUserRegion()
        if userRegion and userRegion.name == 'Taiwan':
            tg_templates = "ecrm.templates.kohlspo.indexRegion"
        else:
            tg_templates = "ecrm.templates.kohlspo.index"

        isAdmin = "Admin" in identity.current.groups
        if isAdmin:
            search_widget= SearchWidget_form
        elif userRegion and userRegion.name == 'Taiwan':
            search_widget = RegionSearchWidget_form
        else:
            search_widget = SearchWidget_form_user
        if kw:
            conditions =[]
            _condition = ''
            if userRegion and userRegion.name == 'Taiwan':

                if kw.get("poNo",""):
                    if self.isExistPO(kw.get("poNo","")):
                        conditions.append(" (h.latest_flag > 0 or h.status <> '') ")
                        conditions.append(genCondition('h.po_no', kw.get("poNo","")))
                        conditions.append(" h.active = 1 ")
                    else:
                        conditions.append(" 2 = 1 ")
                else:
                    conditions.append(" (h.latest_flag > 0 or h.status <> '') ")
                    conditions.append(genCondition('h.po_no', kw.get("poNo","")))
                    conditions.append(" h.region_id = %d " % userRegion.id)
                    conditions.append(" h.active = 1 ")

            else:
                status = kw.get("status","")
                if status == '':
                    conditions.append(" (h.latest_flag > 0 or h.status <>'') ") #select the leatest PO
                elif status == 'A':
                    pass
                else:
                    conditions.append(" (h.status = '%s') " % (status))
                conditions.append(" h.active = 1 ")
                date_begin = kw.get("poDateBegin") if kw.get("poDateBegin") else "2000-01-01"
                date_end = kw.get("poDateEnd") if kw.get("poDateEnd") else datetime.now().strftime("%Y-%m-%d")
                date_condition = ( " ( h.edi_file_date >= '%s' and h.edi_file_date <= '%s' ) " %(date_begin + " 00:00:00", date_end + " 23:59:59"))
                conditions.append(genCondition('h.po_no', kw.get("poNo","")))
                conditions.append(genCondition('d.hangtag', kw.get("hangTag","")))
                conditions.append(genCondition('h.manufacture', kw.get("manufacture","")))
                conditions.append(genCondition(('d.style_no','s.style_no'),kw.get("styleNo","")))
                conditions.append(genCondition('h.so_no',kw.get("soNo","")))
                conditions.append(date_condition)
            _condition = ' AND '.join([c for c in conditions if c])
            sql = '''
                SELECT h.id,h.po_no,h.manufacture,h.po_date,edi_file_date,h.so_no
                ,h.order_dept,h.cancel_after,h.ship_not_before,h.exit_fty_start_date,
                h.exit_fty_end_date,h.agent,h.remark, h.status,h.belong,h.region_id from
                (kohls_po_header as h left join
                kohls_po_detail as d on h.id = d.header_id )
                left join
                kohls_sln_detail as s on d.id = s.po_detail_id
                where %s
                group by h.id,h.po_no,h.status,h.so_no,h.manufacture,h.po_date,edi_file_date,h.so_no,
                h.order_dept,h.agent,h.cancel_after,h.ship_not_before,h.exit_fty_start_date,h.exit_fty_end_date,h.remark,h.belong,h.region_id
                order by h.id desc
            ''' %( _condition )
            #logging.info(sql)
            conn = KsPoHeader._connection
            rows = conn.queryAll(sql)

            def renderQty(dto):
                header_id = dto[0]
                sql = '''
                select sum(v.qty),v.po_id from
                (
                select d.id as id,d.po_qty as qty,d.header_id as po_id  from kohls_po_detail d
                where not exists (select * from kohls_sln_detail h where h.po_detail_id=d.id)
                union
                select d.id as id,(d.po_qty*h.qty) as qty,d.header_id as po_id  from (select s.po_detail_id as id,sum(s.qty)as qty from kohls_sln_detail s
                group by s.po_detail_id order by s.po_detail_id) h,
                kohls_po_detail d
                where d.id= h.id
                ) v
                where v.po_id = %s
                group by v.po_id
                order by v.po_id
                ''' % (header_id)
                rs = conn.queryAll(sql)
                if len(rs) > 0:
                    return rs[0][0]
                else:
                    return None

            def renderHangTag(dto):
                header_id = dto[0]
                sql = '''
                        select h.hangtag from (select header_id,hangtag from kohls_po_detail
                        group by header_id,hangtag) h
                        where h.header_id = %s
                    ''' % (header_id)
                rs  = conn.queryAll(sql)
                return "\n".join([item[0] for item in rs])

            def renderStyleNo(dto):
                header_id = dto[0]

                sql = '''
                    select style_no from
                    (
                    select d.style_no
                    from
                            kohls_po_detail as d
                    where d.header_id = %s AND d.measurement_Code = 'EA'
                    union
                    (select s.style_no
                    from
                            kohls_po_detail as d right join
                            kohls_sln_detail as s on d.id = s.po_detail_id
                    where d.header_id = %s AND d.measurement_Code = 'AS'
                    )
                    ) tmp_view
                    group by style_no
                '''  %(header_id,header_id)


#                logging.info(sql)

                resultSet = conn.queryAll(sql)

                return "\n".join([str(item[0]) for item in resultSet])

            def makeLink(dto):
                header_id = dto[0]
                obj = KsPoHeader.select(KsPoHeader.q.id==header_id)
                flag = obj[0].latestFlag
                link = Element("a", attrib={"value":"%s" % str(flag),"id":"%s" % str(dto[1]),"href":"/kohlspo/detail?id=%s" % str(dto[0])})
                link.text = dto[1]
                cb = Element("input", attrib={"type":"hidden","name":"latestflag"+str(header_id),"value":str(flag)})
                cb.text = ""
                return link

            def makeCB(dto):
                header_id = dto[0]
                obj = KsPoHeader.select(KsPoHeader.q.id==header_id)
                flag = obj[0].latestFlag
                cb = Element("input", attrib={"type":"checkbox",
                                              "flag":str(flag),
                                              "po":str(dto[1]),
                                              "name":"header_ids",
                                              "value":str(dto[0]) })
                cb.text = ""
                return cb

            def makeSpan(dto):
                sp = Element("span", attrib={"id": "span_%s" %str(dto[0]) })
                sp.text = dto[5]
                return sp

            def makeSpanSO(dto):
                sp = Element("span", attrib={"id": "spanso_%s" %str(dto[0]) })
                sp.text = dto[12]
                return sp

            def makeStatus(dto):
                sp = Element("span", attrib={"id": "status_%s" %str(dto[0]) })
                sp.text = dto[13]
                return sp

            def makeRegion(dto):
                if dto[-1]:
                    region = KsRegion.select(KsRegion.q.id==dto[-1])
                    sp = Element("span", attrib={"style":"color:red"})
                    sp.text = region[0].name
                    return sp
                else:
                    return ""



            isAdmin = "Admin" in identity.current.groups

            fields = [("",makeCB),("PO NO",makeLink),
                      ("status",makeStatus),
                      ("SO NO",makeSpan),
                      ("SO  Remark",makeSpanSO),
                      ("Hang Tag",renderHangTag),
                      ("style_no",renderStyleNo),
                      ("Order Qty",renderQty),
                      ("Agent",lambda dto:dto[11]),
                      ("Vendor",lambda dto:dto[2]),
                      ("Dept NO",lambda dto:str(dto[6])),
                      ("Cancel After",lambda dto:dto[7]),
                      ("Ship Not Before",lambda dto:dto[8]),
                      ("Start X-Factory Date",lambda dto:dto[9]),
                      ("End X-Factory Date",lambda dto:dto[10]),
                      ("PO Date",lambda dto:str(dto[3])[:10]),
                      ("Receive date",lambda dto:str(dto[4])[:-3]),
                      ("user",lambda dto:dto[14]),
                      ("Region",makeRegion),
                      ]


            return dict(
                    submit_action = "/kohlspo/index",
                    search_widget= search_widget,
                    items = rows,
                    result_widget=widgets.PaginateDataGrid(fields=fields,template = "ecrm.templates.common.paginate"),
                    values = kw,
                    tg_template = tg_templates,
                    )
        else:
            return dict(
                    submit_action = "/kohlspo/index",
                    search_widget=search_widget,
                    items = [],
                    values = kw,
                    tg_template = tg_templates,
                        )

    @expose()
    @tabFocus(tab_type="main")
    def default(self,**kw):
        return dict (rs = "test")

    @expose(template="ecrm.templates.kohlspo.detail")
    @tabFocus(tab_type="main")
    def detail(self,**kw):
        try:
            h = KsPoHeader.get(id=kw["id"])
        except:
            flash("The record doesn't exist!")
            raise redirect("index")

        ######### update hangtag view in excel
        conn = KsPoDetail._connection
        sql = '''select h.hangtag from (select header_id,hangtag from kohls_po_detail
                 group by header_id,hangtag) h
                 where h.header_id = %s
              ''' % (kw["id"])
        rs  = conn.queryAll(sql)

        h.hangtag =  ",".join([item[0] for item in rs])
        #########
        ds = KsPoDetail.selectBy(header=h)

        logging.info(ds.count())

        result = []
        hangtag = None
        for d in ds:
            hangtag = d.hangtag
            if d.measurementCode == "EA":
                result.append( (d.styleNo,d.colorCode,d.colorDesc,d.deptNo,d.classNo,d.subclassNo,
                                d.upc,d.sizeCode,d.retailPrice,d.size,d.poQty,d.hasExported,d.id,"PO1",d.eanCode) )
            elif d.measurementCode == "AS":
                po1Qty = d.poQty
                ss = SLNDetail.selectBy(poDetail = d)
                for s in ss :
                    result.append( (s.styleNo,s.colorCode,s.colorDesc,s.deptNo,s.classNo,s.subclassNo,
                                    s.upc,s.sizeCode,s.retailPrice,s.size,s.qty*po1Qty,s.hasExported,s.id,"SLN",d.eanCode) )

        isAdmin = "Admin" in identity.current.groups


        def makeCB(dto):
            cb = Element("input", attrib={"type":"checkbox","name":"item_ids","value":str(dto[12]),"styleNO":dto[0],"ref":dto[13] })
            cb.text = ""
            if isAdmin:
                return cb
            if dto[11] != 0:
                return ""
            return cb

        can_edit = h.latestFlag > 0 or h.status=='D' #modify by Ray on exporting for user.
        fields = [("",makeCB),("Style",lambda dto:dto[0]),("Color Code",lambda dto:dto[1]),("Color Desc",lambda dto:dto[2]),
                  ("Dept#",lambda dto:dto[3]),("Class#",lambda dto:dto[4]),("Sub Class#",lambda dto:dto[5]),
                  ("UPC",lambda dto:dto[6]),("EAN",lambda dto:dto[14]),("Size Code",lambda dto:dto[7]),("Retail Price",lambda dto:dto[8]),
                  ("Size",lambda dto:dto[9].upper()),("PO Qty",lambda dto:dto[10])]

        if not can_edit:
            fields = fields[1:]
        #h.hangtag = hangtag

        return dict(
                    poDetail_widget =  widgets.DataGrid(fields = fields,template = "ecrm.templates.common.dataGrid"),
                    items = result,
                    POHeader = h,
                    can_edit = can_edit
                    )
    @expose()
    def export(self,**kw):
        return export(kw)


    @expose()
    def productExport(self,**kw):
        return productExport(kw)

    @expose()
    def deletePO(self,**kw):
        h = KsPoHeader.get(id=kw["header_id"])
        if h:
            history = h.history
            his = updateHistory(actionUser=identity.current.user,actionKind="Delete",actionContent="")
            h.set( active=0,history="%s|%s" %(his.id,history) )
            flash("The PO [No#=%s] has been deleted successfully!" % h.poNo)
            raise redirect("index")
        else:
            flash("The record is not exist in the DB!")
            raise redirect("index")

    @expose()
    def addSO(self,**kw):
        try:
            so_no = kw["so_no"]
            so_remark = kw["so_remark"]
            so_date = datetime.strptime( kw["so_date"],"%Y-%m-%d")
            h = KsPoHeader.get(id=kw["header_id"])

            #update on July 12 2010
            userRegion = identity.current.user.getUserRegion()
            #if userRegion and userRegion.name == "TaiWan":
            if userRegion:
                self._updateRegion(h.poNo,userRegion.id)

            if h.latestFlag > 0:
                self._updateOtherPOLatestFlag(h.poNo)
                h.latestFlag = 999
            else:
                pass
            #need to update the latestFlag in other PO with the same PO NO to be 0
            #self._updateOtherPOLatestFlag(h.poNo)
            hisContent = "Change SO NO# from [%s] to [%s] , SO Date from [%s] to [%s]." %(h.soNo,so_no,h.soDate,so_date)
            #logging.info(hisContent)
            hisRef = updateHistory(actionUser=identity.current.user,actionKind="Modify",actionContent=hisContent)
            his = h.history
            #######
            so_remark = kw["so_remark"] + " " + h.status + str(so_date)
            h.set(soNo=so_no,remark= so_remark,soDate=so_date,history="%s|%s" %(hisRef.id,his),belong=identity.current.user_name)#,latestFlag=LATEST_FLAG )
            return "OK"
        except:
            traceback.print_exc()
            return "ERROR"


    @expose("json")
    #@tabFocus(tab_type="main")
    def Replace(self,**kw):
        try:
            target_id = int(kw["header_ids"][0])
            source_id = int(kw["header_ids"][1])
            target = KsPoHeader.get(id=target_id)
            source = KsPoHeader.get(id=source_id)
            actionContent = "The PO [ID: %s] has been Replace by the PO[ID: %s]" %( source.id,target.id)
            history = updateHistory(actionUser = identity.current.user,actionKind = "Replace",actionContent = actionContent)
            s_his = "%s|%s" % (history.id,source.history)
            t_his = "%s|%s" % (history.id,target.history)

            rs = KsPoHeader.select( (KsPoHeader.q.poNo == source.poNo))

            #update on July 12 2010
            userRegion = identity.current.user.getUserRegion()
            #if userRegion and userRegion.name == "TaiWan":
            if userRegion:
                self._updateRegion(rs[0].poNo,userRegion.id)

            _flag = ''
            for obj in rs:
                if obj.ediFileDate > target.ediFileDate:
                    _flag = "O"
                else:
                    continue
            #clear all status values
            self.updateStatusBlank(str(source.poNo))
            target.set(soNo=source.soNo,soDate=source.soDate,latestFlag=999,status=_flag,
                       history=t_his,remark=source.remark,exportVersion=source.exportVersion,agent=source.agent,belong=source.belong)
            source.set(status = "",soDate=None,latestFlag=0,history=s_his,remark="",exportVersion=0,agent="")

            spo1s = source.items
            tpo1s = target.items

            for spo1 in source.items:
                if spo1.measurementCode == "EA" and spo1.hasExported != 0 :
                    tpo1 = target.getByUPC(spo1.upc)
                    if tpo1:
                        tpo1.hasExported = spo1.hasExported
                elif spo1.measurementCode == "AS":
                    tpo1 = target.getByUPC(spo1.upc)
                    if not tpo1:
                        continue
                    for ssln in spo1.slns:
                        if ssln.hasExported != 0:
                            tsln = tpo1.getByUPC(ssln.upc)
                            if tsln:
                                tsln.hasExported = ssln.hasExported
            flash("The latest version of the PO[%s] has been Replace successfully!" %source.poNo)
            return {"flag":"OK"}
        except:
            traceback.print_exc()
            flash("Error occurs on the server side.")
            return {"flag":"error"}

    @expose("json")
    def NoReplace(self,**kw):
        try:
            target_id = int(kw["header_ids"][0])
            source_id = int(kw["header_ids"][1])
            target = KsPoHeader.get(id=target_id)
            source = KsPoHeader.get(id=source_id)
            actionContent = "The PO [ID: %s] has been NoReplaced by the PO[ID: %s]" %( source.id,target.id)
            history = updateHistory(actionUser = identity.current.user,actionKind = "NoReplaced",actionContent = actionContent)
            s_his = "%s|%s" % (history.id,source.history)
            t_his = "%s|%s" % (history.id,target.history)

            #Cancel Order
            rs = KsPoHeader.select( (KsPoHeader.q.poNo == source.poNo))
            #update on July 12 2010
            userRegion = identity.current.user.getUserRegion()
            #if userRegion and userRegion.name == "TaiWan":
            if userRegion:
                self._updateRegion(rs[0].poNo,userRegion.id)

            _flag = 'O'
                        #clear all status values
            self.updateStatusBlank(str(source.poNo))
            target.set(status = "",history=t_his)
            source.set(status = _flag,history=s_his)
            flash("The latest version of the PO[%s] has been NoReplaced successfully!" %source.poNo)
            return {"flag":"OK"}
        except:
            traceback.print_exc()
            flash("Error occurs on the server side.")
            return {"flag":"error"}



    @expose("json")
    def addBatchSOOnly(self,**kw):
        try:
            for spanid in kw:
                status_flag = False
                if spanid.startswith("span_"):
                    id = spanid[5:]
                elif spanid.startswith("spanso_"):
                    id = spanid[7:]
                elif spanid.startswith("status_"):
                    status_flag = True
                    id = spanid[7:]
                else:
                    continue
                h = KsPoHeader.get(id=id)
                return {"latestflag":str(h.latestFlag)}
        except:
            return {"latestflag" :"Error"}

    def _updateRegion(self,poNo,region):
        try:
            conn = KsPoHeader._connection
            sql = '''
                UPDATE kohls_po_header SET region_id=%d WHERE po_no='%s'
            ''' % (region,poNo)
            conn.query(sql)
        except:
            traceback.print_exc()

    @expose("json")
    def addBatchSO(self,**kw):
        try:
            for spanid in kw:
                status_flag = False
                if spanid.startswith("span_"):
                    id = spanid[5:]
                elif spanid.startswith("spanso_"):
                    id = spanid[7:]
                elif spanid.startswith("status_"):
                    status_flag = True
                    id = spanid[7:]
                else:
                    continue
                h = KsPoHeader.get(id=id)

                #update on -5-14 if falg == true : operation overwrite else: just update
                rs = KsPoHeader.select(KsPoHeader.q.id==id)
                #update on July 12 2010
                userRegion = identity.current.user.getUserRegion()
                #if userRegion and userRegion.name == "TaiWan":
                if userRegion:
                    self._updateRegion(h.poNo,userRegion.id)

                if status_flag ==False:
                    #rs = KsPoHeader.select(KsPoHeader.q.id ==id)
                    if rs[0].latestFlag > 0:
                        if spanid.startswith("span_"):
                            self._updateOtherPOLatestFlag(h.poNo)
                            rs[0].latestFlag = 999
                            actionContent = "Change the [SO No] value from [%s] to [%s] \n" % ( null2blank(h.soNo),kw[spanid])
                        else:
                            actionContent = "Change the [SO Remark] value from [%s] to [%s] \n" % ( null2blank(h.remark),kw[spanid])
                    else:
                        if spanid.startswith("spanso_"):
                            actionContent = "Change the [SO Remark] value from [%s] to [%s] \n" % ( null2blank(h.remark),kw[spanid])
                        else:
                            actionContent = "Change the [SO No] value from [%s] to [%s] \n" % ( null2blank(h.soNo),kw[spanid])
                else:
                    #rs = KsPoHeader.select(KsPoHeader.q.id==id)
                    if kw[spanid] == 'D':
                        self._updateOtherPOLatestFlag(h.poNo)
                        rs[0].latestFlag = 999
                        actionContent = "Change the [PO Status] value as 'D' for PO# [%s] \n" % h.poNo
                    else:
                        actionContent = "Change the [PO Status] value as [%s] for PO# [%s] \n" % (kw[spanid],h.poNo)

                his = updateHistory( actionUser=identity.current.user,actionKind="Modify",actionContent = actionContent )
                if spanid.startswith("span_"):
                    h.set(soNo=kw[spanid],history = "%s|%s" %(his.id,null2blank(h.history)),belong=identity.current.user_name)
                elif spanid.startswith("spanso_"):
                    h.set(remark=kw[spanid],history = "%s|%s" %(his.id,null2blank(h.history)))
                    #print "%s|%s" % (his.id,null2blank(h.history))
                else:
                    h.set(status = kw[spanid],history = "%s|%s" %(his.id,null2blank(h.history)))
            return {
                        "flag" : "OK"
                    }
        except:
            traceback.print_exc()
            return {
                        "flag" : "Error",
                        "message" : "Error occur !",
                    }



    @expose()
    def exportBatch(self,**kw):
        return exportBatch(kw,"_export")


    @expose()
    def productExportBatch(self,**kw):
        return exportBatch(kw,"product_export")


    #update all the PO's latest flag to 0 with the giving PO NO.
    def _updateOtherPOLatestFlag(self,poNo):
        try:
            conn = KsPoHeader._connection
            sql = '''
                UPDATE kohls_po_header SET latest_flag=0 WHERE po_no='%s'
            ''' %poNo
            conn.query(sql)
            return True
        except:
            traceback.print_exc()
            return False

    def updateStatusBlank(self,poNo):
        try:
            conn = KsPoHeader._connection
            sql = '''
                UPDATE kohls_po_header SET status = '' WHERE po_no='%s'
            ''' %poNo
            conn.query(sql)
            return True
        except:
            traceback.print_exc()
            return False


    @expose(template="ecrm.templates.kohlspo.version")
    @tabFocus(tab_type="main")
    def showVersions(self,poNo):
        try:
            pos = KsPoHeader.select(KsPoHeader.q.poNo==poNo,orderBy=[DESC(KsPoHeader.q.latestFlag),DESC(KsPoHeader.q.ediFileDate)])
            if pos.count() < 1:
                raise
            return {
                    "pos" : pos,
                    }
        except:
            traceback.print_exc()
            flash("No such po number!")
            raise redirect("/kohlspo/index")

    @expose(template="ecrm.templates.kohlspo.diff")
    @tabFocus(tab_type="main")
    def showDifference(self,**kw):
        try:
            source = KsPoHeader.get(id=kw["source_id"])
            target = KsPoHeader.get(id=kw["target_id"])
            return {
                    "source" : source,
                    "target" : target,
                    }
        except:
            traceback.print_exc()
            flash("Error occurs on the server side.")
            raise redirect("/kohlspo/index")

    @expose()
    @tabFocus(tab_type="main")
    def overWrite(self,**kw):
        try:
            source = KsPoHeader.get(id=kw["source_id"])
            target = KsPoHeader.get(id=kw["target_id"])

            actionContent = "The PO [ID: %s] has been overwritten by the PO[ID: %s]" %( source.id,target.id)
            history = updateHistory(actionUser = identity.current.user,actionKind = "Overwrite",actionContent = actionContent)
            s_his = "%s|%s" % (history.id,source.history)
            t_his = "%s|%s" % (history.id,target.history)


            rs = KsPoHeader.select( (KsPoHeader.q.poNo == source.poNo))

            #update on July 12 2010
            userRegion = identity.current.user.getUserRegion()
            #if userRegion and userRegion.name == "TaiWan":
            if userRegion:
                self._updateRegion(rs[0].poNo,userRegion.id)


            _flag = ''
            for obj in rs:
                if obj.ediFileDate > target.ediFileDate:
                    _flag = "O"
                else:
                    continue
            #clear all status values
            self.updateStatusBlank(str(source.poNo))
            #Cancel Order
            target.set(soNo=source.soNo,soDate=source.soDate,latestFlag=999,status=_flag,
                       history=t_his,remark=source.remark,exportVersion=source.exportVersion,agent=source.agent,belong=source.belong)
            source.set(status = "",soDate=None,latestFlag=0,history=s_his,remark="",exportVersion=0,agent="")

            spo1s = source.items
            tpo1s = target.items


            for spo1 in source.items:
                if spo1.measurementCode == "EA" and spo1.hasExported != 0 :
                    tpo1 = target.getByUPC(spo1.upc)
                    if tpo1:
                        tpo1.hasExported = spo1.hasExported
                elif spo1.measurementCode == "AS":
                    tpo1 = target.getByUPC(spo1.upc)
                    if not tpo1:
                        continue
                    for ssln in spo1.slns:
                        if ssln.hasExported != 0:
                            tsln = tpo1.getByUPC(ssln.upc)
                            if tsln:
                                tsln.hasExported = ssln.hasExported


            flash("The latest version of the PO[%s] has been overwritten successfully!" %source.poNo)
        except:
            traceback.print_exc()
            flash("Error occurs on the server side.")
            raise redirect("/kohlspo/index")
        raise redirect("/kohlspo/showVersions/%s" % source.poNo)


    @expose(template="ecrm.templates.kohlspo.msglist")
    @paginate('items',limit=25)
    @tabFocus(tab_type="main")
    def msglist(self,**kw):
        result = EDI864Header.select(AND(EDI864Header.q.status==1),orderBy=[DESC(EDI864Header.q.importDate)] )
        def makeLink(dto):
            if dto.read == 0:
                link = Element('a',href='msgdetail/%d' % dto.id,attrib={"class":"unread"})
                link.text = "Un-read"
            elif dto.read == 1:
                link = Element('a',href='msgdetail/%d' % dto.id)
                link.text = "Read"
            return link

        fields = [("Sender Code","senderCode"),("EDI File Date","ediFileDate"),("E-mail","contactEmail"),
                  ("Free Form Name","freeFormName"),("Import Date","importDate"),("Action",makeLink)
                  ]

        return dict(
                    items = result,
                    result_widget=widgets.PaginateDataGrid(fields=fields,template = "ecrm.templates.common.PaginateDataGrid"),
                    )


    @expose(template="ecrm.templates.kohlspo.missing")
    @paginate('items',limit=20)
    @tabFocus(tab_type="main")
    def missing(self,**kw):
        #rs  = MissingPO.select(orderBy=[DESC(MissingPO.q.poNo)])
        rs  = KsPoHeader.select(KsPoHeader.q.status == 'Missing')


        def makeLink(dto):
            pass
        fields = [("Id","id"),("Po NO","poNo"),("Po Status","status"),("So No","soNo"),("Po ImportDate","importDate"),
                  ("Po Remark","remark")]
        return dict(
                    items = rs,
                    result_widget=widgets.PaginateDataGrid(fields=fields,template = "ecrm.templates.common.PaginateDataGrid"),
                    )

    @expose()
    def addPO(self,**kw):
        try:
            po_no = kw["po_no"]
            po_remark = kw["po_remark"]
            so_no = kw["so_no"]
            ediFileDate = datetime.strptime("2008-08-08","%Y-%m-%d") # set as fixed value
            h = KsPoHeader(poNo=po_no,status="Missing",remark = po_remark,ediFileDate=ediFileDate,soNo = so_no,latestFlag = -1)
            '''
            self._updateOtherPOLatestFlag(h.poNo)

            hisContent = "Add PO [%s] as Missing PO by [%s]" %(po_no,identity.current.user)
            #logging.info(hisContent)
            hisRef = updateHistory(actionUser=identity.current.user,actionKind="MissingPO",actionContent=hisContent)
            his = h.history
            h.set(soNo=so_no,remark= so_remark,soDate=so_date,history="%s|%s" %(hisRef.id,his),latestFlag=LATEST_FLAG )
            '''
            return "OK"
        except:
            traceback.print_exc()
            return "ERROR"


    @expose(template="ecrm.templates.kohlspo.msgdetail")
    @tabFocus(tab_type="main")
    def msgdetail(self,id):
        try:
            h = EDI864Header.get(id=id)
            h.read = 1
            content = []
            return dict(msgHeader = h)
        except:
            traceback.print_exc()
            flash("The message doesn't exist!")
            raise redirect("/kohlspo/msglist")

    @expose(template="ecrm.templates.kohlspo.report")
    @tabFocus(tab_type="report")
    def report(self,**kw):
        return {}

    @expose()
    def reportDetail(self,**kw):
        #prepare the sql
        if kw["report_type"] == "q":
            templatePath = os.path.join(os.path.abspath(os.path.curdir),"report_download/TEMPLATE/KOHLS_REPORT_QUARTERLY_TEMPLATE.xls")
        elif kw["report_type"] == "m":
            templatePath = os.path.join(os.path.abspath(os.path.curdir),"report_download/TEMPLATE/KOHLS_REPORT_MONTHLY_TEMPLATE.xls")

        sql = createKOHLSSQL(kw)
        print "_*"*30
        print sql
        print "_*"*30
        
        data = []
        #execute the sql ,return the resultset
        try:
            db_connection = createConnection()
            cursor = db_connection.cursor()
            cursor.execute(str(sql))
            resultSet = cursor.fetchall()

            def decodeCol(col):
                if not col:
                    return ""
                if type(col) == datetime:
                    return col.strftime("%Y-%m-%d")
                return str(col).decode("utf8")

            for row in resultSet:
                data.append( tuple([decodeCol(col)[:900] for col in row]) )
        except:
            traceback.print_exc()
            flash("Error occur on the server side.")
            raise redirect("/kohlspo/report")
        finally:
            cursor.close()
        #write the resultset to the excel
        try:
            dateStr = datetime.today().strftime("%Y%m%d")
            fileDir = os.path.join(os.path.abspath(os.path.curdir),"report_download/kohls_report","%s" %dateStr)
            if not os.path.exists(fileDir):
                os.makedirs(fileDir)
            timeStr = datetime.now().time().strftime("%H%M%S")
            filename = os.path.join(fileDir,"%s%s.xls" %(dateStr,timeStr))
            ke = KohlsReportExcel(templatePath = templatePath,destinationPath = filename)
            ke.inputData(data=data)
            ke.outputData()
            return serveFile(filename, "application/x-download", "attachment")
        except:
            traceback.print_exc()
            flash("Error occur whening generating the excel!")
            raise redirect("/kohlspo/report")
        finally:
            pass



    @expose()
    def getAjaxValues(self,**kw):
        limit = kw.get("rowcount", "15")
        if kw["fieldName"] == "in_item_code":
            sql = '''
                select h.ITEM_CODE from T_ITEM_HDR h WHERE h.COMPANY_CODE = '%s' AND h.ITEM_CODE LIKE '%%%s%%' AND ROWNUM <= %s ORDER BY h.ITEM_CODE
            ''' % (kw["ln_company_code"],kw["q"].upper(),limit)
        elif kw["fieldName"] == "in_supl_name":
            sql = '''
                select h.CUST_NAME from t_cust_hdr h where h.COMPANY_CODE = '%s' AND h.CUST_NAME like '%%%s%%' AND ROWNUM <= %s ORDER BY h.CUST_NAME
            ''' % (kw["ln_company_code"],kw["q"].upper(),limit)

        print sql
        try:
            db_connection = createConnection()
            cursor = db_connection.cursor()
            cursor.execute(str(sql))
            resultSet = cursor.fetchall()
            return "\n".join([row[0] for row in resultSet])
        except:
            traceback.print_exc()
            return ""
        finally:
            cursor.close()

    @expose(template="ecrm.templates.kohlspo.history")
    @tabFocus(tab_type="main")
    def history(self,id):
        try:
            pos = KsPoHeader.select(KsPoHeader.q.id==id,orderBy=[DESC(KsPoHeader.q.latestFlag),DESC(KsPoHeader.q.ediFileDate)])
            if pos.count < 0:
                raise

            p = KsPoHeader.get(id)
            if p.history:
                history = p.history[:-1].split("|")
                result = [updateHistory.get(hid)  for hid in history]
            else:
                result = []

            def adjustContent(h):
                adjustedText = h.actionContent
                if h.actionContent:
                    adjustedText = adjustedText.replace("|","\n")
                return adjustedText

            _fields = [("Time",lambda args:Date2Text(args.actionTime,FONTEND_DATE_TIME_FORMAT) ),
                       ("User","actionUser"),("Action Kind","actionKind"),("Content",adjustContent)]
            return dict(po = pos,
                        items = result,
                        result_widget=widgets.PaginateDataGrid(fields=_fields),
                        record_id = id,
                        )
        except:
            traceback.print_exc()
            flash("No such po number!")
            raise redirect("/kohlspo/index")

    def isExistPO(self,po_no):
        try:
            userRegion = identity.current.user.getUserRegion()
            ps = KsPoHeader.select(AND(KsPoHeader.q.poNo==po_no,KsPoHeader.q.latestFlag > 0))
            if ps.count() < 1:
                return False
            elif ps[0].soNo == '':
                return True
            elif ps[0].region and userRegion.id==ps[0].region.id:
                return True
            else:
                return False
        except:
            traceback.print_exc()
            flash("No such po number!")
            raise redirect("/kohlspo/index")