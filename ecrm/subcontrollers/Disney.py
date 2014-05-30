# -*- coding: utf-8 -*-
import turbogears
from turbogears import controllers, expose, flash,redirect,paginate,identity,widgets
from sqlobject.sqlbuilder import *
from cherrypy.lib.cptools import serveFile
from ecrm.util.excel_helper import *
from ecrm.util.oracle_helper import *

import datetime,logging,os,random,traceback,zipfile,shutil
from ecrm.util.common import *

class DisneyController(controllers.Controller, identity.SecureResource):

    require=identity.in_any_group("DISNEY", "Admin")

    @expose(template="ecrm.templates.disney.report")
    @tabFocus(tab_type="report")
    def report(self,**kw):
        return {}

    @expose()
    def reportDetail(self,**kw):
        #prepare the sql
        USD2HKD = turbogears.config.get("USD2HKD")
        USD2RMB = turbogears.config.get("USD2RMB")

        wc = []

        wc.append("where dtl.COMPANY_CODE in ('RPAC', 'RPACPACK') and dtl.PROGRAM='DISNEY' and hdr.ORDER_DEPT='C' and hdr.STATUS != 'D'")

        xlsCountry = 'r-pac Hong Kong'
        xlsDate = '%s ~ %s' % (kw.get("in_issue_date_fr"), kw.get("in_issue_date_to"))

        if kw.get("in_issue_date_fr",None):
            wc.append("hdr.issue_date >= TO_DATE('%s','YYYY-MM-DD')" % kw["in_issue_date_fr"])
        if kw.get("in_issue_date_to",None):
            wc.append("hdr.issue_date <= TO_DATE('%s','YYYY-MM-DD')" % kw["in_issue_date_to"])

        whereCondition = " AND ".join(wc)
        orderByCaulse = " ORDER BY hdr.sales_contract_no, dtl.item_no "

        sql = '''
            select hdr.CUSTOMER_NAME, hdr.ISSUE_DATE, hdr.SALES_CONTRACT_NO, dn_hdr.CONFIRM_DATE,dtl.BRAND, dtl.ITEM_NO, dtl.BASE_QTY, 'USD'CURRENCY,
            decode(hdr.CURRENCY,'HKD',dtl.UNIT_PRICE/%s,'RMB',dtl.UNIT_PRICE/%s,dtl.UNIT_PRICE) UNIT_PRICE,
            decode(hdr.CURRENCY,'HKD',dtl.TOTAL_AMT/%s,'RMB',dtl.TOTAL_AMT/%s,dtl.TOTAL_AMT) TOTAL_AMT, hdr.OTHER_REF
            from T_SALES_CONTRACT_DTL dtl
            inner join T_SALES_CONTRACT_HDR hdr
            on dtl.COMPANY_CODE=hdr.COMPANY_CODE and dtl.SALES_CONTRACT_NO=hdr.SALES_CONTRACT_NO
            left join T_DN_DTL dn_dtl on
            dtl.COMPANY_CODE=dn_dtl.COMPANY_CODE and dtl.LINE_NO=dn_dtl.SC_LINE_NO and dtl.ITEM_NO=dn_dtl.ITEM_NO and dtl.SALES_CONTRACT_NO=dn_dtl.SC_NO
            left join T_DN_HDR dn_hdr
            on dn_dtl.COMPANY_CODE=dn_hdr.COMPANY_CODE and dn_dtl.DN_NO=dn_hdr.DN_NO
            %s %s
            ''' % (USD2HKD, USD2RMB, USD2HKD, USD2RMB, whereCondition, orderByCaulse)

        templatePath = os.path.join(os.path.abspath(os.path.curdir),"report_download/TEMPLATE/DISNEY_LICENSEE_TEMPLATE.xls")
        
        
        data = []
        #execute the sql ,return the resultset
        try:
            db_connection = createConnection()
            cursor = db_connection.cursor()
            cursor.execute(str(sql))
            resultSet = cursor.fetchall()
            data = resultSet
            """
            def decodeCol(col):
                if not col:
                    return ""
                if type(col) == datetime:
                    return col.strftime("%Y-%m-%d")
                return str(col).decode("utf8")
            
            for row in resultSet:
                data.append( tuple([decodeCol(col)[:900] for col in row]) )"""

        except:
            traceback.print_exc()
            flash("Error occur on the server side.")
            raise redirect("/disney/report")
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
            ke = DisneyReportExcel(templatePath = templatePath,destinationPath = filename)
            ke.inputData(xlsCountry, xlsDate, data=data)
            ke.outputData()
            return serveFile(filename, "application/x-download", "attachment")
        except:
            traceback.print_exc()
            flash("Error occur whening generating the excel!")
            raise redirect("/disney/report")
        finally:
            pass
            

