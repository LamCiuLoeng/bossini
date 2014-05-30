# -*- coding: utf-8 -*-
import os, traceback, logging, datetime, turbogears
import win32com.client
from common import *
from win32com.client import DispatchEx
from bossini_helper import *
from ecrm.model import StickerInfo

FORMAT="%(asctime)-15s ------ %(message)s"
logging.basicConfig(format=FORMAT, level=logging.DEBUG)
###################################################################################
# Author          : CL.Lam
# Last modified   : 2008/10/07
# Version         : 0.1
# Description     : basic class for the MS Excel generator
#
####################################################################################

class ExcelBasicGenerator:
    def __init__(self, templatePath=None, destinationPath=None, overwritten=True):
#        logging.info(templatePath)
        pythoncom.CoInitialize()  #solve the problem when create the excel at second time ,the exception is occur.
        self.excelObj=DispatchEx('Excel.Application')
        self.excelObj.Visible=False
        if templatePath and os.path.exists(templatePath):
            self.workBook=self.excelObj.Workbooks.open(templatePath)
        else:
            self.workBook=self.excelObj.Workbooks.Add()
        self.destinationPath=os.path.normpath(destinationPath) if destinationPath else None
        self.overwritten=overwritten

    def inputData(self):
        pass

    def outputData(self):
        try:
            if not self.destinationPath :
                pass
            elif os.path.exists(self.destinationPath):
                if self.overwritten:
                    os.remove(self.destinationPath)
                    self.excelObj.ActiveWorkbook.SaveAs(Filename=self.destinationPath, FileFormat=1)
            else:
                self.excelObj.ActiveWorkbook.SaveAs(Filename=self.destinationPath, FileFormat=1)
        except:
            traceback.print_exc()
            raise "Error when saving the excel!"
        finally:
            try:
                self.workBook.Close(SaveChanges=0)
#                self.excelObj.Quit()
#                del self.workBook,self.excelObj
            except:
                traceback.print_exc()


    def clearData(self):
        try:
            if hasattr(self, "workBook"):
                self.workBook.Close(SaveChanges=0)
#                del self.workBook
#            if hasattr(self,"excelObj"):
#                self.excelObj.Quit()
#                del self.excelObj
        except:
            traceback.print_exc()


class KohlsPOExcel(ExcelBasicGenerator):
    def inputData(self, POHeader, data=[], qty=0):
        excelSheet=self.workBook.Sheets(1)
        excelSheet.Cells(1, 2).Value=POHeader.soNo
        excelSheet.Cells(2, 2).Value=POHeader.poNo
        excelSheet.Cells(3, 2).Value=POHeader.hangtag

        if not data:
            data=[("",), ]

        startRow=9
        row=len(data)
        col=len(data)>1 and len(data[0]) or 0

        for value in data:
            _row=excelSheet.Rows(str(startRow+1))
            _row.Insert()
            nums=1
            for cell in value:
                excelSheet.Cells(startRow, nums).Value=cell
                nums+=1
            startRow+=1
        del_row=excelSheet.Rows(str(startRow+1))
        del_row.Delete()
        del_row=excelSheet.Rows(str(startRow))
        del_row.Delete()

class KohlsReportExcel(ExcelBasicGenerator):
    def inputData(self, data=[]):
        if not data:
            data=[("",), ]
        excelSheet=self.workBook.Sheets(1)
        get=turbogears.config.get
        excelSheet.Cells(4, 9).Value="Exchange Rate : USD : HKD = 1:%s , USD : RMB = 1 : %s"%(turbogears.config.get("USD2HKD"), turbogears.config.get("USD2RMB"))

        startRow=7
        row=len(data)
        col=len(data[0])
        excelSheet.Range("A%d:%s%d"%(startRow, number2alphabet(col)  , startRow+row-1)).Value=data

class VATExcel(ExcelBasicGenerator):
    def inputData(self, additionInfo={}, data=[]):
        if not data:
            data=[("",), ]

        startRow=13
        row=len(data)
        col=len(data[0])
        lastRow=startRow+row

        customer_row=4
        customer_tel_row=customer_row+1
        customer_contact_row=customer_row+2

        tel_fax_row=19+row-1
        email_row=tel_fax_row+1
        contact_row=tel_fax_row+2

        excelSheet=self.workBook.Sheets(1)
        for index in range(startRow+1, lastRow):
            excelSheet.Rows(index).insert
            excelSheet.Rows(index).select
            excelSheet.Rows(startRow).copy
            excelSheet.paste

        #fill in the data    
        excelSheet.Range("A%d:%s%d"%(startRow, number2alphabet(col)  , lastRow-1)).Value=data
        #input the fomula
        for col in ["f", "k", "l", "m", "n", "o", "p"]:
            excelSheet.Cells(lastRow, alphabet2number(col)).Value="=sum(%s)"%",".join(map(lambda a:"%s%d"%(col, a), range(startRow, lastRow)))


        def formatter(str):
            return codeConvert(null2blank(str), "utf8", "gbk")

        #input the addition info for the dzd
        excelSheet.Cells(customer_row, 1).Value=formatter(additionInfo["customer_name"])
        excelSheet.Cells(customer_tel_row, 1).Value="Tel : %s"%formatter(additionInfo["customer_tel"])
        excelSheet.Cells(customer_tel_row, 4).Value="Fax : %s"%formatter(additionInfo["customer_fax"])
        excelSheet.Cells(customer_tel_row, 12).Value="AE : %s"%formatter(additionInfo["ae"])
        excelSheet.Cells(customer_contact_row, 1).Value="Contact Person : %s"%formatter(additionInfo["customer_contact"])
        excelSheet.Cells(customer_contact_row, 4).Value=formatter(additionInfo["customer_code"])
        excelSheet.Cells(tel_fax_row, 1).Value="Tel : %s"%formatter(additionInfo["exporter_tel"])
        excelSheet.Cells(tel_fax_row, 5).Value="Fax : %s"%formatter(additionInfo["exporter_fax"])
        excelSheet.Cells(email_row, 1).Value="E-mail : %s"%formatter(additionInfo["exporter_email"])
        excelSheet.Cells(contact_row, 1).Value=formatter("联系人 : %s"%additionInfo["exporter_name"])

#####################################################################
#    Author          : CL.Lam
#    Last modified   : 2008/10/07
#    Version         : 0.1
#    Description     : the basic class for reading the MS Excel file
#####################################################################
class ExcelReader:
    def __init__(self, sourcePath=None):
        self.soureFile=None
        self.xls=None
        self.wb=None
        self.sheet=None
        self.setSourcePath(sourcePath)

    def setSourcePath(self, sourcePath=None):
        if sourcePath and os.path.exists(sourcePath) and os.path.isfile(sourcePath):
            self._readExcel(sourcePath)
            self.soureFile=sourcePath
        else:
            self.soureFile=None

    def _readExcel(self, sourcePath):
        if not self.xls:
            pythoncom.CoInitialize()
            self.xls=win32com.client.Dispatch("Excel.Application")
            self.xls.Visible=0

        if self.wb:
            self.wb.Close(0)
        try:
            self.wb=self.xls.Workbooks.open (sourcePath)
            self.sheet=self.wb.Sheets[0]
        except:
            print "error in _readExcel"

    def setSheet(self, index=0):
        if not self.soureFile:
            return
        else:
            self.sheet=self.wb.Sheets[index]

    def close(self):
        if self.wb:
            self.wb.Close(0)
            del self.wb
        if self.xls:
            del self.xls


#
#
#    @param byRowOrColumn: 1 by row , 2 by column
    def getDataByRange(self, rows=[], cols=[], byRowOrColumn=1):
        result=[]
        if not self.soureFile:
            return result

        if len(rows)>1:
            rs=[self._translateHeader(r) for r in rows]
        else:
            rs=range(1, self.sheet.UsedRange.Rows.Count+1)

        if len(cols)>1:
            cs=[self._translateHeader(c) for c in cols]
        else:
            cs=range(1, self.sheet.UsedRange.Columns.Count+1)
        if byRowOrColumn==1 :
            for r in rs:
                result.append(
                              [self.sheet.Cells(r, c).Value and unicode(self.sheet.Cells(r, c).Value) or ""  for c in cs ])

        elif byRowOrColumn==2 :
            for c in cs:
                result.append([defaultIfNone(unicode(self.sheet.Cells(r, c).Value)) for r in rs ])

        return result

    def _translateHeader(self, alphabeticHeader=""):
        if type(alphabeticHeader)==int:
            return alphabeticHeader
        ah=alphabeticHeader.upper()
        import math
        result=0
        if ah.isalpha():
            chars=list(ah)
            chars.reverse()
            for (i, char) in enumerate(chars):
                result+=(ord(char)-64)*pow(26, i)
        return result

    def getCellValue(self, row, col):
        return self.sheet.Cells(row, col).Value

    def totalRowsCount(self):
        return self.sheet.UsedRange.Rows.Count

    def totalColumnsCount(self):
        return self.sheet.UsedRange.Columns.Count

class BossiniPOExcel(ExcelBasicGenerator):
    def inputData(self, POHeader, data=[], qty=0):
        excelSheet=self.workBook.Sheets(1)
        if not data:
            data=[("",), ]

        startRow=9
        row=len(data)
        col=len(data[0]) if len(data)>0 else 0
        lastRow=startRow+row
        priceColumn="AH"

#        priceFormat = {
#                       "HKM" : "$#,##0.00",
#                       "CHN" : "\xa3\xa4#,##",
#                       "TWN" : "$#,##0.",
#                       "SIN" : "$#,##0.00",
#                       "MYS" : "",
#                       "EXP" : ""
#                       }

        excelSheet.Cells(4, 22).Value=unicode(POHeader.shipmentQty)
        excelSheet.Cells(5, 22).Value="%.0f%%"%POHeader.wastageQty

        excelSheet.Columns("%s:%s"%(priceColumn, priceColumn)).NumberFormat=getPriceFormat(POHeader.marketList, POHeader.legacyCode)
        excelSheet.Range("A%d:%s%d"%(startRow, number2alphabet(col)  , lastRow-1)).Value=data


class BossiniProductionExcel(ExcelBasicGenerator):
    def inputData(self, POHeader, orderInfo={}, data=[], qty=0, totalQty=0):
        excelSheet=self.workBook.Sheets(1)
        if not data: data=[("",), ]
        startRow=9
        row=len(data)
        col=len(data[0]) if len(data)>0 else 0
        lastRow=startRow+row

        excelSheet.Range("vendorLabel").Value="%s PO NO."%POHeader.vendorCode
        excelSheet.Range("customerOrderNo").Value=orderInfo.get("customerOrderNo", "")
        excelSheet.Range("shipToAddress").Value="%s  %s"%(orderInfo.get("shipToAddress", ""), orderInfo.get("shipToContact", ""))
        excelSheet.Range("SampleQty").Value=POHeader.shipmentQty
        excelSheet.Range("LossRate").Value=float(POHeader.wastageQty)/100

        #modify by CL.Lam on 2010-05-04
        #modify by CL.Lam on 2010-10-06 , just print the price on excel. without format
#        excelSheet.Columns("V:V").NumberFormat=getPriceFormat(POHeader.marketList, POHeader.legacyCode)
        excelSheet.Range("A%d:%s%d"%(startRow, number2alphabet(col), lastRow-1)).Value=data
        excelSheet.Range("L%d"%(lastRow+2)).Value="=sum(L%d:L%d)"%(startRow, lastRow-1)
        excelSheet.Range("O%d"%(lastRow+2)).Value="=sum(O%d:O%d)"%(startRow, lastRow-1)

        excelSheet.Range("O%d:O%d,L%d,O%d"%(startRow, lastRow-1, lastRow+2, lastRow+2)).Interior.ColorIndex=6  #change the cells's background to yellow.

        if POHeader.marketList=="CHN" :
            excelSheet2=self.workBook.Sheets(2)
            excelSheet2.Range("poNo").Value=POHeader.poNo,
            excelSheet2.Range("legacyCode").Value=POHeader.printedLegacyCode
            excelSheet2.Range("hangTag").Value=POHeader.getHangTagCode
            excelSheet2.Range("orderDate").Value=orderInfo.get("orderDate", datetime.now().strftime("%d %b %Y"))
            excelSheet2.Range("season").Value=POHeader.season
            excelSheet2.Range("SampleQty2").Value=POHeader.shipmentQty
#            excelSheet2.Range("totalQty").Value=POHeader.totalQtyWithSampleWastage
            excelSheet2.Range("totalQty").Value="=sum(%s!O%d:O%d)"%(excelSheet.name, startRow, lastRow-1)
            excelSheet2.Range("typeName").Value=orderInfo.get("typeName", "")
            excelSheet2.Range("specification").Value=orderInfo.get("specification", "")
            excelSheet2.Range("prodcuingArea").Value=orderInfo.get("prodcuingArea", "")
            excelSheet2.Range("unit").Value=orderInfo.get("unit", "")
            excelSheet2.Range("grade").Value=orderInfo.get("grade", "")
            excelSheet2.Range("pricer").Value=orderInfo.get("pricer", "")
            excelSheet2.Range("productName").Value=orderInfo.get("productName", "")
            excelSheet2.Range("standard").Value=orderInfo.get("standard", "")
            excelSheet2.Range("grade2").Value=orderInfo.get("grade", "")
            excelSheet2.Range("checker").Value=orderInfo.get("checker", "")
            excelSheet2.Range("no").Value=POHeader.printedLegacyCode
            excelSheet2.Range("technicalType").Value=orderInfo.get("technicalType", "")
            excelSheet2.Range("standardExt").Value=orderInfo.get("standardExt", "")
            excelSheet2.Range("processCompany").Value=orderInfo.get("processCompany", "")


class PolartecExcel(ExcelBasicGenerator):
    def inputData(self, wovData=[], hatData=[], hetData=[], type=None):
        def fillData(excelSheet, data=[], startRow=8):
            try:
                excelSheet.Cells(5, 1).Value="INVENTORY AS OF:  %s"%datetime.now().strftime("%d/%m/%y")
                if not data: data=[("",), ]
                row=len(data)
                col=len(data[0]) if len(data)>0 else 0
                lastRow=startRow+row
                excelSheet.Range("A%d:%s%d"%(startRow, number2alphabet(col)  , lastRow-1)).Value=data
            except:
                file=open('log.txt', 'a')
                traceback.print_exc(None, file)
                file.close()
        fillData(self.workBook.Sheets(1), wovData)
        fillData(self.workBook.Sheets(2), hatData)

        if type=='NOUS': fillData(self.workBook.Sheets(3), hetData)


class BossiniCareLabelOrder(ExcelBasicGenerator):
    def inputData(self, labelInfo={}, img=None):
        excelSheet=self.workBook.Sheets(1)

        excelSheet.Range("fileName").Value=labelInfo["fileName"]
        excelSheet.Range("rectParts").Value=labelInfo["parts"]
        excelSheet.Range("rectCO").Value=labelInfo["coContent"]
        excelSheet.Range("rectCareInstruction").Value=labelInfo["careInstruction"]
        excelSheet.Range("rectAppendixSC").Value=labelInfo["appendixSC"]
        excelSheet.Range("rectAppendixEN").Value=labelInfo["appendixEN"]
        excelSheet.Range("rectAppendixTC").Value=labelInfo["appendixTC"]
        excelSheet.Range("rectAppendixIN").Value=labelInfo["appendixIN"]

        def getNeedFormat(text):
            result=[]
            if not text : return result
            start=1
            for line in text.split("\n"):
                length=line.find("/")
                if length>-1 : result.append((start, length))
                start+=len(line)+1
            return result

        for p, l in getNeedFormat(labelInfo["parts"]):
             excelSheet.Range("rectParts").GetCharacters(p, l).Font.Name="SimSun"

        leftLocation=550
        topLocation=1000

        for rowIndex, il in enumerate(labelInfo["iconsList"]):
            for colIndex, img in enumerate(il):
                if img:
                    left=leftLocation+colIndex*45
                    top=topLocation+rowIndex*45
                    excelSheet.Shapes.AddPicture(img, 1, 1, left, top, 40, 40)


#add by cz@2010-10-13
class BossiniBWLabelExcel(ExcelBasicGenerator):
    def inputData(self, POHeader, orderInfo={}, data=[], qty=0, totalQty=0, imgs=[]):
        excelSheet=self.workBook.Sheets(1)
        if not data: data=[("",), ]
        startRow=9
        row=len(data)
        col=len(data[0]) if len(data)>0 else 0
        lastRow=startRow+row

        excelSheet.Range("vendorLabel").Value="%s PO NO."%POHeader.vendorCode
        excelSheet.Range("customerOrderNo").Value=orderInfo.get("customerOrderNo", "")
        excelSheet.Range("shipToAddress").Value="%s  %s"%(orderInfo.get("shipToAddress", ""), orderInfo.get("shipToContact", ""))
        excelSheet.Range("SampleQty").Value=POHeader.shipmentQty
        #excelSheet.Range("LossRate").Value=float(POHeader.wastageQty)/100
        excelSheet.Range("LossRate").Value=''

        leftLocation=980
        topLocation=108
        attrList=["washing", "bleaching", "drying", "ironing", "dryCleaning"]
        for colIndex, img in enumerate(imgs):
            if img:
                left=leftLocation+colIndex*73
                excelSheet.Shapes.AddPicture(img['imgPath'], 1, 1, left, topLocation, 40, 40)
                #excelSheet.Range(attrList[colIndex]).Value=img['typeNum']

        excelSheet.Range("A%d:%s%d"%(startRow, number2alphabet(col), lastRow-1)).Value=data
        excelSheet.Range("L%d"%(lastRow+2)).Value=str(qty)
        excelSheet.Range("O%d"%(lastRow+2)).Value=str(totalQty)

        excelSheet.Range("O%d:O%d,L%d,O%d"%(startRow, lastRow-1, lastRow+2, lastRow+2)).Interior.ColorIndex=6  #change the cells's background to yellow.


#add by toly 2010-10-15
class BossiniProductionSTExcel(ExcelBasicGenerator):
    def inputData(self, sticker, POHeader, orderInfo , data=[], qty=0, totalQty=0, imgpaths=[], components=(), appendixs=()):
        excelSheet=self.workBook.Sheets(1)
        if not data: data=[("",), ]
        startRow=9
        row=len(data)
        col=len(data[0]) if len(data)>0 else 0
        lastRow=startRow+row

        excelSheet.Range("vendorLabel").Value="%s PO NO."%POHeader.vendorCode
        excelSheet.Range("customerOrderNo").Value=orderInfo.customerOrderNo
        excelSheet.Range("shipToAddress").Value="%s  %s"%(orderInfo.shipToAddress, orderInfo.shipToContact)
        excelSheet.Range("SampleQty").Value=sticker.shipmentQty
        excelSheet.Range("LossRate").Value=float(sticker.wastageQty)/100
        excelSheet.Range("A%d:%s%d"%(startRow, number2alphabet(col), lastRow-1)).Value=data
        excelSheet.Range("L%d"%(lastRow+2)).Value=str(qty)
        excelSheet.Range("O%d"%(lastRow+2)).Value=str(totalQty)

        componentslist=[]
        for i in range(lastRow-startRow):
            componentslist.append(components)
        if POHeader.itemType=="KNIT":
            head_com=[]
            for i in range(len(components)):
                if len(components)>1:
                    head_com.append(u'成份'+str(i+1),)
                else:
                    head_com.append(u'成份',)
            excelSheet.Range("%s%d:%s%d"%(number2alphabet(col+1), startRow-1, number2alphabet(col+len(components)), startRow-1)).Value=head_com
            excelSheet.Range("%s%d:%s%d"%(number2alphabet(col+1), startRow, number2alphabet(col+len(components)), lastRow-1)).Value=componentslist
        excelSheet.Range("O%d:O%d,L%d,O%d"%(startRow, lastRow-1, lastRow+2, lastRow+2)).Interior.ColorIndex=6  #change the cells's background to yellow.
        if len(appendixs)>0:
            appendixslist=[]
            for i in range(lastRow-startRow):
                appendixslist.append(appendixs)
            excelSheet.Range("%s%d:%s%d"%(number2alphabet(col+len(components)+1), startRow, number2alphabet(col+len(components)+len(appendixs)), lastRow-1)).Value=appendixslist
            head_apd=[]
            for i in range(len(appendixs)):
                if len(appendixs)>1:
                    head_apd.append(u'洗水补充说明注意'+str(i+1),)
                else:
                    head_apd.append(u'洗水补充说明注意',)
            excelSheet.Range("%s%d:%s%d"%(number2alphabet(col+len(components)+1), startRow-1, number2alphabet(col+len(components)+len(appendixs)), startRow-1)).Value=head_apd
            excelSheet.Range("%s%d:%s%d"%(number2alphabet(col+len(components)+1), startRow-1, number2alphabet(col+len(components)+len(appendixs)), startRow-1))
        excelSheet.Columns("%s:%s"%(number2alphabet(col+1), number2alphabet(col+len(components)))).EntireColumn.AutoFit()
        excelSheet.Columns("%s:%s"%(number2alphabet(col+len(components)+1), number2alphabet(col+len(components)+len(appendixs)))).EntireColumn.AutoFit()

        left=1075
        for i, img in enumerate(imgpaths):
            excelSheet.Shapes.AddPicture(img[0], 1, 1, left, 108, 40, 40)
            name="num"+str(i)
            excelSheet.Range(name).Value=img[1]
            left+=80
        excelSheet2=self.workBook.Sheets(2)
        excelSheet2.Range("poNo").Value=POHeader.poNo,
        excelSheet2.Range("legacyCode").Value=POHeader.printedLegacyCode
        excelSheet2.Range("hangTag").Value=sticker.item.itemCode
        excelSheet2.Range("orderDate").Value=orderInfo.createDate
        excelSheet2.Range("season").Value=POHeader.season
        excelSheet2.Range("SampleQty2").Value=sticker.shipmentQty
        excelSheet2.Range("totalQty").Value=totalQty
        excelSheet2.Range("typeName").Value=orderInfo.typeName
        excelSheet2.Range("specification").Value=orderInfo.specification
        excelSheet2.Range("prodcuingArea").Value=orderInfo.prodcuingArea
        excelSheet2.Range("unit").Value=orderInfo.unit
        excelSheet2.Range("grade").Value=orderInfo.grade
        excelSheet2.Range("pricer").Value=orderInfo.pricer
        excelSheet2.Range("productName").Value=orderInfo.productName
        excelSheet2.Range("standard").Value=orderInfo.standard
        excelSheet2.Range("grade2").Value=orderInfo.grade
        excelSheet2.Range("checker").Value=orderInfo.checker
        excelSheet2.Range("no").Value=POHeader.printedLegacyCode
        excelSheet2.Range("technicalType").Value=orderInfo.technicalType

        if len(appendixs)>0:
            for i, appendix in enumerate(appendixs):
                if len(appendixs)>1:
                    excelSheet2.Range("head_apd_"+str(i+1)).Value=u'洗水补充说明注意'+str(i+1)+u':'
                else:
                    excelSheet2.Range("head_apd_"+str(i+1)).Value=u'洗水补充说明注意'+u':'
                excelSheet2.Range("appendixs_"+str(i+1)).Value='  '+appendix

        for i, com in enumerate(components):
                if len(components)>1:
                    excelSheet2.Range("com_head_"+str(i+1)).Value=u'成份'+str(i+1)+u':'
                else:
                    excelSheet2.Range("com_head_"+str(i+1)).Value=u'成份'+u':'
                excelSheet2.Range("com_"+str(i+1)).Value=com
        imgDir=os.path.join(os.path.abspath(os.path.curdir), "ecrm/static/images/bossini/")
        if POHeader.itemType=="KNIT":
            img2="%s.jpg"%sticker.item.itemCode
        else:
            img2="-%s.jpg"%sticker.item.itemCode
        pic=os.path.join(imgDir, img2)
        excelSheet2.Shapes.AddPicture(pic, 1, 1, 10, 350, 200, 240)
        left=246
        for i, img in enumerate(imgpaths):
            excelSheet2.Shapes.AddPicture(img[0], 1, 1, left, 624, 40, 40)
            name="num_"+str(i)
            excelSheet2.Range(name).Value=img[1]
            left+=50

        if POHeader.vendorCode=="WY":
            excelSheet2.Range("standardExt").Value=orderInfo.standardExt


# add by cz@2010-10-25
class DisneyReportExcel(ExcelBasicGenerator):
    def inputData(self, country='r-pac Hong Kong', date='', data=[]):
        if not data:
            data=[("",), ]
        excelSheet=self.workBook.Sheets(1)
        excelSheet.Range("country").Value=country
        excelSheet.Range("rate").Value="USD : HKD = 1:%s , USD : RMB = 1:%s"%(turbogears.config.get("USD2HKD"), turbogears.config.get("USD2RMB"))
        excelSheet.Range("date").Value=date

        startRow=5
        row=len(data)
        col=len(data[0])
        excelSheet.Range("A%d:%s%d"%(startRow, number2alphabet(col)  , startRow+row-1)).Value=data
