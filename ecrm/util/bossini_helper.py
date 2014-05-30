# -*- coding: utf-8 -*-
from datetime import datetime as dt
import turbogears
from turbogears.identity.conditions import Predicate, IdentityPredicateHelper
from sqlobject.sqlbuilder import *

__all__=[
#           'getCode', 
           'getPriceFormat', 'mapSizeNo', 'getDefaultVendorInfo', 'getDefaultBillTo', 'getDefaultBillToInfo',
            'getDefaultShipTo', 'getDefaultShipToInfo', 'getMarketCode', 'getLegacyCodeByVendor',
           'getCO', 'getWashing', 'getBleaching', 'getIroning', 'getDryCleaning', 'getDrying',
           'getOthersDrying', 'getAppendix', 'getPart', 'getFiberContent', 'getChinaStandardCode',
           'getChinaArea', 'getChinaChecker', 'getProductName',
           'is_worktime']

#sportHangTag={
#                "HKM" : "01BC61900701",
#                "TWN" : "01BC61900703",
#                "SIN" : "01BC61900704",
#                "MYS" : "01BC61900705",
#                "EXP" : "01BC61900799",
#                "CHN" : "01BC67980702", #should be the same as below
#                }
#
#leisureHangTag={
#                    "HKM" : "01BC66160701",
#                    "CHN" : "01BC67980702", #should be the same as above
#                    "TWN" : "01BC66160703",
#                    "SIN" : "01BC66160704",
#                    "MYS" : "01BC66160705",
#                    "EXP" : "01BC66160799",
#                  }



#priceFormat={
#               "HKM" : "$#,##0.00",
##               "CHN" : "\xa3\xa4#,##",
#                "CHN" : u'\uffe5'+"#,##",
#               "TWN" : "$#,##0.",
#               "SIN" : "$#,##0.00",
#               "MYS" : "",
#               "EXP" : ""
#               }



priceFormat={
               "HKM" : '"HK"$#,##',
                "CHN" : u'\uffe5'+"#,##",
               "TWN" : '"NT"$#,##',
               "SIN" : '"SGD"#,##',
               "MYS" : "",
               "EXP" : ""
               }


marketMapping={ "HKM" : "01", "CHN" : "02", "TWN" : "03", "SIN" : "04", "MYS" : "05" , "EXP" : "99" }


#def getCode(type, maket):
#    if type=="SPORTS" :
#        return sportHangTag[maket]
#    else:
#        return leisureHangTag[maket]



def getPriceFormat(market, legacyCode = None):
    if market=="HKM" and legacyCode and legacyCode.startswith("7") : return '"HK"$#,##0.00'
    return "" if market not in priceFormat else priceFormat[market]


def mapSizeNo(sizeStr, weave, default = []):
    from ecrm.model import BossiniSizeMapping
    if not sizeStr: return default

    if sizeStr.isdigit() and sizeStr.startswith("0") :  sizeStr=sizeStr[1:]

    rs=BossiniSizeMapping.selectBy(size = sizeStr, weave = weave, status = 0)
    if rs.count()<1 : return  default
    return list(rs)


def getDefaultVendorInfo(vendorCode):
    v=vendorCode.selectBy(vendorCode = vendorCode)[0]

    b=getDefaultBillTo(v)
    s=getDefaultBillTo(s)

    return (b, s)


def getDefaultBillTo(v):
    for b in v.billTo:
        if b.flag==1 : return b
    else :
        return v.billTo[0]

def getDefaultBillToInfo(v, default = None):
    b=getDefaultBillTo(v)
    fields=["id", "billTo", "address", "contact", "tel", "fax", "currency", "payterm", "haulage", "needChangeFactory", "needVAT", "needInvoice", "account"]
    returnVal={}
    for f in fields: returnVal.update({f:getattr(b, f, default)})
    return returnVal

def getDefaultShipTo(b):
    for s in b.shipTo:
        if s.flag==1 : return s
    else :
        return b.shipTo[0]

def getDefaultShipToInfo(b, default = None):
    s=getDefaultShipTo(b)
    fields=["id", "shipTo", "address", "contact", "tel", "fax", "email", "sampleReceiver", "sampleReceiverTel", "sampleSendAddress", "requirement"]
    returnVal={}
    for f in fields: returnVal.update({f:getattr(s, f, default)})
    return returnVal

def getMarketCode(marketName):
    return marketMapping.get(marketName, None)


def getWovenLabelOrders(vendorCode):
    from ecrm.model import Bossini, BossiniOrder
    from sqlobject.sqlbuilder import *
    conditions=[
      Bossini.q.done==1 , #the record is after 2009-12-09
      Bossini.q.active==1, #ths record  is active
      Bossini.q.latestFlag==1, #the PO is the latest
      Bossini.q.vendorCode==vendorCode, #corresponding vendor,
      NOTIN(Bossini.q.id, Select(BossiniOrder.q.po, where = AND(BossiniOrder.q.orderType=="WOV", BossiniOrder.q.active==0)))
      ]

    where=reduce(lambda a, b:a&b, conditions)
    os=Bossini.select(where, orderBy = ["legacyCode", ])
    return os


def getLegacyCodeByVendor(vendorCode):
    from ecrm.model import Bossini
    conditions=[
              Bossini.q.done==1 , #the record is after 2009-12-09
              Bossini.q.active==1, #ths record  is active
              Bossini.q.latestFlag==1, #the PO is the latest
              Bossini.q.vendorCode==vendorCode, #corresponding vendor
              LIKE(Bossini.q.legacyCode, "8%"),
              ]

    where=reduce(lambda a, b:a&b, conditions)
    os=Bossini.select(where, orderBy = ["legacyCode", ])
    return sorted(list(set([o.printedLegacyCode for o in os])))


def getCO():
    from ecrm.model import Origin
    return Origin.select()

def getWashing():
    return _getCareInstruction("Washing")

def getBleaching():
    return _getCareInstruction("Bleaching")

def getIroning():
    return _getCareInstruction("Ironing")

def getDryCleaning():
    return _getCareInstruction("DryCleaning")

def getDrying():
    return _getCareInstruction("Drying")

def getOthersDrying():
    return _getCareInstruction("OthersDrying")

def getAppendix():
    return _getCareInstruction("Appendix")


def _getCareInstruction(instructionType):
    from ecrm.model import CareInstruction
    return CareInstruction.select(CareInstruction.q.instructionType==instructionType, orderBy = [CareInstruction.q.contentEn])


def getPart():
    from ecrm.model import Parts
    return Parts.select(orderBy = [Parts.q.content])

def getFiberContent():
    from ecrm.model import FiberContent
    return FiberContent.select(orderBy = [FiberContent.q.HKSINEXP])



def getChinaStandardCode():
    from ecrm.model import BossiniChinaStandardCode
    return BossiniChinaStandardCode.select(BossiniChinaStandardCode.q.status==0, orderBy = [BossiniChinaStandardCode.q.name])


def getProductName():
    from ecrm.model import BossiniChinaProductName
    return BossiniChinaProductName.select(BossiniChinaProductName.q.status==0, orderBy = [BossiniChinaProductName.q.name])


def getChinaArea():
    from ecrm.model import BossiniChinaArea
    return BossiniChinaArea.select(BossiniChinaArea.q.status==0, orderBy = [BossiniChinaArea.q.name])


def getChinaChecker():
    from ecrm.model import BossiniChinaChecker
    return BossiniChinaChecker.select(BossiniChinaChecker.q.status==0, orderBy = [BossiniChinaChecker.q.name])



class is_worktime(Predicate, IdentityPredicateHelper):
    error_message="The system is only avaiable between 7:00 AM TO 11:59 PM"
    def __init__(self):
        pass

    def eval_with_object(self, identity, errors = None):
        if "Admin" in identity.groups:
            return True

        n=dt.now()
        (y, m, d)=(n.year, n.month, n.day)
        get=turbogears.config.get
        (beginHour, beginMin)=get("Bossini_worktime_begin", "7:00").split(":")
        (endHour, endMin)=get("Bossini_worktime_end", "23:59").split(":")

        begin=dt(y, m, d, int(beginHour), int(beginMin))
        end=dt(y, m, d, int(endHour), int(endMin))

        return begin<dt.now()<end



#add by cz@2010-10-12
def getSizeInfo(sizeStr, weave, line):
    from ecrm.model import BossiniSizeMapping
    return BossiniSizeMapping.selectBy(size = sizeStr, weave = weave, line = line, status = 0)
