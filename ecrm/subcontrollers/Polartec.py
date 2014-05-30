# -*- coding: utf-8 -*-
import turbogears, math, datetime, logging, os, random, traceback, zipfile, shutil, re
from turbogears import controllers, expose, flash, redirect, paginate, identity, widgets
from cherrypy.lib.cptools import serveFile
from ecrm.util.excel_helper import *
from ecrm.util.common import *
from ecrm.util.oracle_helper import *


class PolartecController(controllers.Controller, identity.SecureResource):

    require=identity.in_any_group("POLARTEC", "Admin")

    @expose(template="ecrm.templates.polartec.report")
    @tabFocus(tab_type="report")
    def report(self, **kw):
        return {}

    @expose()
    def export(self, type):
        def intValue(v):
            try:
                return int(v)
            except:
                return 0

        def populate(row):
            unit_price=POLERTEC_PRICES[row[2]] if row[2] in POLERTEC_PRICES.keys() else None
            inventory_value=round((intValue(row[5])-intValue(row[6])+intValue(row[8]))/1000*unit_price) if unit_price else None

            return (
                   self._decodeCol(row[0]), #PO
                   self._decodeCol(row[1]), #CUSTOMER PO
                   self._decodeCol(row[2]), #ITEM_NO
                   self._decodeCol(row[3]), #UNIT
                   self._decodeCol(row[4]), #QTY ORDERED
                   self._decodeCol(row[5]), #QTY RECV
                   self._decodeCol(row[6]), #QTY SHIPPED
                   "=RC[-3]-RC[-2]",
                   "=RC[-3]-RC[-2]+RC[3]",
                   intValue(row[7])-intValue(row[6]), #QTY REQUEST
                   "=RC[-2]-RC[-1]",
                   intValue(row[8]), #STOCK ADJUSTMENT
                   unit_price,
                   inventory_value,
                   )


        try:
            db_connection=createConnection()
            cursor=db_connection.cursor()

            def fetchNOUSData(rawRs):
                poData=[]
                soData=[]
                dnData=[]
                wovData=[]

                db_connection=createConnection()
                cursor=db_connection.cursor()

                for row in rawRs:
                    poData.append(self._decodeCol(row[2]))

                cursor.execute(str(self._posearchSQL(poData)))

                poRs=cursor.fetchall()
                for row in poRs:
                    soData.append(self._decodeCol(row[0]))

                cursor.execute(str(self._sosearchSQL(soData)))

                dnRs=cursor.fetchall()
                for row in dnRs:
                    dnData.append(self._decodeCol(row[0]))

                cursor.execute(str(self._dnsearchSQL(dnData)))

                extraRs=cursor.fetchall()
                for init_row in rawRs:
                    for extra_row in extraRs:
                        init_row=list(init_row)
                        if extra_row[0]==init_row[2] and init_row[6] is not None and extra_row[1] is not None:
                            init_row[6]=int(init_row[6])-int(extra_row[1])
                    wovData.append(populate(init_row))
                cursor.close()
                db_connection.close()

                return wovData

            wovData=[]
            hatData=[]
            hetData=[]

            if type=='US':
                cursor.execute(str(self._createSQL(type, "WOV")))

                wovRs=cursor.fetchall()
                for row in wovRs:
                    wovData.append(populate(row))

                cursor.execute(str(self._createSQL(type, "HAT")))

                hatRs=cursor.fetchall()
                for row in hatRs:
                    hatData.append(populate(row))
            elif type=='NOUS':
                cursor.execute(str(self._createSQL(type, "WOV")))
                wovData=fetchNOUSData(cursor.fetchall())

                cursor.execute(str(self._createSQL(type, "HAT")))
                hatData=fetchNOUSData(cursor.fetchall())

                cursor.execute(str(self._createSQL(type, "HET")))
                hetData=fetchNOUSData(cursor.fetchall())
        except:
            traceback.print_exc()
            flash("Error occur on the server side.")
            raise redirect("/polartec/report")
        finally:
            cursor.close()

        #write the resultset to the excel
        try:
            templatePath=os.path.join(os.path.abspath(os.path.curdir), "report_download/TEMPLATE/POLARTEC_TEMPLATE.xls")
            dateStr=datetime.today().strftime("%Y%m%d")
            fileDir=os.path.join(os.path.abspath(os.path.curdir), "report_download/kohls_report", "%s"%dateStr)
            if not os.path.exists(fileDir):
                os.makedirs(fileDir)
            timeStr=datetime.now().time().strftime("%H%M%S")
            filename=os.path.join(fileDir, "%s%s.xls"%(dateStr, timeStr))
            ke=PolartecExcel(templatePath=templatePath, destinationPath=filename)
            ke.inputData(wovData=wovData, hatData=hatData, hetData=hetData, type=type)
            ke.outputData()
            return serveFile(filename, "application/x-download", "attachment")
        except:
            traceback.print_exc()
            flash("Error occur whening generating the excel!")
            raise redirect("/polartec/report")


    def _decodeCol(self, col):
        if not col:
            return ""
        if type(col)==datetime:
            return col.strftime("%Y-%m-%d")
        return str(col).decode("utf8")

    def _createSQL(self, type, tag):
        if type=='US':
            sql='''
            SELECT  FN_SUMPO(COALESCE(T1.ITEM_NO,T3.ITEM_NO),'/'),FN_SUMCUSTPO_US(COALESCE(T1.ITEM_NO,T3.ITEM_NO)), 
            COALESCE(T1.ITEM_NO,T3.ITEM_NO) AS ITEM_NO,COALESCE(T1.UNIT,T3.UNIT) AS UNIT,T3.QTY_ORDERED,T3.RECV_QTY,T2.SHIPED_QTY,T1.QTY_REQUEST,
            nvl(T4.ADJ_Qty, 0)

            FROM
        
            (select d.ITEM_NO AS ITEM_NO,sum(d.QTY) AS QTY_REQUEST,ih.UNIT_MEAS as UNIT
            from T_SALES_CONTRACT_HDR h, T_SALES_CONTRACT_DTL d ,T_ITEM_HDR ih
            where 
            h.COMPANY_CODE='RPACUS' and h.SALES_CONTRACT_NO = d.SALES_CONTRACT_NO
            and h.STATUS !='D' and d.PROGRAM = 'POLARTEC' and d.SUB_CAT1='%s'
            and ih.COMPANY_CODE = h.COMPANY_CODE and ih.ITEM_CODE = d.ITEM_NO
            and ih.PROGRAM = d.PROGRAM
            group by d.ITEM_NO,ih.UNIT_MEAS ORDER BY d.ITEM_NO ) T1
        
            LEFT JOIN
        
            (SELECT dnd.ITEM_NO AS ITEM_NO,sum(dnd.TOTAL_QTY) as SHIPED_QTY
            FROM T_DN_DTL dnd
            WHERE dnd.COMPANY_CODE = 'RPACUS' 
            GROUP BY dnd.ITEM_NO ) T2
        
            ON T1.ITEM_NO=T2.ITEM_NO
    
            FULL OUTER JOIN
        
            (SELECT pd.STOCK_ITEM_NO AS ITEM_NO,ih.UNIT_MEAS AS UNIT, SUM(pd.QTY) as QTY_ORDERED, SUM(pd.TOTAL_RECV_QTY) AS RECV_QTY
            FROM T_PURCHASE_ORDER_HDR ph, T_PURCHASE_ORDER_DTL pd, T_ITEM_HDR ih
            WHERE ph.COMPANY_CODE='RPACUS' and ph.PURCHASE_ORDER_NO = pd.PURCHASE_ORDER_NO
            and ph.STATUS!='D' and pd.PROGRAM='POLARTEC' and pd.SUB_CAT1='%s'
            and ih.COMPANY_CODE = ph.COMPANY_CODE and ih.ITEM_CODE = pd.STOCK_ITEM_NO
            and ih.PROGRAM = pd.PROGRAM
            GROUP BY pd.STOCK_ITEM_NO,ih.UNIT_MEAS
            order by pd.STOCK_ITEM_NO) T3
        
            ON T1.ITEM_NO=T3.ITEM_NO
        
        LEFT JOIN
            (select tih.ITEM_code AS ITEM_NO, sum(decode(adj.TYP,'A',ADJ.ADJUSTMENT_QTY,ADJ.ADJUSTMENT_QTY*(-1))) ADJ_Qty
               from t_item_hdr tih,
                    T_STOCK_ADJUSTMENT_DTL ADJ
              where tih.PROGRAM = 'POLARTEC'
                and tih.SUB_CAT1='%s'
    and tih.COMPANY_CODE=adj.COMPANY_CODE
                AND tih.ITEM_code = ADJ.ITEM_NO
                and adj.company_code = 'RPACUS'
    group by tih.ITEM_code
              ORDER BY tih.ITEM_code) t4
        on t1.item_no = t4.item_no
            '''
        else:
            sql='''
            SELECT FN_SUMPO(COALESCE(T1.ITEM_NO,T3.ITEM_NO),'/'),
       FN_SUMCUSTPO(COALESCE(T1.ITEM_NO,T3.ITEM_NO)),
       COALESCE(T1.ITEM_NO,T3.ITEM_NO) AS ITEM_NO,
       COALESCE(T1.UNIT,T3.UNIT) AS UNIT,
       T3.QTY_ORDERED,
       T3.RECV_QTY,
       T2.SHIPED_QTY,
       T1.QTY_REQUEST,
       nvl(T4.ADJ_Qty, 0)
  FROM (select d.ITEM_NO AS ITEM_NO,
               sum(d.QTY) AS QTY_REQUEST,
               ih.UNIT_MEAS as UNIT
          from T_SALES_CONTRACT_HDR h,
               T_SALES_CONTRACT_DTL d,
               T_ITEM_HDR ih,
               T_GRN_DTL GRN,
               T_PURCHASE_ORDER_HDR ph,
               T_PURCHASE_ORDER_DTL pd
         where h.COMPANY_CODE='RPACUS'
           and h.SALES_CONTRACT_NO = d.SALES_CONTRACT_NO
           and h.STATUS !='D'
           and d.PROGRAM = 'POLARTEC'
           and d.SUB_CAT1='%s'
           and ih.COMPANY_CODE = h.COMPANY_CODE
           and ih.ITEM_CODE = d.ITEM_NO
           and ih.PROGRAM = d.PROGRAM
           and d.SALES_CONTRACT_NO = grn.SALES_CONTRACT_NO
           AND GRN.PURCHASE_ORDER_NO = PH.PURCHASE_ORDER_NO
           AND ph.COMPANY_CODE = 'RPACUS'
           and ph.PURCHASE_ORDER_NO = pd.PURCHASE_ORDER_NO
           and ph.STATUS!='D'
           and pd.PROGRAM='POLARTEC'
           and ph.CUST_PO_NO != 'US'
         group by d.ITEM_NO,ih.UNIT_MEAS
         ORDER BY d.ITEM_NO ) T1
LEFT JOIN
       (select sum(a.total_qty) as SHIPED_QTY, a.ITEM_NO AS ITEM_NO from (
SELECT distinct dnd.ITEM_NO AS ITEM_NO,
               dnd.TOTAL_QTY,
      tsr.DOCUMENT_NO
          FROM T_DN_DTL dnd,
               T_DN_HDR DN,
               T_GRN_DTL GRN,
               T_PURCHASE_ORDER_HDR ph,
               T_PURCHASE_ORDER_DTL pd,
           (select distinct tsr1.LOT_NO,tsr1.DOCUMENT_NO from t_stock_reserve tsr1 
        where tsr1.COMPANY_CODE='RPACUS' and tsr1.ITEM_NO='PASTEC-10' ) tsr
         WHERE dnd.COMPANY_CODE = 'RPACUS'
           AND dnd.COMPANY_CODE = dn.COMPANY_CODE
           AND dnd.DN_NO = dn.DN_NO
           AND dn.STATUS = 'F'
         AND dnd.SC_NO = tsr.DOCUMENT_NO
         AND tsr.LOT_NO = grn.GRN_NO
           AND GRN.PURCHASE_ORDER_NO = PH.PURCHASE_ORDER_NO
           AND ph.COMPANY_CODE = 'RPACUS'
           AND ph.PURCHASE_ORDER_NO = pd.PURCHASE_ORDER_NO
           AND ph.STATUS!='D'
           AND pd.PROGRAM='POLARTEC'
           AND ph.CUST_PO_NO != 'US' ) a      
   GROUP BY a.ITEM_NO) T2
    ON T1.ITEM_NO=T2.ITEM_NO
FULL OUTER JOIN
       (SELECT pd.STOCK_ITEM_NO AS ITEM_NO,
               ih.UNIT_MEAS AS UNIT,
               SUM(pd.QTY) as QTY_ORDERED,
               SUM(pd.TOTAL_RECV_QTY) AS RECV_QTY
          FROM T_PURCHASE_ORDER_HDR ph,
               T_PURCHASE_ORDER_DTL pd,
               T_ITEM_HDR ih
         WHERE ph.COMPANY_CODE = 'RPACUS'
           and ph.PURCHASE_ORDER_NO = pd.PURCHASE_ORDER_NO
           and ph.STATUS!='D'
           and pd.PROGRAM='POLARTEC'
           and pd.SUB_CAT1='%s'
           and ih.COMPANY_CODE = ph.COMPANY_CODE
           and ih.ITEM_CODE = pd.STOCK_ITEM_NO
           and ih.PROGRAM = pd.PROGRAM
           and ph.CUST_PO_NO != 'US'
         GROUP BY pd.STOCK_ITEM_NO,
                  ih.UNIT_MEAS
         order by pd.STOCK_ITEM_NO) T3
    ON T1.ITEM_NO = T3.ITEM_NO
LEFT JOIN
       (select tih.ITEM_code AS ITEM_NO,
               sum(decode(adj.TYP,'A',ADJ.ADJUSTMENT_QTY,ADJ.ADJUSTMENT_QTY*(-1))) ADJ_Qty
          from t_item_hdr tih,
               T_STOCK_ADJUSTMENT_DTL ADJ
         where tih.PROGRAM = 'POLARTEC'
           and tih.SUB_CAT1 = '%s'
           and tih.COMPANY_CODE = adj.COMPANY_CODE
           AND tih.ITEM_code = ADJ.ITEM_NO
           and adj.company_code = 'RPACUS'
         group by tih.ITEM_code
         ORDER BY tih.ITEM_code) t4
    on t1.item_no = t4.item_no
            '''

        return sql%((tag,)*3)

    def _posearchSQL(self, poData):
        sql='''
            select po_hdr.purchase_order_no
              from T_PURCHASE_ORDER_HDR po_hdr,
                   T_PURCHASE_ORDER_DTL po_dtl
             where po_hdr.PURCHASE_ORDER_NO = po_dtl.PURCHASE_ORDER_NO
               and po_dtl.STOCK_ITEM_NO in (%s)
               and (po_hdr.CUST_PO_NO = 'US' OR PO_HDR.CUST_PO_NO IS NULL)
               and po_hdr.COMPANY_CODE = 'RPACUS'
            '''%','.join(["'"+str(item)+"'" for item in poData])

        return sql

    def _sosearchSQL(self, soData):
        sql='''
            select stock.DOCUMENT_NO
              from t_grn_dtl grn,
                   t_stock_reserve stock
             where grn.PURCHASE_ORDER_NO in (%s)
               and grn.LOT_NO = stock.LOT_NO
            '''%','.join(["'"+str(item)+"'" for item in soData])

        return sql

    def _dnsearchSQL(self, dnData):
        sql='''
            select dn.ITEM_NO,
                   dn.TOTAL_QTY
              from t_dn_dtl dn
             where dn.SC_NO in (%s)
            '''%','.join(["'"+str(item)+"'" for item in dnData])

        return sql



