from datetime import datetime
import pkg_resources, math
pkg_resources.require("SQLObject>=0.7.1")
from turbogears.database import PackageHub
from sqlobject import SQLObject, SQLObjectNotFound, RelatedJoin, MultipleJoin
from sqlobject import ForeignKey
from sqlobject import StringCol, UnicodeCol, IntCol, DateCol, DateTimeCol, DecimalCol, FloatCol
from turbogears import identity
from turbogears import validators
from sqlobject.sqlbuilder import LIKE

from ecrm.util.common import *
from ecrm.util.bossini_helper import *

#for prostgresql
LIKE.op="ILIKE"

__connection__=hub=PackageHub('ecrm')


class Visit(SQLObject):
    """
    A visit to your site
    """
    class sqlmeta:
        table='visit'

    visit_key=StringCol(length = 40, alternateID = True, alternateMethodName = 'by_visit_key')
    created=DateTimeCol(default = datetime.now)
    expiry=DateTimeCol()

    def lookup_visit(cls, visit_key):
        try:
            return cls.by_visit_key(visit_key)
        except SQLObjectNotFound:
            return None
    lookup_visit=classmethod(lookup_visit)


class VisitIdentity(SQLObject):
    """
    A Visit that is link to a User object
    """
    visit_key=StringCol(length = 40, alternateID = True, alternateMethodName = 'by_visit_key')
    user_id=IntCol()


class Group(SQLObject):
    """
    An ultra-simple group definition.
    """
    # names like "Group", "Order" and "User" are reserved words in SQL
    # so we set the name to something safe for SQL
    class sqlmeta:
        table='tg_group'

    group_name=UnicodeCol(length = 30, alternateID = True, alternateMethodName = 'by_group_name')
    created=DateTimeCol(default = datetime.now)

    # collection of all users belonging to this group
    users=RelatedJoin('User', intermediateTable = 'user_group', joinColumn = 'group_id', otherColumn = 'user_id')
    permissions=RelatedJoin('Permission', intermediateTable = 'group_permission', joinColumn = 'group_id', otherColumn = 'permission_id')
    region=ForeignKey('KsRegion', cascade = False, default = None)
    def _display_name(self):
        return self.group_name
    display_name=property(fget = _display_name)

    def __str__(self):
        return self.group_name



class User(SQLObject):
    """
    Reasonably basic User definition.
    Probably would want additional attributes.
    """
    # names like "Group", "Order" and "User" are reserved words in SQL
    # so we set the name to something safe for SQL
    class sqlmeta:
        table='tg_user'
    user_name=UnicodeCol(length = 30)
    password=UnicodeCol(length = 40)
    display_name=UnicodeCol(length = 30)
    email_address=UnicodeCol(length = 255, alternateMethodName = 'by_email_address')
    #phone = UnicodeCol(length=20,default="")
    #fax =  UnicodeCol(length=20,default="")
    created=DateTimeCol(default = datetime.now)

    # groups this user belongs to
    groups=RelatedJoin('Group', intermediateTable = 'user_group', joinColumn = 'user_id', otherColumn = 'group_id')


    def _set_password(self, cleartext_password):
        """Runs cleartext_password through the hash algorithm before saving."""
        password_hash=identity.encrypt_password(cleartext_password)
        self._SO_set_password(password_hash)

    def set_password_raw(self, password):
        """Saves the password as-is to the database."""
        self._SO_set_password(password)

    def __str__(self):
        return self.display_name if self.display_name else self.user_name

    def _show_groups(self):
        return ",".join([g.group_name for g in self.groups])
    show_groups=property(fget = _show_groups)

    def _show_permissions(self):
        return ",".join([p.permission_name for p in self.permissions])
    show_permissions=property(fget = _show_permissions)

    #Only if the user type the right user name ,no matter the user name is in uppercase or lowercase , can login the system.
    @classmethod
    def by_user_name(clz, user_name):
        try:
            return User.select(LIKE(User.q.user_name, user_name))[0]
        except:
            raise SQLObjectNotFound


    def _get_permissions(self):
        perms=set()
        for g in self.groups:
            perms|=set(g.permissions)
        return perms

    def getUserRegion(self):
#        if self.locationGroup : return self.locationGroup.region
#        return None
        for g in self.groups:
            if g.region : return g.region
        return None

class Permission(SQLObject):
    """
    A relationship that determines what each Group can do
    """
    permission_name=UnicodeCol(length = 30, alternateID = True, alternateMethodName = 'by_permission_name')
    description=UnicodeCol(length = 255)
    groups=RelatedJoin('Group', intermediateTable = 'group_permission', joinColumn = 'permission_id', otherColumn = 'group_id')
    def __str__(self):
        return self.permission_name


class updateHistory(SQLObject):
    class sqlmeta:
        table="update_history"
    actionTime=DateTimeCol(default = datetime.now, validator = validators.DateTimeConverter(format = DB_DATE_TIME_FORMAT))
    actionUser=ForeignKey('User', cascade = False)
    actionKind=UnicodeCol(length = 100, default = "")
    actionContent=UnicodeCol(length = 3000, default = "")


class KsPoHeader(SQLObject):
    """
        kohl's Po Header
    """
    class sqlmeta:
        table="kohls_po_header"
    #CompanyCode = UnicodeCol(length=30,notNone=True)
    poNo=UnicodeCol(length = 30, notNone = True)
    poDate=DateTimeCol(default = None)
    orderDept=UnicodeCol(default = '', length = 3, notNone = False)
    status=UnicodeCol(default = '', length = 3, notNone = False)
    manufacture=UnicodeCol(default = '', length = 300, notNone = False)
    poType=UnicodeCol(default = '', length = 2, notNone = False)
    poPurposeCode=UnicodeCol(default = '', length = 2, notNone = False)
    cancelAfter=DateCol(default = None)
    shipNotBefore=DateCol(default = None)
    exitFtyStartDate=DateCol(default = None)
    exitFtyEndDate=DateCol(default = None)
    # User input field.
    soNo=UnicodeCol(default = '', length = 300, notNone = False)
    soDate=DateCol(default = None)
    ## import info record
    importFormat=UnicodeCol(default = '', length = 30, notNone = False) # pdf or edi text
    revNo=UnicodeCol(default = '', length = 10, notNone = False)
    releaseNo=UnicodeCol(default = '', length = 10, notNone = False)
    importDate=DateTimeCol(default = datetime.now)
    ediFileDate=DateTimeCol(default = None)
    items=MultipleJoin('KsPoDetail', joinColumn = 'header_id')

    history=UnicodeCol(default = '', length = 500)
    active=IntCol(default = 1)  # 1 is active , 0 is inactive

    latestFlag=IntCol(default = 1)
    exportVersion=IntCol(default = 0) # this field would be
    agent=UnicodeCol(default = '', length = 50, notNone = False)
    remark=UnicodeCol(default = '', length = 300, notNone = False)
    belong=UnicodeCol(default = '', length = 30, notNone = False)
    #add by Ray July 9 2010
    region=ForeignKey('KsRegion', cascade = False, default = None)

    def getByUPC(self, upc):
        for item in self.items:
            if item.upc==upc:
                return item

class KsPoDetail(SQLObject):
    """
        kohl's Po item detail
    """
    class sqlmeta:
        table="kohls_po_detail"
    header=ForeignKey('KsPoHeader')
    hangtag=UnicodeCol(default = '', length = 30, notNone = False)
    styleNo=UnicodeCol(default = '', length = 30, notNone = False)
    colorCode=UnicodeCol(default = '', length = 5, notNone = False)
    colorDesc=UnicodeCol(default = '', length = 30, notNone = False)
    deptNo=UnicodeCol(default = '', length = 3, notNone = False)
    classNo=UnicodeCol(default = '', length = 2, notNone = False)
    subclassNo=UnicodeCol(default = '', length = 2, notNone = False)
    upc=UnicodeCol(default = '', length = 12, notNone = False)
    eanCode=UnicodeCol(default = '', length = 20, notNone = False)
    sizeCode=UnicodeCol(default = '', length = 5, notNone = False)
    retailPrice=DecimalCol(default = 0.00, size = 10, precision = 2)
    size=UnicodeCol(default = '', length = 20, notNone = False)
    sizeDesc=UnicodeCol(default = '', length = 20, notNone = False)
    poQty=IntCol(default = 0)
    pcSet=UnicodeCol(default = '', length = 20, notNone = False)
    measurementCode=UnicodeCol(default = '', length = 20, notNone = False)
    slns=MultipleJoin('SLNDetail', joinColumn = 'po_detail_id')
    productDesc=UnicodeCol(default = '', length = 100, notNone = False)
    hasExported=IntCol(default = 0)  # 0 -> hasn't exported . >0 means this item has been exported once.

    def getByUPC(self, upc):
        for sln in self.slns:
            if sln.upc==upc:
                return sln


class SLNDetail(SQLObject):
    class sqlmeta:
        table="kohls_sln_detail"
    poDetail=ForeignKey('KsPoDetail')
    styleNo=UnicodeCol(default = '', length = 30, notNone = False)
    colorCode=UnicodeCol(default = '', length = 5, notNone = False)
    colorDesc=UnicodeCol(default = '', length = 30, notNone = False)
    sizeCode=UnicodeCol(default = '', length = 5, notNone = False)
    upc=UnicodeCol(default = '', length = 12, notNone = False)
    eanCode=UnicodeCol(default = '', length = 20, notNone = False)
    retailPrice=DecimalCol(default = 0.00, size = 10, precision = 2)
    size=UnicodeCol(default = '', length = 20, notNone = False)
    qty=IntCol(default = 0)
    productDesc=UnicodeCol(default = '', length = 100, notNone = False)
    sizeDesc=UnicodeCol(default = '', length = 30, notNone = False) #sln Product Description
    deptNo=UnicodeCol(default = '', length = 3, notNone = False)
    classNo=UnicodeCol(default = '', length = 2, notNone = False)
    subclassNo=UnicodeCol(default = '', length = 2, notNone = False)
    hasExported=IntCol(default = 0)  # 0 -> hasn't exported . >0 means this item has been exported once.


class EDI864Header(SQLObject):
    class sqlmeta:
        table="kohls_edi_864_header"
    senderCode=UnicodeCol(default = '', length = 20, notNone = False)
    receiverCode=UnicodeCol(default = '', length = 20, notNone = False)
    ediFileDate=DateTimeCol(default = None)
    groupControlNumber=UnicodeCol(default = '', length = 20, notNone = False)
    industryIDCode=UnicodeCol(default = '', length = 20, notNone = False)
    transactionSetControlNumber=UnicodeCol(default = '', length = 20, notNone = False)
    referenceIndentification=UnicodeCol(default = '', length = 20, notNone = False)
    referenceDesc=UnicodeCol(default = '', length = 200, notNone = False)
    entityIndentifierCode=UnicodeCol(default = '', length = 5, notNone = False)
    freeFormName=UnicodeCol(default = '', length = 50, notNone = False)
    contactFunctionCode=UnicodeCol(default = '', length = 5, notNone = False)
    contactEmail=UnicodeCol(default = '', length = 20, notNone = False)
    msgs=MultipleJoin('EDI864Msg', joinColumn = 'header_id')

    status=IntCol(default = 1)  # 1 is active , 0 is inactive
    importDate=DateTimeCol(default = datetime.now)
    read=IntCol(default = 0)  # 1 is read , 0 is un-read

class EDI864Msg(SQLObject):
    class sqlmeta:
        table="kohls_edi_864_msg"
    header=ForeignKey('EDI864Header')
    content=UnicodeCol(default = '', length = 300, notNone = False)



class MissingPO(SQLObject):
    """
        kohls missing PO #
    """
    class sqlmeta:
        table="kohls_po_missing"

    poNo=UnicodeCol(length = 30, notNone = True)
    status=UnicodeCol(default = 'missing', length = 20, notNone = False)
    importDate=DateTimeCol(default = datetime.now)
    remark=UnicodeCol(default = '', length = 300, notNone = False)
#-------------------End-------------------------------------------------------------
#--------------------kohl's PO------------------------------------------------------


#----------------------------Bossini EDI--------------------------------------------

class Bossini(SQLObject):

    #_connection = ph
    class sqlmeta:
        table="bossini_header_po"
    #base fields
    poNo=UnicodeCol(default = '', length = 30, notNone = True)
    lotNum=IntCol(default = 0, notNone = False)
    lotCount=IntCol(default = 0, notNone = False)
    season=UnicodeCol(default = '', length = 10, notNone = False)
    styleNo=UnicodeCol(default = '', length = 30, notNone = False)
    legacyCode=UnicodeCol(default = '', length = 30, notNone = False)
    line=UnicodeCol(default = '', length = 30, notNone = False)
    marketList=UnicodeCol(default = '', length = 10, notNone = False)
    collection=UnicodeCol(default = '', length = 30, notNone = False)

    vendorCode=UnicodeCol(default = '', length = 10, notNone = False)

#    priceCurrency=UnicodeCol(default = '', length = 10, notNone = False)
#    netPrice=UnicodeCol(default = '', length = 10, notNone = False)
#    blankPrice=UnicodeCol(default = '', length = 2, notNone = False)
#    sizeRange=UnicodeCol(default = '', length = 100, notNone = False)
#    resizeRange=UnicodeCol(default = '', length = 100, notNone = False)
    orderType=UnicodeCol(default = '', length = 30, notNone = False)
    subCat=UnicodeCol(default = '', length = 200, notNone = False)
    status=UnicodeCol(default = '', length = 10, notNone = False)
    hangTagType=UnicodeCol(default = '', length = 20, notNone = False)
    itemType=UnicodeCol(default = '', length = 20, notNone = False) #added in 20/10
    storeDate=DateTimeCol(default = datetime.now)
    #expand fields
    soNo=UnicodeCol(default = '', length = 100, notNone = False)
    versions=IntCol(default = 1)
    items=MultipleJoin('BossDetail', joinColumn = 'header_id')
    latestFlag=IntCol(default = 1)
    remark=UnicodeCol(default = '', length = 500, notNone = False)
    exportVersion=IntCol(default = 0)
    shipmentQty=IntCol(default = 0)
    wastageQty=IntCol(default = 0)

    isComplete=IntCol(default = 0)  #0 means that not all the information is complete, 1 means all the information is complete.
    attachment=UnicodeCol(default = '', length = 200)
    importdate=DateTimeCol(default = datetime.now)
    history=UnicodeCol(default = '', length = 500)
    issuedBy=ForeignKey('User', cascade = False, default = 1)
    active=IntCol(default = 1)  # 1 is active , 0 is inactive

    done=IntCol(default = 1)  # the cut off day is 2009-12-09 ,before the day is old ,set to 0 , after the day ,is new ,set to 1


    @property
    def sortedSubChildren(self):
        #return reduce(lambda x,obj:x+obj.qty,self.items)
        #return reduce(lambda x, y:x+y, map(lambda x:x.qty, self.items), 0)
        return sum([n.qty for n in BossNewDetail.selectBy(header = self)])

    @property
    def totalQtyWithSampleWastage(self):
        return sum([n.totalQty for n in BossNewDetail.selectBy(header = self)])

	#add by cz@2010-10-15
    @property
    def totalQtyWithSample(self):
        return sum([n.shipSampleQty for n in BossNewDetail.selectBy(header = self)])

    @property
    def totalQtyWithoutRoundup(self):
        return sum([n.wastageQty for n in BossNewDetail.selectBy(header = self)])


    @property
    def printedLegacyCode(self):
            #change by CL , on 2010-03-18 , required by Joanna
            #From 2010-03-22, the lot num should be totally follow the info Bossini supply.
#        if self.lotCount > 0 :
#            return "%s-%s-%s(%d)" % (self.legacyCode[:2],self.legacyCode[2:7],self.legacyCode[7:],self.lotCount)
        if self.lotNum>0:
            return "%s-%s-%s(%d)"%(self.legacyCode[:2], self.legacyCode[2:7], self.legacyCode[7:], self.lotNum)
        return "%s-%s-%s"%(self.legacyCode[:2], self.legacyCode[2:7], self.legacyCode[7:])



#    @property
#    def printedNetPrice(self):
#        if self.marketList in ['EXP', 'MYS'] : return ""
#        if not self.netPrice : return ""
#
#        np=fmtNumber(self.netPrice)
#
#        if self.legacyCode.startswith("6") or self.legacyCode.startswith("7"):
#            if self.marketList=="HKM" : return "$%s.00"%np
#            if self.marketList=="TWN" : return "$%s."%np
#            if self.marketList=="SIN" : return "$%s.00"%np
#            if self.marketList=="CHN" : return u'\uffe5%s'%np
#        elif self.legacyCode.startswith("8"):
#            if self.marketList=="HKM" : return "HK$ %s"%np
#            if self.marketList=="TWN" : return "NT$ %s"%np
#            if self.marketList=="SIN" : return "SGD %s"%np
#            if self.marketList=="CHN" : return u"\uffe5 %s"%np
#        else:return np




#    @property
#    def priceInHTML(self):
#        if self.marketList in ['EXP', 'MYS'] : return ""
#        if not self.netPrice : return ""
#
#        np=fmtNumber(self.netPrice)
#
#        if self.legacyCode.startswith("6") or self.legacyCode.startswith("7"):
#            if self.marketList=="CHN" : return "&yen; %s"%np
#            elif self.marketList=="TWN" : return "$%s."%np
#            #Add by CL.Lam on 2010-05-04,if the market is HK and legacy code is start with "7", the net price should be "HK$##.##"
#            elif self.marketList=="HKM" and self.legacyCode and self.legacyCode.startswith("7") : return "HK$%s.00"%np
#            else : return "$%s.00"%np
#        elif self.legacyCode.startswith("8"):
#            if self.marketList=="HKM" : return "HK$ %s"%np
#            if self.marketList=="TWN" : return "NT$ %s"%np
#            if self.marketList=="SIN" : return "SGD %s"%np
#            if self.marketList=="CHN" : return "&yen; %s"%np
#        else: return self.netPrice



    @property
    def printedHangTagType(self):
        if self.hangTagType=="H" : return "Hang Tag"
        elif self.hangTagType=="W" : return "Waist Card"
        elif self.hangTagType=="S" : return "Sticker"
        return ""

    @property
    def getHangTagCode(self):
        for n in BossNewDetail.selectBy(header = self):
            if n.hangTag : return n.hangTag
        return ""


class BossDetail(SQLObject):
    #_connection = ph
    class sqlmeta:
        table="bossini_detail_po"
    header=ForeignKey('Bossini')
    colorCode=UnicodeCol(default = '', length = 10, notNone = False)
    recolorCode=UnicodeCol(default = '', length = 10, notNone = False)
    colorName=UnicodeCol(default = '', length = 30, notNone = False)
    sizeCode=UnicodeCol(default = '', length = 30, notNone = False)
    sizeName=UnicodeCol(default = '', length = 10, notNone = False)
    sizeRange=UnicodeCol(default = '', length = 100, notNone = False)
    resizeRange=UnicodeCol(default = '', length = 100, notNone = False)
    qty=IntCol(default = 0, notNone = False)
    eanCode=UnicodeCol(default = '', length = 50, notNone = False)
    length=UnicodeCol(default = '', notNone = False)
    hasExported=IntCol(default = 0)
    collectionCode=UnicodeCol(default = '', length = 20, notNone = False)
    launchMonth=UnicodeCol(default = '', length = 20, notNone = False)
    priceCurrency=UnicodeCol(default = '', length = 10, notNone = False)
    netPrice=UnicodeCol(default = '', length = 10, notNone = False)
    blankPrice=UnicodeCol(default = '', length = 2, notNone = False)


class BossNewDetail(BossDetail):
    #_connection = ph
    class sqlmeta:
        table="bossini_new_detail"
    hangTag=UnicodeCol(default = '', length = 30, notNone = False)
    waistCard=UnicodeCol(default = '', length = 100, notNone = False)
    mainLable=UnicodeCol(default = '', length = 100, notNone = False)
    sizeLable=UnicodeCol(default = '', length = 100, notNone = False)
    shipSample=IntCol(default = 0, notNone = False)
    wastage=IntCol(default = 0, notNone = False)
    invoiceNo=UnicodeCol(default = '', length = 100, notNone = False)
    exDate=DateTimeCol(default = datetime.now)
    inseamx=UnicodeCol(default = '', length = 30, notNone = False)
    inseamy=UnicodeCol(default = '', length = 30, notNone = False)
    frameColor=UnicodeCol(default = '', length = 30, notNone = False)



    @property
    def shipSampleQty(self):
        return self.header.shipmentQty+self.qty

    @property
    def wastageQty(self):
        return int(round(self.shipSampleQty*(1+float(self.header.wastageQty)/100)))


    @property
    def totalQty(self):
        q=self.wastageQty
        qq=q/10*10+10 if math.fmod(q, 10)>0 else q
        return qq if qq>50 else 50



    @property
    def printedNetPrice(self):
        if self.header.marketList in ['EXP', 'MYS'] : return ""
        if not self.netPrice : return ""

        np=fmtNumber(self.netPrice)

        if self.header.legacyCode.startswith("6") or self.header.legacyCode.startswith("7"):
            if self.header.marketList=="HKM" : return "$%s.00"%np
            if self.header.marketList=="TWN" : return "$%s."%np
            if self.header.marketList=="SIN" : return "$%s.00"%np
            if self.header.marketList=="CHN" : return u'\uffe5%s'%np
        elif self.header.legacyCode.startswith("8"):
            if self.header.marketList=="HKM" : return "HK$ %s"%np
            if self.header.marketList=="TWN" : return "NT$ %s"%np
            if self.header.marketList=="SIN" : return "SGD %s"%np
            if self.header.marketList=="CHN" : return u"\uffe5 %s"%np
        else:return np



    @property
    def priceInHTML(self):
        if self.header.marketList in ['EXP', 'MYS'] : return ""
        if not self.netPrice : return ""

        np=fmtNumber(self.netPrice)

        if self.header.legacyCode.startswith("6") or self.header.legacyCode.startswith("7"):
            if self.header.marketList=="CHN" : return "&yen; %s"%np
            elif self.header.marketList=="TWN" : return "$%s."%np
            #Add by CL.Lam on 2010-05-04,if the market is HK and legacy code is start with "7", the net price should be "HK$##.##"
            elif self.header.marketList=="HKM" and self.header.legacyCode and self.header.legacyCode.startswith("7") : return "HK$%s.00"%np
            else : return "$%s.00"%np
        elif self.header.legacyCode.startswith("8"):
            if self.header.marketList=="HKM" : return "HK$ %s"%np
            if self.header.marketList=="TWN" : return "NT$ %s"%np
            if self.header.marketList=="SIN" : return "SGD %s"%np
            if self.header.marketList=="CHN" : return "&yen; %s"%np
        else: return self.netPrice




class BossiniLegacyInfo(SQLObject):
    #_connection = ph
    class sqlmeta:
        table="bossini_legacy_info"
    legacyCode=UnicodeCol(default = '', length = 20, notNone = False)
    mainLabel=UnicodeCol(default = '', length = 20, notNone = False)
    sizeLabel=UnicodeCol(default = '', length = 20, notNone = False)
    hangTag=UnicodeCol(default = '', length = 20, notNone = False)
    waistCard=UnicodeCol(default = '', length = 20, notNone = False)
    inseamx=UnicodeCol(default = '', length = 20, notNone = False)
    inseamy=UnicodeCol(default = '', length = 20, notNone = False)
    cat=UnicodeCol(default = '', length = 20, notNone = False)

    isHangTagForAllMarket=IntCol(default = 0) #0 is for one market , 1 is for all market
    isWaistCardForAllMarket=IntCol(default = 0) #0 is for one market , 1 is for all market
    createDate=DateTimeCol(default = datetime.now)
    status=IntCol(default = 0) # 0 is active ,1 is inactive


class Vendor(SQLObject):
    class sqlmeta:
        table="bossini_vendor"

    vendorCode=UnicodeCol(length = 20)
    vendorName=UnicodeCol(length = 50, default = None)
    erpCode=UnicodeCol(length = 20, default = None)
    description=UnicodeCol(length = 2000, default = None)
    billTo=MultipleJoin('VendorBillToInfo', joinColumn = 'vendor_id')
    shipTo=MultipleJoin('VendorShipToInfo', joinColumn = 'vendor_id')

    feedbackEmail=UnicodeCol(length = 100, default = None)
    aeEmail=UnicodeCol(length = 100, default = None)

    history=UnicodeCol(length = 100, default = None)
    createDate=DateTimeCol(default = datetime.now)
    issuedBy=ForeignKey('User', cascade = False, default = 1)
    active=IntCol(default = 1) # 1 is active ,0 is inactive


class VendorBillToInfo(SQLObject):
    class sqlmeta:
        table="bossini_vendor_billto_info"
    vendor=ForeignKey('Vendor')
    billTo=UnicodeCol(length = 200)
    address=UnicodeCol(length = 1000, default = "")
    contact=UnicodeCol(length = 100, default = "")
    tel=UnicodeCol(length = 100, default = "")
    fax=UnicodeCol(default = None, length = 50)
    currency=UnicodeCol(length = 20, default = "")
    payterm=UnicodeCol(length = 100, default = "")
    needChangeFactory=UnicodeCol(length = 20, default = "")
    needVAT=UnicodeCol(length = 20, default = "")
    needInvoice=UnicodeCol(length = 20, default = "")
    account=UnicodeCol(length = 100, default = "")
    createDate=DateTimeCol(default = datetime.now)
    issuedBy=ForeignKey('User', cascade = False, default = 1)
    active=IntCol(default = 0) # 0 is active ,1 is inactive
    flag=IntCol(default = 0) #be set default as 1
    haulage=UnicodeCol(length = 100, default = "")

    def __str__(self):
        return self.billTo


class VendorShipToInfo(SQLObject):
    class sqlmeta:
        table="bossini_vendor_shipto_info"

    vendor=ForeignKey('Vendor')
    shipTo=UnicodeCol(length = 200)
    address=UnicodeCol(length = 1000)
    contact=UnicodeCol(length = 100, default = "")
    tel=UnicodeCol(length = 100, default = "")
    fax=UnicodeCol(default = None, length = 50)
    email=UnicodeCol(length = 100, default = "")
    sampleReceiver=UnicodeCol(length = 100, default = "")
    sampleReceiverTel=UnicodeCol(length = 100, default = "")
    sampleSendAddress=UnicodeCol(length = 1000, default = "")
    requirement=UnicodeCol(length = 2000, default = "")
    createDate=DateTimeCol(default = datetime.now)
    issuedBy=ForeignKey('User', cascade = False, default = 1)
    active=IntCol(default = 0) # 0 is active ,1 is inactive
    flag=IntCol(default = 0) #be set default as 1

    def __str__(self):
        return self.shipTo


class BossiniOrder(SQLObject):
    class sqlmeta:
        table="bossini_order_info"
    po=ForeignKey('Bossini')
    billTo=ForeignKey('VendorBillToInfo')
    billToAddress=UnicodeCol(default = None, length = 1000)
    billToContact=UnicodeCol(default = None, length = 100)
    billToTel=UnicodeCol(default = None, length = 100)
    billToFax=UnicodeCol(default = None, length = 100)
    billToEmail=UnicodeCol(default = None, length = 100)
    currency=UnicodeCol(default = None, length = 20)
    payterm=UnicodeCol(length = 100, default = "")
    shipmentInstruction=UnicodeCol(default = None, length = 200)
    needChangeFactory=UnicodeCol(length = 20, default = None)
    VATInfo=UnicodeCol(default = None, length = 100)
    invoiceInfo=UnicodeCol(default = None, length = 100)
    accountContact=UnicodeCol(default = None, length = 100)

    shipTo=ForeignKey('VendorShipToInfo')
    shipToAddress=UnicodeCol(default = None, length = 1000)
    shipToContact=UnicodeCol(default = None, length = 100)
    shipToTel=UnicodeCol(default = None, length = 100)
    shipToFax=UnicodeCol(default = None, length = 100)
    shipToEmail=UnicodeCol(default = None, length = 100)
    sampleReceiver=UnicodeCol(default = None, length = 100)
    sampleReceiverTel=UnicodeCol(default = None, length = 100)
    sampleSendAddress=UnicodeCol(default = None, length = 1000)
    requirement=UnicodeCol(default = None, length = 1000)

    #for CHN market
    typeName=UnicodeCol(default = None, length = 100)
    specification=UnicodeCol(default = None, length = 100)
    prodcuingArea=UnicodeCol(default = None, length = 100)
    unit=UnicodeCol(default = None, length = 100)
    pricer=UnicodeCol(default = None, length = 100)

    productName=UnicodeCol(default = None, length = 100)
    standard=UnicodeCol(default = None, length = 100)
    standardExt=UnicodeCol(default = None, length = 100)
    grade=UnicodeCol(default = None, length = 100)
    checker=UnicodeCol(default = None, length = 100)
    no=UnicodeCol(default = None, length = 100)
    technicalType=UnicodeCol(default = None, length = 100)

    customerOrderNo=UnicodeCol(default = None, length = 100)
    orderType=UnicodeCol(default = None, length = 10)


    createDate=DateTimeCol(default = datetime.now)
    issuedBy=ForeignKey('User', cascade = False, default = 1)
    lastModifyTime=DateTimeCol(default = datetime.now)
    lastModifyBy=ForeignKey('User', cascade = False)
    active=IntCol(default = 0) # 0 is active ,1 is inactive

    processCompany=UnicodeCol(default = None, length = 100)

    #add below filed as joanna by Ray
    confirmDate=DateTimeCol(default = datetime.now)
    filename=UnicodeCol(default = None, length = 1000)
    exitFactoryDate=DateTimeCol(default = None)
    receiptDate=DateTimeCol(default = None)
    vendor=ForeignKey('Vendor')
    wlShipment=IntCol(default = 0)  #woven label's shipment qty
    

    @property
    def getMainLabelPrice(self):
        if not self.billTo : return 0
        wls=WovenLabelInfo.selectBy(orderInfo = self, active = 0, labelType = "M")
        if wls.count()<1 : return 0

        if self.billTo.currency=='RMB' : return wls[0].item.rmbPrice
        elif self.billTo.currency=='HKD' : return wls[0].item.hkPrice

    @property
    def getSizeLabelPrice(self):
        if not self.billTo : return 0
        wls=WovenLabelInfo.selectBy(orderInfo = self, active = 0, labelType = "S")
        if wls.count()<1 : return 0

        if self.billTo.currency=='RMB' : return wls[0].item.rmbPrice
        elif self.billTo.currency=='HKD' : return wls[0].item.hkPrice


    @property
    def countMainLabelAmt(self):
        if not self.billTo : return 0
        if self.billTo.currency=='RMB' :
            return sum([w.qty*w.item.rmbPrice for w in WovenLabelInfo.selectBy(orderInfo = self, active = 0, labelType = "M")])
        elif self.billTo.currency=='HKD':
            return sum([w.qty*w.item.hkPrice for w in WovenLabelInfo.selectBy(orderInfo = self, active = 0, labelType = "M")])


    @property
    def countSizeLabelAmt(self):
        if not self.billTo : return 0
        if self.billTo.currency=='RMB' :
            return sum([w.qty*w.item.rmbPrice for w in WovenLabelInfo.selectBy(orderInfo = self, active = 0, labelType = "S")])
        elif self.billTo.currency=='HKD':
            return sum([w.qty*w.item.hkPrice for w in WovenLabelInfo.selectBy(orderInfo = self, active = 0, labelType = "S")])


class PrintingCardInfo(SQLObject):
    class sqlmeta:
        table="bossini_order_printing_card"
    orderInfo=ForeignKey('BossiniOrder')
    cardType=UnicodeCol(default = None, length = 50)
    item=ForeignKey('BossiniItem')
    qty=IntCol(default = 0)
    active=IntCol(default = 0) # 0 is active ,1 is inactive


class WovenLabelInfo(SQLObject):
    class sqlmeta:
        table="bossini_order_woven_label"
    orderInfo=ForeignKey('BossiniOrder')
    labelType=UnicodeCol(default = None, length = 50)
    item=ForeignKey('BossiniItem')
    size=UnicodeCol(default = None, length = 10)
    measure=UnicodeCol(length = 20, default = None)
    qty=IntCol(default = 0)
    length=UnicodeCol(length = 10, default = None)
    active=IntCol(default = 0) # 0 is active ,1 is inactive



class BossiniItem(SQLObject):
    class sqlmeta:
        table="bossini_item"

    itemCode=UnicodeCol(default = None, length = 50)
    description=UnicodeCol(default = None, length = 2000)
    unit=UnicodeCol(default = None, length = 50)
    rmbPrice=DecimalCol(size = 20, precision = 6)
    hkPrice=DecimalCol(size = 20, precision = 6)
    active=IntCol(default = 0) # 0 is active ,1 is inactive
    itemType=UnicodeCol(default = None, length = 10) # H=>HangTag, W=>WaistCard,WOV=>WovenLabel
    labelType=UnicodeCol(default = None, length = 10) # just belong to WovenLabel, has SizeLable as S and MainLabel as M FlagLable as F
    component=UnicodeCol(length = 50, default = None)
    display=UnicodeCol(default = None, length = 100)
    img=UnicodeCol(default = None, length = 50)
    #add by CL on 2010-09-21,indicate the item belong to Man,Ladies,Kid or Baby
#    grouping=IntCol()   # 0 is for all, 1 is men, 2 is ladies, 3 is kid(boy), 
#                                   # 4 is kid(girls),5 is baby(boy) 6 is baby(girl) , 7 is yb(m), 8 is yb(f)

    def __str__(self):
        return self.display

    @property
    def showItemType(self):
        if self.itemType=="H" : return "Hang Tag"
        if self.itemType=="W" : return "Waist Card"
        if self.itemType=="WOV":
            if self.labelType=="M" : return "Main Label"
            if self.labelType=="S" : return "Size Label"
        if self.itemType=="F" : return "Function Card"
        if self.itemType=="C" : return "Care Label"
        if self.itemType=="CO" : return "Country of Origin"
        if self.itemType=="S" : return "Style Printed Label"
        if self.itemType=="ST" : return "Sticker"
        if self.itemType=="BW" : return "Bodywear"

        return ""


class UploadObject(SQLObject):
    class sqlmeta:
        table="upload_object"

    name=UnicodeCol(length = 100, default = None)
    path=UnicodeCol(length = 200, default = None)
    comment=UnicodeCol(length = 500, default = None)
    size=UnicodeCol(length = 100, default = None)
    createTime=DateTimeCol(default = datetime.now, validator = validators.DateTimeConverter(format = DB_DATE_TIME_FORMAT))
    issuedBy=ForeignKey('User', cascade = False)
    status=IntCol(default = 0)  # 0 is active , 1 is inactive


class BossiniSizeMapping(SQLObject):
    class sqlmeta:
        table="bossini_size_mapping"

    size=UnicodeCol(length = 20, default = None)
    measure=UnicodeCol(length = 20, default = None)
    type=UnicodeCol(length = 10, default = None)
    line=UnicodeCol(length = 20, default = None)
    weave=UnicodeCol(length = 10, default = None) #WOVEN,KNIT two kinds are storded in db
    status=IntCol(default = 0)  # 0 is active , 1 is inactive

    @property
    def getWeaveStatus(self):
        if self.weave=='WOVEN':
            return 'WOVEN'
        else:
            #knit or sweater return knit
            return 'KNIT'


class Parts(SQLObject):
    class sqlmeta: table="bossini_parts"

    content=UnicodeCol(length = 100, default = None)
    contentSC=UnicodeCol(length = 100, default = None)
    contentTC=UnicodeCol(length = 100, default = None)
    needCoating=IntCol(default = 0)  # 0 mean don't need the coating, 1 mean need the coating.
    status=IntCol(default = 0)  # 0 is active , 1 is inactive


class Origin(SQLObject):
    class sqlmeta: table="bossini_origin"

    China=UnicodeCol(length = 100, default = None)
    HKSINEXP=UnicodeCol(length = 100, default = None)
    TWN=UnicodeCol(length = 100, default = None)
    Egypt=UnicodeCol(length = 100, default = None)
    Romanian=UnicodeCol(length = 100, default = None)
    Poland=UnicodeCol(length = 100, default = None)
    Russia=UnicodeCol(length = 100, default = None)
    Japanese=UnicodeCol(length = 100, default = None)
    French=UnicodeCol(length = 100, default = None)
    Germany=UnicodeCol(length = 100, default = None)
    Spanish=UnicodeCol(length = 100, default = None)
    Italian=UnicodeCol(length = 100, default = None)
    Korea=UnicodeCol(length = 100, default = None)
    Indonesia=UnicodeCol(length = 100, default = None)
    Ukrainian=UnicodeCol(length = 100, default = None)
    Portuguese=UnicodeCol(length = 100, default = None)

    status=IntCol(default = 0)  # 0 is active , 1 is inactive

class FiberContent(SQLObject):
    class sqlmeta: table="bossini_fiber_content"

    China=UnicodeCol(length = 100, default = None)
    HKSINEXP=UnicodeCol(length = 100, default = None)
    TWN=UnicodeCol(length = 100, default = None)
    Egypt=UnicodeCol(length = 100, default = None)
    Romanian=UnicodeCol(length = 100, default = None)
    Poland=UnicodeCol(length = 100, default = None)
    Russia=UnicodeCol(length = 100, default = None)
    Japanese=UnicodeCol(length = 100, default = None)
    French=UnicodeCol(length = 100, default = None)
    Germany=UnicodeCol(length = 100, default = None)
    Spanish=UnicodeCol(length = 100, default = None)
    Italian=UnicodeCol(length = 100, default = None)
    Indonesia=UnicodeCol(length = 100, default = None)
    Ukrainian=UnicodeCol(length = 100, default = None)
    Portuguese=UnicodeCol(length = 100, default = None)

    TraditionChinese=UnicodeCol(length = 100, default = None)

    status=IntCol(default = 0)  # 0 is active , 1 is inactive


class CareInstruction(SQLObject):
    class sqlmeta: table="bossini_care_instruction"

    styleIndex=IntCol()
    contentEn=UnicodeCol(length = 100, default = None)  #English
    contentSC=UnicodeCol(length = 100, default = None)  #simple Chinese
    contentTC=UnicodeCol(length = 100, default = None)  #tradition Chinese
    Indonesia=UnicodeCol(length = 100, default = None)
    instructionType=UnicodeCol(length = 20, default = None)
    bindFor=UnicodeCol(length = 20, default = None)
    status=IntCol(default = 0)  # 0 is active , 1 is inactive
    typenum=UnicodeCol(length = 20, default = None)

############################################################# move by Ray
class FunctionCardInfo(SQLObject):
    class sqlmeta: table="bossini_function_card_info"

    orderInfo=ForeignKey('BossiniOrder')
    item=ForeignKey('BossiniItem')
    qty=IntCol(default = 0)
    status=IntCol(default = 0) # 0 is active ,1 is inactive

    def getDetails(self):
        return FunctionCardInfoDetail.selectBy(header = self)

class StyleLabelInfo(SQLObject):
    class sqlmeta: table="bossini_style_label_info"

    orderInfo=ForeignKey('BossiniOrder')
    item=ForeignKey('BossiniItem')
    status=IntCol(default = 0) # 0 is active ,1 is inactive

    def getDetails(self):
        return StyleLabelInfoDetail.selectBy(header = self)

class DownJacketInfo(SQLObject):
    class sqlmeta: table="bossini_down_jacket_info"

    orderInfo=ForeignKey('BossiniOrder')
    item=ForeignKey('BossiniItem')
    qty=IntCol(default = 0)
    downContent=IntCol(default = None)
    filling165=IntCol(default = None)
    filling170=IntCol(default = None)
    filling175=IntCol(default = None)
    filling180=IntCol(default = None)
    filling185=IntCol(default = None)

    #Children size for stain
    fillingC100=IntCol(default = None)
    fillingC110=IntCol(default = None)
    fillingC120=IntCol(default = None)
    fillingC130=IntCol(default = None)
    fillingC140=IntCol(default = None)
    fillingC150=IntCol(default = None)
    fillingC160=IntCol(default = None)
    fillingC170=IntCol(default = None)
    #BB size for stain
    fillingB6=IntCol(default = None)
    fillingB12=IntCol(default = None)
    fillingB18=IntCol(default = None)
    fillingB90=IntCol(default = None)
    fillingB100=IntCol(default = None)

    fillingW160=IntCol(default = None)
    fillingW165=IntCol(default = None)
    fillingW170=IntCol(default = None)
    fillingW17592Y=IntCol(default = None)
    fillingW17592A=IntCol(default = None)
    fillingW17596A=IntCol(default = None)

    status=IntCol(default = 0) # 0 is active ,1 is inactive

    def getDetails(self):
        return DownJacketInfoDetail.selectBy(header = self)
#######################################################################

class BossiniLegacyCode(SQLObject):
    class sqlmeta: table="bossini_legacy_code"

    legacyCode=UnicodeCol(default = '', length = 20, notNone = False)
    functionCardInfos=RelatedJoin('FunctionCardInfo', intermediateTable = 'bossini_legacy_function', joinColumn = 'legacy_id', otherColumn = 'function_id')
    styleLabelInfos=RelatedJoin('StyleLabelInfo', intermediateTable = 'bossini_legacy_style', joinColumn = 'legacy_id', otherColumn = 'style_id')
    downJacketInfos=RelatedJoin('DownJacketInfo', intermediateTable = 'bossini_legacy_downjacket', joinColumn = 'legacy_id', otherColumn = 'downjacket_id')
    status=IntCol(default = 0)  # 0 is active , 1 is inactive

    def __str__(self):
        return self.legacyCode





class FunctionCardInfoDetail(SQLObject):
    class sqlmeta: table="bossini_function_card_info_detail"

    header=ForeignKey('FunctionCardInfo')
    legacyCode=ForeignKey('BossiniLegacyCode')





class StyleLabelInfoDetail(SQLObject):
    class sqlmeta: table="bossini_style_label_info_detail"

    header=ForeignKey('StyleLabelInfo')
    legacyCode=ForeignKey('BossiniLegacyCode')
    qty=IntCol(default = 0)




class CareLabelInfo(SQLObject):
    class sqlmeta: table="bossini_care_label_info"

    orderInfo=ForeignKey('BossiniOrder')
    item=ForeignKey('BossiniItem')
    origin=ForeignKey('Origin')
    washing=ForeignKey('CareInstruction')
    bleaching=ForeignKey('CareInstruction')
    ironing=ForeignKey('CareInstruction')
    dryCleaning=ForeignKey('CareInstruction')
    drying=ForeignKey('CareInstruction')
    othersDrying=ForeignKey('CareInstruction')
    appendix=UnicodeCol(default = None, length = 50)
    status=IntCol(default = 0) # 0 is active ,1 is inactive

    def getDetail(self):
        return CareLabelInfoDetail.selectBy(header = self)

    def getComponents(self):
        return CareLabelComponentHeader.selectBy(careLabelInfo = self)

class CareLabelInfoDetail(SQLObject):
    class sqlmeta: table="bossini_care_label_info_detail"

    header=ForeignKey('CareLabelInfo')
    legacyCode=ForeignKey('BossiniLegacyCode')
    qty=IntCol(default = 0)
    customerOrderNo=UnicodeCol(default = None, length = 100)
    status=IntCol(default = 0) # 0 is active ,1 is inactive


class CareLabelComponentHeader(SQLObject):
    class sqlmeta: table="bossini_care_label_component_header"

    careLabelInfo=ForeignKey('CareLabelInfo')
    name=ForeignKey('Parts')
    coating=UnicodeCol(length = 5, default = None)
    microelement=UnicodeCol(length = 5, default = None)
    status=IntCol(default = 0) # 0 is active ,1 is inactive

    def getDetail(self):
        return CareLabelComponentDetail.selectBy(header = self)

class CareLabelComponentDetail(SQLObject):
    class sqlmeta: table="bossini_care_label_component_detail"

    header=ForeignKey('CareLabelComponentHeader')
#    percentage = IntCol(default=0)
    percentage=UnicodeCol(length = 10, default = None)
    component=ForeignKey('FiberContent')



class DownJacketInfoDetail(SQLObject):
    class sqlmeta: table="bossini_down_jacket_info_detail"

    header=ForeignKey('DownJacketInfo')
    legacyCode=ForeignKey('BossiniLegacyCode')


class CareLabelPattern(SQLObject):
    class sqlmeta: table="bossini_care_label_pattern"

    vendor=ForeignKey('Vendor')
    name=UnicodeCol(default = None, length = 20)
    origin=ForeignKey('Origin')
    washing=ForeignKey('CareInstruction')
    bleaching=ForeignKey('CareInstruction')
    ironing=ForeignKey('CareInstruction')
    dryCleaning=ForeignKey('CareInstruction')
    drying=ForeignKey('CareInstruction')
    othersDrying=ForeignKey('CareInstruction')
    appendix=UnicodeCol(default = None, length = 50)
    status=IntCol(default = 0) # 0 is active ,1 is inactive

    def getComponents(self):
        return PatternComponentHeader.selectBy(careLabelInfo = self)


class PatternComponentHeader(SQLObject):
    class sqlmeta: table="bossini_pattern_component_header"

    careLabelInfo=ForeignKey('CareLabelPattern')
    name=ForeignKey('Parts')
    coating=UnicodeCol(length = 5, default = None)

    def getDetail(self):
        return PatternComponentDetail.selectBy(header = self)

class PatternComponentDetail(SQLObject):
    class sqlmeta: table="bossini_pattern_component_detail"

    header=ForeignKey('PatternComponentHeader')
    percentage=UnicodeCol(length = 10, default = None)
    component=ForeignKey('FiberContent')



class BossiniRemark(SQLObject):
    class sqlmeta: table="bossini_remark"

    vendor=UnicodeCol(length = 10)
    remark=UnicodeCol(length = 1000)
    active=IntCol(default = 0) # 0 is active ,1 is inactive



class KsRegion(SQLObject):
    class sqlmeta:
        table="kohls_region"
    name=UnicodeCol(length = 100)
    email_address=UnicodeCol(length = 255, default = None)
    description=UnicodeCol(length = 1000, default = None)
    isWork=IntCol(default = 0)  #0 is work region , and 1 is not workable ,won't show on the drop down list in the new or revised page.

    hardlineEmail=UnicodeCol(length = 255, default = None)
    softlineEmail=UnicodeCol(length = 255, default = None)
    combinedEmail=UnicodeCol(length = 255, default = None)
    forHardline=IntCol(default = 0)
    forSoftline=IntCol(default = 0)


    createTime=DateTimeCol(default = datetime.now, validator = validators.DateTimeConverter(format = DB_DATE_TIME_FORMAT))
    lastModifyTime=DateTimeCol(default = datetime.now, validator = validators.DateTimeConverter(format = DB_DATE_TIME_FORMAT))
    issuedBy=ForeignKey('User', cascade = False)
    lastModifyBy=ForeignKey('User', cascade = False)
    histroty=UnicodeCol(length = 500, default = "")

    departmentFlag=IntCol(default =-1)
    status=IntCol(default = 0)  # 0 is active , 1 is inactive
    def __str__(self):
        return self.name


class StickerInfo(SQLObject):
    class sqlmeta:
        table="bossini_stickerinfo"
    orderInfo=ForeignKey('BossiniOrder')
    item=ForeignKey('BossiniItem')
    washing=ForeignKey('CareInstruction')
    bleaching=ForeignKey('CareInstruction')
    ironing=ForeignKey('CareInstruction')
    dryCleaning=ForeignKey('CareInstruction')
    drying=ForeignKey('CareInstruction')
    othersDrying=ForeignKey('CareInstruction')
    appendix=UnicodeCol(default = None, length = 50)
    shipmentQty=IntCol(default = 0)
    wastageQty=IntCol(default = 0)
    qty=IntCol(default = 0)
    active=IntCol(default = 0) # 0 is active ,1 is inactive



#===============================================================================
# add by CL on  2010-10-11
#===============================================================================

class BossiniFiberContentLayer(SQLObject):
    class sqlmeta: table="bossini_fiber_content_layer"

    percentage=UnicodeCol(length = 10, default = None)
    component=ForeignKey('FiberContent')
    grouping=UnicodeCol(length = 50, default = None)
    orderInfo=ForeignKey('BossiniOrder')
    value1=UnicodeCol(length = 100, default = None)
    value2=UnicodeCol(length = 100, default = None)
    value3=UnicodeCol(length = 100, default = None)
    value4=UnicodeCol(length = 100, default = None)
    value5=UnicodeCol(length = 100, default = None)


class BossiniChinaStandardCode(SQLObject):
    class sqlmeta: table="bossini_china_standard_code"
    name=UnicodeCol(length = 100)
    status=IntCol(default = 0) # 0 is active ,1 is inactive

    def __str__(self): return self.name



class BossiniChinaProductName(SQLObject):
    class sqlmeta: table="bossini_china_product_name"
    name=UnicodeCol(length = 100)
    status=IntCol(default = 0) # 0 is active ,1 is inactive

    def __str__(self): return self.name



class BossiniChinaArea(SQLObject):
    class sqlmeta: table="bossini_china_area"
    name=UnicodeCol(length = 100)
    status=IntCol(default = 0) # 0 is active ,1 is inactive

    def __str__(self): return self.name




class BossiniChinaChecker(SQLObject):
    class sqlmeta: table="bossini_china_checker"
    name=UnicodeCol(length = 100)
    status=IntCol(default = 0) # 0 is active ,1 is inactive

    def __str__(self): return self.name


#add by cz@2010-10-12
class BodyWearLabelInfo(SQLObject):
    class sqlmeta:
        table="bossini_order_body_wear_label"
    orderInfo=ForeignKey('BossiniOrder')
    item=ForeignKey('BossiniItem')
    qty=IntCol(default = 0)
    washing=ForeignKey('CareInstruction')
    bleaching=ForeignKey('CareInstruction')
    ironing=ForeignKey('CareInstruction')
    dryCleaning=ForeignKey('CareInstruction')
    drying=ForeignKey('CareInstruction')
    othersDrying=ForeignKey('CareInstruction')
    active=IntCol(default = 0) # 0 is active ,1 is inactive

class BodyWearLabelDetail(SQLObject):
    class sqlmeta:
        table="bossini_body_wear_label_detail"
    bodyWearLabelInfo=ForeignKey('BodyWearLabelInfo')
    bossNewDetail=ForeignKey('BossNewDetail')
    measure=UnicodeCol(length = 20, default = None)
    active=IntCol(default = 0) # 0 is active ,1 is inactive


#===========================================================================
# Main Label@2011-01-04.
#===========================================================================
class MainLabelInfo(SQLObject):
    class sqlmeta: table="bossini_main_label_info"

    orderInfo=ForeignKey('BossiniOrder')
    item=ForeignKey('BossiniItem')
    status=IntCol(default = 0) # 0 is active ,1 is inactive

    def getDetails(self):
        return MainLabelInfoDetail.selectBy(header = self)

class MainLabelInfoDetail(SQLObject):
    class sqlmeta: table="bossini_main_label_info_detail"

    header=ForeignKey('MainLabelInfo')
    legacyCode=ForeignKey('BossiniLegacyCode')
    qty=IntCol(default = 0)


if __name__=="__main__":
#    print PLS.get(id = 1).populate()
    pass

