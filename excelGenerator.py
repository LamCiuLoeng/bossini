import os,sched,shutil
from datetime import datetime as dt
import turbogears
from ecrm.util.common import *
from ecrm.util.excel_helper import ExcelBasicGenerator

mainFolder = r"D:\temp2"
templatePath = os.path.join( os.getcwd(),r"report_download\TEMPLATE\ALL_VENDOR_TEMPLATE.xls" )


todayStr = "2010-01-19 00:01:00" #dt.now().strftime("%Y-%m-%d")
#todayStr = dt.now().strftime("%Y-%m-%d")

def getAllVendorList():
    sql = "select distinct vendor_code from bossini_header_po order by vendor_code"
    result = _connection.queryAll(sql)
    return [row[0] for row in result]

def getTodayUpdatedVendors():
#    sql = "select distinct vendor_code from bossini_header_po order by vendor_code"
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

def getPOSByVendor(vendor):
#    hs = Bossini.select( (Bossini.q.vendorCode==vendor) & (Bossini.q.latestFlag==1) & (Bossini.q.importdate>todayStr) )
    hs = Bossini.select( (Bossini.q.active==1) &  
                         (Bossini.q.done==1) &
                         (Bossini.q.latestFlag==1) & 
                         (Bossini.q.importdate>todayStr) &  #-------------------should be back
                         (Bossini.q.vendorCode==vendor) 
                         )
    return hs

def getTodayNewPOByVendor(vendor):
    hs = Bossini.select( (Bossini.q.active==1) &  
                         (Bossini.q.done == 1) & 
                         (Bossini.q.latestFlag==1) & 
                         (Bossini.q.importdate>todayStr) & 
                         (Bossini.q.vendorCode==vendor) & 
                         (Bossini.q.versions==1) )
    return hs

def getTodayRevisedPOByVendor(vendor):
    hs = Bossini.select( (Bossini.q.active==1) &  
                         (Bossini.q.done == 1) & 
                         (Bossini.q.latestFlag==1) & 
                         (Bossini.q.importdate>todayStr) & 
                         (Bossini.q.vendorCode==vendor) ) # & 
#                         (Bossini.q.versions>1) )
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
    
def createAllVendorExcel(filePath,allVendor):
    bpe = TotalPOExcel(templatePath = templatePath,destinationPath = filePath)
    bpe.inputData(allVendor=allVendor)
    bpe.outputData()
        

def getPriceFormat(marketList):
    priceFormat = {
                       "HKM" : "$#,##0.00",
#                       "CHN" : "\xa3\xa4#,##",
                       "CHN" : u'\uffe5'+"#,##",
                       "TWN" : "$#,##0.",
                       "SIN" : "$#,##0.00",
                       "MYS" : "",
                       "EXP" : ""
                       }
    return priceFormat[marketList]

class POExcel(ExcelBasicGenerator):
    def inputData(self,POHeader,data=[],qty=0):
        excelSheet = self.workBook.Sheets(1)
        if not data:
            data = [("",),]

        startRow = 9
        row = len(data)
        col =  len(data[0]) if len(data) > 1 else 0
        lastRow = startRow + row
        priceColumn = "AC"        
        excelSheet.Cells(4,22).Value = unicode(POHeader.shipmentQty)
        excelSheet.Cells(5,22).Value = "%.0f%%" % POHeader.wastageQty
        excelSheet.Columns("%s:%s" %(priceColumn,priceColumn)).NumberFormat = getPriceFormat(POHeader.marketList)
        excelSheet.Range("A%d:%s%d" %( startRow, number2alphabet(col)  ,lastRow-1 )).Value = data    
        
class TotalPOExcel(ExcelBasicGenerator):
      def inputData(self,allVendor={}):
          excelSheet = self.workBook.Sheets(1)
          startRow = 9
          for vendor in allVendor:
              data = allVendor[vendor]
              if not data or len(data) < 1 : continue
              rows = len(data)
              lastRow = startRow + rows
              col = len(data[0])
              
              for index,d in enumerate(data) : excelSheet.Cells(startRow+index,29).NumberFormat = getPriceFormat(d[16])
              
              excelSheet.Range("A%d:%s%d" %( startRow, number2alphabet(col)  ,lastRow-1 )).Value = data 
              startRow += rows
    
def genAllVendor():
    print "------- begin All_vendor.xls -----------"
    allVendor = {}
    for vendor in getAllVendorList():
        allVendor[vendor] = []
        for po in getAllPOSByVendor(vendor): allVendor[vendor].extend(populate(po))           
    allVendorFilePath = os.path.join(mainFolder,"All_vendor_new.xls")
    createAllVendorExcel(allVendorFilePath, allVendor)
    print "------- finish All_vendor.xls -----------"
 
    
def genTodayUpdate(fun,fileName):
    print "------- begin %s -----------" % fileName
    allVendor = {}
    for vendor in getTodayUpdatedVendors():
        allVendor[vendor] = []
        for po in fun(vendor): allVendor[vendor].extend(populate(po))           
    allVendorFilePath = os.path.join(mainFolder,fileName)
    createAllVendorExcel(allVendorFilePath, allVendor)
    print "------- finish %s -----------" % fileName


def genAllVendorDetail():
    print "------- begin every vendor detail -----------"
    for vendor in getTodayUpdatedVendors():
        print "---- begin : ",vendor," ----------"
        for po in getPOSByVendor(vendor):
            data = populate(po)
            folder = createVendorFolder(vendor)
            filePath = os.path.join(folder,"%s_%s.xls" %(po.poNo,vendor))
            createExcel(filePath,po,data)
        print "---- finish : ",vendor," ----------"
    print "------- finish every vendor detail  -----------"
        
if __name__ == "__main__":
    turbogears.update_config(configfile="Bossinis_report.cfg",modulename="ecrm.config")
    from ecrm import model2
    from ecrm.model2 import *
    _connection = Bossini._connection
    
    genAllVendor()
#    genTodayUpdate(getTodayNewPOByVendor,"All_vendor_today_new.xls")
    genTodayUpdate(getTodayRevisedPOByVendor,"All_vendor_today_revised.xls")
    genAllVendorDetail()
            