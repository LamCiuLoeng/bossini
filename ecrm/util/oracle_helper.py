import cx_Oracle, os, traceback, turbogears
os.environ["NLS_LANG"]="american_america.al32utf8"

#Create the Oracle connection 
def createConnection():
        connstr=turbogears.config.get("oracle_connection_str")
        return cx_Oracle.connect(connstr)

def executeSearchSQL(dbconnection, sql, params, all=True, wrap=False):
    cursor=dbconnection.cursor()
    cursor.prepare(sql)
    cursor.execute(None, params)
    if all:
        if wrap:
            return [dtoWrap(cursor, row) for row in cursor.fetchall()]
        else:
            return cursor.fetchall()
    else:
        if wrap:
            return dtoWrap(cursor, cursor.fetchone())
        else:
            return cursor.fetchone()


def searchOracle(sql, params, all=True, wrap=False):
    dbconn=createConnection()
    try:
        return executeSearchSQL(dbconn, sql, params, all, wrap)
    except:
        traceback.print_exc()
        return None
    finally:
        dbconn.close()

class oracleDTO(dict):
    """A dictionary that provides attribute-style access."""

    def __getitem__(self, key):
        return  dict.__getitem__(self, key)

    def __getattr__(self, name):
        return self[name]

    __setattr__=dict.__setitem__

    def __delattr__(self, name):
        try:
            del self[name]
        except KeyError:
            raise AttributeError(name)


def dtoWrap(cursor, row):
    dto=oracleDTO()
    for index, item in enumerate(cursor.description):
        dto[item[0]]=row[index]
    return dto



def createKOHLSSQL(kw):
        USD2HKD=turbogears.config.get("USD2HKD")
        USD2RMB=turbogears.config.get("USD2RMB")


        #quarterly report
        if kw["report_type"]=="q":
            u1_where1a=["ihdr.COMPANY_CODE = '%s'"%kw["ln_company_code"], "ihdr.COMPANY_CODE = idtl.COMPANY_CODE",
                         #"SUBSTR(ihdr.INVOICE_NO,1,2)='SC'",
                         "ihdr.INVOICE_NO = idtl.INVOICE_NO", ]
            u1_where1b=["tdtl.COMPANY_CODE = '%s'"%kw["ln_company_code"],
                        #"SUBSTR(tdtl.SC_NO,1,3)='SOC'",
                          "thdr.COMPANY_CODE = tdtl.COMPANY_CODE", "thdr.NOTE_NO = tdtl.NOTE_NO", "thdr.note_type = 'C'"]

            if kw.get("in_issue_date_fr", None):
                u1_where1a.append("ihdr.INVOICE_DATE >= TO_DATE('%s','YYYY-MM-DD')"%kw["in_issue_date_fr"])
                u1_where1b.append("tdtl.CREATE_DATE >= TO_DATE('%s','YYYY-MM-DD')"%kw["in_issue_date_fr"])
            if kw.get("in_issue_date_to", None):
                u1_where1a.append("ihdr.INVOICE_DATE <= TO_DATE('%s','YYYY-MM-DD')"%kw["in_issue_date_to"])
                u1_where1b.append("tdtl.CREATE_DATE <= TO_DATE('%s','YYYY-MM-DD')"%kw["in_issue_date_to"])

            u1_where2=["hdr.company_code = '%s'"%kw["ln_company_code"], ]
            if kw.get("in_so_no_fr", None):
                u1_where2.append("hdr.sales_contract_no >= '%s'"%kw["in_so_no_fr"])
            if kw.get("in_so_no_to", None):
                u1_where2.append("hdr.sales_contract_no <= '%s'"%kw["in_so_no_to"])
            if kw.get("in_supl_code", None):
                u1_where2.append("hdr.customer_code like '%%%s%%'"%kw["in_supl_code"].upper())
            if kw.get("in_supl_name", None):
                u1_where2.append("hdr.customer_name like '%%%s%%'"%kw["in_supl_name"].upper())
            if kw.get("in_item_code", None):
                u1_where2.append("dtl.item_no = '%s'"%kw["in_item_code"].upper())
            if kw.get("in_item_cat", None):
                u1_where2.append("dtl.item_cat = '%s'"%kw["in_item_cat"])
            if kw.get("in_sub_cat1", None):
                u1_where2.append("dtl.sub_cat1 = '%s'"%kw["in_sub_cat1"])

#            case
#                when SUBSTR(dtl.item_no,LENGTH(dtl.item_no)-1,2)='MD' then 'MUDD'
#                when SUBSTR(dtl.item_no,LENGTH(dtl.item_no)-1,2)='A9' then 'APT NO.9'
#                else null
#                end as brand
#            dtl.item_no as brand,
#               AND SUBSTR(hdr.sales_contract_no,1,3)='SOC'
#            case
#                when dtl.QTY=dnp.qty and hdr.currency='USD' then si_dtl.invoice_item_amt
#                when dtl.QTY=dnp.qty and hdr.currency='HKD' then ROUND(si_dtl.invoice_item_amt *hdr.EXCHANGE_RATE/%s,2)
#                when dtl.QTY=dnp.qty and hdr.currency='RMB' then ROUND(si_dtl.invoice_item_amt *hdr.EXCHANGE_RATE/%s,2)
#                when dnp.dn_no=min(dnp.dn_no) over(partition by hdr.SALES_CONTRACT_NO,dtl.LINE_NO) and hdr.currency='USD' then si_dtl.invoice_item_amt
#                when dnp.dn_no=min(dnp.dn_no) over(partition by hdr.SALES_CONTRACT_NO,dtl.LINE_NO) and hdr.currency='HKD' then ROUND(si_dtl.invoice_item_amt *hdr.EXCHANGE_RATE/%s,2)
#                when dnp.dn_no=min(dnp.dn_no) over(partition by hdr.SALES_CONTRACT_NO,dtl.LINE_NO) and hdr.currency='RMB' then ROUND(si_dtl.invoice_item_amt *hdr.EXCHANGE_RATE/%s,2)
#                when dnp.dn_no IS NULL and hdr.currency='USD' then si_dtl.invoice_item_amt
#                when dnp.dn_no IS NULL and hdr.currency='HKD' then ROUND(si_dtl.invoice_item_amt *hdr.EXCHANGE_RATE/%s,2)
#                when dnp.dn_no IS NULL and hdr.currency='RMB' then ROUND(si_dtl.invoice_item_amt *hdr.EXCHANGE_RATE/%s,2)
#                end as subtitute_amt
            union_p1='''
                SELECT  hdr.sales_contract_no,hdr.issue_date,hdr.customer_name,
                (select city_desc from t_city b where b.company_code = 'N/A' and b.city_code = hdr.bill_city and b.country_code = hdr.bill_country) as bill2city,
                (select ref_desc from t_code_dtl b where b.company_code = 'N/A' and b.ref_code = hdr.bill_country) as bill2country,
                (select city_desc from t_city b where b.company_code = 'N/A' and b.city_code = hdr.ship_city and b.country_code = hdr.ship_country) as ship2city,
                (select ref_desc from t_code_dtl b where b.company_code = 'N/A' and b.ref_code = hdr.ship_country) as ship2coutry,
                '"'||replace(item.PROD_FEATURE, '"', '')||'"' as kohls_code,dtl.item_no,
                dtl.brand as brand,
                '"'||replace(dtl.description, '"', '')||'"' as description,
                
                case
                when dtl.QTY=dnp.qty then dtl.qty
                when dnp.dn_no=min(dnp.dn_no) over(partition by hdr.SALES_CONTRACT_NO,dtl.LINE_NO) then
                dtl.qty
                when dnp.dn_no IS NULL then dtl.qty
                else null
                end as subtitute_qty,
                
                dtl.unit,dnhdr.issue_date as dn_shipped_date,dnp.qty as dn_shipped_qty,
                
                hdr.currency,
                si_dtl.invoice_item_amt as dtl_amt,
                exchange.ccy_rate,
                si_dtl.invoice_item_amt * exchange.ccy_rate,
                '"'||replace(item.PROD_SPEC, '"', '')||'"' as kohls_category, hdr.OTHER_REF as kohls_season,
                item.PACK_REMARK as kohls_style,
                (select ITEM_CAT_DESC from t_item_cat_master b where b.company_code = 'N/A' and b.item_cat_code = dtl.item_cat) as packaging_category,
                (select sub_CAT1_DESC from t_sub_cat1_master b where b.company_code = 'N/A' and b.item_cat_code = dtl.item_cat and b.sub_cat1_code = dtl.sub_cat1) packaging_type
                 ,hdr.remarks
                
                from t_sales_contract_hdr hdr,t_sales_contract_dtl dtl,t_item_hdr item,t_sales_contract_packset ps,t_dn_product dnp,t_dn_hdr dnhdr,
               (select t0.*
                from 
                t_ccy_exchange t0,
                (
                select t1.COMPANY_CODE,t1.CCY_CODE_FR,t1.CCY_CODE_TO, max(t1.EFFECTIVE_DATE) as EFFECTIVE_DATE
                from t_ccy_exchange t1
                group by t1.COMPANY_CODE,t1.CCY_CODE_FR,t1.CCY_CODE_TO
                ) t2
                where t0.CCY_CODE_FR = t2.CCY_CODE_FR and t0.CCY_CODE_TO = t2.CCY_CODE_TO and t0.EFFECTIVE_DATE = t2.EFFECTIVE_DATE and t0.COMPANY_CODE = t2.COMPANY_CODE 
                ) exchange,

                t_company company,
                (SELECT sr.COMPANY_CODE,sr.SC_NO,sr.SC_ITEM_LINE_NO,SUM(sr.ITEM_TOTAL) as invoice_item_amt
                FROM (
                select ihdr.COMPANY_CODE,ihdr.SC_NO,idtl.SC_ITEM_LINE_NO,idtl.ITEM_TOTAL
                from t_invoice_hdr ihdr , t_invoice_dtl idtl
                WHERE  %s
                union all
                select tdtl.COMPANY_CODE,tdtl.SC_NO,tdtl.SC_ITEM_LINE_NO,tdtl.ITEM_TOTAL*-1
                from t_cust_note_dtl tdtl,t_cust_note_hdr thdr 
                where %s ) sr
                GROUP BY sr.COMPANY_CODE,sr.SC_NO,sr.SC_ITEM_LINE_NO ) si_dtl
                
                
                WHERE 
                %s 
                 
                AND hdr.company_code = dtl.company_code
                AND hdr.sales_contract_no = dtl.sales_contract_no
                AND dtl.PROGRAM = 'KOHLS'  
                AND dtl.company_code = si_dtl.company_code 
                AND dtl.sales_contract_no = si_dtl.sc_no 
                AND dtl.line_no = si_dtl.SC_ITEM_LINE_NO 
                AND item.company_code = dtl.company_code
                AND item.item_code = dtl.item_no
                AND ps.company_code = dtl.company_code
                AND ps.sales_contract_no = dtl.sales_contract_no
                AND ps.item_line_no = dtl.line_no
                AND dnp.company_code (+) = ps.company_code
                AND dnp.sc_no (+) = ps.sales_contract_no
                AND dnp.sc_line_no (+) = ps.line_no
                AND dnhdr.company_code (+) = dnp.company_code
                AND dnhdr.dn_no (+) = dnp.dn_no
                AND dnhdr.status (+) = 'F'
                AND company.company_code = '%s'
                AND exchange.ccy_code_fr = hdr.currency
                AND exchange.ccy_code_to = company.base_ccy
                AND exchange.company_code = '%s'

                
            '''%(" AND ".join(u1_where1a), " AND ".join(u1_where1b), " AND ".join(u1_where2), kw['ln_company_code'], kw['ln_company_code'],)
#            %(USD2HKD, USD2RMB, USD2HKD, USD2RMB, USD2HKD, USD2RMB, " AND ".join(u1_where1a), " AND ".join(u1_where1b), " AND ".join(u1_where2))


            u2_where=["ihdr2.COMPANY_CODE = '%s'"%kw["ln_company_code"], "ihdr2.SC_NO =  hdr2.sales_contract_no",
                      #"SUBSTR(ihdr2.SC_NO,1,3)='SOC'"
                      ]
            if kw.get("in_issue_date_fr", None):
                u2_where.append("ihdr2.INVOICE_DATE >= TO_DATE('%s','YYYY-MM-DD')"%kw["in_issue_date_fr"])
            if kw.get("in_issue_date_to", None):
                u2_where.append("ihdr2.INVOICE_DATE <= TO_DATE('%s','YYYY-MM-DD')"%kw["in_issue_date_to"])
            if kw.get("in_so_no_fr", None):
                u2_where.append("hdr2.sales_contract_no >= '%s'"%kw["in_so_no_fr"])
            if kw.get("in_so_no_to", None):
                u2_where.append("hdr2.sales_contract_no <= '%s'"%kw["in_so_no_to"])
            if kw.get("in_supl_code", None):
                u2_where.append("hdr2.customer_code like '%%%s%%'"%kw["in_supl_code"].upper())
            if kw.get("in_supl_name", None):
                u2_where.append("hdr2.customer_name like '%%%s%%'"%kw["in_supl_name"].upper())


            u2_where.append("ihdr2.SC_NO = filter_so.SALES_CONTRACT_NO")
            u2_where.append("ihdr2.INVOICE_NO = ichr.invoice_no")

            union_p2='''
                select hdr2.sales_contract_no,hdr2.issue_date,hdr2.customer_name,
                (select city_desc from t_city b where b.company_code = 'N/A' and b.city_code = hdr2.bill_city and b.country_code = hdr2.bill_country) as bill2city,
                (select ref_desc from t_code_dtl b where b.company_code = 'N/A' and b.ref_code = hdr2.bill_country) as bill2country,
                (select city_desc from t_city b where b.company_code = 'N/A' and b.city_code = hdr2.ship_city and b.country_code = hdr2.ship_country) as ship2city,
                (select ref_desc from t_code_dtl b where b.company_code = 'N/A' and b.ref_code = hdr2.ship_country) as ship2coutry,
                '',ichr.CHARGE_CODE,'','',NULL,NULL,NULL,NULL,
                case
                when ihdr2.CURRENCY='USD' then ichr.TOTAL
                when ihdr2.CURRENCY='HKD' then  ROUND(ichr.TOTAL * ihdr2.EXCHANGE_RATE/%s,2)
                when ihdr2.CURRENCY='RMB' then  ROUND(ichr.TOTAL * ihdr2.EXCHANGE_RATE/%s,2)
                end as charge_amount, ihdr2.CURRENCY || ichr.TOTAL as total_amt, '','','','',''
                from  t_sales_contract_hdr hdr2,t_invoice_hdr ihdr2 , t_invoice_charges ichr ,
                (select DISTINCT dtl2.SALES_CONTRACT_NO from t_sales_contract_dtl dtl2 where dtl2.PROGRAM = 'KOHLS' ) filter_so
                where 
                %s
            '''%(USD2HKD, USD2RMB, " AND ".join(u2_where))


            u3_where=["ihdr3.COMPANY_CODE = '%s'"%kw["ln_company_code"], "ihdr3.SC_NO =  hdr3.sales_contract_no",
                      #"SUBSTR(ihdr3.SC_NO,1,3)='SOC'"
                      ]
            if kw.get("in_issue_date_fr", None):
                u3_where.append("ihdr3.INVOICE_DATE >= TO_DATE('%s','YYYY-MM-DD')"%kw["in_issue_date_fr"])
            if kw.get("in_issue_date_to", None):
                u3_where.append("ihdr3.INVOICE_DATE <= TO_DATE('%s','YYYY-MM-DD')"%kw["in_issue_date_to"])

            if kw.get("in_so_no_fr", None):
                u3_where.append("hdr3.sales_contract_no >= '%s'"%kw["in_so_no_fr"])
            if kw.get("in_so_no_to", None):
                u3_where.append("hdr3.sales_contract_no <= '%s'"%kw["in_so_no_to"])
            if kw.get("in_supl_code", None):
                u3_where.append("hdr3.customer_code like '%%%s%%'"%kw["in_supl_code"].upper())
            if kw.get("in_supl_name", None):
                u3_where.append("hdr3.customer_name like '%%%s%%'"%kw["in_supl_name"].upper())

            u3_where.append("ihdr3.SC_NO = filter_so3.SALES_CONTRACT_NO")
            u3_where.append("ihdr3.INVOICE_NO = tcnh.INVOICE_NO")
            u3_where.append("tcnh.NOTE_NO = tcnc.NOTE_NO")


            union_p3='''
                select hdr3.sales_contract_no,hdr3.issue_date,hdr3.customer_name,
                (select city_desc from t_city b where b.company_code = 'N/A' and b.city_code = hdr3.bill_city and b.country_code = hdr3.bill_country) as bill2city,
                (select ref_desc from t_code_dtl b where b.company_code = 'N/A' and b.ref_code = hdr3.bill_country) as bill2country,
                (select city_desc from t_city b where b.company_code = 'N/A' and b.city_code = hdr3.ship_city and b.country_code = hdr3.ship_country) as ship2city,
                (select ref_desc from t_code_dtl b where b.company_code = 'N/A' and b.ref_code = hdr3.ship_country) as ship2coutry,
                '',tcnc.CHG_DISCOUNT_CODE,'','',NULL,NULL,NULL,NULL,
                case
                when ihdr3.CURRENCY='USD' then tcnc.TOTAL * -1
                when ihdr3.CURRENCY='HKD' then  ROUND(tcnc.TOTAL * ihdr3.EXCHANGE_RATE/%s,2) *-1
                when ihdr3.CURRENCY='RMB' then  ROUND(tcnc.TOTAL * ihdr3.EXCHANGE_RATE/%s,2) *-1
                end as charge_amount,
                ihdr3.CURRENCY || tcnc.TOTAL as total_amount, '','','','',''
                from  t_sales_contract_hdr hdr3,t_invoice_hdr ihdr3 ,t_cust_note_hdr tcnh, t_cust_note_charges tcnc,
                (select DISTINCT dtl3.SALES_CONTRACT_NO from t_sales_contract_dtl dtl3 where dtl3.PROGRAM = 'KOHLS' ) filter_so3
                where
                %s        
            '''%(USD2HKD, USD2RMB, " AND ".join(u3_where))


            if kw["show_charge"]=="no":
                sql='''
                    SELECT TEMP.* FROM (
                    %s
                    ) TEMP ORDER BY TEMP.sales_contract_no
                '''%(union_p1)
            else:
                sql='''
                    SELECT TEMP.* FROM (
                    %s
                    UNION ALL
                    %s
                    UNION ALL
                    %s
                    ) TEMP ORDER BY TEMP.sales_contract_no
                '''%(union_p1, union_p2, union_p3)

            print "_*"*30
            print sql
            print "_*"*30

            return sql

#        case
#                when SUBSTR(dtl.item_no,LENGTH(dtl.item_no)-1,2)='MD' then 'MUDD'
#                when SUBSTR(dtl.item_no,LENGTH(dtl.item_no)-1,2)='A9' then 'APT NO.9'
#                else null
#                end as brand
        #monthly report
        elif kw["report_type"]=="m":
#            dtl.item_no as brand,
            selectFields='''
  
                SELECT hdr.ISSUE_DATE,hdr.customer_name as vender_name, hdr.SALES_CONTRACT_NO,
                dtl.brand as brand,
                hdr.OTHER_REF as kohls_season,
                '"'||replace(item.PROD_SPEC, '"', '')||'"' as Kohls_Category,
                (select city_desc from t_city b where b.company_code = 'N/A' and b.city_code = hdr.ship_city and b.country_code = hdr.ship_country) ship2city,
                (select ref_desc from t_code_dtl b where b.company_code = 'N/A' and b.ref_code = hdr.ship_country) ship2country,
                SUBSTR(hdr.REMARKS,1,instr(hdr.REMARKS,'**')-1) as kohls_style,
                '"'||replace(item.PROD_FEATURE, '"', '')||'"' as kohls_code,
                dtl.ITEM_NO,
                '"'||replace(dtl.description, '"', '')||'"' as description,
                (select sub_CAT1_DESC from t_sub_cat1_master b where b.company_code = 'N/A' and b.item_cat_code = dtl.item_cat and b.sub_cat1_code = dtl.sub_cat1) as packing_type,
                (select sub_CAT2_DESC from t_sub_cat2_master bb where bb.company_code = 'N/A' and bb.item_cat_code = dtl.item_cat and bb.item_cat_code = dtl.item_cat and bb.sub_cat2_code = dtl.sub_cat2) as sub_cat2_desc,
                dtl.QTY,dtl.UNIT,
                (case hdr.currency
                when 'USD' then dtl.TOTAL_AMT
                when 'HKD' then ROUND(dtl.TOTAL_AMT*hdr.EXCHANGE_RATE/%s,2)
                when 'RMB' then ROUND(dtl.TOTAL_AMT*hdr.EXCHANGE_RATE/%s,2)
                end )as total_amt_usd,
                hdr.currency||dtl.TOTAL_AMT as TOTAL_AMT
                ,dtl.line_no,hdr.REMARKS
            '''%(USD2HKD, USD2RMB)

            fromTables=" FROM t_sales_contract_hdr hdr, t_sales_contract_dtl dtl, t_item_hdr item "

            wc=[]
            wc.append("WHERE hdr.company_code = '%s'"%kw["ln_company_code"])
            wc.append("dtl.PROGRAM = 'KOHLS'") # this function is just for KOHLS
#            wc.append("SUBSTR(hdr.sales_contract_no,1,3)='SOC'")
            wc.append("dtl.company_code = hdr.company_code")
            wc.append("dtl.sales_contract_no = hdr.sales_contract_no")
            wc.append("item.company_code = dtl.company_code")
            wc.append("item.item_code = dtl.item_no")

            if kw.get("in_issue_date_fr", None):
                wc.append("hdr.issue_date >= TO_DATE('%s','YYYY-MM-DD')"%kw["in_issue_date_fr"])
            if kw.get("in_issue_date_to", None):
                wc.append("hdr.issue_date <= TO_DATE('%s','YYYY-MM-DD')"%kw["in_issue_date_to"])
            if kw.get("in_so_no_fr", None):
                wc.append("hdr.sales_contract_no >= '%s'"%kw["in_so_no_fr"])
            if kw.get("in_so_no_to", None):
                wc.append("hdr.sales_contract_no <= '%s'"%kw["in_so_no_to"])
            if kw.get("in_supl_code", None):
                wc.append("hdr.customer_code like '%%%s%%'"%kw["in_supl_code"].upper())
            if kw.get("in_supl_name", None):
                wc.append("hdr.customer_name like '%%%s%%'"%kw["in_supl_name"].upper())
            if kw.get("in_item_code", None):
                wc.append("dtl.item_no = '%s'"%kw["in_item_code"].upper())
            if kw.get("in_item_cat", None):
                wc.append("dtl.item_cat = '%s'"%kw["in_item_cat"])
            if kw.get("in_sub_cat1", None):
                wc.append("dtl.sub_cat1 = '%s'"%kw["in_sub_cat1"])

            whereCondition=" AND ".join(wc)
            orderByCaulse=" ORDER BY hdr.sales_contract_no ,dtl.item_no "

            sql1=selectFields+fromTables+whereCondition+orderByCaulse

            sql='''
            SELECT so_group.ISSUE_DATE,so_group.vender_name,so_group.SALES_CONTRACT_NO,so_group.brand,so_group.kohls_season,
            so_group.Kohls_Category,so_group.ship2city,so_group.ship2country,so_group.kohls_style,
            so_group.kohls_code,so_group.ITEM_NO,so_group.description,so_group.packing_type,so_group.sub_cat2_desc,
            so_group.QTY,so_group.UNIT,so_group.total_amt_usd,so_group.TOTAL_AMT,
            dn_group.dn_shipped_date,dn_group.dn_shipped_qty,so_group.REMARKS
            FROM ( %s ) so_group
            LEFT JOIN
            (SELECT dndtl.sc_no,dndtl.sc_line_no,max(dnhdr.issue_date) as dn_shipped_date, sum(dndtl.total_qty) AS dn_shipped_qty
            FROM t_dn_hdr dnhdr, t_dn_dtl dndtl
            WHERE  SUBSTR(dndtl.sc_no,1,3)='SOC' 
            AND dndtl.dn_no=dnhdr.dn_no 
            group by dndtl.sc_no,sc_line_no
            ) dn_group
            ON dn_group.sc_no=so_group.sales_contract_no AND dn_group.sc_line_no=so_group.line_no
            '''%sql1

            print sql
            return sql




if __name__=="__main__":
    dto=oracleDTO()
    dto.aa="aa1"
    print dto['aa']
    print dto.aa
