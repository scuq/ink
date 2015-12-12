#!/usr/bin/python
# this is a squid external_acl handler
# example squid.conf line:
#
# external_acl_type k_acl ipv4 children-startup=20 
# children-max=70 ttl=28800 negative_ttl=1200 
# concurrency=1 protocol=2.5 %SRC %DST %LOGIN %URI /usr/local/bin/ksquid-acl.py
#
import logging
import pg
import sys
reload(sys)
sys.setdefaultencoding('utf8')
import time
import codecs
import ConfigParser
from netaddr import IPAddress
import socket
import os
import time
import re
from urllib2 import quote
from logging.handlers import SysLogHandler
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("ink-acl")
logger.setLevel(logging.INFO)
syslog = SysLogHandler(address='/dev/log',facility="local4")
#formatter = logging.Formatter('%(name)s: %(levelname)s %(message)s')
formatter = logging.Formatter('%(name)s[%(process)d]:%(levelname)s %(message)s')
syslog.setFormatter(formatter)
logger.addHandler(syslog)
from optparse import OptionParser

def make_unicode(input):
    if type(input) != unicode:
        input =  input.decode('ISO-8859-1').encode('UTF-8')
        return input
    else:
        return input

def isIp(addr):
        try:
                socket.inet_aton(addr)
                return True
        except:
                return False


def grant(logmsg,displaymsg,test):
	try:
		if test:
			print logmsg
		else:
			logger.info(logmsg)
		sys.stdout.write('OK\n')
		sys.stdout.flush()
	except:
		pass

def deny(logmsg,displaymsg,test):
	try:
		displaymsg=displaymsg.replace("\\", "\\\\")
		if test:
			print logmsg
		else:
			logger.info(logmsg)
		sys.stdout.write('ERR message=\"'+displaymsg+'\"\n')
		sys.stdout.flush()
	except:
		pass


def preparse(linesplitted):

	netbiosdomainname=""
	xx=linesplitted[0]
	src=linesplitted[1]
	dst=linesplitted[2]
	if isIp(dst):
		dstisip=True
	else:
		dstisip=False
	username=linesplitted[3]
	if username.count("%5C") > 0:
		username = username.replace("%5C","\\")
	if username.count("\\\\") > 0:
		username = username.replace("\\\\","\\")
	if username.count("\\") > 0:
		netbiosdomainname = username.split("\\")[0]
		username = username.split("\\")[1]
	#uri=" ".join(linesplitted[5:len(linesplitted)]).strip()
	uri=linesplitted[4]
	if uri.count("://") > 0:
		uri = uri.split("://")[1]
	uri = uri.replace("'","''")
	#useragent=str(linesplitted[5:len(linesplitted)-1])
	useragent=" ".join(linesplitted[5:len(linesplitted)-1])


	return src, dst, dstisip, username, netbiosdomainname, uri, useragent


def req_allowed_useragent(test,pgcon,username,src,uri,dst,dstisip,netbiosdomainname,useragent):

        result = {}

        dstisipstr="f"

        if dstisip == True:
                dstisipstr="t"
                dst = str(IPAddress(dst))

	_query = "select * from req_allowed_useragent('"+useragent+"','"+src+"', E'"+make_unicode(uri)+"','"+dst+"','"+dstisipstr+"')"

        try:

                logger.debug(_query)
                result = pgcon.query(_query).dictresult()

                result = result[len(result)-1]

                _tst = result["req_allowed"]


        except:
                result = {}
		logger.error(_query)
                logger.error("db-error: "+str(sys.exc_info()[0])+" "+str(sys.exc_info()[1])+" q:"+_query)
                error=True

        return result

def req_allowed(test,pgcon,username,src,uri,dst,dstisip,netbiosdomainname):

	result = {}

	dstisipstr="f"

	if dstisip == True:
		dstisipstr="t"
		dst = str(IPAddress(dst))

	_query = "select * from req_allowed_default('"+username+"','"+src+"',E'"+make_unicode(uri)+"','"+dst+"','"+netbiosdomainname+"','"+dstisipstr+"')"

        try:
#                pgcon = pg.connect(db["name"],db["host"],int(db["port"]),None,None,db["user"],db["password"])


		logger.debug(_query)
                result = pgcon.query(_query).dictresult()

		result = result[len(result)-1]

		_tst = result["req_allowed"] 

#                pgcon.close()

        except:
		result = {}
		logger.error(_query)
                logger.error("db-error: "+str(sys.exc_info()[0])+" "+str(sys.exc_info()[1])+" q:"+_query)
                error=True

	return result


def main():

        parser = OptionParser()
        parser.add_option("-i", "--input", dest="input", help="input line pass args like squid will do on stdin, used in test mode")
        parser.add_option("-t", "--test", action="store_true", dest="test", default=False, help="enable testing/monitoring mode")
        parser.add_option("", "--useragent-mode", action="store_true", dest="useragentmode", default=False, help="run in user-agent/subnet mode instead of validating the %LOGIN")
        (options, args) = parser.parse_args()

	if options.useragentmode:
		logger = logging.getLogger("ink-acl-useragent")
	else:
		logger = logging.getLogger("ink-acl")


        inkdb={}
	if not os.path.isfile('/etc/ink/ink.cfg'):
		 logger.error("no config file found: /etc/ink/ink.cfg")
		 sys.exit(1)
	else:
		config = ConfigParser.RawConfigParser()
		config.read('/etc/ink/ink.cfg')
		inkdb["type"]=config.get("database", "type")
		inkdb["name"]=config.get("database", "name")
		inkdb["host"]=config.get("database", "host")
		inkdb["port"]=config.get("database", "port")
		inkdb["user"]=config.get("database", "queryuser")
		inkdb["password"]=config.get("database", "querypassword")
	
	requests_processed=0
	process_time=0
	
	if options.test and options.input:
		line=options.input
	else:
		line = sys.stdin.readline()[:-1]

	pgcon = pg.connect(inkdb["name"],inkdb["host"],int(inkdb["port"]),None,None,inkdb["user"],inkdb["password"])

	while line:
		requests_processed += 1
		if requests_processed%100 == 0:
			logger.info("my ("+str(os.getpid())+") statistics: requests_processed: "+str(requests_processed)+" avg_process_time: "+str(process_time/requests_processed)+" seconds.")

		start = time.time()
		logger.info("line: "+line)
		stdinline=line.strip().split(" ")
		if len(stdinline) >= 5:
			logger.info(stdinline)

			src, dst, dstisip, username, netbiosdomainname, uri, useragent = preparse(stdinline)

			try:
				
				if options.useragentmode:
					result = req_allowed_useragent(options.test,pgcon,username,src,uri,dst,dstisip,netbiosdomainname,useragent)
				else:
					result = req_allowed(options.test,pgcon,username,src,uri,dst,dstisip,netbiosdomainname)
				done=False

				if result["profile"] == "<NONE>":
					displaymsg="Es konnte keine Profilzuordnung zu Ihrem Benutzer ("+username+") gefunden werden, daher ist der Zugriff auf "+dst+" unterbunden."
					logmsg="user: "+username+" with profile  NOT found within "+str(time.time()-start)+" seconds, denying."
					done=True
					deny(logmsg,displaymsg,options.test)

				if done == False:

					if result["req_allowed"] == "t":
						if options.useragentmode:
							logmsg="pseudouser (useragent) "+result["accountname"]+" matches profile "+result["profile"]+", profile is in mode: "+result["profile_mode"]+", request to "+dst+" allowed. lookuptime: "+str(time.time()-start)+" seconds."
						else:
							logmsg="user "+username+" matches profile "+result["profile"]+", profile is in mode: "+result["profile_mode"]+", request to "+dst+" allowed. lookuptime: "+str(time.time()-start)+" seconds."
						displaymsg=""
						process_time += time.time()-start
						
						grant(logmsg,displaymsg,options.test)

					else:
						if options.useragentmode:
							logmsg="pseudouser (useragent) "+result["accountname"]+" matches profile "+result["profile"]+", profile is in mode: "+result["profile_mode"]+", request to "+dst+" denied. lookuptime: "+str(time.time()-start)+" seconds."
						else:
							logmsg="user "+username+" matches profile "+result["profile"]+", profile is in mode: "+result["profile_mode"]+", request to "+dst+" denied. lookuptime: "+str(time.time()-start)+" seconds."
						displaymsg="Ihrem Benutzer '"+username+"' ist das Profil "+result["profile"]+"  zugeordnet in diesem Profil ist der Zugriff auf "+dst+" unterbunden."
						process_time += time.time()-start

						deny(logmsg,displaymsg,options.test)

			except:
				logger.error("req_allowed call failed: "+str(sys.exc_info()[0])+" "+str(sys.exc_info()[1]))
				logmsg=""
				displaymsg="982235"
				deny(logmsg,displaymsg,options.test)

#			else:


		if options.test and options.input:
			break

		line = sys.stdin.readline()[:-1]

			
	pgcon.close()
		

if __name__ == '__main__':
        main()
