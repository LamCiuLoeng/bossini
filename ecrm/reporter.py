import os,sched,shutil,turbogears
from datetime import datetime as dt

from turbogears import config

from ecrm.model import *
from ecrm.util.common import *
from ecrm.util.excel_helper import ExcelBasicGenerator

from ecrm.util.bossini_helper import getPriceFormat

mainFolder = config.get("Bossini_workfolder","d:/temp2")
templatePath = os.path.join( os.getcwd(),r"report_download/TEMPLATE/ALL_VENDOR_TEMPLATE.xls" )
allVendorExcel = os.path.join( mainFolder,"All_vendor.xls")

_connection = Bossini._connection

__all__ = ["begin2Gen"]

def begin2Gen():
        # 1. create all_vendor.xls
        allVenforFile = genAllVendor()
        
        #if there's not update today
        if allVenforFile is None: return (False,None,None)
        
        # 2. create detail excel
        fileList = genAllVendorDetail()
        # 3. house keeping
        return (True,allVenforFile,fileList)



def genAllVendor():
    print "------------- begin to gen all vendor file ------------"

    updatedVendors = getTodayUpdatedVendors()
    
    # if there's not updte today
    if len(updatedVendors) < 1 : return None
    
    print "--------- get all update vendor --------------"

    allVendorUpdate = {}
    for vendor in updatedVendors:
        allVendorUpdate[vendor] = []
        for po in getTodayRevisedPOByVendor(vendor): allVendorUpdate[vendor].extend(populate(po))   
    
    
    print "-------- get total ------------"
    allVendor = {}
    for vendor in getAllVendorList():
        allVendor[vendor] = []
        for po in getAllPOSByVendor(vendor): allVendor[vendor].extend(populate(po))      
             
        
    filePath = createAllVendorExcel(allVendor,allVendorUpdate) 
    print "------------- finish all vendor file -------------------------"
    return filePath


def genAllVendorDetail():
    print "------- begin every vendor detail -----------"
    allFiles = []
    for vendor in getTodayUpdatedVendors():
        print "---- begin : ",vendor," ----------"
        for po in getPOSByVendor(vendor):
            data = populate(po)
            folder = createVendorFolder(vendor)
            filePath = os.path.join(folder,"%s_%s.xls" %(po.poNo,vendor))
            createExcel(filePath,po,data)
            allFiles.append(filePath)
        print "---- finish : ",vendor," ----------"
    print "------- finish every vendor detail  -----------"
    return allFiles
    

def getTodayStr():
#    return "2009-12-16"
    return dt.now().strftime("%Y-%m-%d")


def getAllVendorList():
    sql = "select distinct vendor_code from bossini_header_po order by vendor_code"
    result = _connection.queryAll(sql)
    return [row[0] for row in result]

def getTodayUpdatedVendors():
    todayStr = getTodayStr()
    sql = "select distinct vendor_code from bossini_header_po where importdate > '%s' and latest_flag = 1 and done=1 and active=1" % todayStr
    result = _connection.queryAll(sql)
    return [row[0] for row in result]


def getAllPOSByVendor(vendor):
    #only need the data after 2009-12-04,which is the cut off day.
    hs = Bossini.select( (Bossini.q.active==1) &             #all the valid data
                         (Bossini.q.done == 1) &             #all the data after 2009-12-04
                         (Bossini.q.latestFlag==1) &         #all the latet data
                         (Bossini.q.vendorCode==vendor) )    #all the data belong to this vendor
    return hs


def getTodayRevisedPOByVendor(vendor):
    todayStr = getTodayStr()
    hs = Bossini.select( (Bossini.q.active==1) &  
                         (Bossini.q.done == 1) & 
                         (Bossini.q.latestFlag==1) & 
                         (Bossini.q.importdate>todayStr) & 
                         (Bossini.q.vendorCode==vendor) )
#                         (Bossini.q.versions>1) )
    return hs

def getPOSByVendor(vendor):
    todayStr = getTodayStr()
    hs = Bossini.select( (Bossini.q.active==1) &  
                         (Bossini.q.done==1) &
                         (Bossini.q.latestFlag==1) & 
                         (Bossini.q.importdate>todayStr) &  #-------------------should be back
                         (Bossini.q.vendorCode==vendor) 
                         )
    return hs



def createVendorFolder(vendor):
    path = os.path.join(mainFolder,vendor)
    if not os.path.exists(path):
        os.mkdir(path)
    return path

def populate(h):
    
    def countTotal(q):
        qq = q/10*10+10 if math.fmod(q, 10) > 0 else q
        return qq if qq > 50 else 50
    
    def correctSizeCode(v):
        if not v : return ""
        if len(v) < 3 : return ("000%s" %v)[-3:]
        else : return v[:3]
    
    result = []
    ds = BossNewDetail.selectBy(header=h)
    for d in ds:
        result.append( (h.season,h.collection,h.itemType,h.line,h.status,h.orderType,h.subCat,h.poNo,h.styleNo,h.printedHangTagType,
                        d.hangTag,d.waistCard,d.mainLable,d.sizeLable,h.lotNum,h.printedLegacyCode,h.marketList,h.vendorCode,
                        h.storeDate,
                        # just show the orign data, no mix with the data you fill in the web.
#                        d.qty,d.shipSampleQty,d.wastageQty,d.totalQty,
                        d.qty,d.qty,d.qty,countTotal(d.qty),
                        d.recolorCode,d.colorName,correctSizeCode(d.sizeCode),d.sizeName,d.resizeRange,
                        d.printedNetPrice,d.blankPrice,d.eanCode,d.frameColor
                        ) )
    return result

def createExcel(filePath,header,data):
    bpe = POExcel(templatePath = templatePath,destinationPath = filePath)
    bpe.inputData( POHeader=header,data=data)
    bpe.outputData()
    
def createAllVendorExcel(allVendor,allVendorUpdate):
    bpe = TotalPOExcel(templatePath = allVendorExcel,destinationPath = allVendorExcel,overwritten=False)
    bpe.inputData(allVendor=allVendor,allVendorUpdate=allVendorUpdate)
    bpe.outputData()
    return allVendorExcel
        

#def getPriceFormat(marketList):
#    priceFormat = {
#                       "HKM" : "$#,##0.00",
#                       "CHN" : "\xa3\xa4#,##",
#                       "TWN" : "$#,##0.",
#                       "SIN" : "$#,##0.00",
#                       "MYS" : "",
#                       "EXP" : ""
#                       }
#    return priceFormat[marketList]

class POExcel(ExcelBasicGenerator):
    def inputData(self,POHeader,data=[]):
        excelSheet = self.workBook.Sheets(1)
        if not data:
            data = [("",),]

        startRow = 9
        row = len(data)
        col =  len(data[0]) if len(data) > 1 else 0
        lastRow = startRow + row
        priceColumn = "AC"        
        excelSheet.Columns("%s:%s" %(priceColumn,priceColumn)).NumberFormat = getPriceFormat(POHeader.marketList)
        excelSheet.Range("A%d:%s%d" %( startRow, number2alphabet(col)  ,lastRow-1 )).Value = data    
        
class TotalPOExcel(ExcelBasicGenerator):
    def inputData(self,allVendor={},allVendorUpdate={}):
        
        print "----------- come in fill data -------------"
        
        defaultStartRow = 9
        
        def fillData(sheet,vendorData,startRow=defaultStartRow):
            for vendor in vendorData:
                data = vendorData[vendor]
                if not data or len(data) < 1 : continue

                rows = len(data)
                lastRow = startRow + rows
                col = len(data[0])
          
                for index,d in enumerate(data) : sheet.Cells(startRow+index,29).NumberFormat = getPriceFormat(d[16])
                sheet.Range("A%d:%s%d" %( startRow, number2alphabet(col)  ,lastRow-1 )).Value = data 
                startRow += rows
        try:
            self.excelObj.DisplayAlerts = False
            oSheet = self.workBook.Sheets["Report2"]
            oSheet.Delete()
        except:
            pass

        print "----------- total sheet ----------------"
        templateSheet =  self.workBook.Sheets["template"]  
        templateSheet.Copy(self.workBook.Sheets(1))  
        totalSheet = self.workBook.ActiveSheet
        totalSheet.name="Report2"
        fillData(totalSheet, allVendor)       
        
        print "------------ new sheet ---------------------"
        # create a new sheet and fill in today's data
        templateSheet.Copy(templateSheet)
        updateSheet = self.workBook.ActiveSheet
        updateSheet.name = "%s New & Revised" % datetime.now().strftime("%d %b")
        fillData(updateSheet, allVendorUpdate)
        self.excelObj.DisplayAlerts = True
        self.workBook.Save()
        print "------------ exit ----------------------"
    
#def genAllVendor():
#    print "------- begin All_vendor.xls -----------"
#    allVendor = {}
#    for vendor in getAllVendorList():
#        allVendor[vendor] = []
#        for po in getAllPOSByVendor(vendor): allVendor[vendor].extend(populate(po))           
#    allVendorFilePath = os.path.join(mainFolder,"All_vendor_new.xls")
#    createAllVendorExcel(allVendorFilePath, allVendor)
#    print "------- finish All_vendor.xls -----------"
# 
#    
#def genTodayUpdate(fileName):
#    print "------- begin %s -----------" % fileName
#    allVendor = {}
#    for vendor in getTodayUpdatedVendors():
#        allVendor[vendor] = []
#        for po in getTodayRevisedPOByVendor(vendor): allVendor[vendor].extend(populate(po))           
#    allVendorFilePath = os.path.join(mainFolder,fileName)
#    createAllVendorExcel(allVendorFilePath, allVendor)
#    print "------- finish %s -----------" % fileName



        
if __name__ == "__main__":
#    turbogears.update_config(configfile="Bossinis_report.cfg",modulename="ecrm.config")
#    from ecrm import model2
#    from ecrm.model2 import *
#    _connection = Bossini._connection
#    
#    genAllVendor()
#    genTodayUpdate(getTodayNewPOByVendor,"All_vendor_today_new.xls")
#    genTodayUpdate(getTodayRevisedPOByVendor,"All_vendor_today_revised.xls")
#    genAllVendorDetail()
    pass
            