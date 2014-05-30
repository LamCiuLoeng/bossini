# -*- coding: utf-8 -*-
import sys, os
reload(sys)
sys.setdefaultencoding('utf8')

import math, zlib, random, sha, datetime, logging, os, random, traceback, zipfile, shutil, re
from thread import allocate_lock
import cherrypy, turbogears
from cherrypy.lib.cptools import serveFile
from turbogears import controllers, expose, flash, redirect, paginate, identity, widgets
from sqlobject.sqlbuilder import *
from kid import Element, XML

##########################
from ecrm.widgets.widget_bossini import SearchWidget_form, SearchHangType_form
from ecrm.util.excel_helper import *
from ecrm.util.sql_helper import genCondition
from ecrm.model import *
from ecrm.util.common import *
from ecrm.util.bossini_helper import *
from ecrm.util.web_helper import *
import ecrm.widgets.widget_bossini as wb


class BossiniPOController(controllers.Controller, identity.SecureResource):

    require = identity.All(is_worktime(), identity.in_any_group("BOSSINI_TEAM", "Admin"))

    myLock = allocate_lock()

    def judgeRight(self):
        try:
            current_vendor = identity.current.groups
#            vendor_list = ["TR","GD","FNI","KFO","JS","LWF","TPL","TX","WM","WY","WJ","AE","AS","TD","WS"]
            vendor = list(set(current_vendor).intersection(set(self._getVendorList())))
            if len(vendor) == 0:
                return (True, "admin")
            else:
                return (False, vendor[0])
        except:
            self.record_errorLog()
            traceback.print_exc()
            raise("/bossinipo/index")

    def _getVendorList(self, needAE = False):
        venderList = [b.vendorCode for b in Vendor.select(Vendor.q.active == 1, orderBy = [Vendor.q.vendorCode, ])]
        return ["AE"] + venderList if needAE else venderList

    @expose(template = "ecrm.templates.bossini.index")
    @paginate('items', limit = 40)
    @tabFocus(tab_type = "main")
    def index(self, **kw):

        isAdmin = self.judgeRight()
        if isAdmin[0]:
            current_vendor = 'admin'
        else:
            raise redirect("/index")
            #current_vendor = isAdmin[1]
        if kw:
            condition = self._createSeachCondition(kw)

            cherrypy.session["search_clause"] = condition
            cherrypy.session["criteria"] = kw.get("criteria", "")
            result = Bossini.select(condition, orderBy = [DESC(Bossini.q.importdate), Bossini.q.legacyCode, Bossini.q.poNo])
        else :
            if cherrypy.session.get("search_clause"): del cherrypy.session["search_clause"]
            if cherrypy.session.get("criteria"): del cherrypy.session["criteria"]
            result = []

        def makeCB(dto):
            cb = Element("input", attrib = {"type":"checkbox", "name":"header_id", "value":str(dto.id) })
            return cb

        def makeLink(dto):
            if dto.active:
                link = Element("a", attrib = {"href":"/bossinipo/detail?id=%s" % dto.id})
            else:
                link = Element("a", attrib = {"href":"/bossinipo/detail?id=%s" % dto.id, "class":"error"})

            link.text = dto.poNo
            return link

        def checkOrders(dto):
            if dto.done == 0 : return "---"
            result = []
            if BossiniOrder.selectBy(po = dto, orderType = "H", active = 0).count() > 0 : result.append("H")
            if BossiniOrder.selectBy(po = dto, orderType = "WOV", active = 0).count() > 0 : result.append("WOV")
            if BossiniOrder.selectBy(po = dto, orderType = "ST", active = 0).count() > 0 : result.append("ST")
            return ",".join(result)


        #def makePrice(dto):
            #return XML(dto.priceInHTML)

        fields = [
                  ("Bossini PO#", makeLink),
                  ("Legacy Code", "printedLegacyCode"), ("Vendor", "vendorCode"),
                  ("Market", "marketList"),
                  ("Type", "hangTagType"),
                  ("Collection", "collection"),
                  ("Season", "season"),
                  ("SubCat", "subCat"),
                 # ("Order Qty", "sortedSubChildren"),
                  ("In-Store Date", lambda dto:Date2Text(dto.storeDate, "%Y-%m-%d")),
                  #("Net price", makePrice),
                  ("Item Type", "itemType"),
                  ("Import Date", "importdate"),
                  ("Confirmed Orders", checkOrders),
                  ("Is Old Data", lambda v:"Yes" if v.done == 0 else "No")
                ]
        #kw["vendorCode"] = "TR"
        return dict(items = result,
                    search_widget = wb.CustomSearchWidget_form(current_vendor),
                    values = kw,
                    submit_action = "/bossinipo/index",
                    result_widget = widgets.PaginateDataGrid(fields = fields, template = "ecrm.templates.common.paginateDataGrid"))


    def _createSeachCondition(self, kw):
        def _OR(v, f):
            tmp = []
            for n in v.strip().split(): tmp.append(f(n))
            return reduce(lambda x, y:x | y, tmp)
        result = []
        result.append(Bossini.q.active == 1)
        if not kw.get("importDateBegin", False) and not kw.get("importDateEnd", False):
            result.append(Bossini.q.latestFlag > 0)
        else:
            result.append(Bossini.q.latestFlag > -1)
        if kw.get("poNo", False):            result.append(_OR(kw['poNo'], lambda po:LIKE(Bossini.q.poNo, "%%%s%%" % po)))
        if kw.get("vendorCode", False) :     result.append(_OR(kw['vendorCode'], lambda vc:Bossini.q.vendorCode == vc))
        if kw.get("legacyCode", False) :     result.append(LIKE(Bossini.q.legacyCode, "%%%s%%" % kw['legacyCode']))
        if kw.get("sizeCode", False) :       result.append(Bossini.q.sizeCode == kw['sizeCode'])
        if kw.get("marketList", False) :     result.append(Bossini.q.marketList == kw['marketList'])
        #if kw.get("hangTagType", False) :    result.append(Bossini.q.hangTagType==kw['hangTagType'])
        if kw.get("hangTagType", False) :
            if  kw.get("hangTagType") != 'ST':
                result.append(Bossini.q.hangTagType == kw['hangTagType'])
            else:
                result.append(IN(Bossini.q.id, Select(BossiniOrder.q.po, where = BossiniOrder.q.orderType == 'ST')))
        if kw.get("styleNo", False) :        result.append(_OR(kw['styleNo'], lambda sn:LIKE(Bossini.q.styleNo, "%%%s%%" % sn)))
        if kw.get("poDateBegin", False) :    result.append(Bossini.q.storeDate >= kw["poDateBegin"])
        if kw.get("poDateEnd", False) :      result.append(Bossini.q.storeDate <= kw["poDateEnd"] + " 23:59:59")
        if kw.get("importDateBegin", False): result.append(Bossini.q.importdate >= kw["importDateBegin"])
        if kw.get("importDateEnd", False):   result.append(Bossini.q.importdate <= kw["importDateEnd"] + " 23:59:59")
        if kw.get("collection", False) :     result.append(Bossini.q.collection == kw["collection"])

        return reduce(lambda x, y:x & y, result, True)


    @expose()
    def exportHangTagOrder(self, **kw):
        oh = getOr404(BossiniOrder, kw["id"], "/bossinipo/index", "The record doesn't exist!")
        h = oh.po

        pcs = PrintingCardInfo.selectBy(orderInfo = oh)

        orderInfo = {
                     "customerOrderNo" : oh.customerOrderNo, "shipToAddress" : oh.shipToAddress, "shipToContact" : oh.shipToContact,
                     "orderDate" : oh.confirmDate,
                     "typeName" : oh.typeName, "specification" : oh.specification, "prodcuingArea" : oh.prodcuingArea, "unit" : oh.unit,
                     "grade" : oh.grade, "pricer" : oh.pricer, "productName" : oh.productName, "standard" : oh.standard, "checker" : oh.checker,
                     "technicalType" : oh.technicalType, "standardExt" : oh.standardExt,
                     "orderItems" : {}, "processCompany" : oh.processCompany,
                     }
        hangTagItems = []
        waistCardItems = []
        stickerItems = []

        for pc in pcs:
            if pc.cardType == "H" : hangTagItems.append(pc.item.itemCode)
            elif pc.cardType == "W" : waistCardItems.append(pc.item.itemCode)
            elif pc.cardType == "ST" : stickerItems.append(pc.item.itemCode)

        orderInfo["orderItems"]["hangTag"] = ",".join(hangTagItems)
        orderInfo["orderItems"]["waistCard"] = ",".join(waistCardItems)
        orderInfo["orderItems"]["sticker"] = ",".join(stickerItems)

        layers = BossiniFiberContentLayer.select(BossiniFiberContentLayer.q.orderInfo == oh, orderBy = [BossiniFiberContentLayer.q.id])
        orderInfo["fiberContentLayer"] = []
        for layer in layers:
            if h.marketList != 'EXP' :
                orderInfo["fiberContentLayer"].append("%s%% %s" % (layer.percentage, " ".join([layer.component.HKSINEXP, layer.component.TWN])))
            else:
                orderInfo["fiberContentLayer"].append("%s%% %s" % (layer.percentage, " ".join([layer.component.HKSINEXP,
                                            layer.component.TWN, layer.component.Indonesia, layer.component.Ukrainian, layer.component.Egypt])))

        xlsFileName = "%s.xls" % oh.filename
        self.myLock.acquire()
        (flag, fileName) = self._genHangTagProductionFile(h, orderInfo, xlsFileName)
        self.myLock.release()
        if flag == 0 :
            flash("Error occur when generate the production file!")
            raise redirect("/bossinipo/detail?id=%s" % h.id)
        else:
            return serveFile(fileName, "application/x-download", "attachment")

    @expose()
    def exportSTOrder(self, **kw):
        oh = getOr404(BossiniOrder, kw["id"], "/bossinipo/index", "The record doesn't exist!")
        h = oh.po

        pcs = PrintingCardInfo.selectBy(orderInfo = oh)

        orderInfo = {
                     "customerOrderNo" : oh.customerOrderNo, "shipToAddress" : oh.shipToAddress, "shipToContact" : oh.shipToContact,
                     "orderDate" : oh.confirmDate,
                     "typeName" : oh.typeName, "specification" : oh.specification, "prodcuingArea" : oh.prodcuingArea, "unit" : oh.unit,
                     "grade" : oh.grade, "pricer" : oh.pricer, "productName" : oh.productName, "standard" : oh.standard, "checker" : oh.checker,
                     "technicalType" : oh.technicalType,
                     "orderItems" : {}
                     }
        xlsFileName = "%s.xls" % oh.filename
        self.myLock.acquire()
        (flag, fileName) = self._genSTProductionFile(h, oh, xlsFileName)
        self.myLock.release()
        if flag == 0 :
            flash("Error occur when generate the production file!")
            raise redirect("/bossinipo/detail?id=%s" % kw["id"])
        else:
            return serveFile(fileName, "application/x-download", "attachment")

    @expose()
    def comparePo(self, **kw):
        try:
            header_id = int(kw.get("header_id", "0"))
            self.checkVendor(header_id)
            currentHeader = Bossini.get(header_id)
            latestHeader = Bossini.select(AND(Bossini.q.latestFlag == 1, Bossini.q.poNo == currentHeader.poNo))[0]


            source_detail = BossNewDetail.select(BossNewDetail.q.header == latestHeader, orderBy = [BossNewDetail.q.colorCode, BossNewDetail.q.sizeCode])
            target_detail = BossNewDetail.select(BossNewDetail.q.header == currentHeader, orderBy = [BossNewDetail.q.colorCode, BossNewDetail.q.sizeCode])

            return {
                    "source" : [latestHeader, source_detail],
                    "target" : [currentHeader, target_detail],
                    "header_id" : kw["header_id"],
                    }
        except:
            self.record_errorLog()
            traceback.print_exc()
            flash("Error occurs on the server side.")
            raise redirect("/bossinipo/index")


    @expose(template = "ecrm.templates.bossini.version")
    @tabFocus(tab_type = "main")
    def versions(self, **kw):
        self.checkVendor(kw["id"])
        try:
            rs = Bossini.get(kw['id'])
            poNo = rs.poNo
            #all po that latestFlag less than 0 is the duplicate and useless.
            pos = Bossini.select(AND(Bossini.q.poNo == poNo, Bossini.q.latestFlag > -1), orderBy = [DESC(Bossini.q.latestFlag), DESC(Bossini.q.importdate)])
            if pos.count() < 1:
                raise
            return {
                    "pos" : pos,
                    "POHeader" : rs,
                    "header_id" : kw['id'],
                    }
        except:
            self.record_errorLog()
            traceback.print_exc()
            flash("No such po number!")
            raise redirect("/bossinipo/index")


    @expose()
    def getAjaxField(self, **kw):
        fieldName = kw["fieldName"]
        value = kw["q"]
        return "\n".join(["%s|%s" % (row[0], row[0])  for row in self._getDistinctValue(fieldName, value)])


    def _getDistinctValue(self, fieldName, value):
        sql = "SELECT DISTINCT %s FROM bossini_header_po where %s ILIKE '%%%s%%' ORDER BY %s" % (fieldName, fieldName, value, fieldName)
        rs = Bossini._connection.queryAll(sql)
        return rs



    def _getImg(self, code):
        if not code : return None
        src = os.path.join(os.path.abspath(os.path.curdir), "ecrm", "static", "images", "bossini", "%s.jpg" % code)
        if not os.path.exists(src):
            return None
        return src


    def _getWCCode(self, ds):
        for d in ds :
            if d.waistCard : return d.waistCard
        return None



    @expose()
    @tabFocus(tab_type = "main")
    def showOrderInfo(self, **kw):
        id = kw["id"]
        order = getOr404(BossiniOrder, id, "/bossinipo/vendor_index", "你所要访问的记录不存在!")
        header = order.po

        if order.orderType == "H" :
            items = PrintingCardInfo.selectBy(orderInfo = order)
            ds = BossNewDetail.selectBy(header = header)
            images = []
            for it in items:
                if it.item.itemCode not in images : images.append(it.item.itemCode)
            layers = [layer for layer in BossiniFiberContentLayer.select(BossiniFiberContentLayer.q.orderInfo == order, orderBy = [BossiniFiberContentLayer.q.id])]
            return {
                "header" : header,
                "details" : ds,
                "order" : order,
                "items" : items,
                "images" :images,
                "tg_template" : "ecrm.templates.bossini.order_view_h",
                "layers" : layers,
                }
        elif order.orderType == "WOV" :
            items = WovenLabelInfo.selectBy(orderInfo = order)
            images = []
            for it in items:
                if it.item.itemCode not in images : images.append(it.item.display)

            return {
                "header" : header,
                "order" : order,
                "items" : items,
                "images" :images,
                "tg_template" : "ecrm.templates.bossini.order_view_w",
                }

        elif order.orderType == "F" :
            fcInfos = FunctionCardInfo.selectBy(orderInfo = order, status = 0)
            if fcInfos.count() < 1 :
                flash("没有这张订单的具体信息！")
                raise redirect("/index")

            return {
                "header" : header,
                "order" : order,
                "fcInfo" : fcInfos[0],
                "tg_template" : "ecrm.templates.bossini.order_view_fc",
                }

        elif order.orderType == "D" :
            djInfos = DownJacketInfo.selectBy(orderInfo = order, status = 0)
            if djInfos.count() < 1 :
                flash("没有这张订单的具体信息！")
                raise redirect("/index")

            return {
                "header" : header,
                "order" : order,
                "djInfo" : djInfos[0],
                "tg_template" : "ecrm.templates.bossini.order_view_d",
                }

        elif order.orderType == "CO" :
            coInfos = FunctionCardInfo.selectBy(orderInfo = order, status = 0)

            if coInfos.count() < 1:
                flash("没有这张订单的具体信息！")
                raise redirect("/index")

            coInfo = coInfos[0]

            return {
                "header" : header,
                "order" : order,
                "coInfo" : coInfo,
                "tg_template" : "ecrm.templates.bossini.order_view_c",
                }

        elif order.orderType == "S" :
            slInfos = StyleLabelInfo.selectBy(orderInfo = order, status = 0)
            if slInfos.count() < 1:
                flash("没有这张订单的具体信息！")
                raise redirect("/index")

            slInfo = slInfos[0]

            return {
                "header" : header,
                "order" : order,
                "slInfo" : slInfo,
                "tg_template" : "ecrm.templates.bossini.order_view_s",
                }

        elif order.orderType == "C" :
            clInfos = CareLabelInfo.selectBy(orderInfo = order, status = 0)
            if clInfos.count() < 1:
                flash("没有这张订单的具体信息！")
                raise redirect("/index")

            clInfo = clInfos[0]

            if clInfo.appendix:
                appendixList = [CareInstruction.get(a) for a in clInfo.appendix.split("|") if a]
            else:
                appendixList = []

            return {
                "header" : header,
                "order" : order,
                "clInfo" : clInfo,
                "tg_template" : "ecrm.templates.bossini.order_view_cl",
                "appendixList" : appendixList,
                }
        #add by cz@2010-10-14
        elif order.orderType == "BW" :
            bwInfo = BodyWearLabelInfo.selectBy(orderInfo = order)[0]
            if not bwInfo:
                flash("没有这张订单的具体信息！")
                raise redirect("/index")

            ds = BossNewDetail.selectBy(header = header)
            bwDetail = {}
            for d in ds:
                tmp = BodyWearLabelDetail.selectBy(bodyWearLabelInfo = bwInfo, bossNewDetail = d, active = 0)[0]
                bwDetail[d.id] = tmp.measure

            bcls = BossiniFiberContentLayer.selectBy(orderInfo = order)

            return {
                "header" : header,
                "details" : ds,
                "order" : order,
                "bwInfo" : bwInfo,
                "bwDetail" : bwDetail,
                "components" : bcls,
                "image" : bwInfo.item.itemCode ,
                "tg_template" : "ecrm.templates.bossini.order_view_bw",
                }
        #add by toly 2010-10-15
        elif order.orderType == "ST":
            sticker = StickerInfo.selectBy(orderInfo = order)[0]
            items = sticker.item
            ds = BossNewDetail.selectBy(header = header)
            contentLayers = BossiniFiberContentLayer.selectBy(orderInfo = order)
            appendix_ids = sticker.appendix.split('|')
            appendixlist = []
            if sticker.appendix:
                for i in appendix_ids:
                    id = int(i)
                    appendix = CareInstruction.get(id = id)
                    appendixlist.append(appendix)
            return {
                "sticker":sticker,
                "header" : header,
                "details" : ds,
                "order" : order,
                "items" : items,
                "contentLayers":contentLayers,
                "appendixlist":appendixlist,
                "tg_template" : "ecrm.templates.bossini.order_view_st",
                }
        #Main Label@2011-01-04.
        elif order.orderType == "WOV_M" :
            mlInfos = MainLabelInfo.selectBy(orderInfo = order, status = 0)
            if mlInfos.count() < 1:
                flash("没有这张订单的具体信息！")
                raise redirect("/index")

            mlInfo = mlInfos[0]

            return {
                "header" : header,
                "order" : order,
                "mlInfo" : mlInfo,
                "tg_template" : "ecrm.templates.bossini.order_view_m",
                }
        else:
            flash("没有这种订单类型！")
            raise redirect("/index")



    def _getBossiniDownloadPath(self):
        get = turbogears.config.get
        current = datetime.now()
        dateStr = current.today().strftime("%Y%m%d%H%M%S")
        fileDir = os.path.join(get("ecrm.downloads"), "bossini_download", identity.current.user_name, dateStr)
        if not os.path.exists(fileDir):
            os.makedirs(fileDir)
        return fileDir


    # gen the hang tag and waist card production file
    def _genHangTagProductionFile(self, poHeader, orderInfo, xlsFileName):
        fileDir = self._getBossiniDownloadPath()

        if poHeader.marketList == "CHN" :
            templatePath = os.path.join(os.path.abspath(os.path.curdir), "report_download/TEMPLATE/BOSSINI_PRODUCTION_CN_TEMPLATE.xls")
            if orderInfo["orderItems"].get("hangTag", ""):
                ic = orderInfo["orderItems"]["hangTag"]
                if ic in ['06BC75620902'] :
                    templatePath = os.path.join(os.path.abspath(os.path.curdir), "report_download/TEMPLATE/BOSSINI_PRODUCTION_CN_YB_TEMPLATE_1.xls")
                elif ic in ['06BC75630902', '06BC75640902', '06BC75770902'] :
                    templatePath = os.path.join(os.path.abspath(os.path.curdir), "report_download/TEMPLATE/BOSSINI_PRODUCTION_CN_YB_TEMPLATE_2.xls")
        else:
            templatePath = os.path.join(os.path.abspath(os.path.curdir), "report_download/TEMPLATE/BOSSINI_PRODUCTION_TEMPLATE.xls")

        rm = random.randint(1, 1000)
        copyTemplatePath = os.path.join(fileDir, "BOSSINSI_PRODUCTION_TEMPLATE_%d.xls" % rm)
        shutil.copyfile(templatePath, copyTemplatePath)

        isStickerOnly = True
        if orderInfo["orderItems"].get("hangTag", "") or orderInfo["orderItems"].get("waistCard", ""):
            isStickerOnly = False

        ds = BossNewDetail.selectBy(header = poHeader)
        result = []
        sumQty = 0
        sumTotal = 0
        if poHeader.marketList == "CHN":
            for d in ds:
                result.append(
                (poHeader.season, poHeader.collection, poHeader.itemType, poHeader.subCat, poHeader.poNo,
                 " ".join([orderInfo["orderItems"].get("hangTag", ""), orderInfo["orderItems"].get("sticker", "")]).strip(),
                 orderInfo["orderItems"].get("waistCard", ""),

                   #poHeader.lotCount,   #Changed by CL, on 2010-03-18 ,required by Joanna
                   poHeader.lotNum,
                   poHeader.printedLegacyCode, poHeader.marketList, poHeader.vendorCode, d.qty,
                   d.shipSampleQty, d.wastageQty,
                   d.totalQty if not isStickerOnly else d.wastageQty,
                   d.recolorCode, d.colorName, d.sizeCode, d.sizeName, d.resizeRange, d.length, d.printedNetPrice, d.blankPrice,
                   d.eanCode, d.frameColor,
                   orderInfo.get("typeName", ""), orderInfo.get("specification", ""), orderInfo.get("prodcuingArea", ""), orderInfo.get("unit", ""), orderInfo.get("grade", ""),
                   orderInfo.get("pricer", ""), "12358", "(020)81371188", orderInfo.get("productName", ""),
                   #update by CL.Lam on 2010-10-27,to solove the ACC problem
                   " ".join([orderInfo.get("standard", ""), orderInfo.get("standardExt", "")]) if orderInfo.get("standardExt", None) else orderInfo.get("standard", ""),
                   orderInfo.get("grade", ""), orderInfo.get("checker", ""), poHeader.printedLegacyCode, orderInfo.get("technicalType", ""),
                   "GB 18401-2003", orderInfo.get("processCompany", ""), d.collectionCode, d.launchMonth)
                )

                sumQty += d.qty
                sumTotal += d.totalQty
        else:
            for d in ds:
                tmp = [poHeader.season, poHeader.collection, poHeader.itemType, poHeader.subCat, poHeader.poNo,
                    " ".join([orderInfo["orderItems"].get("hangTag", ""), orderInfo["orderItems"].get("sticker", "")]).strip(),
                    orderInfo["orderItems"].get("waistCard", ""),
                   #poHeader.lotCount,    #Changed by CL, on 2010-03-18 ,required by Joanna
                   poHeader.lotNum,
                   poHeader.printedLegacyCode, poHeader.marketList, poHeader.vendorCode, d.qty,
                   d.shipSampleQty, d.wastageQty,
                   d.totalQty if not isStickerOnly else d.wastageQty,
                   d.recolorCode, d.colorName, d.sizeCode, d.sizeName, d.resizeRange, d.length, d.printedNetPrice, d.blankPrice,
                   d.eanCode, d.frameColor]
                tmp.extend(orderInfo.get("fiberContentLayer", []))
                result.append(tmp)
                sumQty += d.qty
                sumTotal += d.totalQty

        filename = os.path.join(fileDir, xlsFileName)
        ke = BossiniProductionExcel(templatePath = copyTemplatePath, destinationPath = filename)
        try:
            ke.inputData(POHeader = poHeader, orderInfo = orderInfo, data = result, qty = sumQty, totalQty = sumTotal)
            ke.outputData()
            return (1, filename)
        except:
            self.record_errorLog()
            traceback.print_exc()
            if ke:
                ke.clearData()
            return (0, "Error occur in the Excel Exporting !")



    @expose("json")
    def ajaxItemInfo(self, **kw):
        try:
            condition = [BossiniItem.q.active == 0, BossiniItem.q.itemType == kw["itemType"]]

            if kw["itemType"] == "WOV":
                condition.append(BossiniItem.q.labelType == kw["labelType"])

            #NEW updateby CL, on 2010-04-07
#            else : condition.append( LIKE(BossiniItem.q.itemCode,"%%%s" %getMarketCode(kw["marketList"])) )

            rs = BossiniItem.select(reduce(lambda x, y:x & y, condition), orderBy = [BossiniItem.q.itemCode])
            return {"result":[{"id":r.id, "itemCode":r.display, "rmbPrice":r.rmbPrice, "hkPrice":r.hkPrice} for r in rs]}

        except:
            self.record_errorLog()
            traceback.print_exc()
            return ""


    def checkVendor(self, id):
        try:
            result = Bossini.get(id)
            vendor = result.vendorCode
            isAdmin = self.judgeRight()
            if isAdmin[0]:
                return True
            elif isAdmin[1] == vendor:
                return True
            else:
                flash("You have no-right to view the PO#!")
                raise redirect("/bossinipo/index")
        except:
            self.record_errorLog()
            traceback.print_exc()
            flash("You have no-right to view the PO#!")
            raise redirect("/bossinipo/index")


    @expose("ecrm.templates.bossini.attachment")
    @tabFocus(tab_type = "main")
    def viewAttachment(self, **kw):
        h = getOr404(Bossini, kw["id"], "/bossinipo/index", "The record doesn't exist!")

        try:
            if not h.attachment: attachments = []
            else:   attachments = [UploadObject.get(a) for a in h.attachment.split("|")]
        except:
            self.record_errorLog()
            traceback.print_exc()
            flash("Error occur on the server side!")
            raise redirect("/bossinipo/showOrderInfo?id=%s" % kw["id"])
        return dict(header = h, attachments = attachments)


    @expose()
    def uploadAttachment(self, id, **kw):
        p = getOr404(Bossini, id, "/bossinipo/index", "The record doesn't exist!")

        try:
            relativePath = os.path.join("attachment_upload", "bossini")
            saveName = Date2Text(dateTimeFormat = "%Y%m%d%H%M%S" , defaultNow = True) + str(random.randint(1000, 9999)) + os.path.splitext(kw["filePath"].filename)[1]
            fileUpload(kw["filePath"], relativePath, saveName)
            u = UploadObject(name = kw["fileName"], path = os.path.join(relativePath, saveName), issuedBy = identity.current.user)
            p.attachment = str(u.id) if not p.attachment else "%s|%s" % (u.id, p.attachment)
        except:
            self.record_errorLog()
            traceback.print_exc()
            flash("Error occur on the server side!")
            raise redirect("/bossinipo/viewAttachment?id=%s" % id)
        flash("The file has been uploaded successfully!")
        raise redirect("/bossinipo/viewAttachment?id=%s" % id)


    @expose()
    def download(self, **kw):
        u = UploadObject.get(kw["fn"])
        filePath = os.path.join(os.path.abspath(os.path.curdir), u.path)
        return serveFile(filePath, "application/x-download", "attachment")


    @expose("json")
    def deleteDownload(self, **kw):
        try:
            s = Bossini.get(kw['id'])
        except:
            self.record_errorLog()
            traceback.print_exc()
            flash("The record doesn't exist!")
            return {"flag":1}

        fn = kw['fn']
        attachment = s.attachment
        newAttachment = "|".join(filter(lambda a:a != fn, attachment.split("|")))
        s.attachment = newAttachment
        flash("The attachment has been deleted successfully!")
        return {"flag" : 0}


    @expose(allow_json = True, format = "JSON")
    def ajaxSizeInfo(self, **kw):
        try:
            sizeStr = kw["size"]
            if sizeStr.isdigit() and sizeStr.startswith("0") :  sizeStr = sizeStr[1:]

            rs = BossiniSizeMapping.selectBy(size = sizeStr, weave = kw["weave"], line = kw["line"], status = 0)

            return {"result":[{"id":r.id, "measure":r.measure} for r in rs]}

        except:
            self.record_errorLog()
            traceback.print_exc()
            return {"result":[]}


    @expose(template = "ecrm.templates.bossini.history")
    @paginate('items', limit = 25)
    @tabFocus(tab_type = "main")
    def history(self, **kw):
        header = getOr404(Bossini, kw["id"], "/bossinipo/index", "The record doesn't exist!")
        if header.history:
            hs = [updateHistory.get(hid) for hid in header.history.split("|") if hid]
        else :
            hs = []

        fields = [("Time", lambda args:Date2Text(args.actionTime, FONTEND_DATE_TIME_FORMAT), {"width":"150"}),
                  ("User", "actionUser", {"width":"150"}), ("Action Kind", "actionKind", {"width":"100"}),
                  ("Content", "actionContent", {"width":"700"})]

        return dict(result_widget = widgets.PaginateDataGrid(fields = fields, template = "ecrm.templates.common.paginateDataGrid"),
                        items = hs,
                        POHeader = header
                        )


    @expose()
    def dispatch(self, **kw):
        #if it's admin / vendor / AE
        (flag, vendor) = self.judgeRight()
        if "Admin" in identity.current.groups:
            raise redirect("/bossinipo/index")
        elif vendor in self._getVendorList():
            raise redirect("/bossinipo/vendor_index")
        elif "AE" in identity.current.groups:
            raise redirect("/bossinipo/ae_search")
        else:
            flash("You are not permited to view the site!")
            raise redirect("/index")


    @expose(template = "ecrm.templates.bossini.vendor_index")
    @tabFocus(tab_type = "main")
    def vendor_index(self, **kw):
        (flag, vendor) = self.judgeRight()
        return {"vendorCode":vendor}


    @expose(template = "ecrm.templates.bossini.vendor_index1")
    @tabFocus(tab_type = "main")
    def vendor_index1(self, **kw):
        (flag, vendor) = self.judgeRight()
        return {"vendorCode":vendor}

    @expose(template = "ecrm.templates.bossini.vendor_index2")
    @paginate('items', limit = 40)
    @tabFocus(tab_type = "main")
    def vendor_index2(self, **kw):
        (flag, vendor) = self.judgeRight()
        if vendor not in self._getVendorList():
            raise redirect("/index")

        if kw:
            if kw["orderType"] == 'H' or kw["orderType"] == 'ST':
                conditions = []
                conditions.append(" h.latest_flag = 1 ")
                conditions.append(" o.active = 0 ")
                conditions.append(genCondition('o.order_type', kw.get("orderType", "")))
                conditions.append(genCondition("h.vendor_code", vendor))
                conditions.append(" h.is_complete = 1 ")

                _condition = ' AND '.join([c for c in conditions if c])
                sql = '''select o.id,o.confirm_date,o.filename,o.exit_factory_date,o.receipt_date,
					h.is_complete from bossini_order_info as o inner join bossini_header_po as h on h.id = o.po_id where %s
					order by o.last_modify_time desc''' % (_condition)

                conn = BossiniOrder._connection
                result = conn.queryAll(sql)
            else :
                sql = '''select o.id,o.confirm_date,o.filename,o.exit_factory_date,o.receipt_date
                       from bossini_order_info as o
                      inner join bossini_vendor as v
                         on o.vendor_id = v.id
                      where o.active = 0 and o.order_type='%s' and v.vendor_code='%s'
                      order by o.last_modify_time desc''' % (kw["orderType"], vendor)

                try:
                    conn = BossiniOrder._connection
                    result = conn.queryAll(sql)
                    print '*' * 30
                    print sql
                    print '#' * 30
                except:
                    self.record_errorLog()
                    logfile = open("log.file", "w")
                    traceback.print_exc(None, logfile)
                    logfile.close()
                    raise redirect("/bossinipo/vendor_index2")
        else:
            result = []

        def makeLink(dto):
            link = Element("a", attrib = {"href":"/bossinipo/showOrderInfo?id=%s" % str(dto[0])})
            link.text = "View Detail"
            return link

        field = [
                 ("Confirm Date", lambda dto:Date2Text(dto[1], "%Y-%m-%d %H:%M:%S"), {"width":"150", "height":"25"}),
                 ("File Name", lambda dto:dto[2], {"width":"600", "height":"25", "style":"color:red"}),
                 ("Reference Ex-factory date from r-pac", lambda dto:Date2Text(dto[3], "%Y-%m-%d"), {"width":"250", "height":"25"}),

                 ("View Detail", makeLink)
                 ]

        return dict(items = result,
                    search_widget = SearchHangType_form,
                    values = kw,
                    result_widget = widgets.PaginateDataGrid(fields = field, template = "ecrm.templates.common.paginateDataGrid"),
                    submit_action = "/bossinipo/vendor_index2",
#                    hangTag = hangTag,
                    )

    @expose(template = "ecrm.templates.bossini.vendor_index3")
    @paginate('items', limit = 40)
    @tabFocus(tab_type = "main")
    def vendor_index3(self, **kw):
        (flag, vendor) = self.judgeRight()
#        vendor_list = ["TR","GD","FNI","KFO","JS","LWF","TPL","TX","WM","WY","WJ","TestVendor1","TestVendor2","JCPenny"]        
        if vendor not in self._getVendorList():
            raise redirect("/index")
        conditions = []
        conditions.append(" h.latest_flag = 1 ")
        conditions.append(" h.is_complete = 0 ")
        conditions.append(" o.active = 0 ")
        conditions.append(" (o.order_type = 'H' OR o.order_type = 'ST') ")
        conditions.append(genCondition("h.vendor_code", vendor))

        _condition = ' AND '.join([c for c in conditions if c])
        sql = '''select o.id,o.confirm_date,o.filename,o.exit_factory_date,o.receipt_date,
             h.is_complete from bossini_order_info as o inner join bossini_header_po as h on h.id = o.po_id 
             where %s order by o.last_modify_time desc''' % (_condition)

        conn = BossiniOrder._connection
        result = conn.queryAll(sql)

        def makeLink(dto):
            link = Element("a", attrib = {"href":"/bossinipo/showOrderInfo?id=%s" % str(dto[0])})
            link.text = "View Detail"
            return link

        field = [
                 ("Confirm Date", lambda dto:Date2Text(dto[1], "%Y-%m-%d %H:%M:%S"), {"width":"150", "height":"25"}),
                 ("File Name", lambda dto:dto[2], {"width":"600", "height":"25", "style":"color:red"}),
                 ("Exit Factory Date", lambda dto:Date2Text(dto[3], "%Y-%m-%d"), {"width":"150", "height":"25"}),
                 ("Receipt Date", lambda dto:Date2Text(dto[4], "%Y-%m-%d"), {"width":"150", "height":"25"}),
                 ("View Detail", makeLink)
                 ]

        return dict(items = result,
#                    search_widget= SearchHangType_form,
                    values = kw,
                    result_widget = widgets.PaginateDataGrid(fields = field, template = "ecrm.templates.common.paginateDataGrid"),
                    submit_action = "/bossinipo/vendor_index3",
#                    hangTag = hangTag,
                    )

    @expose(allow_json = True, format = "JSON")
    def ajaxPOInfo(self, **kw):
        try:
            marketList = kw.get("marketList", None)
            vendorCode = kw.get("vendorCode", None)
            orderType = kw.get("orderType", None)

            conditions = [
                          Bossini.q.done == 1 , #the record is after 2009-12-09
                          Bossini.q.active == 1, #ths record  is active
                          Bossini.q.latestFlag == 1, #the PO is the latest
                          Bossini.q.vendorCode == vendorCode, #corresponding vendor
                          LIKE(Bossini.q.legacyCode, "8%"),
                          NOTIN(Bossini.q.id, Select(BossiniOrder.q.po, where = AND(BossiniOrder.q.orderType == orderType, BossiniOrder.q.active == 0)))
                          ]

            if orderType == "H":
                conditions.append(Bossini.q.marketList == marketList)  #corresponding market


            where = reduce(lambda a, b:a & b, conditions)
            os = Bossini.select(where, orderBy = ["legacyCode", ])
            return {"result" : [{"id":o.id, "info":"%s      %s" % (o.printedLegacyCode, o.poNo)} for o in os]}

        except:
            self.record_errorLog()
            traceback.print_exc()
            return {"result":[]}


    @expose()
    @tabFocus(tab_type = "main")
    def vendor_input(self, **kw):
        h = getOr404(Bossini, kw["poInfo"], "/bossinipo/vendor_index", "The record doesn't exist!")
        token = identity.current.user.user_name + datetime.now().strftime("%y%m%d%H%M%S") + str(random.randint(100, 999))
        token = sha.new(token).hexdigest()
        cherrypy.session["token"] = token

        try:
            ds = BossNewDetail.selectBy(header = h)
            vendor = Vendor.selectBy(vendorCode = h.vendorCode)[0]
            defaultBillToInfo = getDefaultBillToInfo(vendor)
            defaultShipToInfo = getDefaultShipToInfo(vendor)

            if kw["orderType"] == "H" :
                item, itemRange = self._presetHangTag(h)
                return {
                        "tg_template" : "ecrm.templates.bossini.order_input_h",
                        "header" : h,
                        "details" : ds,
                        "vendor" : vendor,
                        "item" : item,
                        "itemRange" : itemRange,
                        "defaultBillToInfo" : defaultBillToInfo,
                        "defaultShipToInfo" : defaultShipToInfo,
                        "token" :token,
                        "isComplete" : 1 if self._checkIsComplete(h) else 0
                        }
            elif kw["orderType"] == "WOV" :
                condition = [BossiniItem.q.active == 0, BossiniItem.q.itemType == 'WOV', BossiniItem.q.labelType == 'S']
                rs = BossiniItem.select(reduce(lambda x, y:x & y, condition), orderBy = [BossiniItem.q.itemCode])

                return {
                        "tg_template" : "ecrm.templates.bossini.order_input_w",
                        "header" : h,
                        "details" : ds,
                        "vendor" : vendor,
                        "defaultBillToInfo" : defaultBillToInfo,
                        "defaultShipToInfo" : defaultShipToInfo,
                        "token" :token,
                        "items" : rs,
                        }
            else:
                raise "No order type select"

        except:
            self.record_errorLog()
            traceback.print_exc()
            flash("Some problems occur on the server side, the servise is not available now.Please try it later.Thank you.")
            raise redirect("/bossinipo/vendor_index")



    def _presetHangTag(self, header):
        code = None
        if header.marketList == 'CHN':
            if header.line.startswith("BOSSINI YOUTH"): code = "06BC75630902"
            else : code = "01BC80191102"
        else:
            if header.line == "BOSSINI MEN" or header.line == "BOSSINI LADIES" :
                code = "01BC801411%s" % getMarketCode(header.marketList)
            elif header.line.startswith("BOSSINI YOUTH"):
                 code = "01BC801811%s" % getMarketCode(header.marketList)
            elif header.line == "BOSSINI BOYS" or header.line == "BOSSINI GIRLS":
                code = "03BC801611%s" % getMarketCode(header.marketList)
            elif header.line == "BOSSINI BABY":
                code = "08BC801711%s" % getMarketCode(header.marketList)

        try:
            item = BossiniItem.selectBy(itemCode = code, active = 0)[0]
            conditions = [BossiniItem.q.itemType == item.itemType, BossiniItem.q.active == 0]
            if item.itemType == "ST" : conditions.append(LIKE(BossiniItem.q.itemCode, "01BC801811%"),)

            itemRange = BossiniItem.select(AND(*conditions), orderBy = [BossiniItem.q.itemCode])

            return (item, itemRange)
        except:
            self.record_errorLog()
            traceback.print_exc()
            return (None, [])

    @expose(template = "ecrm.templates.bossini.ae_search")
    @identity.require(identity.in_any_group("AE", "Admin"))
    @paginate('items', limit = 25)
    @tabFocus(tab_type = "main")
    def ae_search(self, **kw):
        if kw:
            whereClause = [BossiniOrder.q.active == 0]

            if kw.get("confirmDateBegin", False) :whereClause.append(BossiniOrder.q.confirmDate >= kw["confirmDateBegin"])
            if kw.get("confirmDateEnd", False) : whereClause.append(BossiniOrder.q.confirmDate <= kw["confirmDateEnd"])
            if kw.get("customerOrderNo", False) :whereClause.append(LIKE(BossiniOrder.q.customerOrderNo, "%%%s%%" % kw["customerOrderNo"]))
            if kw.get("vendorCode", False) : whereClause.append(BossiniOrder.q.vendor == kw["vendorCode"])
            if not kw.get("orderType", False) or kw["orderType"] not in ["H", "WOV", "ST"]:
                if kw.get("orderType", False) : whereClause.append(BossiniOrder.q.orderType == kw["orderType"])
                where = reduce(lambda x, y:x & y, whereClause)
                result = BossiniOrder.select(where, orderBy = [DESC(BossiniOrder.q.confirmDate), ])
            else:
                whereClause.append(Bossini.q.done == 1)
                whereClause.append(Bossini.q.active == 1)
                whereClause.append(Bossini.q.latestFlag == 1)
                whereClause.append(BossiniOrder.q.po == Bossini.q.id)
                whereClause.append(BossiniOrder.q.orderType == kw["orderType"])

                if kw.get("marketList", False) : whereClause.append(Bossini.q.marketList == kw["marketList"])
                if kw.get("poNo", False):whereClause.append(Bossini.q.poNo == kw["poNo"])
                if kw.get("legacyCode", False):whereClause.append(LIKE(Bossini.q.legacyCode, "%%%s%%" % kw["legacyCode"]))
                if kw["orderType"] in ["H", "ST"] and kw.get("iscomplete", False) : whereClause.append(Bossini.q.isComplete == int(kw["iscomplete"]))
                where = reduce(lambda x, y:x & y, whereClause)
                result = BossiniOrder.select(join = INNERJOINOn(BossiniOrder, Bossini, where), orderBy = [DESC(BossiniOrder.q.confirmDate), ])

        else: result = []

        def makeCB(dto):
            cb = Element("input", attrib = {"type":"checkbox", "name":"order_id", "id":"order_id", "value":str(dto.id)})
            return cb

        def makeLink(dto):
            link = Element("a", attrib = {"href":"/bossinipo/showOrderInfo?id=%d" % dto.id})
            link.text = "View Detail"
            return link

        def formatEXDate(dto):
            if dto.exitFactoryDate: return dto.exitFactoryDate.strftime("%Y-%m-%d")
            else : return ""

        def formatRecDate(dto):
            if dto.receiptDate: return dto.receiptDate.strftime("%Y-%m-%d")
            else : return ""

        def isComplete(dto):
            if (dto.orderType == "H" or dto.orderType == "ST") and dto.po.isComplete == 0:
                cb = Element("span", attrib = {"width":"200", "height":"25", "style":"color:red"})
                cb.text = "Pending"
            else:
                cb = Element("span", attrib = {"width":"200", "height":"25", "style":"color:green"})
                cb.text = "Confirmed"
            return cb


        fields = [("", makeCB),
                  ("Confirm Date", "confirmDate", {"width":"150"}),
                  ("File Name", "filename", {"width":"650"}),
                  ("Exit Factory Date", formatEXDate, {"width":"130"}),
                  ("Receipt Date", formatRecDate, {"width":"130"}),
                  ("Status", isComplete, {"width":"100"}),
                  ("View Detail", makeLink, {"width":"100"})
                  ]

        return dict(items = result,
            search_widget = SearchWidget_form,
            values = kw,
            result_widget = widgets.PaginateDataGrid(fields = fields, template = "ecrm.templates.common.paginateDataGrid"),
            submit_action = "/bossinipo/ae_search")



    @expose("json")
    @tabFocus(tab_type = "main")
    def updateDate(self, **kw):
        try:
            x_date = kw.get("x_f_date", None)
            r_date = kw.get("r_date", None)

            if kw.get("ids", False):
                ids = [id for id in kw["ids"].split("|") if id]
            else:
                ids = []

            for id in ids:
                rs = BossiniOrder.get(id)
                if x_date: rs.exitFactoryDate = datetime.strptime(x_date, "%Y-%m-%d")
                if r_date: rs.receiptDate = datetime.strptime(r_date, "%Y-%m-%d")
            return {"flag":"0"}
        except:
            self.record_errorLog()
            traceback.print_exc()
            return {"flag":"1"}



    @expose()
    @tabFocus(tab_type = "main")
    def viewOrder(self, **kw):
        (falg, id) = rpacDecrypt(kw.get("code", ""))
        if not falg :
            flash("你输入的URL有误，请不要非法访问！")
            raise redirect("/bossinipo/vendor_index")

        order = getOr404(BossiniOrder, id, "/bossinipo/vendor_index", "你所要访问的记录不存在!")
        header = order.po

        if order.orderType == "H" :
            items = PrintingCardInfo.selectBy(orderInfo = order)
            ds = BossNewDetail.selectBy(header = header)
            layers = [layer for layer in BossiniFiberContentLayer.select(BossiniFiberContentLayer.q.orderInfo == order, orderBy = [BossiniFiberContentLayer.q.id])]

            return {
                "header" : header,
                "details" : ds,
                "order" : order,
                "items" : items,
                "tg_template" : "ecrm.templates.bossini.order_view_h",
                "layers" : layers,
                }

        elif order.orderType == "WOV" :
            items = WovenLabelInfo.selectBy(orderInfo = order)
            images = []
            for it in items:
                if it.item.itemCode not in images : images.append(it.item.display)

            return {
                "header" : header,
                "order" : order,
                "items" : items,
                "images" :images,
                "tg_template" : "ecrm.templates.bossini.order_view_w",
                }

        elif order.orderType == "F" :
            fcInfos = FunctionCardInfo.selectBy(orderInfo = order, status = 0)
            if fcInfos.count() < 1 :
                flash("没有这张订单的具体信息！")
                raise redirect("/index")

            return {
                "header" : header,
                "order" : order,
                "fcInfo" : fcInfos[0],
                "tg_template" : "ecrm.templates.bossini.order_view_fc",
                }

        elif order.orderType == "D" :
            djInfos = DownJacketInfo.selectBy(orderInfo = order, status = 0)
            if djInfos.count() < 1 :
                flash("没有这张订单的具体信息！")
                raise redirect("/index")

            return {
                "header" : header,
                "order" : order,
                "djInfo" : djInfos[0],
                "tg_template" : "ecrm.templates.bossini.order_view_d",
                }

        elif order.orderType == "S" :
            slInfos = StyleLabelInfo.selectBy(orderInfo = order, status = 0)
            if slInfos.count() < 1:
                flash("没有这张订单的具体信息！")
                raise redirect("/index")

            slInfo = slInfos[0]

            return {
                "header" : header,
                "order" : order,
                "slInfo" : slInfo,
                "tg_template" : "ecrm.templates.bossini.order_view_s",
                }

        elif order.orderType == "CO" :
            coInfos = FunctionCardInfo.selectBy(orderInfo = order, status = 0)

            if coInfos.count() < 1:
                flash("没有这张订单的具体信息！")
                raise redirect("/index")

            coInfo = coInfos[0]

            return {
                "header" : header,
                "order" : order,
                "coInfo" : coInfo,
                "tg_template" : "ecrm.templates.bossini.order_view_c",
                }

        elif order.orderType == "C" :
            clInfos = CareLabelInfo.selectBy(orderInfo = order, status = 0)
            if clInfos.count() < 1:
                flash("没有这张订单的具体信息！")
                raise redirect("/index")

            clInfo = clInfos[0]

            if clInfo.appendix:
                appendixList = [CareInstruction.get(a) for a in clInfo.appendix.split("|") if a]
            else:
                appendixList = []

            return {
                "header" : header,
                "order" : order,
                "clInfo" : clInfo,
                "tg_template" : "ecrm.templates.bossini.order_view_cl",
                "appendixList" : appendixList,
                }
        #add by cz@2010-10-14
        elif order.orderType == "BW" :
            bwInfo = BodyWearLabelInfo.selectBy(orderInfo = order)[0]
            if not bwInfo:
                flash("没有这张订单的具体信息！")
                raise redirect("/index")

            ds = BossNewDetail.selectBy(header = header)
            bwDetail = {}
            for d in ds:
                tmp = BodyWearLabelDetail.selectBy(bodyWearLabelInfo = bwInfo, bossNewDetail = d, active = 0)[0]
                bwDetail[d.id] = tmp.measure

            bcls = BossiniFiberContentLayer.selectBy(orderInfo = order)

            return {
                "header" : header,
                "details" : ds,
                "order" : order,
                "bwInfo" : bwInfo,
                "bwDetail" : bwDetail,
                "components" : bcls,
                "image" : bwInfo.item.itemCode ,
                "tg_template" : "ecrm.templates.bossini.order_view_bw",
                }
        #add by toly 2010-10-15
        elif order.orderType == "ST":
            sticker = StickerInfo.selectBy(orderInfo = order)[0]
            items = sticker.item
            ds = BossNewDetail.selectBy(header = header)
            contentLayers = BossiniFiberContentLayer.selectBy(orderInfo = order)
            appendix_ids = sticker.appendix.split('|')
            appendixlist = []
            if sticker.appendix:
                for i in appendix_ids:
                    id = int(i)
                    appendix = CareInstruction.get(id = id)
                    appendixlist.append(appendix)
            return {
                "sticker":sticker,
                "header" : header,
                "details" : ds,
                "order" : order,
                "items" : items,
                "contentLayers":contentLayers,
                "appendixlist":appendixlist,
                "tg_template" : "ecrm.templates.bossini.order_view_st",
                }
        #Main Label@2011-01-04.
        elif order.orderType == "WOV_M" :
            mlInfos = MainLabelInfo.selectBy(orderInfo = order, status = 0)
            if mlInfos.count() < 1:
                flash("没有这张订单的具体信息！")
                raise redirect("/index")

            mlInfo = mlInfos[0]

            return {
                "header" : header,
                "order" : order,
                "mlInfo" : mlInfo,
                "tg_template" : "ecrm.templates.bossini.order_view_m",
                }
        else:
            flash("没有这种订单类型！")
            raise redirect("/index")




    @expose(template = "ecrm.templates.bossini.detail")
    @tabFocus(tab_type = "main")
    def detail(self, **kw):
        self.checkVendor(kw["id"])
        try:
            h = Bossini.get(id = kw["id"])
            can_edit = h.latestFlag
        except:
            flash("The record doesn't exist!")
            raise redirect("index")

        bnd = BossNewDetail.selectBy(header = h)

        def makeQty(dto):
            e = Element("span", attrib = {"class":"tb-qty"})
            e.text = dto.qty
            return e

        def makeTotalQty(dto):
            e = Element("span", attrib = {"class":"tb-totalqty"})
            e.text = dto.totalQty
            return e
        def makePrice(dto):
            return XML(dto.priceInHTML)

        fields = [("Color Code", "recolorCode"), ("Color Name", "colorName"), ("Size Code", "sizeCode"), ("Size Name", "sizeName"),
                  ("size Range", "resizeRange"),
                  ("Hang Tag", "hangTag"), ("Waist Card", "waistCard"),
                  ("Frame Color", "frameColor"),
                  ("EAN Code", "eanCode"), ("Net Price", makePrice), ("Blank Price", "blankPrice"), ("PO Qty", makeQty), ("Total Qty", makeTotalQty)]

#        code=""
#        if h.hangTagType=="H" :
#            code=getCode(h.collection, h.marketList)
#        elif h.hangTagType=="W" :
#            pass
        hangTagOrders = BossiniOrder.selectBy(po = h, orderType = "H", active = 0)

        hangTagOrder = None if hangTagOrders.count() < 1 else hangTagOrders[0]

        wovenLabelOrders = BossiniOrder.selectBy(po = h, orderType = "WOV", active = 0)

        wovenLabelOrder = None if wovenLabelOrders.count() < 1 else wovenLabelOrders[0]

        stickerOrders = BossiniOrder.selectBy(po = h, orderType = "ST", active = 0)

        stickerOrder = None if stickerOrders.count() < 1 else stickerOrders[0]

        return dict(
                    poDetail_widget = widgets.DataGrid(fields = fields, template = "ecrm.templates.common.dataGrid"),
                    items = bnd,
                    POHeader = h,
                    can_edit = can_edit,
                    image_url = "/static/images/blank.png",
                    hangTagOrder = hangTagOrder,
                    wovenLabelOrder = wovenLabelOrder,
                    stickerOrder = stickerOrder,
                    needResolve = self._checkNeedResolve(h.poNo),
                    )


    @expose()
    def cancelOrder(self, **kw):
        order = getOr404(BossiniOrder, kw["id"], "/bossinipo/index", "The record is not exist!")

        if not identity.has_permission("BOSSINI_CANCEL_ORDER"):  #modify by CL on 2010-10-07, to release the cancel order access to AE
#        if not identity.in_group("Admin") :
            flash("You are not permitted to do this operation!")
            raise redirect("/bossinipo/dispatch")

        content = "User[%s] cancel Bossini order,record id is %d, order type is [%s]" % (identity.current.user, order.id, order.orderType)

        updateHistory(actionUser = identity.current.user, actionKind = "CANCEL ORDER", actionContent = content)
        order.active = 1
        flash("Cancel the order successfully!")
        raise redirect("/bossinipo/dispatch")




    #---------------------------- new add function ------------------------------
    @expose("ecrm.templates.bossini.order_input_fc")
    @tabFocus(tab_type = "main")
    def fcuntionCardOrder(self, **kw):
        token = identity.current.user.user_name + datetime.now().strftime("%y%m%d%H%M%S") + str(random.randint(100, 999))
        token = sha.new(token).hexdigest()
        cherrypy.session["token"] = token

        (flag, vendorCode) = self.judgeRight()
#        vendor_list = ["TR","GD","FNI","KFO","JS","LWF","TPL","TX","WM","WY","WJ"]        
        if vendorCode not in self._getVendorList():
            raise redirect("/bossinipo/index")


        try:
            vendor = Vendor.selectBy(vendorCode = vendorCode)[0]
            defaultBillToInfo = getDefaultBillToInfo(vendor)
            defaultShipToInfo = getDefaultShipToInfo(vendor)

            items = BossiniItem.select(AND(BossiniItem.q.active == 0, BossiniItem.q.itemType == "F"), orderBy = [BossiniItem.q.itemCode])

            legacyCodes = getLegacyCodeByVendor(vendorCode)

            return {
                    "vendor" : vendor,
                    "items" : items,
                    "defaultBillToInfo" : defaultBillToInfo,
                    "defaultShipToInfo" : defaultShipToInfo,
                    "token" :token,
                    "legacyCodes" : legacyCodes
                    }
        except:
            self.record_errorLog()
            traceback.print_exc()
            flash("The servise is not available now.Please try it later.Thank you.")
            raise redirect("/bossinipo/vendor_index")


    @expose()
    @tabFocus(tab_type = "main")
    def saveFunctionCardOrder(self, **kw):
        if "token" not in cherrypy.session or cherrypy.session["token"] != kw.get("token", None):
            flash("<strong>请不要重复提交订单信息，谢谢！</strong>")
            raise redirect("/bossinipo/vendor_index")

        hub.begin()
        try:
            history = updateHistory(actionUser = identity.current.user, actionKind = "Submit", actionContent = "User[%s] confirm the order[%s]." % (identity.current.user, kw.get("customerOrderNo", None)))
            vendor = Vendor.selectBy(vendorCode = kw.get("vendorCode"))[0]

            orderParams = self._prepareOrderHeader(kw)
            orderParams["vendor"] = vendor


            bo = BossiniOrder(**orderParams)
            tmp = BossiniItem.get(id = kw["item"])
            functionCard = FunctionCardInfo(orderInfo = bo, item = tmp, qty = int(kw["qty"]))

            legacyList = sorted([v for k, v in kw.items() if k.startswith("legacyCode") and v])

            for v in  legacyList:
                v = v.strip().replace("（", "(").replace("）", ")")
                lcs = BossiniLegacyCode.selectBy(legacyCode = v)
                if lcs.count() > 0:
                    lc = lcs[0]
                else:
                    lc = BossiniLegacyCode(legacyCode = v)
                FunctionCardInfoDetail(header = functionCard, legacyCode = lc)
                lc.addFunctionCardInfo(functionCard)

            #send email  
            feedbackStr = "%s %s %s" % (bo.customerOrderNo, functionCard.item, datetime.now().strftime("%d %b %Y"))
            self._sendNotifyEmail(vendor, kw.get("customerOrderNo", None), bo, feedbackStr)
            bo.filename = feedbackStr

            msg = ["Thank you %s. Please note that your Production Order No.<font color='green'>%s</font>  will now on the queue of production orders  of r-pac." % (vendor.vendorCode, kw.get("customerOrderNo", None)),
                   "Separate Confirmation e-mail will be sent to your e-mail address within 24-work hour.",
                   "",
                   "感谢您 %s,请注意贵司确认的生产订单：<font color='green'>%s</font> 已经送进 r-pac 订单操作的系统里,我司会在 24 小时内自动回传确认订单的电邮给贵公司的。" % (vendor.vendorCode, kw.get("customerOrderNo", None)),
                   ]
        except:
            self.record_errorLog()
            traceback.print_exc()
            hub.rollback()
            flash("对不起，系统出现错误，服务暂时不可用，订单未能提交，请稍后再试，谢谢。")
            raise redirect("/bossinipo/vendor_index")

        hub.commit()

        flash("<br />".join(msg))
        raise redirect("/bossinipo/vendor_index")


    @expose("ecrm.templates.bossini.order_input_cl")
    @tabFocus(tab_type = "main")
    def careLabelOrder(self, **kw):
        token = identity.current.user.user_name + datetime.now().strftime("%y%m%d%H%M%S") + str(random.randint(100, 999))
        token = sha.new(token).hexdigest()
        cherrypy.session["token"] = token

        (flag, vendorCode) = self.judgeRight()
        if vendorCode not in self._getVendorList():
            raise redirect("/bossinipo/index")

        try:
            vendor = Vendor.selectBy(vendorCode = vendorCode)[0]
            defaultBillToInfo = getDefaultBillToInfo(vendor)
            defaultShipToInfo = getDefaultShipToInfo(vendor)

            items = BossiniItem.select(AND(BossiniItem.q.active == 0, BossiniItem.q.itemType == "C"), orderBy = [BossiniItem.q.itemCode])
            legacyCodes = getLegacyCodeByVendor(vendorCode)

            ps = CareLabelPattern.selectBy(vendor = vendor, status = 0)
            if ps.count() == 0 :
                defaultPatterns = None
            else:
                defaultPatterns = ps

            return {
                    "vendor" : vendor,
                    "items" : items,
                    "defaultBillToInfo" : defaultBillToInfo,
                    "defaultShipToInfo" : defaultShipToInfo,
                    "token" :token,
                    "legacyCodes" : legacyCodes,
                    "defaultPatterns" : defaultPatterns,
                    }
        except:
            self.record_errorLog()
            traceback.print_exc()
            flash("The servise is not available now.Please try it later.Thank you.")
            raise redirect("/bossinipo/vendor_index")


    #new add by CL,on 2010-03-19
    @expose("ecrm.templates.bossini.vendor_new_order")
    @tabFocus(tab_type = "main")
    def vendor_new_order(self, **kw):
        (flag, vendor) = self.judgeRight()
        return {"vendorCode":vendor}

    @expose("ecrm.templates.bossini.vendor_h_order")
    @tabFocus(tab_type = "main")
    def vendor_h_order(self, **kw):
        (flag, vendor) = self.judgeRight()
        return {"vendorCode":vendor}


    @expose("ecrm.templates.bossini.vendor_w_allline")
    @tabFocus(tab_type = "main")
    def vendor_w_allline(self, **kw):
        return {}


    @expose("ecrm.templates.bossini.vendor_w_order")
    @tabFocus(tab_type = "main")
    def vendor_w_order(self, **kw):
        (flag, vendor) = self.judgeRight()
        conditions = [
              Bossini.q.done == 1 , #the record is after 2009-12-09
              Bossini.q.active == 1, #ths record  is active
              Bossini.q.latestFlag == 1, #the PO is the latest
              Bossini.q.vendorCode == vendor, #corresponding vendor,
              ((Bossini.q.line == 'BOSSINI MEN') | (Bossini.q.line == 'BOSSINI YOUTH M') | (Bossini.q.line == 'BOSSINI LADIES') | (Bossini.q.line == 'BOSSINI YOUTH F')),
              LIKE(Bossini.q.legacyCode, "8%"),
              NOTIN(Bossini.q.id, Select(BossiniOrder.q.po, where = AND(BossiniOrder.q.orderType == "WOV", BossiniOrder.q.active == 0)))
              ]
        where = reduce(lambda a, b:a & b, conditions)
        result = Bossini.select(where, orderBy = ["legacyCode", ])
        return {"vendorCode":vendor, "result":result}


        '''
        if kw.get("line", None):
            if kw["line"] not in ["men", "ladies"] :
                flash("No such order type!")
                raise redirect("/bossinipo/index")

            conditions=[
              Bossini.q.done==1 , #the record is after 2009-12-09
              Bossini.q.active==1, #ths record  is active
              Bossini.q.latestFlag==1, #the PO is the latest
              Bossini.q.vendorCode==vendor, #corresponding vendor,
#              Bossini.q.line==line,
              LIKE(Bossini.q.legacyCode, "8%"),
              NOTIN(Bossini.q.id, Select(BossiniOrder.q.po, where = AND(BossiniOrder.q.orderType=="WOV", BossiniOrder.q.active==0)))
              ]

            if kw["line"]=="men" :
                conditions.append((Bossini.q.line=='BOSSINI MEN')|(Bossini.q.line=='BOSSINI YOUTH M'))
            elif kw["line"]=="ladies":
                conditions.append((Bossini.q.line=='BOSSINI LADIES')|(Bossini.q.line=='BOSSINI YOUTH F'))


            where=reduce(lambda a, b:a&b, conditions)
            result=Bossini.select(where, orderBy = ["legacyCode", ])

            return {"vendorCode":vendor, "result":result}
        else:
            flash("No such order type!")
            raise redirect("/bossinipo/index")
        '''



    @expose("ecrm.templates.bossini.order_input_s")
    @tabFocus(tab_type = "main")
    def styleLabelOrder(self, **kw):
        token = identity.current.user.user_name + datetime.now().strftime("%y%m%d%H%M%S") + str(random.randint(100, 999))
        token = sha.new(token).hexdigest()
        cherrypy.session["token"] = token

        (flag, vendorCode) = self.judgeRight()
#        vendor_list = ["TR","GD","FNI","KFO","JS","LWF","TPL","TX","WM","WY","WJ"]        
        if vendorCode not in self._getVendorList():
            raise redirect("/bossinipo/index")


        try:
            vendor = Vendor.selectBy(vendorCode = vendorCode)[0]
            defaultBillToInfo = getDefaultBillToInfo(vendor)
            defaultShipToInfo = getDefaultShipToInfo(vendor)

            items = BossiniItem.select(AND(BossiniItem.q.active == 0, BossiniItem.q.itemType == "S"), orderBy = [BossiniItem.q.itemCode])

            legacyCodes = getLegacyCodeByVendor(vendorCode)

            return {
                    "vendor" : vendor,
                    "items" : items,
                    "defaultBillToInfo" : defaultBillToInfo,
                    "defaultShipToInfo" : defaultShipToInfo,
                    "token" :token,
                    "legacyCodes" : legacyCodes
                    }
        except:
            self.record_errorLog()
            traceback.print_exc()
            flash("The servise is not available now.Please try it later.Thank you.")
            raise redirect("/bossinipo/vendor_index")


    @expose()
    def saveStyleLabelOrder(self, **kw):
        if "token" not in cherrypy.session or cherrypy.session["token"] != kw.get("token", None):
            flash("<strong>请不要重复提交订单信息，谢谢！</strong>")
            raise redirect("/bossinipo/vendor_index")

        hub.begin()
        try:
            history = updateHistory(actionUser = identity.current.user, actionKind = "Submit", actionContent = "User[%s] confirm the order[%s]." % (identity.current.user, kw.get("customerOrderNo", None)))
            vendor = Vendor.selectBy(vendorCode = kw.get("vendorCode"))[0]

            orderParams = self._prepareOrderHeader(kw)
            orderParams["vendor"] = vendor

            bo = BossiniOrder(**orderParams)
            tmp = BossiniItem.get(id = kw["item"])
            styleLabel = StyleLabelInfo(orderInfo = bo, item = tmp)

            legacyList = sorted([k for k, v in kw.items() if k.startswith("legacyCode") and v])

            for key in  legacyList:
                v = kw[key]
                v = v.strip().replace("（", "(").replace("）", ")")
                lcs = BossiniLegacyCode.selectBy(legacyCode = v)
                if lcs.count() > 0:
                    lc = lcs[0]
                else:
                    lc = BossiniLegacyCode(legacyCode = v)
#                lc.addFunctionCardInfo(styleLabel)
                qty = int(kw[key.replace("legacyCode", "qty")])
                StyleLabelInfoDetail(header = styleLabel, legacyCode = lc, qty = qty)

            #send email 
            feedbackStr = "%s %s %s" % (bo.customerOrderNo, styleLabel.item, datetime.now().strftime("%d %b %Y"))
            self._sendNotifyEmail(vendor, kw.get("customerOrderNo", None), bo, feedbackStr)
            bo.filename = feedbackStr

            msg = ["Thank you %s. Please note that your Production Order No.<font color='green'>%s</font>  will now on the queue of production orders  of r-pac." % (vendor.vendorCode, kw.get("customerOrderNo", None)),
                   "Separate Confirmation e-mail will be sent to your e-mail address within 24-work hour.",
                   "",
                   "感谢您 %s,请注意贵司确认的生产订单：<font color='green'>%s</font> 已经送进 r-pac 订单操作的系统里,我司会在 24 小时内自动回传确认订单的电邮给贵公司的。" % (vendor.vendorCode, kw.get("customerOrderNo", None)),
                   ]
        except:
            self.record_errorLog()
            traceback.print_exc()
            hub.rollback()
            flash("对不起，系统出现错误，服务暂时不可用，订单未能提交，请稍后再试，谢谢。")
            raise redirect("/bossinipo/vendor_index")

        hub.commit()

        flash("<br />".join(msg))
        raise redirect("/bossinipo/vendor_index")



    def _prepareOrderHeader(self, kw):
        orderParams = {"po": None, "issuedBy" : identity.current.user, "lastModifyBy" : identity.current.user, "lastModifyTime" : datetime.now(),
                       "billTo" :None if not kw.get("billTo", False) else VendorBillToInfo.get(kw["billTo"]),
                       "billToAddress" : kw.get("billToAddress", None), "billToContact" : kw.get("billToContact", None),
                       "billToTel" : kw.get("billToTel", None),
                       "billToEmail" : kw.get("billToEmail", None), "currency":kw.get("currency", None), "payterm" : kw.get("payterm", None),
                       "shipmentInstruction" : kw.get("shipmentInstruction", None),
                       "VATInfo" : kw.get("VATInfo", None),
                       "invoiceInfo" : kw.get("invoiceInfo", None), "accountContact" : kw.get("accountContact", None),
                       "shipTo" : None if not kw.get("shipTo", False) else VendorShipToInfo.get(kw["shipTo"]),
                       "shipToAddress" : kw.get("shipToAddress", None),
                       "shipToContact" : kw.get("shipToContact", None), "shipToTel" : kw.get("shipToTel", None),
                       "shipToEmail" : kw.get("shipToEmail", None),
                       "sampleReceiver" : kw.get("sampleReceiver", None), "sampleReceiverTel" : kw.get("sampleReceiverTel", None),
                       "sampleSendAddress" : kw.get("sampleSendAddress", None), "requirement" : kw.get("requirement", None),
                       "customerOrderNo" : kw.get("customerOrderNo", None),
                       "vendor" : kw.get("vendorCode", None), "orderType":kw["orderType"]
                           }
        return orderParams


    def _sendNotifyEmail(self, vendor, customerOrderNo, bossiniOrder, subject, files = []):
        #send email 
        send_from = "r-pac-Bossini-order-system"

        try:
            send_to = vendor.feedbackEmail.split(";") + vendor.aeEmail.split(";")
        except:
            try:
                send_to = identity.current.user.email_address.split(";")
            except:
                send_to = turbogears.config.get("Bossini_order_sendto").split(";")

        text = ["Thank you for your confirmation!",
                "You could view the order's detail information via the link below:",
                "%s/bossinipo/viewOrder?code=%s" % (turbogears.config.get("website_url"), rpacEncrypt(bossiniOrder.id)) ,
                "\n\n************************************************************************************",
                "This e-mail is sent by the r-pac Bossini ordering system automatically.",
                "Please don't reply this e-mail directly!",
                "************************************************************************************"
                ]
        cc_to = turbogears.config.get("Bossini_order_cc").split(";")
        send_mail(send_from, send_to, subject, "\n".join(text), cc_to, files)


    @expose("ecrm.templates.bossini.order_input_c")
    @tabFocus(tab_type = "main")
    def COOrder(self, **kw):
        token = identity.current.user.user_name + datetime.now().strftime("%y%m%d%H%M%S") + str(random.randint(100, 999))
        token = sha.new(token).hexdigest()
        cherrypy.session["token"] = token

        (flag, vendorCode) = self.judgeRight()
#        vendor_list = ["TR","GD","FNI","KFO","JS","LWF","TPL","TX","WM","WY","WJ"]        
        if vendorCode not in self._getVendorList():
            raise redirect("/bossinipo/index")


        try:
            vendor = Vendor.selectBy(vendorCode = vendorCode)[0]
            defaultBillToInfo = getDefaultBillToInfo(vendor)
            defaultShipToInfo = getDefaultShipToInfo(vendor)
            items = BossiniItem.select(AND(BossiniItem.q.active == 0, BossiniItem.q.itemType == "CO"), orderBy = [BossiniItem.q.itemCode])
            legacyCodes = getLegacyCodeByVendor(vendorCode)
            return {
                    "vendor" : vendor,
                    "items" : items,
                    "defaultBillToInfo" : defaultBillToInfo,
                    "defaultShipToInfo" : defaultShipToInfo,
                    "token" :token,
                    "legacyCodes" : legacyCodes
                    }
        except:
            self.record_errorLog()
            traceback.print_exc()
            flash("The servise is not available now.Please try it later.Thank you.")
            raise redirect("/bossinipo/vendor_index")


    @expose()
    def saveCOOrder(self, **kw):
        if "token" not in cherrypy.session or cherrypy.session["token"] != kw.get("token", None):
            flash("<strong>请不要重复提交订单信息，谢谢！</strong>")
            raise redirect("/bossinipo/vendor_index")

        hub.begin()
        try:
            history = updateHistory(actionUser = identity.current.user, actionKind = "Submit", actionContent = "User[%s] confirm the order[%s]." % (identity.current.user, kw.get("customerOrderNo", None)))
            vendor = Vendor.selectBy(vendorCode = kw.get("vendorCode"))[0]

            orderParams = self._prepareOrderHeader(kw)
            orderParams["vendor"] = vendor


            bo = BossiniOrder(**orderParams)
            tmp = BossiniItem.get(id = kw["item"])
            functionCard = FunctionCardInfo(orderInfo = bo, item = tmp, qty = int(kw["qty"]))

            legacyList = sorted([v for k, v in kw.items() if k.startswith("legacyCode") and v])

            for v in  legacyList:
                v = v.strip().replace("（", "(").replace("）", ")")
                lcs = BossiniLegacyCode.selectBy(legacyCode = v)
                if lcs.count() > 0:
                    lc = lcs[0]
                else:
                    lc = BossiniLegacyCode(legacyCode = v)
                FunctionCardInfoDetail(header = functionCard, legacyCode = lc)
                lc.addFunctionCardInfo(functionCard)

            #send email 
            feedbackStr = "%s %s %s" % (bo.customerOrderNo, functionCard.item, datetime.now().strftime("%d %b %Y"))
            self._sendNotifyEmail(vendor, kw.get("customerOrderNo", None), bo, feedbackStr)
            bo.filename = feedbackStr

            msg = ["Thank you %s. Please note that your Production Order No.<font color='green'>%s</font>  will now on the queue of production orders  of r-pac." % (vendor.vendorCode, kw.get("customerOrderNo", None)),
                   "Separate Confirmation e-mail will be sent to your e-mail address within 24-work hour.",
                   "",
                   "感谢您 %s,请注意贵司确认的生产订单：<font color='green'>%s</font> 已经送进 r-pac 订单操作的系统里,我司会在 24 小时内自动回传确认订单的电邮给贵公司的。" % (vendor.vendorCode, kw.get("customerOrderNo", None)),
                   ]
        except:
            self.record_errorLog()
            traceback.print_exc()
            hub.rollback()
            flash("对不起，系统出现错误，服务暂时不可用，订单未能提交，请稍后再试，谢谢。")
            raise redirect("/bossinipo/vendor_index")

        hub.commit()

        flash("<br />".join(msg))
        raise redirect("/bossinipo/vendor_index")


    def _filterAndSorted(self, prefix, kw):
        return sorted(filter(lambda (k, v): k.startswith(prefix), kw.iteritems()), cmp = lambda x, y:cmp(x[0], y[0]))


    @expose()
    def saveCareLabelOrder(self, **kw):
        if "token" not in cherrypy.session or cherrypy.session["token"] != kw.get("token", None):
            flash("<strong>请不要重复提交订单信息，谢谢！</strong>")
            raise redirect("/bossinipo/vendor_index")

        hub.begin()
        try:
            history = updateHistory(actionUser = identity.current.user, actionKind = "Submit", actionContent = "User[%s] confirm the order[%s]." % (identity.current.user, kw.get("customerOrderNo", None)))
            vendor = Vendor.selectBy(vendorCode = kw["vendorCode"])[0]

            orderParams = self._prepareOrderHeader(kw)
            orderParams["vendor"] = vendor
            #Modify by CL on 2010-06-04 , the care label order no is assign by system .
            orderParams["customerOrderNo"] = "%s_CARELABEL_%s" % (kw["vendorCode"], datetime.now().strftime("%m%d%H%M"))

            bo = BossiniOrder(**orderParams)

            careLabeParams = {
                              "item" : BossiniItem.get(id = kw["itemCode"]) if kw.get("itemCode", False) else None,
                              "origin" : Origin.get(kw["origin"]) if kw.get("origin", False) else None,
                              "washing" : CareInstruction.get(kw["washing"]) if kw.get("washing", False) else None,
                              "bleaching" : CareInstruction.get(kw["bleaching"]) if kw.get("bleaching", False) else None,
                              "ironing" : CareInstruction.get(kw["ironing"]) if kw.get("ironing", False) else None,
                              "dryCleaning" : CareInstruction.get(kw["dryCleaning"]) if kw.get("dryCleaning", False) else None,
                              "drying" : CareInstruction.get(kw["drying"]) if kw.get("drying", False) else None,
                              "othersDrying" : CareInstruction.get(kw["othersDrying"]) if kw.get("othersDrying", False) else None,
                              }

#            def filterAndSorted(prefix):
#                return sorted( filter(lambda (k,v): k.startswith(prefix),kw.iteritems()),cmp=lambda x,y:cmp(x[0],y[0]) )

            appendixList = self._filterAndSorted("appendix", kw)
            careLabeParams["appendix"] = "|".join([av for (ak, av) in appendixList if av]) if appendixList else None

            cli = CareLabelInfo(orderInfo = bo, **careLabeParams)
            parts = self._filterAndSorted("part_", kw)
            for pk, pv in parts:
                fieldName, index1, index2 = pk.split("_")
                percentagePrefix = "_".join(["percentage", index1, index2])
                percentageList = self._filterAndSorted(percentagePrefix, kw)

                if not any([perval for (perkey, perval) in percentageList]) : continue

                fibercontentPrefix = "_".join(["fibercontent", index1, index2])
                fibercontentList = self._filterAndSorted(fibercontentPrefix, kw)

                coatingName = "_".join(["coating", index1, index2])
                coating = kw[coatingName] if kw.get(coatingName, False) else None

                microelementName = "_".join(["microelement", index1, index2])
                microelement = kw[microelementName] if kw.get(microelementName, False) else None

                clch = CareLabelComponentHeader(careLabelInfo = cli, name = (Parts.get(pv) if pv else None), coating = coating, microelement = microelement)

                for (pfk, pfv), (ffk, ffv) in zip(percentageList, fibercontentList):
                    if pfv and ffv :  CareLabelComponentDetail(header = clch, percentage = pfv, component = FiberContent.get(ffv))

            #updated by CL on 2011-03-01
            legacyCodeList = self._filterAndSorted("legacyCode", kw)
            qtyList = self._filterAndSorted("qty", kw)
            customerPOs = self._filterAndSorted("customerOrderNo", kw)
            for (legacyCodeField, legacyCodeValue), (qtyField, qtyValue), (cpoField, cpoValue) in zip(legacyCodeList, qtyList, customerPOs):
                if qtyValue and cpoValue:
                    if legacyCodeValue:
                        legacyCodeValue = legacyCodeValue.strip().replace("（", "(").replace("）", ")")
                        lcs = BossiniLegacyCode.selectBy(legacyCode = legacyCodeValue, status = 0)
                        if lcs.count() > 0:
                            legacyCode = lcs[0]
                        else:
                            legacyCode = BossiniLegacyCode(legacyCode = legacyCodeValue)
                    else:
                        legacyCode = None
                    CareLabelInfoDetail(header = cli, legacyCode = legacyCode, qty = int(qtyValue), customerOrderNo = cpoValue)


            #gen production file
            feedbackStr = "%s %s %s" % (bo.customerOrderNo, cli.item, datetime.now().strftime("%d %b %Y"))
            xlsFileName = "%s.xls" % feedbackStr
            #synchronize the excel generation , update by CL on 2010-07-05
            self.myLock.acquire()
            (flag, filePath) = self._genCareLabelProductionFile(cli, xlsFileName)
            self.myLock.release()
            if not flag: raise "Error occur on when generating the production report!"
            bo.filename = feedbackStr

            send_from = "r-pac-Bossini-order-system"
            try:
                send_to = vendor.feedbackEmail.split(";") + vendor.aeEmail.split(";")
            except:
                try:
                    send_to = identity.current.user.email_address.split(";")
                except:
                    send_to = turbogears.config.get("Bossini_order_sendto").split(";")

            text = ["Thank you for your confirmation!",
                    "You could view the order's detail information via the link below:",
                    "%s/bossinipo/viewOrder?code=%s" % (turbogears.config.get("website_url"), rpacEncrypt(bo.id)) ,
                    "\n\nProduction file for vendor :",
                    "%s/bossinipo/vendorCareLabelOrder?code=%s" % (turbogears.config.get("website_url"), rpacEncrypt(bo.id)) ,
                    "\n\n************************************************************************************",
                    "This e-mail is sent by the r-pac Bossini ordering system automatically.",
                    "Please don't reply this e-mail directly!",
                    "************************************************************************************"
                    ]
            cc_to = turbogears.config.get("Bossini_order_cc").split(";")
            send_mail(send_from, send_to, feedbackStr, "\n".join(text), cc_to, [filePath])

            msg = ["Thank you %s. Please note that your Production Order No.<font color='green'>%s</font>  will now on the queue of production orders  of r-pac." % (vendor.vendorCode, bo.customerOrderNo),
                   "Separate Confirmation e-mail will be sent to your e-mail address within 24-work hour.",
                   "",
                   "感谢您 %s,请注意贵司确认的生产订单：<font color='green'>%s</font> 已经送进 r-pac 订单操作的系统里,我司会在 24 小时内自动回传确认订单的电邮给贵公司的。" % (vendor.vendorCode, bo.customerOrderNo),
                   ]
        except:
            self.record_errorLog()
            traceback.print_exc()
            hub.rollback()
            flash("对不起，系统出现错误，服务暂时不可用，订单未能提交，请稍后再试，谢谢。")
            raise redirect("/bossinipo/vendor_index")

        hub.commit()

        flash("<br />".join(msg))
        raise redirect("/bossinipo/vendor_index")


    def _genCareLabelProductionFile(self, careLabelObj, xlsFileName):
        fileDir = self._getBossiniDownloadPath()
        templatePath = os.path.join(os.path.abspath(os.path.curdir), "report_download/TEMPLATE/BOSSINI_CARELABEL_TEMPLATE.xls")
        rm = random.randint(1, 1000)
        copyTemplatePath = os.path.join(fileDir, "BOSSINI_CARELABEL_TEMPLATE_%d.xls" % rm)
        shutil.copyfile(templatePath, copyTemplatePath)
        filename = os.path.join(fileDir, xlsFileName)
        bclo = BossiniCareLabelOrder(templatePath = copyTemplatePath, destinationPath = filename)

        info = {}

        languages = ["China", "HKSINEXP", "TWN", "Egypt", "Romanian", "Poland", "Russia", "Japanese", "French",
                     "Germany", "Spanish", "Italian", "Indonesia", "Ukrainian", "Portuguese"]
        info["coContent"] = "\n".join([getattr(careLabelObj.origin, language) for language in languages])

        appendixObjList = [] if not careLabelObj.appendix else [CareInstruction.get(aID) for aID in careLabelObj.appendix.split("|") if aID]
        info["appendixSC"] = ",".join([ao.contentSC for ao in appendixObjList if ao.contentSC])
        info["appendixTC"] = ",".join([ao.contentTC for ao in appendixObjList if ao.contentTC])
        info["appendixEN"] = ".".join([ao.contentEn for ao in appendixObjList if ao.contentEn])
        info["appendixIN"] = ".".join([ao.Indonesia for ao in appendixObjList if ao.Indonesia])

        info["careInstruction"] = ".".join(filter(lambda v:v, [ careLabelObj.washing.contentEn,
                                             careLabelObj.bleaching.contentEn,
                                             careLabelObj.drying.contentEn if careLabelObj.drying else careLabelObj.othersDrying.contentEn,
                                             careLabelObj.ironing.contentEn,
                                             careLabelObj.dryCleaning.contentEn,
                                             ]))


        partsStrList = [u"成分含量/CONTENTS/成分含量:"]
        components = careLabelObj.getComponents()
        for component in careLabelObj.getComponents():
            if component.name:
                partsStrList.append("%s :" % "/".join([component.name.contentSC, component.name.content, component.name.contentTC]))

            componentDetails = component.getDetail()
            if componentDetails.count() == 1 :
                d = componentDetails[0]

                firstStr = d.component.China
                if component.coating :  firstStr = u"%s(加涂层)" % firstStr
                elif component.microelement : firstStr = u"%s(含微量其它纤维)" % firstStr

                componentContentList = [firstStr] + [getattr(d.component, language) for language in languages[1:]]
                partsStrList.append("%s%% %s" % (d.percentage, "/".join(componentContentList)))

            elif componentDetails.count() > 1 :
                for d in  componentDetails:
                    componentContentList = [getattr(d.component, language) for language in languages]
                    partsStrList.append("%s%% %s" % (d.percentage, "/".join(componentContentList)))
                if component.coating : partsStrList.append(u'(加涂层)')
                if component.microelement :  partsStrList.append(u'(含微量其它纤维)')

        info["parts"] = "\n".join(partsStrList)

        iconMarkets = ["CHN", "EXP", "TWN", "POLAN", "JAPAN"]
        if careLabelObj.drying:
            attrList = ["washing", "bleaching", "drying", "ironing", "dryCleaning"]
        else:
            attrList = ["washing", "bleaching", "othersDrying", "ironing", "dryCleaning"]

        iconsList = []
        imgDir = os.path.join(os.path.abspath(os.path.curdir), "ecrm/static/images/bossini/care_label")
        for index, ic in enumerate(iconMarkets):
            imgList = []
            for attr in attrList:
                obj = getattr(careLabelObj, attr)
                img = "%s_%s_%d.jpg" % (ic, obj.instructionType, obj.styleIndex)
                imgPath = os.path.join(imgDir, ic, img)
                if os.path.exists(imgPath):
                    imgList.append(imgPath)
                else:
                    imgList.append(None)
            iconsList.append(imgList)

        info["iconsList"] = iconsList
        info["fileName"] = xlsFileName.replace(".xls", "")
        try:
            bclo.inputData(info)
            bclo.outputData()
            return (1, filename)
        except:
            self.record_errorLog()
            traceback.print_exc()
            if bclo:
                bclo.clearData()
            return (0, "Error occur in the Excel Exporting !")


    @expose("ecrm.templates.bossini.order_input_d")
    @tabFocus(tab_type = "main")
    def downJacketOrder(self, **kw):
        token = identity.current.user.user_name + datetime.now().strftime("%y%m%d%H%M%S") + str(random.randint(100, 999))
        token = sha.new(token).hexdigest()
        cherrypy.session["token"] = token

        (flag, vendorCode) = self.judgeRight()
#        vendor_list = ["TR","GD","FNI","KFO","JS","LWF","TPL","TX","WM","WY","WJ"]        
        if vendorCode not in self._getVendorList():
            raise redirect("/bossinipo/index")

        try:
            vendor = Vendor.selectBy(vendorCode = vendorCode)[0]
            defaultBillToInfo = getDefaultBillToInfo(vendor)
            defaultShipToInfo = getDefaultShipToInfo(vendor)

            items = BossiniItem.select(AND(BossiniItem.q.active == 0, BossiniItem.q.itemType == "D"), orderBy = [BossiniItem.q.itemCode])

            legacyCodes = getLegacyCodeByVendor(vendorCode)

            return {
                    "vendor" : vendor,
                    "items" : items,
                    "defaultBillToInfo" : defaultBillToInfo,
                    "defaultShipToInfo" : defaultShipToInfo,
                    "token" :token,
                    "legacyCodes" : legacyCodes
                    }
        except:
            self.record_errorLog()
            traceback.print_exc()
            flash("The servise is not available now.Please try it later.Thank you.")
            raise redirect("/bossinipo/vendor_index")


    @expose()
    def saveDownJacketOrder(self, **kw):
        if "token" not in cherrypy.session or cherrypy.session["token"] != kw.get("token", None):
            flash("<strong>请不要重复提交订单信息，谢谢！</strong>")
            raise redirect("/bossinipo/vendor_index")

        hub.begin()
        try:
            history = updateHistory(actionUser = identity.current.user, actionKind = "Submit", actionContent = "User[%s] confirm the order[%s]." % (identity.current.user, kw.get("customerOrderNo", None)))
            vendor = Vendor.selectBy(vendorCode = kw.get("vendorCode"))[0]

            orderParams = self._prepareOrderHeader(kw)
            orderParams["vendor"] = vendor

            bo = BossiniOrder(**orderParams)
            tmp = BossiniItem.get(id = kw["item"])

            fillingParams = {"downContent":int(kw["downContent"])}

            if tmp.component == "Nylon" :
#                for f in ["filling165","filling170","filling175","filling180","filling185"]:
#                    fillingParams[f] = int(kw[f])
#                    
                fillingNormal = self._filterAndSorted("filling1", kw)
                fillingWomen = self._filterAndSorted("fillingW", kw)
                if any(map(lambda (a, b):b, fillingNormal)):
                    for (k, v) in fillingNormal:
                        if v : fillingParams[k] = int(v)
                elif any(map(lambda (a, b):b, fillingWomen)):
                    for (k, v) in fillingWomen:
                        if v : fillingParams[k] = int(v)


            elif tmp.component == "Satin":
                fillingChildren = self._filterAndSorted("fillingC", kw)
                fillingBB = self._filterAndSorted("fillingB", kw)

                #if all( map(lambda (a,b):b,fillingChildren) ):
                #if it's the children size , the '160/80' and '170/84' could be blank.
#                fillingChildrenNeedCheck = filter(lambda (fa,fb):not fa.endswith("160") and not fa.endswith("170"),fillingChildren )
#                if all( map(lambda (a,b):b,fillingChildrenNeedCheck) ):  
#                    for (fck,fcv) in fillingChildren : fillingParams[fck] = None if not fcv else int(fcv)
#                elif all( map(lambda (a,b):b,fillingBB) ):
#                    for (fbk,fbv) in fillingBB : fillingParams[fbk] = int(fbv)
#                    

                if any(map(lambda (a, b):b, fillingChildren)):
                    for k, v in fillingChildren:
                        if v : fillingParams[k] = int(v)
                elif any(map(lambda (a, b):b, fillingBB)):
                    for k, v in fillingBB:
                        if v : fillingParams[k] = int(v)

            downJacket = DownJacketInfo(orderInfo = bo, item = tmp, qty = int(kw["qty"]), **fillingParams)

            legacyList = sorted([v for k, v in kw.items() if k.startswith("legacyCode") and v])

            for v in  legacyList:
                v = v.strip().replace("（", "(").replace("）", ")")
                lcs = BossiniLegacyCode.selectBy(legacyCode = v)
                if lcs.count() > 0:
                    lc = lcs[0]
                else:
                    lc = BossiniLegacyCode(legacyCode = v)
                DownJacketInfoDetail(header = downJacket, legacyCode = lc)
                lc.addFunctionCardInfo(downJacket)

            #send email  
            feedbackStr = "%s %s %s" % (bo.customerOrderNo, downJacket.item, datetime.now().strftime("%d %b %Y"))
            self._sendNotifyEmail(vendor, kw.get("customerOrderNo", None), bo, feedbackStr)
            bo.filename = feedbackStr

            msg = ["Thank you %s. Please note that your Production Order No.<font color='green'>%s</font>  will now on the queue of production orders  of r-pac." % (vendor.vendorCode, kw.get("customerOrderNo", None)),
                   "Separate Confirmation e-mail will be sent to your e-mail address within 24-work hour.",
                   "",
                   "感谢您 %s,请注意贵司确认的生产订单：<font color='green'>%s</font> 已经送进 r-pac 订单操作的系统里,我司会在 24 小时内自动回传确认订单的电邮给贵公司的。" % (vendor.vendorCode, kw.get("customerOrderNo", None)),
                   ]
        except:
            self.record_errorLog()
            traceback.print_exc()
            hub.rollback()
            flash("对不起，系统出现错误，服务暂时不可用，订单未能提交，请稍后再试，谢谢。")
            raise redirect("/bossinipo/vendor_index")

        hub.commit()

        flash("<br />".join(msg))
        raise redirect("/bossinipo/vendor_index")

    @expose()
    def getCareLabelProductionFile(self, **kw):
        order = getOr404(BossiniOrder, kw["id"], "/bossinipo/index", "The record is not exist!")
        clInfos = CareLabelInfo.selectBy(orderInfo = order, status = 0)

        if clInfos.count() < 0:
            flash("No such order info!")
            raise redirect("/bossinipo/dispatch")
        else:
            clInfo = clInfos[0]

        xlsFileName = "%s.xls" % order.filename
        self.myLock.acquire()
        (flag, filePath) = self._genCareLabelProductionFile(clInfo, xlsFileName)
        self.myLock.release()

        if not flag:
            flash("Error occur on when generating the production report!")
            raise redirect("/bossinipo/dispatch")
        else:
            print "------------ it's OK-----------------"
            print filePath
            print type(filePath)
            return serveFile(filePath, "application/x-download", "attachment")


    @expose("ecrm.templates.bossini.order_view_cl_vendor")
    @tabFocus(tab_type = "main")
    def vendorCareLabelOrder(self, **kw):
        (falg, id) = rpacDecrypt(kw.get("code", ""))
        if not falg :
            flash("你输入的URL有误，请不要非法访问！")
            raise redirect("/bossinipo/vendor_index")

        order = getOr404(BossiniOrder, id, "/bossinipo/vendor_index", "你所要访问的记录不存在!")
        header = order.po
        clInfos = CareLabelInfo.selectBy(orderInfo = order, status = 0)
        if clInfos.count() < 1:
            flash("没有这张订单的具体信息！")
            raise redirect("/index")

        clInfo = clInfos[0]

        if clInfo.appendix:
            appendixList = [CareInstruction.get(a) for a in clInfo.appendix.split("|") if a]
        else:
            appendixList = []

        return {
            "header" : header,
            "order" : order,
            "clInfo" : clInfo,
            "appendixList" : appendixList,
            }


    @expose("ecrm.templates.bossini.order_view_cl_preview")
    def ajaxCareLabelPreview(self, **kw):
        try:
            returnVals = {}

            if kw.get("drying", False):
                ciFields = ["washing", "bleaching", "drying", "ironing", "dryCleaning"]
            else:
                ciFields = ["washing", "bleaching", "othersDrying", "ironing", "dryCleaning"]

            for ciField in ciFields:
                returnVals[ciField] = CareInstruction.get(kw[ciField]) if kw.get(ciField, False) else None
            returnVals["careInstruction"] = ".".join(filter(lambda a:a, [returnVals[c].contentEn for c in ciFields if returnVals[c]]))

#            def filterAndSorted(prefix):
#                return sorted( filter(lambda (k,v): k.startswith(prefix),kw.iteritems()),cmp=lambda x,y:cmp(x[0],y[0]) )

            languages = ["China", "HKSINEXP", "TWN", "Egypt", "Romanian", "Poland", "Russia", "Japanese", "French",
                         "Germany", "Spanish", "Italian", "Indonesia", "Ukrainian", "Portuguese"]
            #orgin
            if kw.get("origin", False):
                originObj = Origin.get(kw["origin"])
                returnVals["orginStrList"] = [getattr(originObj, l) for l in languages]
            else:
                returnVals["orginStrList"] = []


            appendixList = self._filterAndSorted("appendix", kw)
            appendixObjectList = [CareInstruction.get(av) for (ak, av) in appendixList if av]

            returnVals["appendixSCStr"] = ",".join([ao.contentSC for ao in appendixObjectList if ao.contentSC])
            returnVals["appendixTCStr"] = ",".join([ao.contentTC for ao in appendixObjectList if ao.contentTC])
            returnVals["appendixENStr"] = ".".join([ao.contentEn for ao in appendixObjectList if ao.contentEn])
            returnVals["appendixINStr"] = ".".join([ao.Indonesia for ao in appendixObjectList if ao.Indonesia])

            partList = []
            parts = self._filterAndSorted("part_", kw)
            for pk, pv in parts:
                fieldName, index1, index2 = pk.split("_")
                percentagePrefix = "_".join(["percentage", index1, index2])
                percentageList = self._filterAndSorted(percentagePrefix, kw)

                if not any([perval for (perkey, perval) in percentageList]) : continue

                fibercontentPrefix = "_".join(["fibercontent", index1, index2])
                fibercontentList = self._filterAndSorted(fibercontentPrefix, kw)

                coatingName = "_".join(["coating", index1, index2])
                coating = kw[coatingName] if kw.get(coatingName, False) else None

                microelementName = "_".join(["microelement", index1, index2])
                microelement = kw[microelementName] if kw.get(microelementName, False) else None

                cHeader = None if not pv else Parts.get(pv)

                partList.append({
                                 "componentHeader" : "" if not cHeader else "/".join([cHeader.contentSC, cHeader.content, cHeader.contentTC]),
                                 "componentDetail" : zip([pv for (pk, pv) in percentageList if pv], [FiberContent.get(fv) for (fk, fv) in fibercontentList if fv]),
                                 "coating" : coating,
                                 "microelement" : microelement
                                 })

            returnVals["partList"] = partList
            return {"values" : returnVals}
        except:
            self.record_errorLog()
            traceback.print_exc()
            return {"tg_template" : "ecrm.templates.bossini.order_view_cl_preview_error", }


    #add by CL on 2010-06-08 ,chech whether the order is all the info is complete for real time
    def _checkIsComplete(self, po):
        if po.marketList in ["EXP", "MYS"] : return True
        if po.marketList in ["HKM", "SIN", "TWN"]:
            ds = BossNewDetail.select(BossNewDetail.q.header == po)
            if ds:
                if ds[0].netPrice:
                    return True
                return False
            return False
        if po.marketList in ["CHN"] :

            #if po.netPrice :
                #ds=BossNewDetail.select(BossNewDetail.q.header==po)
                #return all([d.eanCode for d in ds])
            ds = BossNewDetail.select(BossNewDetail.q.header == po)
            if ds:
                if ds[0].netPrice:
                    return all([d.eanCode for d in ds])
            return False
        return False


    def _checkNeedResolve(self, po):
        return Bossini.select(AND(Bossini.q.poNo == po, Bossini.q.latestFlag == -9)).count() > 0

    @expose()
    def resolve(self, **kw):
        try:
            h = Bossini.get(id = kw["id"])
        except:
            flash("The record doesn't exist!")
            raise redirect("index")

        if not self._checkNeedResolve(h.poNo) :
            flash("The record no need to resolve!")
            raise redirect("index")

        hub.begin()
        try:
            #get the latest conflict record
            latestConflict = Bossini.select(AND(Bossini.q.poNo == h.poNo, Bossini.q.latestFlag == -9), orderBy = [DESC(Bossini.q.importdate)])[0]
            #replace the orders to be the latest conflict header
            for o in BossiniOrder.select(BossiniOrder.q.po == h) : o.po = latestConflict
            #;update the origal order to be 0
            h.latestFlag = 0
            #update all the conflict record to be -1
            for b in Bossini.select(AND(Bossini.q.poNo == h.poNo, Bossini.q.latestFlag == -9)): b.latestFlag = -1
            #set the latest conflict record to be 1
            latestConflict.latestFlag = 1

            history = updateHistory(actionUser = identity.current.user, actionKind = "Resolve",
                                    actionContent = "User[%s] resolve the record,original record's id is %d." % (identity.current.user, h.id))
            if not latestConflict.history :
                latestConflict.history = history.id
            else:
                latestConflict.history = "|".join([str(history.id), ] + latestConflict.history.split("|"))
        except:
            self.record_errorLog()
            traceback.print_exc()
            hub.rollback()
            flash("Error occur on the server side!")
            raise redirect("index")

        hub.commit()

        flash("The record has been resolved!")
        raise redirect("index")




    #===========================================================================
    # new update by CL on 2010-10-07. split the HT and WOV save method
    #===========================================================================
    @expose()
    def saveWovenOrder(self, **kw):
        if "token" not in cherrypy.session or cherrypy.session["token"] != kw.get("token", None):
            flash("<strong>请不要重复提交订单信息，谢谢！</strong>")
            raise redirect("/bossinipo/vendor_index")

        del cherrypy.session["token"]

        h = getOr404(Bossini, kw["id"], "/bossinipo/vendor_index", "这张 PO 不存在!")
        cwos = BossiniOrder.selectBy(po = h, orderType = "WOV", active = 0)
        if cwos.count() > 0 :
            flash(u"这张 Bossini PO 已经存在同类型的订单，不能重复保存！")
            raise redirect("/bossinipo/vendor_index")

        hub.begin()
        try:
            history = updateHistory(actionUser = identity.current.user, actionKind = "Submit", actionContent = "User[%s] confirm the order[%s]." % (identity.current.user, h.poNo))
            headerParams = {"issuedBy" : identity.current.user, "history"  : str(history.id)}
            h.set(**headerParams)
            vendor = Vendor.selectBy(vendorCode = h.vendorCode)[0]

            orderParams = self._prepareOrderHeader(kw)
            orderParams["po"] = h
            orderParams["vendor"] = vendor

            if kw.get("wlShipment", None) : orderParams["wlShipment"] = int(kw["wlShipment"])
            bo = BossiniOrder(**orderParams)

            orderInfoCopy = orderParams.copy()
            orderInfoCopy["orderItems"] = {}
#            orderedMainLabel = []
            orderedSizeLabel = []

            for k, v in kw.iteritems():
                if not k.startswith("nwl_item_") or not v : continue

                (flag, field, id) = k.split("_")

                qtyStr = "nwl_qty_%s" % id
#                labelType = "nwl_labelType_%s" % id
                sizeStr = "nwl_size_%s" % id
                measureStr = "nwl_measure_%s" % id
                lengthStr = "nwl_length_%s" % id

#                if labelType not in kw or not kw[labelType] : continue
                if not kw.get(sizeStr, False) : continue
                if qtyStr not in kw or not kw[qtyStr] : continue

                tmp = BossiniItem.get(id = v)
                if kw.get(measureStr, None) :
                    measure = BossiniSizeMapping.get(kw[measureStr]).measure
                else:
                    measure = None

                if tmp.itemCode in ["01WL661307", "01WL661407", "01WL767610", "01WL633707"]:
                    WovenLabelInfo(orderInfo = bo, item = tmp, labelType = tmp.labelType, size = kw.get(sizeStr, None),
                                   length = kw.get(lengthStr, None) , measure = measure, qty = int(kw[qtyStr]))
                else:
                    WovenLabelInfo(orderInfo = bo, item = tmp, labelType = tmp.labelType, size = kw.get(sizeStr, None),
                                   measure = measure, qty = int(kw[qtyStr]))
                if tmp.itemCode not in orderedSizeLabel : orderedSizeLabel.append(tmp.itemCode)


#            orderInfoCopy["orderItems"]["mainLable"] = " ".join(orderedMainLabel)
            orderInfoCopy["orderItems"]["sizeLable"] = " ".join(orderedSizeLabel)

            itemCodeStr = orderInfoCopy["orderItems"].get("sizeLable", "")
            feedbackStr = "%s %s %s %s %s" % (orderInfoCopy.get("customerOrderNo", ""), itemCodeStr, h.printedLegacyCode, h.poNo, datetime.now().strftime("%d %b %Y"))

            msg = ["Thank you %s. Please note that your Production Order No.<font color='green'>%s</font>  will now on the queue of production orders  of r-pac." % (h.vendorCode, feedbackStr),
               "Separate Confirmation e-mail will be sent to your e-mail address within 24-work hour.",
               "",
               "感谢您 %s,请注意贵司确认的生产订单：<font color='green'>%s</font> 已经送进 r-pac 订单操作的系统里,我司会在 24 小时内自动回传确认订单的电邮给贵公司的。" % (h.vendorCode, feedbackStr),
               ]

            bo.set(filename = feedbackStr)
            #send email 
            send_from = "r-pac-Bossini-order-system"

            try:
                send_to = vendor.feedbackEmail.split(";") + vendor.aeEmail.split(";")
            except:
                try:
                    send_to = identity.current.user.email_address.split(";")
                except:
                    send_to = turbogears.config.get("Bossini_order_sendto").split(";")
            subject = feedbackStr

            text = ["Thank you for your confirmation!",
                    "You could view the order's detail information via the link below:",
                    "%s/bossinipo/viewOrder?code=%s" % (turbogears.config.get("website_url"), rpacEncrypt(bo.id)) ,
                    "\n\n************************************************************************************",
                    "This e-mail is sent by the r-pac Bossini ordering system automatically.",
                    "Please don't reply this e-mail directly!",
                    "************************************************************************************"
                    ]
            cc_to = turbogears.config.get("Bossini_order_cc").split(";")
            send_mail(send_from, send_to, subject, "\n".join(text), cc_to)
        except:
            self.record_errorLog()
            traceback.print_exc()
            hub.rollback()
            flash("对不起，系统出现错误，服务暂时不可用，订单未能提交，请稍后再试，谢谢。")
            raise redirect("/bossinipo/vendor_index")

        hub.commit()
        flash("<br />".join(msg))
        raise redirect("/bossinipo/vendor_index")




    @expose()
    def saveHTOrder(self, **kw):
        if "token" not in cherrypy.session or cherrypy.session["token"] != kw.get("token", None):
            flash("<strong>请不要重复提交订单信息，谢谢！</strong>")
            raise redirect("/bossinipo/vendor_index")

        del cherrypy.session["token"]

        h = getOr404(Bossini, kw["id"], "/bossinipo/vendor_index", "这张 PO 不存在!")
        chs = BossiniOrder.selectBy(po = h, orderType = "H", active = 0)
        if chs.count() > 0 :
            flash(u"这张 Bossini PO 已经存在同类型的订单，不能重复保存！")
            raise redirect("/bossinipo/vendor_index")

        hub.begin()
        try:
            history = updateHistory(actionUser = identity.current.user, actionKind = "Submit", actionContent = "User[%s] confirm the order[%s]." % (identity.current.user, h.poNo))
            headerParams = {"issuedBy" : identity.current.user, "history"  : str(history.id)}

            if kw.get("shipmentQty", False):
                headerParams["shipmentQty"] = int(kw["shipmentQty"])
            if kw.get("wastageQty", False):
                headerParams["wastageQty"] = int(kw["wastageQty"])

            h.set(**headerParams)
            vendor = Vendor.selectBy(vendorCode = h.vendorCode)[0]

            orderParams = self._prepareOrderHeader(kw)
            orderParams["po"] = h
            orderParams["vendor"] = vendor

            totalQtyWithSampleWastage = h.totalQtyWithSampleWastage

            if h.marketList == "CHN":
                orderParams.update({"typeName" : kw.get("typeName", None), "specification" : kw.get("specification", None),
                                    "prodcuingArea" : kw.get("prodcuingArea", None), "unit" : kw.get("unit", None),
                                    "productName" : kw.get("productName", None),
                                    "standard" : kw.get("standard", None), "grade" : kw.get("grade", None),
                                    "checker" : kw.get("checker", None), "technicalType" : kw.get("technicalType", None),
                                    "standardExt" : kw.get("standardExt", None),
                                    "processCompany" : kw.get("processCompany", None),
                                    })

            bo = BossiniOrder(**orderParams)

            orderInfoCopy = orderParams.copy()
            orderInfoCopy["orderItems"] = {}
            orderedHangTag = []
            orderedWaistCard = []
            orderedSticker = []

            isSpecialWaistCard = False

            for k, v in self._filterAndSorted("npc_item_", kw):
                if not v: continue
                tmp = BossiniItem.get(id = v)
                PrintingCardInfo(orderInfo = bo, item = tmp, cardType = tmp.itemType, qty = totalQtyWithSampleWastage)
                if tmp.itemType == "H" :
                    if tmp.itemCode not in orderedHangTag : orderedHangTag.append(tmp.itemCode)
                elif tmp.itemType == "W" :
                    if tmp.itemCode not in orderedWaistCard : orderedWaistCard.append(tmp.itemCode)
                elif tmp.itemType == "ST":
                    if tmp.itemCode not in orderedSticker : orderedSticker.append(tmp.itemCode)

                if tmp.itemCode.startswith("01HT80611101"):  isSpecialWaistCard = True

            if isSpecialWaistCard :
                for nd in BossNewDetail.selectBy(header = h):
                    nd.set(length = kw.get("detail_length_%d" % nd.id, None))

            orderInfoCopy["orderItems"]["hangTag"] = " ".join(orderedHangTag)
            orderInfoCopy["orderItems"]["waistCard"] = " ".join(orderedWaistCard)
            orderInfoCopy["orderItems"]["sticker"] = " ".join(orderedSticker)

            orderInfoCopy["fiberContentLayer"] = []
            percentages = self._filterAndSorted("percentage_", kw)
            components = self._filterAndSorted("component_", kw)
            for (pkey, pval), (ckey, cval) in zip(percentages, components):
                if pval and cval :
                    fc = FiberContent.get(id = cval)
                    BossiniFiberContentLayer(percentage = pval, component = fc, orderInfo = bo)
                    if h.marketList != 'EXP' :
                        orderInfoCopy["fiberContentLayer"].append("%s%% %s" % (pval, " ".join([fc.HKSINEXP, fc.TWN])))
                    else:
                        orderInfoCopy["fiberContentLayer"].append("%s%% %s" % (pval, "/".join([fc.HKSINEXP, fc.TWN, fc.Indonesia, fc.Ukrainian, fc.Egypt])))

            filesNeedToSend = []
            itemCodeStr = orderInfoCopy["orderItems"].get("hangTag", "") + " " + orderInfoCopy["orderItems"].get("waistCard", "") + " " + orderInfoCopy["orderItems"].get("sticker", "")
            feedbackStr = "%s %s %s %s %s" % (orderInfoCopy.get("customerOrderNo", ""), itemCodeStr, h.printedLegacyCode, h.poNo, datetime.now().strftime("%d %b %Y"))

    #                if h.isComplete == 0:  #the order's material is not complete ,just a remider.
            #check whether the po is all the info complete( real time )).
            if not self._checkIsComplete(h):
                msg = ['''This order %s %s will be put in the <font color='green'>3. Pending for Information Order</font> list until bossini’s information is available for production.''' % (h.legacyCode, h.poNo),
                   "Thank you.",
                   '''贵司的 %s %s 订单先行资料已经存储在 <font color='green'>3.等待 Bossini 确认挂卡价格/代号资料的订单里</font>，Bossini 的资料齐备的时候，系统会发放确认订单的讯息给贵司的指定邮箱的。''' % (h.legacyCode, h.poNo),
                   "谢谢。"]

            else:  #the order's material is complete ,send the confirm alert.
                msg = ["Thank you %s. Please note that your Production Order No.<font color='green'>%s</font>  will now on the queue of production orders  of r-pac." % (h.vendorCode, feedbackStr),
               "Separate Confirmation e-mail will be sent to your e-mail address within 24-work hour.",
               "",
               "感谢您 %s,请注意贵司确认的生产订单：<font color='green'>%s</font> 已经送进 r-pac 订单操作的系统里,我司会在 24 小时内自动回传确认订单的电邮给贵公司的。" % (h.vendorCode, feedbackStr),
               ]

                xlsFileName = feedbackStr + ".xls"
                self.myLock.acquire()
                (flag, fileName) = self._genHangTagProductionFile(h, orderInfoCopy, xlsFileName)
                self.myLock.release()
                if not flag: raise "Error occur on when generating the production report!"

                filesNeedToSend.append(fileName)

            bo.set(filename = feedbackStr)
            #send email 
            send_from = "r-pac-Bossini-order-system"
            try:
                send_to = vendor.feedbackEmail.split(";") + vendor.aeEmail.split(";")
            except:
                try:
                    send_to = identity.current.user.email_address.split(";")
                except:
                    send_to = turbogears.config.get("Bossini_order_sendto").split(";")
            subject = feedbackStr

            text = ["Thank you for your confirmation!",
                    "You could view the order's detail information via the link below:",
                    "%s/bossinipo/viewOrder?code=%s" % (turbogears.config.get("website_url"), rpacEncrypt(bo.id)) ,
                    "\n\n",
                    "亲爱的客户：",
                    "贵司清楚我们的产能已满，会接受我们在12月15-24日后才出厂的货期，后附文件是贵司确认的生产订单资料，请在3-4个工作天后，在r-pac 系统里就可以看到实际订单安排后的出厂日期。",
                    "谢谢您们。",
                    "\n\n************************************************************************************",
                    "This e-mail is sent by the r-pac Bossini ordering system automatically.",
                    "Please don't reply this e-mail directly!",
                    "************************************************************************************"
                    ]
            cc_to = turbogears.config.get("Bossini_order_cc").split(";")
            if self._checkIsComplete(h):
                send_mail(send_from, send_to, subject, "\n".join(text), cc_to, filesNeedToSend)

        except:
            self.record_errorLog()
            traceback.print_exc()
            hub.rollback()
            flash("对不起，系统出现错误，服务暂时不可用，订单未能提交，请稍后再试，谢谢。")
            raise redirect("/bossinipo/vendor_index")

        hub.commit()
        flash("<br />".join(msg))
        raise redirect("/bossinipo/vendor_index")


    #===========================================================================
    # BodyWear by CZ@2010-10-11.
    #===========================================================================
    @expose("ecrm.templates.bossini.vendor_bw_order")
    @tabFocus(tab_type = "main")
    def vendor_bw_order(self, **kw):
        (flag, vendor) = self.judgeRight()
        conditions = [
              Bossini.q.done == 1 , #the record is after 2009-12-09
              Bossini.q.active == 1, #ths record  is active
              Bossini.q.latestFlag == 1, #the PO is the latest
              Bossini.q.vendorCode == vendor, #corresponding vendor,
              ((Bossini.q.line == 'BOSSINI MEN') | (Bossini.q.line == 'BOSSINI LADIES')),
              Bossini.q.collection == "BODYWEAR",
              LIKE(Bossini.q.legacyCode, "8%"),
              NOTIN(Bossini.q.id, Select(BossiniOrder.q.po, where = AND(BossiniOrder.q.orderType == "BW", BossiniOrder.q.active == 0)))
              ]
        where = reduce(lambda a, b:a & b, conditions)
        result = Bossini.select(where, orderBy = ["legacyCode", ])
        return {"vendorCode":vendor, "result":result}

    @expose()
    @tabFocus(tab_type = "main")
    def vendor_bw_input(self, **kw):
        h = getOr404(Bossini, kw["poInfo"], "/bossinipo/vendor_index", "The record doesn't exist!")

        token = identity.current.user.user_name + datetime.now().strftime("%y%m%d%H%M%S") + str(random.randint(100, 999))
        token = sha.new(token).hexdigest()
        cherrypy.session["token"] = token

        try:

            ds = BossNewDetail.selectBy(header = h)
#            wcCode=self._getWCCode(ds)
            vendor = Vendor.selectBy(vendorCode = h.vendorCode)[0]
            defaultBillToInfo = getDefaultBillToInfo(vendor)
            defaultShipToInfo = getDefaultShipToInfo(vendor)

#            itemCode=None
#            for n in ds:
#                if n.hangTag :
#                    itemCode=n.hangTag
#                    break
            items = BossiniItem.selectBy(itemType = 'BW', active = 0)
            #item=self._presetHangTag(h)

            if kw["orderType"] == "BW" :
                template = "ecrm.templates.bossini.order_input_bw"
            else:
                raise "No order type select"

        except:
            self.record_errorLog()
            traceback.print_exc()
            flash("Some problems occur on the server side, the servise is not available now.Please try it later.Thank you.")
            raise redirect("/bossinipo/vendor_index")

        return {
                "tg_template" : template,
                "header" : h,
                "details" : ds,
                "vendor" : vendor,
                "items" : items,
#                "waistCardCode" : wcCode,
                "defaultBillToInfo" : defaultBillToInfo,
                "defaultShipToInfo" : defaultShipToInfo,
                "token" :token,
                "isComplete" : 1 if self._checkIsComplete(h) else 0
                }

    @expose()
    def saveBWOrder(self, **kw):
        if "token" not in cherrypy.session or cherrypy.session["token"] != kw.get("token", None):
            flash("<strong>请不要重复提交订单信息，谢谢！</strong>")
            raise redirect("/bossinipo/vendor_index")

        del cherrypy.session["token"]

        h = getOr404(Bossini, kw["id"], "/bossinipo/vendor_index", "这张 PO 不存在!")
        chs = BossiniOrder.selectBy(po = h, orderType = "BW", active = 0)
        if chs.count() > 0 :
            flash(u"这张 Bossini PO 已经存在同类型的订单，不能重复保存！")
            raise redirect("/bossinipo/vendor_index")

        hub.begin()
        try:
            history = updateHistory(actionUser = identity.current.user, actionKind = "Submit", actionContent = "User[%s] confirm the order[%s]." % (identity.current.user, h.poNo))
            headerParams = {"issuedBy" : identity.current.user, "history"  : str(history.id)}

            if kw.get("shipmentQty", False):
                headerParams["shipmentQty"] = int(kw["shipmentQty"])
            #if kw.get("wastageQty", False):
                #headerParams["wastageQty"]=int(kw["wastageQty"])

            h.set(**headerParams)
            vendor = Vendor.selectBy(vendorCode = h.vendorCode)[0]

            orderParams = self._prepareOrderHeader(kw)
            orderParams["po"] = h
            orderParams["vendor"] = vendor

            totalQtyWithSample = h.totalQtyWithSample

            bo = BossiniOrder(**orderParams)

            orderInfoCopy = orderParams.copy()

            bodyWearLabelParams = {
                              "item" : BossiniItem.get(id = kw.get("item")) if kw.get("item", False) else None,
                              "washing" : CareInstruction.get(kw["washing"]) if kw.get("washing", False) else None,
                              "bleaching" : CareInstruction.get(kw["bleaching"]) if kw.get("bleaching", False) else None,
                              "ironing" : CareInstruction.get(kw["ironing"]) if kw.get("ironing", False) else None,
                              "dryCleaning" : CareInstruction.get(kw["dryCleaning"]) if kw.get("dryCleaning", False) else None,
                              "drying" : CareInstruction.get(kw["drying"]) if kw.get("drying", False) else None,
                              "othersDrying" : CareInstruction.get(kw["othersDrying"]) if kw.get("othersDrying", False) else None,
                              "qty" : totalQtyWithSample
                              }
            bwlInfo = BodyWearLabelInfo(orderInfo = bo, **bodyWearLabelParams)

            percentageList = self._filterAndSorted("percentage", kw)
            fibercontentList = self._filterAndSorted("fibercontent", kw)

            for (pfk, pfv), (ffk, ffv) in zip(percentageList, fibercontentList):
                if pfv and ffv :  BossiniFiberContentLayer(orderInfo = bo, percentage = pfv, component = FiberContent.get(ffv))

            for nd in BossNewDetail.selectBy(header = h):
                BodyWearLabelDetail(bodyWearLabelInfo = bwlInfo, bossNewDetail = nd, measure = kw.get("measure_%d" % nd.id, None))


            filesNeedToSend = []
            itemCodeStr = ''
            #itemCodeStr=orderInfoCopy["orderItems"].get("hangTag", "")+" "+orderInfoCopy["orderItems"].get("waistCard", "")
            tmp = BossiniItem.get(id = kw.get("item"))
            if tmp:
                itemCodeStr = tmp.itemCode

            feedbackStr = "%s %s %s %s %s" % (orderInfoCopy.get("customerOrderNo", ""), itemCodeStr, h.printedLegacyCode, h.poNo, datetime.now().strftime("%d %b %Y"))
            #the order's material is complete ,send the confirm alert.
            msg = ["Thank you %s. Please note that your Production Order No.<font color='green'>%s</font>  will now on the queue of production orders  of r-pac." % (h.vendorCode, feedbackStr),
              "Separate Confirmation e-mail will be sent to your e-mail address within 24-work hour.",
               "",
               "感谢您 %s,请注意贵司确认的生产订单：<font color='green'>%s</font> 已经送进 r-pac 订单操作的系统里,我司会在 24 小时内自动回传确认订单的电邮给贵公司的。" % (h.vendorCode, feedbackStr),
            ]


            xlsFileName = feedbackStr + ".xls"
            self.myLock.acquire()
            (flag, fileName) = self._genBWLabelProductionFile(h, orderInfoCopy, bwlInfo, xlsFileName)
            self.myLock.release()
            if not flag: raise "Error occur on when generating the production report!"

            filesNeedToSend.append(fileName)


            bo.set(filename = feedbackStr)
            #send email
            send_from = "r-pac-Bossini-order-system"
            try:
                send_to = vendor.feedbackEmail.split(";") + vendor.aeEmail.split(";")
            except:
                try:
                    send_to = identity.current.user.email_address.split(";")
                except:
                    send_to = turbogears.config.get("Bossini_order_sendto").split(";")
            subject = feedbackStr

            text = ["Thank you for your confirmation!",
                    "You could view the order's detail information via the link below:",
                    "%s/bossinipo/viewOrder?code=%s" % (turbogears.config.get("website_url"), rpacEncrypt(bo.id)) ,
                    "\n\n************************************************************************************",
                    "This e-mail is sent by the r-pac Bossini ordering system automatically.",
                    "Please don't reply this e-mail directly!",
                    "************************************************************************************"
                    ]
            cc_to = turbogears.config.get("Bossini_order_cc").split(";")
            #if self._checkIsComplete(h):
                #send_mail(send_from, send_to, subject, "\n".join(text), cc_to, filesNeedToSend)
            send_mail(send_from, send_to, subject, "\n".join(text), cc_to, filesNeedToSend)

        except:
            self.record_errorLog()
            traceback.print_exc()
            hub.rollback()
            flash("对不起，系统出现错误，服务暂时不可用，订单未能提交，请稍后再试，谢谢。")
            raise redirect("/bossinipo/vendor_index")

        hub.commit()
        flash("<br />".join(msg))
        raise redirect("/bossinipo/vendor_index")

    def _genBWLabelProductionFile(self, poHeader, orderInfo, bwlInfo, xlsFileName):
        fileDir = self._getBossiniDownloadPath()
        templatePath = os.path.join(os.path.abspath(os.path.curdir), "report_download/TEMPLATE/BOSSINI_BODYWEAR_LABEL_TEMPLATE.xls")
        rm = random.randint(1, 1000)
        copyTemplatePath = os.path.join(fileDir, "BOSSINI_BODYWEAR_LABEL_TEMPLATE_%d.xls" % rm)
        shutil.copyfile(templatePath, copyTemplatePath)

        ds = BossNewDetail.selectBy(header = poHeader)
        result = []
        sumQty = 0
        sumTotal = 0

        for d in ds:
            bwD = BodyWearLabelDetail.selectBy(bodyWearLabelInfo = bwlInfo, bossNewDetail = d, active = 0)[0]
            bcls = BossiniFiberContentLayer.selectBy(orderInfo = bwlInfo.orderInfo)
            rowData = [poHeader.season, poHeader.collection, poHeader.itemType, poHeader.subCat, poHeader.poNo,
                    "", "",
                   poHeader.lotNum,
                   poHeader.printedLegacyCode, poHeader.marketList, poHeader.vendorCode, d.qty,
                   d.shipSampleQty, '', d.shipSampleQty,
                   d.recolorCode, d.colorName, d.sizeCode, d.sizeName, d.resizeRange, d.length,
                   '', d.blankPrice, d.eanCode, d.frameColor, bwlInfo.item.itemCode, bwD.measure
                    ]
            for bcl in bcls:
                if bcl.component:
                    cpt = bcl.component
                    rowData.append(''.join([bcl.percentage, '% ',
                        '/'.join([cpt.HKSINEXP, cpt.TWN, cpt.Indonesia, cpt.Ukrainian, cpt.Egypt])])
                    )

            result.append(rowData)

            sumQty += d.qty
            sumTotal += d.shipSampleQty

        #iconMarkets=["CHN", "EXP", "TWN", "POLAN", "JAPAN"]
        ic = "EXP"
        if bwlInfo.drying:
            attrList = ["washing", "bleaching", "drying", "ironing", "dryCleaning"]
        else:
            attrList = ["washing", "bleaching", "othersDrying", "ironing", "dryCleaning"]

        #iconsList=[]
        imgDir = os.path.join(os.path.abspath(os.path.curdir), "ecrm/static/images/bossini/care_label/")
        imgList = []
        for attr in attrList:
            obj = getattr(bwlInfo, attr)
            img = "%s_%s_%d.jpg" % (ic, obj.instructionType, obj.styleIndex)
            imgPath = os.path.join(imgDir, ic, img)
            if os.path.exists(imgPath):
                imgList.append({'typeNum':obj.typenum, 'imgPath':imgPath})
            else:
                imgList.append({'typeNum':obj.typenum, 'imgPath':None})

        filename = os.path.join(fileDir, xlsFileName)
        ke = BossiniBWLabelExcel(templatePath = copyTemplatePath, destinationPath = filename)
        try:
            ke.inputData(POHeader = poHeader, orderInfo = orderInfo, data = result, qty = sumQty, totalQty = sumTotal, imgs = imgList)
            ke.outputData()
            return (1, filename)
        except:
            self.record_errorLog()
            traceback.print_exc()
            if ke:
                ke.clearData()
            return (0, "Error occur in the Excel Exporting !")


    #add by toly 2010-10-15    
    @expose("ecrm.templates.bossini.vendor_st_order")
    @tabFocus(tab_type = "main")
    def vendor_st_order(self, **kw):
        (flag, vendor) = self.judgeRight()
        (flag, vendor) = self.judgeRight()
        conditions = [
              Bossini.q.done == 1 , #the record is after 2009-12-09
              Bossini.q.active == 1, #ths record  is active
              Bossini.q.latestFlag == 1, #the PO is the latest
              Bossini.q.vendorCode == vendor, #corresponding vendor,
              Bossini.q.marketList == 'CHN',
              LIKE(Bossini.q.legacyCode, "8%"),
              NOTIN(Bossini.q.id, Select(BossiniOrder.q.po, where = AND(BossiniOrder.q.orderType == "ST", BossiniOrder.q.active == 0)))
              ]
        where = reduce(lambda a, b:a & b, conditions)
        result = Bossini.select(where, orderBy = ["legacyCode", ])
        A = 1
        return {"vendorCode":vendor, "result":result}
    @expose("ecrm.templates.bossini.order_input_st")
    @tabFocus(tab_type = "main")
    def vendor_input_st(self, **kw):
        h = getOr404(Bossini, kw["poInfo"], "/bossinipo/vendor_index", "The record doesn't exist!")

        token = identity.current.user.user_name + datetime.now().strftime("%y%m%d%H%M%S") + str(random.randint(100, 999))
        token = sha.new(token).hexdigest()
        cherrypy.session["token"] = token

        try:

            ds = BossNewDetail.selectBy(header = h)
            vendor = Vendor.selectBy(vendorCode = h.vendorCode)[0]
            defaultBillToInfo = getDefaultBillToInfo(vendor)
            defaultShipToInfo = getDefaultShipToInfo(vendor)
            items = BossiniItem.select(AND(OR(BossiniItem.q.itemCode == '09BC75750902', BossiniItem.q.itemCode == '01BC80221102'), BossiniItem.q.itemType == 'ST'))
            item = self._presetHangTag(h)
        except:
            self.record_errorLog()
            traceback.print_exc()
            flash("Some problems occur on the server side, the servise is not available now.Please try it later.Thank you.")
            raise redirect("/bossinipo/vendor_index")
        totalqty = 0
        for d in ds:
            totalqty += d.qty
        return {
                "items":items,
                "header" : h,
                "details" : ds,
                "vendor" : vendor,
                "item" : item,
                "defaultBillToInfo" : defaultBillToInfo,
                "defaultShipToInfo" : defaultShipToInfo,
                "token" :token,
                "totalqty":totalqty,
                "isComplete" : 1 if self._checkIsComplete(h) else 0,
                }

    @expose()
    def saveSTOrder(self, **kw):
        if "token" not in cherrypy.session or cherrypy.session["token"] != kw.get("token", None):
            flash("<strong>请不要重复提交订单信息，谢谢！</strong>")
            raise redirect("/bossinipo/vendor_index")

        del cherrypy.session["token"]

        h = getOr404(Bossini, kw["id"], "/bossinipo/vendor_index", "这张 PO 不存在!")
        chs = BossiniOrder.selectBy(po = h, orderType = "ST", active = 0)
        if chs.count() > 0 :
            flash(u"这张 Bossini PO 已经存在同类型的订单，不能重复保存！")
            raise redirect("/bossinipo/vendor_index")

        hub.begin()
        try:

            history = updateHistory(actionUser = identity.current.user, actionKind = "Submit", actionContent = "User[%s] confirm the order[%s]." % (identity.current.user, h.poNo))
            headerParams = {"issuedBy" : identity.current.user, "history"  : str(history.id)}

            if kw.get("shipmentQty", False):
                headerParams["shipmentQty"] = int(kw["shipmentQty"])
            if kw.get("wastageQty", False):
                headerParams["wastageQty"] = int(kw["wastageQty"])

            h.set(**headerParams)
            vendor = Vendor.selectBy(vendorCode = h.vendorCode)[0]

            orderParams = self._prepareOrderHeader(kw)
            orderParams["po"] = h
            orderParams["vendor"] = vendor

            totalQtyWithSampleWastage = sum([n.totalQty for n in BossNewDetail.selectBy(header = h)])
            numbs = 0
            ship = int(kw.get("shipmentQty", '0'))
            wast = int(kw.get("wastageQty", '0'))
            for i in BossNewDetail.selectBy(header = h):
                numbs += int(math.ceil((float(i.qty) + float(ship)) * (float(100) + float(wast)) / float(100)))

            orderParams.update({"typeName" : kw.get("typeName", None), "specification" : kw.get("specification", None),
                                "prodcuingArea" : kw.get("prodcuingArea", None), "unit" : kw.get("unit", None),
                                "productName" : kw.get("productName", None),
                                "standard" : kw.get("standard", None), "grade" : kw.get("grade", None),
                                "checker" : kw.get("checker", None), "technicalType" : kw.get("technicalType", None),
                                "standardExt" : kw.get("standardExt", None),
                                "orderType":"ST"
                                })

            bo = BossiniOrder(**orderParams)

            orderInfoCopy = orderParams.copy()

            filesNeedToSend = []

            feedbackStr = "%s %s %s %s %s" % (kw.get("customerOrderNo", ""), kw.get('StickerType', ''), h.printedLegacyCode, h.poNo, datetime.now().strftime("%d %b %Y"))
            tmp = BossiniItem.selectBy(itemCode = kw.get("sticker_item"))[0]
            for k, v in kw.iteritems():
                if k.startswith("fibercontent_") and v:
                    pt = k.replace('fibercontent', 'percentage')
                    percentage = kw.get(pt, "0")
                    fibercontent = FiberContent.get(id = v)
                    BossiniFiberContentLayer(percentage = percentage, component = fibercontent, orderInfo = bo)
            StickerInfoParams = {
                              "item" : tmp,
                              "washing" : CareInstruction.get(kw["washing"]) if kw.get("washing", False) else None,
                              "bleaching" : CareInstruction.get(kw["bleaching"]) if kw.get("bleaching", False) else None,
                              "ironing" : CareInstruction.get(kw["ironing"]) if kw.get("ironing", False) else None,
                              "dryCleaning" : CareInstruction.get(kw["dryCleaning"]) if kw.get("dryCleaning", False) else None,
                              "drying" : CareInstruction.get(kw["drying"]) if kw.get("drying", False) else None,
                              "othersDrying" : CareInstruction.get(kw["othersDrying"]) if kw.get("othersDrying", False) else None,
                               "qty":numbs,
                               "shipmentQty":int(kw.get("shipmentQty", '0')),
                               "wastageQty":int(kw.get("wastageQty", '0'))
                              }
            appendixList = self._filterAndSorted("appendix", kw)
            StickerInfoParams["appendix"] = "|".join([av for (ak, av) in appendixList if av]) if appendixList else None
            StickerInfo(orderInfo = bo, **StickerInfoParams)
            if not self._checkIsComplete(h):
                msg = ['''This order %s %s will be put in the <font color='green'>3. Pending for Information Order</font> list until bossini’s information is available for production.''' % (h.legacyCode, h.poNo),
                   "Thank you.",
                   '''贵司的 %s %s 订单先行资料已经存储在 <font color='green'>3.等待 Bossini 确认挂卡价格/代号资料的订单里</font>，Bossini 的资料齐备的时候，系统会发放确认订单的讯息给贵司的指定邮箱的。''' % (h.legacyCode, h.poNo),
                   "谢谢。"]

            else:
                msg = ["Thank you %s. Please note that your Production Order No.<font color='green'>%s</font>  will now on the queue of production orders  of r-pac." % (h.vendorCode, feedbackStr),
               "Separate Confirmation e-mail will be sent to your e-mail address within 24-work hour.",
               "",
               "感谢您 %s,请注意贵司确认的生产订单：<font color='green'>%s</font> 已经送进 r-pac 订单操作的系统里,我司会在 24 小时内自动回传确认订单的电邮给贵公司的。" % (h.vendorCode, feedbackStr),
               ]

                xlsFileName = feedbackStr + ".xls"
                self.myLock.acquire()
                (flag, fileName) = self._genSTProductionFile(h, bo, xlsFileName,)
                self.myLock.release()
                if not flag: raise "Error occur on when generating the production report!"

                filesNeedToSend.append(fileName)


            bo.set(filename = feedbackStr)

            send_from = "r-pac-Bossini-order-system"
            try:
                send_to = vendor.feedbackEmail.split(";") + vendor.aeEmail.split(";")
            except:
                try:
                    send_to = identity.current.user.email_address.split(";")
                except:
                    send_to = turbogears.config.get("Bossini_order_sendto").split(";")
            subject = feedbackStr

            text = ["Thank you for your confirmation!",
                    "You could view the order's detail information via the link below:",
                    "%s/bossinipo/viewOrder?code=%s" % (turbogears.config.get("website_url"), rpacEncrypt(bo.id)) ,
                    "\n\n",
                    "亲爱的客户：",
                    "贵司清楚我们的产能已满，会接受我们在12月15-24日后才出厂的货期，后附文件是贵司确认的生产订单资料，请在3-4个工作天后，在r-pac 系统里就可以看到实际订单安排后的出厂日期。",
                    "谢谢您们。",
                    "\n\n************************************************************************************",
                    "This e-mail is sent by the r-pac Bossini ordering system automatically.",
                    "Please don't reply this e-mail directly!",
                    "************************************************************************************"
                    ]
            cc_to = turbogears.config.get("Bossini_order_cc").split(";")
            if  self._checkIsComplete(h):
                send_mail(send_from, send_to, subject, "\n".join(text), cc_to, filesNeedToSend)

        except:
            self.record_errorLog()
            traceback.print_exc()
            hub.rollback()
            flash("对不起，系统出现错误，服务暂时不可用，订单未能提交，请稍后再试，谢谢。")
            raise redirect("/bossinipo/vendor_index")

        hub.commit()
        flash("<br />".join(msg))
        raise redirect("/bossinipo/vendor_index")

    def _genSTProductionFile(self, poHeader, orderInfo, xlsFileName):
        fileDir = self._getBossiniDownloadPath()
        templatePath = os.path.join(os.path.abspath(os.path.curdir), "report_download/TEMPLATE/BOSSINI_PRODUCTION_ST_TEMPLATE.xls")
        rm = random.randint(1, 1000)
        copyTemplatePath = os.path.join(fileDir, "BOSSINSI_PRODUCTION_ST_TEMPLATE_%d.xls" % rm)
        shutil.copyfile(templatePath, copyTemplatePath)
        ds = BossNewDetail.selectBy(header = poHeader)
        result = []
        sumQty = 0
        sumTotal = 0
        sticker = StickerInfo.selectBy(orderInfo = orderInfo)[0]
        imgpaths = []
        imgDir = os.path.join(os.path.abspath(os.path.curdir), "ecrm/static/images/bossini/care_label/CHN")
        washingImg = 'CHN_washing_%s.jpg' % sticker.washing.styleIndex
        bleachingImg = 'CHN_bleaching_%s.jpg' % sticker.bleaching.styleIndex
        ironingImg = 'CHN_ironing_%s.jpg' % sticker.ironing.styleIndex
        dryCleaningImg = 'CHN_dryCleaning_%s.jpg' % sticker.dryCleaning.styleIndex
        washingImgPath = os.path.join(imgDir, washingImg)
        bleachingImgPath = os.path.join(imgDir, bleachingImg)

        ironingImgPath = os.path.join(imgDir, ironingImg)
        dryCleaningImgPath = os.path.join(imgDir, dryCleaningImg)

        imgpaths.append((washingImgPath, sticker.washing.typenum))
        imgpaths.append((bleachingImgPath, sticker.bleaching.typenum))
        if sticker.drying:
            dryingImg = 'CHN_drying_%s.jpg' % sticker.drying.styleIndex
            dryingImgPath = os.path.join(imgDir, dryingImg)
            imgpaths.append((dryingImgPath, sticker.drying.typenum))
        if sticker.othersDrying:
            othersDryingImg = 'CHN_othersDrying_%s.jpg' % sticker.othersDrying.styleIndex
            othersDryingImgPath = os.path.join(imgDir, othersDryingImg)
            imgpaths.append((othersDryingImgPath, sticker.othersDrying.typenum))
        imgpaths.append((ironingImgPath, sticker.ironing.typenum))
        imgpaths.append((dryCleaningImgPath, sticker.dryCleaning.typenum))

        components = []
        contentLayers = BossiniFiberContentLayer.selectBy(orderInfo = orderInfo)

        for contentLayer in contentLayers:
            compont = contentLayer.component.China
            percentage = contentLayer.percentage
            components.append(percentage + '%' + ' ' + compont)
        components = tuple(components)

        appendix_ids = sticker.appendix.split('|')
        appendixlist = []
        if sticker.appendix:
            for i in appendix_ids:
                id = int(i)
                appendix = CareInstruction.get(id = id).contentSC
                appendixlist.append(appendix)
        appendixs = tuple(appendixlist)

        for d in ds:
            ceiltotal = int(math.ceil((float(d.qty) + float(sticker.shipmentQty)) * (float(sticker.wastageQty) + float(100)) / float(100)))
            result.append(
            (poHeader.season, poHeader.collection, poHeader.itemType, poHeader.subCat, poHeader.poNo, sticker.item.itemCode,
               '',
               poHeader.lotNum,
               poHeader.printedLegacyCode, poHeader.marketList, poHeader.vendorCode, d.qty,
               d.qty + sticker.shipmentQty, ceiltotal, ceiltotal,
               d.recolorCode, d.colorName, d.sizeCode, d.sizeName, d.resizeRange, d.length, d.printedNetPrice, d.blankPrice,
               d.eanCode, d.frameColor,

               orderInfo.typeName, orderInfo.specification, orderInfo.prodcuingArea, orderInfo.unit, orderInfo.grade,
               orderInfo.pricer, "12358", "(020)81371188", orderInfo.productName, orderInfo.standard,
               orderInfo.grade, orderInfo.checker, poHeader.printedLegacyCode, orderInfo.technicalType,
               "GB 18401-2003", d.collectionCode, d.launchMonth)
            )

            sumQty += d.qty
            sumTotal += ceiltotal
        filename = os.path.join(fileDir, xlsFileName)
        ke = BossiniProductionSTExcel(templatePath = copyTemplatePath, destinationPath = filename)
        try:
            ke.inputData(sticker = sticker, POHeader = poHeader, orderInfo = orderInfo, data = result, qty = sumQty, totalQty = sumTotal, imgpaths = imgpaths, components = components, appendixs = appendixs)
            ke.outputData()
            return (1, filename)
        except:
            self.record_errorLog()
            traceback.print_exc()
            if ke:
                ke.clearData()
            return (0, "Error occur in the Excel Exporting !")


    def exportexcel(self, xlsFileName):
        fileDir = self._getBossiniDownloadPath()
        copyTemplatePath = os.path.join(fileDir, "BOSSINSI_PRODUCTION_ST_TEMPLATE_%d.xls" % rm)
        filename = os.path.join(fileDir, xlsFileName)
        ke = BossiniProductionSTExcel(templatePath = copyTemplatePath, destinationPath = filename)


    def record_errorLog(self):
        import StringIO
        get = turbogears.config.get
        current = datetime.now().strftime("%Y%m%d %X")
        dateStr = datetime.today().strftime("%Y%m%d")
        errorInfo = "user:%s       errortime:%s" % (identity.current.user_name, current)
        fileDir = os.path.join(get("ecrm.errors"), "bossini_errors")
        if not os.path.exists(fileDir):
            os.makedirs(fileDir)
        filename = os.path.join(fileDir, dateStr + '.txt')
        f = open(filename, 'a')
        fp = StringIO.StringIO()
        traceback.print_exc(file = fp)
        message = fp.getvalue()
        f.write(errorInfo + '\n' + message + '\n\n')
        f.close()

    #===========================================================================
    # Main Label@2011-01-04.
    #===========================================================================
    @expose("ecrm.templates.bossini.order_input_m")
    @tabFocus(tab_type = "main")
    def mainLabelOrder(self, **kw):
        token = identity.current.user.user_name + datetime.now().strftime("%y%m%d%H%M%S") + str(random.randint(100, 999))
        token = sha.new(token).hexdigest()
        cherrypy.session["token"] = token

        (flag, vendorCode) = self.judgeRight()
#        vendor_list = ["TR","GD","FNI","KFO","JS","LWF","TPL","TX","WM","WY","WJ"]
        if vendorCode not in self._getVendorList():
            raise redirect("/bossinipo/index")


        try:
            vendor = Vendor.selectBy(vendorCode = vendorCode)[0]
            defaultBillToInfo = getDefaultBillToInfo(vendor)
            defaultShipToInfo = getDefaultShipToInfo(vendor)

            items = BossiniItem.select(AND(BossiniItem.q.active == 0, BossiniItem.q.itemType == "WOV", BossiniItem.q.labelType == 'M'), orderBy = [BossiniItem.q.itemCode])

            legacyCodes = getLegacyCodeByVendor(vendorCode)

            return {
                    "vendor" : vendor,
                    "items" : items,
                    "defaultBillToInfo" : defaultBillToInfo,
                    "defaultShipToInfo" : defaultShipToInfo,
                    "token" :token,
                    "legacyCodes" : legacyCodes
                    }
        except:
            self.record_errorLog()
            traceback.print_exc()
            flash("The servise is not available now.Please try it later.Thank you.")
            raise redirect("/bossinipo/vendor_index")

    @expose()
    def saveMainLabelOrder(self, **kw):
        if "token" not in cherrypy.session or cherrypy.session["token"] != kw.get("token", None):
            flash("<strong>请不要重复提交订单信息，谢谢！</strong>")
            raise redirect("/bossinipo/vendor_index")

        hub.begin()
        try:
            history = updateHistory(actionUser = identity.current.user, actionKind = "Submit", actionContent = "User[%s] confirm the order[%s]." % (identity.current.user, kw.get("customerOrderNo", None)))
            vendor = Vendor.selectBy(vendorCode = kw.get("vendorCode"))[0]

            orderParams = self._prepareOrderHeader(kw)
            orderParams["vendor"] = vendor


            bo = BossiniOrder(**orderParams)
            tmp = BossiniItem.get(id = kw["item"])
            mainLabel = MainLabelInfo(orderInfo = bo, item = tmp)

            legacyList = sorted([k for k, v in kw.items() if k.startswith("legacyCode") and v])

            for key in  legacyList:
                v = kw[key]
                v = v.strip().replace("（", "(").replace("）", ")")
                lcs = BossiniLegacyCode.selectBy(legacyCode = v)
                if lcs.count() > 0:
                    lc = lcs[0]
                else:
                    lc = BossiniLegacyCode(legacyCode = v)
                #lc.addFunctionCardInfo(mainLabel)
                qty = int(kw[key.replace("legacyCode", "qty")])
                MainLabelInfoDetail(header = mainLabel, legacyCode = lc, qty = qty)

            #send email
            feedbackStr = "%s %s %s" % (bo.customerOrderNo, mainLabel.item, datetime.now().strftime("%d %b %Y"))
            self._sendNotifyEmail(vendor, kw.get("customerOrderNo", None), bo, feedbackStr)
            bo.filename = feedbackStr

            msg = ["Thank you %s. Please note that your Production Order No.<font color='green'>%s</font>  will now on the queue of production orders  of r-pac." % (vendor.vendorCode, kw.get("customerOrderNo", None)),
                   "Separate Confirmation e-mail will be sent to your e-mail address within 24-work hour.",
                   "",
                   "感谢您 %s,请注意贵司确认的生产订单：<font color='green'>%s</font> 已经送进 r-pac 订单操作的系统里,我司会在 24 小时内自动回传确认订单的电邮给贵公司的。" % (vendor.vendorCode, kw.get("customerOrderNo", None)),
                   ]
        except:
            self.record_errorLog()
            traceback.print_exc()
            hub.rollback()
            flash("对不起，系统出现错误，服务暂时不可用，订单未能提交，请稍后再试，谢谢。")
            raise redirect("/bossinipo/vendor_index")

        hub.commit()

        flash("<br />".join(msg))
        raise redirect("/bossinipo/vendor_index")
