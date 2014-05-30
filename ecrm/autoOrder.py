# -*- coding: utf-8 -*-
import os,traceback,zipfile,zlib
from datetime import timedelta, datetime as dt

from turbogears.scheduler import add_weekday_task
from turbogears import config
from sqlobject.sqlbuilder import *

from ecrm.model import *
from ecrm.util.excel_helper import ExcelBasicGenerator
from ecrm.util.common import *


__all__ = ["scheduleAM","schedulePM"]

templatePath = os.path.join( os.getcwd(),r"report_download/TEMPLATE/WOVEN_LABEL_TEMPLATE.xls" )

class DTO(object): pass

       
def processAM():
    n = dt.now()
    startTime = n.strftime("%Y-%m-%d")
    endTime = n.strftime("%Y-%m-%d 13:00:00")
    process(startTime,endTime,"AM")

def processPM():
    n = dt.now()
    startTime = n.strftime("%Y-%m-%d 13:00:00")
    endTime = (n+timedelta(1)).strftime("%Y-%m-%d")

    process(startTime, endTime,"PM")
    

def process(startTime,endTime,timeFlag):  
    try:
        todayStr = dt.now().strftime("%Y%m%d")
        #get the woven label order
        ws = BossiniOrder.select(AND(BossiniOrder.q.orderType=="WOV",
                            BossiniOrder.q.active==0,
                            BossiniOrder.q.createDate < endTime,
                            BossiniOrder.q.createDate > startTime),
                            orderBy=[BossiniOrder.q.billTo,BossiniOrder.q.shipTo,BossiniOrder.q.createDate]
                            )
        #gen the excel
        if ws.count() < 1 : return 

        #group the data
        info = {}
        for w in ws:
            btst = "%d_%d" %(w.billTo.id,w.shipTo.id)
            if btst in info :
                info[btst].extend(populate(w))
            else:
                info[btst] = populate(w)
        
        
        xlsDir = os.path.join(os.getcwd(),"report_download","WOVEN_LABEL_ORDER",dt.now().strftime("%Y%m%d"),timeFlag)
        if not os.path.exists(xlsDir) : os.makedirs(xlsDir)
        vendorMapping = {}
        #generate the excel files       
        xlsFiles = []
        
        f = lambda v: v if v else ""
        
        for btst,data in info.iteritems():
            billtoID,shiptoID = btst.split("_")
#            bt = VendorBillToInfo.get(billtoID)
            st = VendorShipToInfo.get(shiptoID)
            br = BossiniRemark.select(BossiniRemark.q.vendor==bt.vendor.vendorCode)[0]
            
            addition = {
#                        "billto" : "\n".join([bt.billTo,f(bt.address)]),
                        "shipTo" : "\n".join([st.shipTo,"Address : " %f(st.address),"Contact : " % f(st.contact),"Tel : " %f(st.tel)]),
                        "remark" : br.remark,
                        }
            
            if st.vendor.vendorCode in vendorMapping:
                vendorMapping[st.vendor.vendorCode] += 1
            else:
                vendorMapping[st.vendor.vendorCode] = 1
                
            fileName = "%s_%s_%d.xls" %(st.vendor.vendorCode,dt.now().strftime("%Y%m%d%H%m%S"),vendorMapping[st.vendor.vendorCode])                
            xlsFiles.append( genExcel(xlsDir,fileName,addition,data) )
        
        #zip the file
        zipFilePath = os.path.join(xlsDir,"WOVENLABEL_%s_%s.zip" %(todayStr,timeFlag))
        dlzip = zipfile.ZipFile(zipFilePath,"w",zlib.DEFLATED)
        for f in xlsFiles : 
            dlzip.write(os.path.abspath(f),str(os.path.basename(f)))
        dlzip.close()
        
        #send email
        send_from = "r-pac-Bossini-order-system"
        send_to = config.get("Bossini_order_pickup_sendto","cl.lam@r-pac.com.cn").split(";")
        suject = "Bossini Woven Lable Order Summary(%s %s)" % (todayStr,timeFlag)
        text = "\n".join([
                          "FYI","",
                          "*" * 80,
                          "This e-mail is sent by the r-pac Bossini ordering system automatically.",
                          "Please don't reply this e-mail directly!",
                          "*" * 80,
                          ])
        files = [zipFilePath]
        send_mail(send_from,send_to,suject,text,files=files)
        
        #remove the excel file
        try:
            for f in xlsFiles : os.remove(f)
        except:
            pass
    except:
        traceback.print_exc()
        send_from = "r-pac-Bossini-order-system"
        send_to = config.get("Bossini_backup_error_sendto","cl.lam@r-pac.com.cn").split(";")
        suject = "[Error] Woven Lable Order(%s)" % todayStr
        text = traceback.format_exc()
        send_mail(send_from,send_to,suject,text)
        
        
def populate(w): 
        items = {}
        ls = WovenLabelInfo.select(AND(WovenLabelInfo.q.orderInfo==w,WovenLabelInfo.q.active==0))
        for l in ls :
            if l.item.itemCode not in items : 
                d = DTO()
                d.comment = [u"客户订单号 : %s" %w.customerOrderNo,
                               "Bossini Legacy Code : %s" % w.po.printedLegacyCode,
                               "Bossini PO No : %s" % w.po.poNo,]
                d.sum = l.qty
                if l.labelType == "S" : 
                    d.comment.append("%s --- %s --- %d" %(l.size,l.measure,l.qty))
                    d.labelType = "S"
                elif l.labelType == "M":
                    d.labelType == "M"
                items[l.item.itemCode] = d
            else:
                d = items[l.item.itemCode]
                if l.labelType == "S" : 
                    d.comment.append("%s --- %s --- %d" %(l.size,l.measure,l.qty))
                    d.sum += l.qty
        mainLabel = [("=row()-13",k,"\n".join(v.comment),v.sum) for (k,v) in items.iteritems() if v.labelType=="M"]
        sizeLabel = [("=row()-13",k,"\n".join(v.comment),v.sum) for (k,v) in items.iteritems() if v.labelType=="S"]
        return mainLabel + sizeLabel


def genExcel(xlsDir,fileName,addition,data):
    xlsPath = os.path.join(xlsDir,fileName)
    xlsObj = OrderExcel(templatePath,xlsPath)
    xlsObj.inputData(addition,data)
    xlsObj.outputData()
    
    return xlsPath


class OrderExcel(ExcelBasicGenerator):
    def inputData(self,addition,data):
        excelSheet = self.workBook.Sheets(1)
        
#        excelSheet.Range("billto").Value = addition["billto"]
        excelSheet.Range("shipTo").Value = addition["shipTo"]
        excelSheet.Range("remark").Value = addition["remark"]
#        excelSheet.Range("today").Value = dt.now().strftime("%Y%m%d%H%M")
        
        firstRow = 14
        lastRow = firstRow + len(data) - 1
        endCol = chr(ord("A")+len(data[0])-1)
        excelSheet.Range("A%d:%s%d" %( firstRow, endCol ,lastRow )).Value = data
        
        excelSheet.Range("%s%d" %(endCol,lastRow+2)).Value = "=sum(%s%d:%s%d)" %( endCol,firstRow,endCol,lastRow )
        excelSheet.Range("%s%d" %(endCol,lastRow+2)).Interior.ColorIndex = 6  #change the cells's background to yellow.
        
        excelSheet.Range("A:Z").WrapText = False


def scheduleAM():
    (h,m) = config.get("Bossini_order_pickup_time_am","13:30").split(":")
    add_weekday_task(action=processAM,weekdays=range(1,8), timeonday=((int(h),int(m))))
    
def schedulePM():
    (h,m) = config.get("Bossini_order_pickup_time_pm","23:30").split(":")
    add_weekday_task(action=processPM,weekdays=range(1,8), timeonday=((int(h),int(m))))