import os,traceback
from turbogears import controllers, expose, flash,redirect

def getOr404(model,id,redirect_path,message=""):
    try:
        o = model.get(id)
    except:
        traceback.print_exc()
        flash(message)
        raise redirect(redirect_path)
    else:
        return o