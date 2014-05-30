import sys
from fcgi import WSGIServer
import os
import atexit
import cherrypy

import cherrypy._cpwsgi
import turbogears

turbogears.update_config(configfile="C:\\workspace\\eCRM\\prod.cfg", modulename="ecrm.config")

from ecrm.controllers import Root

cherrypy.root = Root()

if cherrypy.server.state == 0:
    atexit.register(cherrypy.server.stop)
    cherrypy.server.start(init_only=True, server_class=None)

def application(environ, start_response):
    if environ['SCRIPT_NAME']:
        environ['PATH_INFO'] = environ['SCRIPT_NAME'][1:]
    environ['SCRIPT_NAME'] = '/'
    
    return cherrypy._cpwsgi.wsgiApp(environ, start_response)
    
WSGIServer(application, bindAddress = ("192.168.1.183",888)).run()