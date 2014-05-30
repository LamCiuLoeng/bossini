from turbogears.scheduler import add_weekday_task
from turbogears import config
import traceback,os,zlib,zipfile,random,shutil

from datetime import datetime as dt

from ecrm.util.common import *
from reporter import *

def main():   
    #clean the files
    houseKeeping()
    #1.gen the files
    try:
        (flag,allVendorFile,detailVendorFiles) = begin2Gen()
    except:
        s= traceback.format_exc()
        traceback.print_exc()
        #send email and stop the next step
        sendErrorEmail(s)
        return
    
    # There's not update today,return 
    if not flag : return 
    
    #2.backup the folders files
    try:
        backup()
    except Exception ,e:
        traceback.print_exc()
        s= traceback.format_exc()
        #send email and stop the next step
        sendErrorEmail(s)
    else:
        try:
            #3.Overwrite the files
            overwrite()
        except Exception ,e:
            traceback.print_exc()
            #send email alert
            s= traceback.format_exc()
            sendErrorEmail(s)
    print "-------- exist main------------"
            
            
def sendErrorEmail(content):
    send_from = "Bossini_Backup_Robot"
    send_to =  config.get("Bossini_backup_error_sendto").split(";")
    subject = "Error when doing the report udpate.(%s)" % dt.now().strftime("%Y-%m-%d %H:%M:%s")
    send_mail(send_from,send_to,subject,content)

def backup():
    sourcePath = config.get("Bossini_reports_dir")
    backupDir = config.get("Bossini_reports_backup_dir","d:/backup")
    if not os.path.exists(backupDir) : os.makedirs(backupDir)
    zipFileName = "Bossini-backup-%s-%d.zip" %( dt.now().strftime("%Y%m%d%H%M%S"),random.randint(1,100))   
    zipFile = zipfile.ZipFile(os.path.join( backupDir, zipFileName),"w",zlib.DEFLATED)
           
    sourceTop = os.path.abspath(sourcePath)
       
    for (dirpath, dirnames, filenames) in os.walk(sourcePath):
        for fn in filenames:
            if fn.endswith("xls"): 
                f = os.path.join( os.path.abspath(dirpath),fn )
                cf = f[len(sourceTop)+1:]                 
                zipFile.write( f,cf )
    zipFile.close()

def overwrite():
    print "---------- begin to overwrite ---------------"
    source = config.get("Bossini_workfolder","d:/temp2")
    dest = config.get("Bossini_reports_dir")    
    for (dirpath, dirnames, filenames) in os.walk(source):
        for fn in filenames:
            f = os.path.join( dirpath,fn )
            df = os.path.join( dest,f[len(source)+1:] )
            ddir = os.path.join( dest,dirpath[len(source)+1:] )
            if not os.path.exists(ddir) : os.makedirs(ddir)
            shutil.copy(f, df)
            
def houseKeeping():
    #remove all the detail file and folder
    source = config.get("Bossini_workfolder","d:/temp2")
    for (dirpath, dirnames, filenames) in os.walk(source):
        for fn in filenames:
            f = os.path.join( dirpath,fn )
            if fn.endswith(".xls") and fn!="All_vendor.xls" :os.remove(f)  

def schedule():
    (h,m) = config.get("Bossini_backuptime","4:30").split(":")
    add_weekday_task(action=main,weekdays=range(1,8), timeonday=((int(h),int(m))))
    
    
if __name__ == "__main__":
    backup("d:/temp")
    pass