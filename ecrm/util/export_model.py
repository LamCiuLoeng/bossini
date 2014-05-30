import turbogears
from ecrm.model import *
from turbogears import controllers, expose, flash,redirect,paginate,identity,widgets
import re
import logging,os,random,traceback,zipfile,shutil
from datetime import datetime
from ecrm.util.excel_helper import *
from cherrypy.lib.cptools import serveFile
import zlib

def export(kw):
    h = KsPoHeader.get(id=kw["header_id"])
    ######### update hangtag view in excel
    conn = KsPoDetail._connection
    sql = '''select h.hangtag from (select header_id,hangtag from kohls_po_detail
             group by header_id,hangtag) h
             where h.header_id = %s
          ''' % (kw["header_id"])
    rs  = conn.queryAll(sql)
    h.hangtag =  ",".join([item[0] for item in rs])
    #########

    podetail_ids = [id for id in  kw["podetail_ids"].split("|") if id]
    sln_ids = [id for id in  kw["sln_ids"].split("|") if id]

    po1Objs = [KsPoDetail.get(id=id) for id in podetail_ids ]
    slnObjs = [SLNDetail.get(id=id) for id in sln_ids]

    isAdmin = "Admin" in identity.current.groups

    if not isAdmin:
        any = lambda fun: lambda iterable: reduce(lambda a,b:a or b, imap(fun,iterable))
        if any(lambda obj:obj.hasExported!=0)( po1Objs + slnObjs ):  #if any of the item has been exported before, can't export again.
            flash("Some items in the list have been exported before ,please contact the admin if you want to generate the excel again.")
            raise redirect("/kohlspo/detail?id=%s" %kw["header_id"])


    result = []

    hangtag = None   #use to fill in the item name in the excel header , not the real attr for the KsPoHeader
    poUOM = None   #use to gen the excel file name,just use the first measurementCode in the detail or the SLN.

    total_qty = 0
   ###########
    for d in po1Objs:
        if poUOM is None:
            poUOM = d.measurementCode
        if hangtag is None:
            hangtag = d.hangtag
        total_qty += int(d.poQty)
        tmp_list = re.split('^(\d*)\s*(\D*)$',(d.size))
        _list = [n for n in tmp_list if n]
        upcORean = d.upc if d.upc else d.eanCode
        if len(_list) > 1:
            result.append( (d.styleNo,d.colorCode,d.colorDesc,d.deptNo,d.classNo,d.subclassNo,
                            upcORean,d.retailPrice,_list[0],_list[1].upper(),"","","","","",d.poQty) )
        else:
            result.append( (d.styleNo,d.colorCode,d.colorDesc,d.deptNo,d.classNo,d.subclassNo,
                            upcORean,d.retailPrice,d.size.upper(),"","","","","","",d.poQty) )
        if not isAdmin: d.set(hasExported=1)
    for s in slnObjs:
        logging.info(str(s))
        if poUOM is None:
            poUOM = s.poDetail.measurementCode
        if hangtag is None:
            hangtag = s.poDetail.hangtag
        po1Qty = s.poDetail.poQty
        total_qty += int(s.qty*po1Qty)
        tmp_list = re.split('^(\d*)\s*(\D*)$',(s.size))
        _list = [n for n in tmp_list if n]
        upcORean = s.upc if s.upc else s.eanCode
        if len(_list) > 1:
            result.append( (s.styleNo,s.colorCode,s.colorDesc,s.deptNo,s.classNo,s.subclassNo,
                            upcORean,s.retailPrice,_list[0],_list[1].upper(),"","","","","",s.qty*po1Qty) )
        else:
            result.append( (s.styleNo,s.colorCode,s.colorDesc,s.deptNo,s.classNo,s.subclassNo,
                            upcORean,s.retailPrice,s.size.upper(),"","","","","","",s.qty*po1Qty) )
        if not isAdmin: s.set(hasExported=1)

    #h.hangtag = hangtag

    get = turbogears.config.get
    current = datetime.now()
    dateStr = current.today().strftime("%Y%m%d")
    fileDir = os.path.join(get("ecrm.downloads"),"kohlsPO_download",identity.current.user_name,dateStr)

    #logging.info(fileDir)
    if not os.path.exists(fileDir):
        os.makedirs(fileDir)
    timeStr = current.time().strftime("%H%M%S")

    rn = random.randint(0,10000)
    username = identity.current.user_name
    templatePath = os.path.join(os.path.abspath(os.path.curdir),"report_download/TEMPLATE/Kohls_TEMPLATE.xls")

    #The following is used to gen the excel file name in the special format.
    if poUOM == 'AS':
        _UOM = 'Assorted'
    elif poUOM == 'EA':
        _UOM = 'Each'
    if h.poType == 'BK' :
        _poType = ''
    else :
        _poType = h.poType + '_'
    if h.poPurposeCode == '07' :
        _purposeCode = '_Rev'
    else :
        _purposeCode = ''

    if isAdmin:
        xlsFileName = "%s%s%s_%s.xls" % (_poType, h.poNo, _purposeCode, _UOM)
    else:
        h.set(exportVersion=h.exportVersion+1) #update the export version
        xlsFileName = "%s%s%s_%s-%d.xls" % (_poType, h.poNo, _purposeCode, _UOM , h.exportVersion )
    #******finish the excel file name gen process ***************

    filename = os.path.join(fileDir,xlsFileName)

    ke = KohlsPOExcel(templatePath = templatePath,destinationPath = filename)
    try:
        ke.inputData( POHeader=h,data=result,qty =total_qty)
        ke.outputData()
        if "Admin" not in identity.current.groups:
            _updateExportFlag(h)
        return serveFile(filename, "application/x-download", "attachment")
    except:
        traceback.print_exc()
        if ke:
            ke.clearData()
        flash("Error occur in the Excel Exporting !")
        raise redirect("index")


def productExport(kw):
    h = KsPoHeader.get(id=kw["header_id"])
    ######### update hangtag view in excel
    conn = KsPoDetail._connection
    sql = '''select h.hangtag from (select header_id,hangtag from kohls_po_detail
             group by header_id,hangtag) h
             where h.header_id = %s
          ''' % (kw["header_id"])
    rs  = conn.queryAll(sql)
    h.hangtag =  ",".join([item[0] for item in rs])
    #########

    podetail_ids = [id for id in  kw["podetail_ids"].split("|") if id]
    sln_ids = [id for id in  kw["sln_ids"].split("|") if id]

    po1Objs = [KsPoDetail.get(id=id) for id in podetail_ids ]
    slnObjs = [SLNDetail.get(id=id) for id in sln_ids]

    isAdmin = "Admin" in identity.current.groups

    if not isAdmin:
        any = lambda fun: lambda iterable: reduce(lambda a,b:a or b, imap(fun,iterable))
        if any(lambda obj:obj.hasExported!=0)( po1Objs + slnObjs ):  #if any of the item has been exported before, can't export again.
            flash("Some items in the list have been exported before ,please contact the admin if you want to generate the excel again.")
            raise redirect("/kohlspo/detail?id=%s" %kw["header_id"])


    result = []

    hangtag = None   #use to fill in the item name in the excel header , not the real attr for the KsPoHeader
    poUOM = None   #use to gen the excel file name,just use the first measurementCode in the detail or the SLN.
    eanCode = None
    upcCode = None
    total_qty = 0
   ###########
    for d in po1Objs:
        if poUOM is None:
            poUOM = d.measurementCode
        if hangtag is None:
            hangtag = d.hangtag
        if eanCode is None:
            eanCode = d.eanCode if d.eanCode else None
        if upcCode is None:
            upcCode = d.upc if d.upc else None
        total_qty += int(d.poQty)
        tmp_list = re.split('^(\d*)\s*(\D*)$',(d.size))
        _list = [n for n in tmp_list if n]
        upcORean = d.upc if d.upc else d.eanCode
        if len(_list) > 1:
            result.append( (d.styleNo,d.colorCode,d.colorDesc,d.deptNo,d.classNo,d.subclassNo,
                            upcORean,d.retailPrice,_list[0],_list[1].upper(),d.productDesc.upper().split(":")[0],"","","","","",d.poQty) )
        else:
            result.append( (d.styleNo,d.colorCode,d.colorDesc,d.deptNo,d.classNo,d.subclassNo,
                            upcORean,d.retailPrice,d.size.upper(),"",d.productDesc.upper().split(":")[0],"","","","","",d.poQty) )
        if not isAdmin: d.set(hasExported=1)
    for s in slnObjs:
        logging.info(str(s))
        if poUOM is None:
            poUOM = s.poDetail.measurementCode
        if hangtag is None:
            hangtag = s.poDetail.hangtag
        if eanCode is None:
            eanCode = s.eanCode if s.eanCode else None
        if upcCode is None:
            upcCode = s.upc if s.upc else None
        po1Qty = s.poDetail.poQty
        total_qty += int(s.qty*po1Qty)
        tmp_list = re.split('^(\d*)\s*(\D*)$',(s.size))
        _list = [n for n in tmp_list if n]
        upcORean = s.upc if s.upc else s.eanCode
        if len(_list) > 1:
            result.append( (s.styleNo,s.colorCode,s.colorDesc,s.deptNo,s.classNo,s.subclassNo,
                            upcORean,s.retailPrice,_list[0],_list[1].upper(),s.productDesc.upper().split(":")[0],"","","","","",s.qty*po1Qty) )
        else:
            result.append( (s.styleNo,s.colorCode,s.colorDesc,s.deptNo,s.classNo,s.subclassNo,
                            upcORean,s.retailPrice,s.size.upper(),"",s.productDesc.upper().split(":")[0],"","","","","",s.qty*po1Qty) )
        if not isAdmin: s.set(hasExported=1)

    #h.hangtag = hangtag
    h.upc = upcCode
    h.eanCode = eanCode

    get = turbogears.config.get
    current = datetime.now()
    dateStr = current.today().strftime("%Y%m%d")
    fileDir = os.path.join(get("ecrm.downloads"),"kohlsPO_download",identity.current.user_name,dateStr)

    #logging.info(fileDir)
    if not os.path.exists(fileDir):
        os.makedirs(fileDir)
    timeStr = current.time().strftime("%H%M%S")

    rn = random.randint(0,10000)
    username = identity.current.user_name
    templatePath = os.path.join(os.path.abspath(os.path.curdir),"report_download/TEMPLATE/Kohls_PRODUCT_TEMPLATE.xls")

    #The following is used to gen the excel file name in the special format.
    if poUOM == 'AS':
        _UOM = 'Assorted'
    elif poUOM == 'EA':
        _UOM = 'Each'
    if h.poType == 'BK' :
        _poType = ''
    else :
        _poType = h.poType + '_'
    if h.poPurposeCode == '07' :
        _purposeCode = '_Rev'
    else :
        _purposeCode = ''

    if isAdmin:
        xlsFileName = "%s%s%s_%s.xls" % (_poType, h.poNo, _purposeCode, _UOM)
    else:
        h.set(exportVersion=h.exportVersion+1) #update the export version
        xlsFileName = "%s%s%s_%s-%d.xls" % (_poType, h.poNo, _purposeCode, _UOM , h.exportVersion )
    #******finish the excel file name gen process ***************

    filename = os.path.join(fileDir,xlsFileName)

    ke = KohlsPOExcel(templatePath = templatePath,destinationPath = filename)
    try:
        ke.inputData( POHeader=h,data=result,qty =total_qty)
        ke.outputData()
        if "Admin" not in identity.current.groups:
            _updateExportFlag(h)
        return serveFile(filename, "application/x-download", "attachment")
    except:
        traceback.print_exc()
        if ke:
            ke.clearData()
        flash("Error occur in the Excel Exporting !")
        raise redirect("index")

def exportBatch(kw,exportType=None):
    template_config = {"_export":"report_download/TEMPLATE/Kohls_TEMPLATE.xls",
                       "product_export":"report_download/TEMPLATE/Kohls_PRODUCT_TEMPLATE.xls",
                       }
    header_ids = kw["header_ids"]
    if type(header_ids) != list:
        header_ids = [header_ids]

    get = turbogears.config.get
    current = datetime.now()
    dateStr = current.today().strftime("%Y%m%d%H%M%S")
    fileDir = os.path.join(get("ecrm.downloads"),"kohlsPO_download",identity.current.user_name,dateStr)
    if not os.path.exists(fileDir):
        os.makedirs(fileDir)


    dlzipFile = os.path.join(fileDir,"report_%s.zip" % current.strftime("%Y%m%d%H%M%S"))

    try:

        templatePath = os.path.join(os.path.abspath(os.path.curdir),template_config[exportType])


        rm = random.randint(1,1000)
        copyTemplatePath = os.path.join(fileDir,"Kohls_TEMPLATE_%d.xls" %rm)
        #copy the template to the dest folder to invoid the confict.
        shutil.copyfile(templatePath,copyTemplatePath)
        isAdmin = "Admin" in identity.current.groups #add by ray on 29/5
        fileList = []
        for header_id in header_ids:
            #print header_id,fileDir,copyTemplatePath,"=========================="
            rs = KsPoHeader.get(id=header_id)
            if rs.latestFlag < 1 and not isAdmin:# and turbogears.identity.user.user_name <> 'admin':
                continue
            if exportType == "_export":
                (flag,fileName) = _createExcel(header_id,fileDir,copyTemplatePath)
            else:
                (flag,fileName) = product_createExcel(header_id,fileDir,copyTemplatePath)
            if flag:
                fileList.append( fileName )

        dlzip = zipfile.ZipFile(dlzipFile,"w",zlib.DEFLATED)
        for fl in fileList:
            logging.info(os.path.abspath(fl))
            dlzip.write(os.path.abspath(str(fl)),os.path.basename(str(fl)))
        dlzip.close()
        try:
            for fl in fileList:
                os.remove(fl)

            os.remove(copyTemplatePath)
        except:
            pass
        return serveFile(dlzipFile, "application/x-download", "attachment")
    except:
        traceback.print_exc()
        flash("Error occur in the Excel Exporting !")
        raise redirect("index")

def _createExcel(header_id,fileDir,templateFilePath):
    h = KsPoHeader.get(id=header_id)
    ######### update hangtag view in excel 5-18
    conn = KsPoDetail._connection
    sql = '''select h.hangtag from (select header_id,hangtag from kohls_po_detail
             group by header_id,hangtag) h
             where h.header_id = %s
          ''' % (header_id)
    rs_hang  = conn.queryAll(sql)
    h.hangtag =  ",".join([item[0] for item in rs_hang])
    #########
    ds = KsPoDetail.selectBy(header=h)
    result = []

    hangtag = None   #use to fill in the item name in the excel header , not the real attr for the KsPoHeader
    poUOM = None   #use to gen the excel file name,just use the first measurementCode in the detail or the SLN.
    isAdmin = "Admin" in identity.current.groups

    for d in ds:
        hangtag = d.hangtag
        if poUOM is None:
            poUOM = d.measurementCode
        if d.measurementCode == "EA":
            tmp_list = re.split('^(\d*)\s*(\D*)$',(d.size))
            _list = [n for n in tmp_list if n]
            upcORean = d.upc if d.upc else d.eanCode
            if len(_list) > 1:
                result.append( (d.styleNo,d.colorCode,d.colorDesc,d.deptNo,d.classNo,d.subclassNo,
                            upcORean,d.retailPrice,_list[0],_list[1].upper(),"","","","","",d.poQty) )
            else:
                result.append( (d.styleNo,d.colorCode,d.colorDesc,d.deptNo,d.classNo,d.subclassNo,
                            upcORean,d.retailPrice,d.size.upper(),"","","","","","",d.poQty) )
            if not isAdmin : d.hasExported = 1
        elif d.measurementCode == "AS":
            po1Qty = d.poQty
            ss = SLNDetail.selectBy(poDetail = d)
            for s in ss :
                tmp_list = re.split('^(\d*)\s*(\D*)$',(s.size))
                _list = [n for n in tmp_list if n]
                upcORean = s.upc if s.upc else s.eanCode
                if len(_list) > 1:
                    result.append( (s.styleNo,s.colorCode,s.colorDesc,s.deptNo,s.classNo,s.subclassNo,
                                    upcORean,s.retailPrice,_list[0],_list[1].upper(),"","","","","",s.qty*po1Qty) )
                else:
                    result.append( (s.styleNo,s.colorCode,s.colorDesc,s.deptNo,s.classNo,s.subclassNo,
                                    upcORean,s.retailPrice,s.size.upper(),"","","","","","",s.qty*po1Qty) )
                if not isAdmin : s.hasExported = 1

    #h.hangtag = hangtag

    #The following is used to gen the excel file name in the special format.
    #1:EA/AS 2:BK.. 3:00/07 3:po#
    xlsFileName = _generateFileName( poUOM,h.poType,h.poPurposeCode,h.poNo)
    #******finish the excel file name gen process ***************

    filename = os.path.join(fileDir,xlsFileName)

#        ke = KohlsPOExcel(templatePath = templatePath,destinationPath = filename)
    ke = KohlsPOExcel(templatePath = templateFilePath,destinationPath = filename)
    try:
        ke.inputData( POHeader=h,data=result)
        ke.outputData()

        if "Admin" not in identity.current.groups:
            _updateExportFlag(h)
        return (1,filename)
#            return serveFile(filename, "application/x-download", "attachment")
    except:
        traceback.print_exc()
        if ke:
            ke.clearData()
        return (0,"Error occur in the Excel Exporting !")


def product_createExcel(header_id,fileDir,templateFilePath):
    h = KsPoHeader.get(id=header_id)
    ######### update hangtag view in excel 5-18
    conn = KsPoDetail._connection
    sql = '''select h.hangtag from (select header_id,hangtag from kohls_po_detail
             group by header_id,hangtag) h
             where h.header_id = %s
          ''' % (header_id)
    rs_hang  = conn.queryAll(sql)
    h.hangtag =  ",".join([item[0] for item in rs_hang])
    #########
    ds = KsPoDetail.selectBy(header=h)
    result = []

    hangtag = None   #use to fill in the item name in the excel header , not the real attr for the KsPoHeader
    poUOM = None   #use to gen the excel file name,just use the first measurementCode in the detail or the SLN.
    isAdmin = "Admin" in identity.current.groups

    for d in ds:
        hangtag = d.hangtag
        if poUOM is None:
            poUOM = d.measurementCode
        if d.measurementCode == "EA":
            tmp_list = re.split('^(\d*)\s*(\D*)$',(d.size))
            _list = [n for n in tmp_list if n]
            upcORean = d.upc if d.upc else d.eanCode
            if len(_list) > 1:
                result.append( (d.styleNo,d.colorCode,d.colorDesc,d.deptNo,d.classNo,d.subclassNo,
                            upcORean,d.retailPrice,_list[0],_list[1].upper(),d.productDesc.upper().split(":")[0],"","","","","",d.poQty) )
            else:
                result.append( (d.styleNo,d.colorCode,d.colorDesc,d.deptNo,d.classNo,d.subclassNo,
                            upcORean,d.retailPrice,d.size.upper(),"",d.productDesc.upper().split(":")[0],"","","","","",d.poQty) )
            if not isAdmin : d.hasExported = 1
        elif d.measurementCode == "AS":
            po1Qty = d.poQty
            ss = SLNDetail.selectBy(poDetail = d)
            for s in ss :
                tmp_list = re.split('^(\d*)\s*(\D*)$',(s.size))
                _list = [n for n in tmp_list if n]
                upcORean = s.upc if s.upc else s.eanCode
                if len(_list) > 1:
                    result.append( (s.styleNo,s.colorCode,s.colorDesc,s.deptNo,s.classNo,s.subclassNo,
                                    upcORean,s.retailPrice,_list[0],_list[1].upper(),s.productDesc.upper().split(":")[0],"","","","","",s.qty*po1Qty) )
                else:
                    result.append( (s.styleNo,s.colorCode,s.colorDesc,s.deptNo,s.classNo,s.subclassNo,
                                    upcORean,s.retailPrice,s.size.upper(),"",s.productDesc.upper().split(":")[0],"","","","","",s.qty*po1Qty) )
                if not isAdmin : s.hasExported = 1

    #h.hangtag = hangtag

    #The following is used to gen the excel file name in the special format.
    #1:EA/AS 2:BK.. 3:00/07 3:po#
    xlsFileName = _generateFileName( poUOM,h.poType,h.poPurposeCode,h.poNo)
    #******finish the excel file name gen process ***************

    filename = os.path.join(fileDir,xlsFileName)

#        ke = KohlsPOExcel(templatePath = templatePath,destinationPath = filename)
    ke = KohlsPOExcel(templatePath = templateFilePath,destinationPath = filename)
    try:
        ke.inputData( POHeader=h,data=result)
        ke.outputData()

        if "Admin" not in identity.current.groups:
            _updateExportFlag(h)
        return (1,filename)
#            return serveFile(filename, "application/x-download", "attachment")
    except:
        traceback.print_exc()
        if ke:
            ke.clearData()
        return (0,"Error occur in the Excel Exporting !")


def _generateFileName(poUOM,poType,poPurposeCode,poNo):
    if poUOM == 'AS':
        _UOM = 'Assorted'
    elif poUOM == 'EA':
        _UOM = 'Each'
    if poType == 'BK' :
        _poType = ''
    else :
        _poType = poType + '_'
    if poPurposeCode == '07' :
        _purposeCode = '_Rev'
    else :
        _purposeCode = ''
    return "%s%s%s_%s.xls" % (_poType, poNo, _purposeCode, _UOM )

def _updateExportFlag(poHeader):
    if not poHeader or not poHeader.items:
        return
    try:
        userRegion = identity.current.user.getUserRegion()
        if userRegion and userRegion.name == 'Taiwan':
            poHeader.region = userRegion
            poHeader.belong = identity.current.user_name
            poHeader.soNo = "Taiwan Order"
            poHeader.remark = str(identity.current.user_name) + str(datetime.now())
        for d in poHeader.items:
            if d.measurementCode == "EA":
                d.hasExported = 1
            elif d.measurementCode == "AS" and d.slns:
                for s in d.slns:
                    s.hasExported = 1
    except:
        traceback.print_exc()
        return

