# -*- coding: utf-8 -*-
xlsPath = r"d:\data1.xls";

countries = {
                'HKM':'01',
                'CHN':'02',
                'TWN':'03',
                'SIN':'04',
                'MYS':'05',
                'EXP':'99',
            }


def uniStr(nullOrStr):
    if not nullOrStr : return ""
    if type(nullOrStr) == float : return unicode(int(nullOrStr))
    return unicode(nullOrStr).strip()
    
def formatLC(nullOrStr):
    if not nullOrStr or type(nullOrStr) not in [str,unicode] : return ""
    return "".join([c for c in nullOrStr if c.isdigit()])
    
if __name__ == "__main__":
    import turbogears,os,re
    import win32com.client
    from sqlobject import *
    from ecrm.util.common import *
    from sqlobject.sqlbuilder import *
    
    LIKE.op = "ILIKE"
    turbogears.update_config(configfile="dev.cfg",modulename="ecrm.config")
    from ecrm import model
    from ecrm.model import *
    print "=======================start to read the ecxel============================="
    pythoncom.CoInitialize()
    xls = win32com.client.Dispatch("Excel.Application")
    xls.Visible = 0
    wb = xls.Workbooks.open(xlsPath)
    sheet = wb.Sheets[0]

    beginRow = 2
    endRow =80
   
    data = []
    for row in range(beginRow,endRow+1):
        data.append( {
                "legacyCode": uniStr( formatLC(sheet.Cells(row,3).Value) ),
                "mainLabel" : uniStr(sheet.Cells(row,4).Value),
                "sizeLabel" : uniStr(sheet.Cells(row,5).Value),
                "hangTag" : uniStr(sheet.Cells(row,6).Value),
                "waistCard" : uniStr(sheet.Cells(row,7).Value),
                "inseamx" : uniStr(sheet.Cells(row,8).Value),
                "inseamy" : uniStr(sheet.Cells(row,9).Value),
                "cat":uniStr(sheet.Cells(row,10).Value)
                })
    wb.Close(SaveChanges = 0)
    del wb,xls

    print "===========read the end of the excel========================="

    errors = []
    nomatch = []
    for (index,rd) in enumerate(data):
        try:
            rd["isHangTagForAllMarket"] = 1 if len(rd["hangTag"]) > 10 else 0
            rd["isWaistCardForAllMarket"] = 1 if len(rd["waistCard"]) > 10 else 0
            BossiniLegacyInfo(**rd)
            
        except Exception,e:
            errors.append( "=========%d  error!=================" %(beginRow + index) )
            errors.append( str(e) )
        else:
            print "============NO.%d record insert==============" %(beginRow + index)

    if len(errors) > 0:
        f = open("errors.txt","w")
        f.write("\n".join(errors))
        f.flush()
        f.close()
        print "==========error in erros.txt============="
    else:
        model.hub.commit()
        print "################## Not match rows   #######################"
        for l in nomatch:
            print l 
            
    print "==============finished======================="
