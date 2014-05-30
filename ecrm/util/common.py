# -*- coding: utf-8 -*-
import sys, os, math
reload(sys)
sys.setdefaultencoding('utf8')

import os, traceback, codecs, pythoncom, smtplib, base64, sha
from itertools import *
from datetime import datetime, date, time
from formencode import validators as formencodeValidators
from formencode.api import Invalid
from win32com.client import Dispatch

from email.MIMEMultipart import MIMEMultipart
from email.MIMEBase import MIMEBase
from email.MIMEText import MIMEText
from email.Utils import COMMASPACE, formatdate
from email import Encoders
from email.header import Header



##################################################################
#  The code below is to solve the problem :
#  after the package "formencode" is upgrade to 1.2.1, the validator "RPACDateConvert"
#  in this module is not work .  
#  Overwrite the validator "All" 's function "is_empty" with its father class's one.
##################################################################
import pkg_resources
formencode_pkg=pkg_resources.parse_requirements("formencode")
formencode_meta=pkg_resources.working_set.find(list(formencode_pkg)[0])
if formencode_meta.version>"1.2":
    from formencode.compound import All
    All.is_empty=All.__bases__[0].is_empty
##################################################################

DB_DATE_FORMAT="%Y/%m/%d"

DB_DATE_TIME_FORMAT="%Y/%m/%d %H:%M:%S"

FONTEND_DATE_FORMAT="%d/%m/%Y"

FONTEND_DATE_TIME_FORMAT="%d/%m/%Y %H:%M:%S"


def Date2Text(value=None, dateTimeFormat=None, defaultNow=False):
    if not value and defaultNow :
        value=datetime.now()

    format=dateTimeFormat and dateTimeFormat or FONTEND_DATE_FORMAT

    result=value
    if isinstance(value, date):
        try:
            result=value.strftime(format)
        except:
            traceback.print_exc()
    elif hasattr(value, "strftime"):
        try:
            result=value.strftime(format)
        except:
            traceback.print_exc()

    if not result:
        result=""
    return result


def Text2Date(value, dateTimeFormat=None, todayIfNone=False):
    if not dateTimeFormat:
        format=FONTEND_DATE_FORMAT
    else:
        format=dateTimeFormat

    result=None
    if isinstance(value, str):
        try:
            result=datetime.strptime(value, dateTimeFormat)
        except:
            pass

    if not result and todayIfNone:
        return datetime.now().today()
    else:
        return result


class RPACDateConvert(formencodeValidators.FancyValidator):
    def from_python(self, value, state):
        if not isinstance(value, date):
            return value
        return value.strftime(DB_DATE_FORMAT)
    def to_python(self, value, state):
        if isinstance(value, date):
            return value
        elif not isinstance(value, str):
            raise Invalid("expected a value string, got %s instead"%(value), value, state)

        return datetime.strptime(value, DB_DATE_FORMAT)

class selectConvert(formencodeValidators.FancyValidator):
    def _to_python(self, value, state):
        if value=="":
            return 0;
        else:
            try:
                return int(value)
            except (ValueError, TypeError):
                raise Invalid("Can't convert to value to be number.")

    _from_python=_to_python


#This method is used in MS Excel to convert the header column from number to alphalbet
def number2alphabet(n):
    result=[]
    while n>=0:
        if n>26:
            result.insert(0, n%26)
            n/=26
        else:
            result.insert(0, n)
            break
    return "".join([chr(r+64) for r in result ]) if result else None


#This method is used in MS Excel to convert the header column form alphalbet to number
def alphabet2number(str):
    if not str or not isinstance(str, basestring) : raise TypeError
    if not str.isalpha() : raise ValueError
    return  reduce(lambda a, b:  (a*26)+ord(b)-ord("a")+1, str.lower(), 0)

def defaultIfNone(blackList=[None, ], default=""):
    def returnFun(value):
        defaultValue=default() if callable(default) else default
        if value in blackList:
            return defaultValue
        else:
            try:
                return str(value)
            except:
                try:
                    return repr(value)
                except:
                    pass
        return defaultValue
    return returnFun

null2blank=defaultIfNone(blackList=[None, "NULL", "null", "None"])


def removeBOM(str, default=""):
    if str is None or not isinstance(str, basestring):
        return default
    else:
        str=str.strip(unicode(codecs.BOM_UTF8, "utf8"))
        return str

#tab order: "main" -> main, "report" -> report ,"master" -> master, "access" ->access
def tabFocus(tab_type=""):
    def decorator(fun):
        def returnFun(*args, **keywordArgs):
            returnVal=fun(*args, **keywordArgs)
            if type(returnVal)==dict and "tab_focus" not in returnVal:
                returnVal["tab_focus"]=tab_type
            return returnVal
        return returnFun
    return decorator


#list the files in the given folder , filter the file withe the filterFun.
def listFiles(sourcePath, filterFun=None, scanSubFolder=True):
    if not os.path.exists(sourcePath) or not os.path.isdir(sourcePath) : raise "direcotry doesn't exist or it's not a directory!"
    if filterFun is None: filterFun=lambda a:a
    for fileOrDir in imap(lambda p:os.path.join(sourcePath, p), os.listdir(sourcePath)):
        if os.path.isfile(fileOrDir) and filterFun(fileOrDir):  yield fileOrDir
        elif os.path.isdir(fileOrDir) and scanSubFolder:
            for v in listFiles(fileOrDir, filterFun, scanSubFolder):  yield v

#convert the code between different ones.            
def codeConvert(str, originCode, targetCode):
    if originCode=="utf8":
        return str.encode(targetCode)
    elif targetCode=="utf8":
        return str.decode(originCode)
    else:
        return str.decode(originCode).encode(targetCode)

def converChinese(v, default=""):
    if not v : return default
    if not issubclass(type(v), basestring) : return default
    return v.decode("utf8")


def send_mail(send_from, send_to, subject, text, cc_to=[], files=[], server="192.168.42.13"):
    assert type(send_to)==list
    assert type(files)==list

    msg=MIMEMultipart()
    msg.set_charset("utf-8")
    msg['From']=send_from
    msg['To']=COMMASPACE.join(send_to)

    if cc_to:
        assert type(cc_to)==list
        msg['cc']=COMMASPACE.join(cc_to)
        send_to.extend(cc_to)

    msg['Date']=formatdate(localtime=True)
    msg['Subject']=subject

    msg.attach(MIMEText(text))

    for f in files:
        part=MIMEBase('application', "octet-stream")
        part.set_payload(open(f, "rb").read())
        fn=os.path.basename(f)
        part.add_header('Content-Disposition', 'attachment; filename="%s"'%Header(fn, 'utf-8'))
        Encoders.encode_base64(part)
        msg.attach(part)

    smtp=smtplib.SMTP(server)
    smtp.sendmail(send_from, send_to, msg.as_string())
    smtp.close()


def dividList(listObj):
    if not listObj:
        return ([], [])

    odd=[]
    even=[]

    for index, item in enumerate(listObj):
        if index%2==0 : odd.append(item)
        else: even.append(item)
    return (odd, even)


def formatLegacyCode(oStr):
    if not oStr or type(oStr) not in [str, unicode] : return ""
    return "".join([c for c in oStr if c.isdigit()])

def pixel2Pound(p):
    return p*3/4

def fileUpload(kw_param, relativePath, fileName):
    try:
        absPath=os.path.join(os.path.abspath(os.path.curdir), relativePath)
        if not os.path.exists(absPath):
            os.makedirs(absPath)
        fn=fileName if not callable(fileName) else fileName()
        targetFileName=os.path.join(absPath, fn)

        f=open(targetFileName, "wb")
        f.write(kw_param.file.read())
        f.close()
        return targetFileName
    except:
        traceback.print_exc()
        return None


encryptPrefix=sha.new("r-pac").hexdigest()[5:15]
encryptSuffix=sha.new("Bossini").hexdigest()[5:15]

def rpacEncrypt(v):
    c=base64.b64encode(unicode(v))
    return encryptPrefix+c+encryptSuffix

def rpacDecrypt(str):
    if not str : return (false, None)
    if str[:10]!=encryptPrefix : return (false, None)
    if str[-10:]!=encryptSuffix : return (False, None)
    return (True, base64.b64decode(str[10:-10]))


def fmtNumber(numberStr, step=3):
    if not numberStr or not isinstance(numberStr, basestring) or not numberStr.isdigit() or step<1: return numberStr
    tmp=numberStr[::-1]
    return ",".join([ tmp[i*step:(i+1)*step] for i in range(int(math.ceil(len(numberStr)*1.0/step))) ])[::-1]

POLERTEC_PRICES={'PLS-10': 32.30, 'PLV-10': 24.30, 'PPD-10': 35.40, 'PPD-10': 35.40,
                 'PPD-10': 35.40, 'PTP-10': 31.00, 'PTP-10': 31.00, 'PWB-10': 31.00,
                 'PWP-10': 35.40, 'PZP-10': 69.00, 'PCL1-10': 31.00, 'PCL2-10': 34.50,
                 'PCL3-10': 31.00, 'PCLM-10': 31.00, 'PHTB-10': 23.75, 'PHTW-10': 23.75,
                 'PPSH-10': 35.40, 'PPST-10': 35.40, 'PPWI-10': 31.00, 'PPWN-10': 31.00,
                 'PECOC-10': 13.90, 'PLCLF-10': 16.50, 'PLCLS-10': 32.30, 'PLCLV-10': 24.85,
                 'PLEES-10': 42.54, 'PLFLT-10': 16.50, 'PLTPF-10': 16.50, 'PLTPS-10': 32.30,
                 'PLTPV-10': 24.30, 'PLWBS-10': 32.30, 'PLWBV-10': 24.30, 'PLWPS-10': 32.30,
                 'PLWPV-10': 25.50, 'POTEC-10': 13.90, 'PPDAS-10': 35.40, 'PPDFR-10': 31.00,
                 'PPSH2-10': 31.00, 'PPSTP-10': 135.40, 'PTPAS-10': 35.40, 'PWBAS-10': 35.40,
                 'PWPAS-10': 31.00, 'PWPFR-10': 31.00, 'PZPSS-10': 72.00, 'PASTEC-10': 13.90,
                 'PCBACC-10': 21.50, 'PCL1AS-10': 31.00, 'PCL2AS-10': 31.00, 'PCL3AS-10': 31.00,
                 'PCL3AS-10': 31.00, 'PCLMAS-10': 31.00, 'PHFTEC-10': 13.90, 'PLPPDF-10': 16.50,
                 'PLPPDS-10': 32.30, 'PLPPDV-10': 24.30, 'PLRECF-10': 16.50, 'PLRECS-10': 32.30,
                 'PLVACC-10': 23.08, 'PPDACC-10': 13.80, 'PPDACC-10': 13.80, 'PPSHSW-10': 35.40,
                 'PPSTFR-10': 31.00, 'PPWIAS-10': 31.00, 'PPWNAS-10': 31.00, 'PSPTEC-10': 13.90,
                 'PSPTEC-10': 13.90, 'PTPACC-10': 13.80, 'PWBACC-10': 17.20, 'PWBACC-10': 17.20,
                 'PWBACT-10': 38.00, 'PWPACC-10': 13.80, 'PCL1ACC-10': 13.80, 'PCL2ACC-10': 13.80,
                 'PCL3ACC-10': 13.80, 'PCLMACC-10': 17.20, 'PCLMACC-10': 17.20, 'PECOREC-10': 20.00,
                 'PHTNEOB-10': 32.10, 'PHTNEOW-10': 32.10, 'PLPPSHF-10': 19.00, 'PLPPSHV-10': 24.30,
                 'PLPPSTF-10': 16.50, 'PLPPSTS-10': 32.30, 'PLPPSTV-10': 25.50, 'PLPPSTV-10': 25.50,
                 'PPDHEAS-10': 35.40, 'PPSH2AS-10': 31.00, 'PPSHACC-10': 13.80, 'PPSHP-10': 31.00,
                 'PPSTACC-10': 17.20, 'PPSTPAS-10': 35.40, 'PTPHLAS-10': 35.40, 'PASTECAS-10': 13.90,
                 'PLCBCLAM-10': 23.47, 'PLEECLAM-10': 10.25, 'PLEESACC-10': 49.00, 'PLPPSH2S-10': 32.30,
                 'PLPPSH2V-10': 24.30, 'PLPPSHPS-10': 32.30, 'PLPPSHPV-10': 16.50, 'PPSHAS-10': 35.40,
                 'PPSTAS-10': 35.40, 'PDWRTEC-10': 13.90, 'PDWRTECAS-10': 13.90, 'PLFT1-ACC-10': 19.83,
                 'PLFT2-ACC-10': 19.83, 'PLFT3-ACC-10': 14.83, 'PLPRNTCLV-10': 43.75, 'PLPRNTPDV-10': 30.60,
                 'PLPRNTWBV-10': 43.75, 'PLRECSACC-10': 49.00, 'PLPRNTPSHPV-10': 43.75,
                 }


if __name__=="__main__" :
    v=rpacEncrypt("1500")
    print v
    print rpacDecrypt(v)
    pass
