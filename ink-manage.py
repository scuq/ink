#!/usr/bin/python
# coding=utf-8
# -*- coding: <utf-8> -*-
# vim: set fileencoding=<utf-8> :
# 
# v0.1

scriptid="ink-manage.py"

# ink for squid management script


import sys, re
reload(sys)  
sys.setdefaultencoding('utf8')
import os
import ConfigParser
import codecs
import time
import logging
import pickle
from prettytable import PrettyTable
#from disk_space import disk_space
import datetime
from netaddr import IPAddress
from types import *
from shutil import copy
import pg
import ldap
from ldap.controls import SimplePagedResultsControl
import shutil
import socket
from subprocess import Popen, PIPE, STDOUT
from time import strftime
from logging.handlers import SysLogHandler
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(scriptid)
logger.setLevel(logging.INFO)
syslog = SysLogHandler(address='/dev/log',facility="local4")
formatter = logging.Formatter('%(name)s[%(process)d]:%(levelname)s %(message)s')
syslog.setFormatter(formatter)
logger.addHandler(syslog)
from optparse import OptionParser
from subprocess import Popen, PIPE, STDOUT
import tarfile
import urllib


def execute(command):

        p = Popen(command, shell=True, stdin=PIPE, stdout=PIPE, stderr=PIPE, close_fds=True)
        stdOut=re.sub('\\n+','\\n',str(p.stdout.read().decode("utf-8"))).split("\n")
        stdErr=str(p.stderr.read()).split("\n")

        return stdOut, stdErr

def isIp(addr):
	try:
		socket.inet_aton(addr)
		return True
	except:
		return False

def refillDbList(db, table, col, csvfile):


        transactionStatement="begin;"

        transactionStatement+="delete from "+table+";"

	transactionStatement+="copy "+table+" ("+col+") from '"+csvfile+"' (FORMAT CSV, DELIMITER('|'));"


	logger.info("copy "+table+" ("+col+") from '"+csvfile+"' (FORMAT CSV, DELIMITER('|'));")

        transactionStatement+="commit;"





        try:
                pgcon = pg.connect(db["name"],db["host"],int(db["port"]),None,None,db["user"],db["password"])

                returnval = pgcon.query(transactionStatement)


                pgcon.close()

        except:
                logging.error("error on inserting to database: "+str(sys.exc_info()[0])+" "+str(sys.exc_info()[1]))
                error=True
                try:
                        pgcon.close()
                except UnboundLocalError:
                        pass


def updateList(workdir,db,profiles,blacklisturl,fetch,profile_to_category,profile_mode):



	if fetch:
		logger.info("retrieving url: %s" % blacklisturl)
		urllib.urlretrieve (blacklisturl, workdir+os.sep+"shalla.tar.gz")

	if os.path.isfile(workdir+os.sep+"shalla.tar.gz"):

		logger.info("extracting: %s" % "shalla.tar.gz")
		tar = tarfile.open(workdir+os.sep+"shalla.tar.gz")
		tar.extractall(workdir)
		tar.close()


	# iter to profiles
	for profile in profile_to_category.keys():

		_csv_file_domains = workdir+os.sep+"temp"+os.sep+profile+"_domains"
		_csv_file_ips = workdir+os.sep+"temp"+os.sep+profile+"_ips"
		_csv_file_urls = workdir+os.sep+"temp"+os.sep+profile+"_urls"

		# delete old temp files
		try:
			if os.path.isfile(_csv_file_domains):
				os.remove(_csv_file_domains)
				os.remove(_csv_file_domains+".uniq")
			if os.path.isfile(_csv_file_ips):
				os.remove(_csv_file_ips)
				os.remove(_csv_file_ips+".uniq")
			if os.path.isfile(_csv_file_urls):
				os.remove(_csv_file_urls)
				os.remove(_csv_file_urls+".uniq")
		except:
			pass

		# find the database table names for the current profile
		for pro in profiles:
			if pro["profile"] == profile:
				list_domains_table = pro["list_domains_table_name"]
				list_urls_table = pro["list_urls_table_name"]
				list_ips_table = pro["list_ips_table_name"]

		# check if the shala dir exist
		#
		if os.path.isdir(workdir+os.sep+"BL") == True:
                        logger.info("parsing shalla blacklist directory: %s" % "BL")
			
			# iterate the shalla dirs
                        for subdir, dirs, files in os.walk(workdir):

				# check if the current subdir matches a category for this profile
                                if  profile_to_category[profile].count(os.path.basename(subdir)) > 0:

                                        logger.info("filling profile "+profile+" with category: "+os.path.basename(subdir))

					# read the orig domains file
                                        if os.path.isfile(subdir+os.sep+"domains"):


						if not os.path.exists(workdir+os.sep+"temp"):
							os.makedirs(workdir+os.sep+"temp")

						tempfile = codecs.open(_csv_file_domains, 'a+', encoding='utf-8')
						tempfileips = codecs.open(_csv_file_ips, 'a+', encoding='utf-8')

						infile = codecs.open(subdir+os.sep+"domains", 'r', encoding='utf-8')	

						# read the orig domains file line by line, if the line is an ip-address move it to a different file
                                                for _ln in infile:
							if isIp(_ln.strip()):
								_ip = ""
								_ip = str(IPAddress(_ln.strip()))
								tempfileips.write(_ip+"\n")
							else:
								tempfile.write(_ln.strip()+"\n")

						

						infile.close()
						tempfile.close()
						tempfileips.close()
						
							

					# read the orig urls file
                                        if os.path.isfile(subdir+os.sep+"urls"):

						if not os.path.exists(workdir+os.sep+"temp"):
							os.makedirs(workdir+os.sep+"temp")


                                                tempfile = codecs.open(_csv_file_urls, 'a+', encoding='utf-8')

                                                infile = codecs.open(subdir+os.sep+"urls", 'r', encoding='utf-8')

                                                # read the orig domains file line by line, if the line is an ip-address move it to a different file
                                                for _ln in infile:
							if not _ln in tempfile:
								tempfile.write(_ln.strip()+"\n")



                                                infile.close()
                                                tempfile.close()

		
						
		
		execute("cat "+_csv_file_domains+" | sort -u > "+_csv_file_domains+".uniq")
		refillDbList(db, list_domains_table, "domain", _csv_file_domains+".uniq")

		execute("cat "+_csv_file_urls+" | sort -u > "+_csv_file_urls+".uniq")
		refillDbList(db, list_urls_table, "url", _csv_file_urls+".uniq")
		
		execute("cat "+_csv_file_ips+" | sort -u > "+_csv_file_ips+".uniq")
		refillDbList(db, list_ips_table, "ip", _csv_file_ips+".uniq")


def genericReadQuery(db, query):

	result = {}

        try:
                pgcon = pg.connect(db["name"],db["host"],int(db["port"]),None,None,db["user"],db["password"])

		logger.debug(query)

                result = pgcon.query(query).dictresult()

                pgcon.close()

        except:
                logging.error("db-error: "+str(sys.exc_info()[0])+" "+str(sys.exc_info()[1]))
                error=True
                try:
                        pgcon.close()
                except UnboundLocalError:
                        pass

        return result

def genericWriteQuery(db, query):

        returnmsg = ""

        try:
                pgcon = pg.connect(db["name"],db["host"],int(db["port"]),None,None,db["user"],db["password"])

                logger.debug(query)

                returnmsg = pgcon.query(query)

                pgcon.close()

        except:
                logging.error("db-error: "+str(sys.exc_info()[0])+" "+str(sys.exc_info()[1]))
                error=True
                try:
                        pgcon.close()
                except UnboundLocalError:
                        pass

        return returnmsg


def getUaSn(db):

	_query = "select * from useragents;"
	return genericReadQuery(db,_query)



def getAccounts(db,account="<ALL>", nbdomain="<ALL>"):

        db_accounts={}
	_query = ""
	if account == "<ALL>" and nbdomain == "<ALL>":
		_query = "select * from accounts;"
	else:
		_query = "select * from accounts WHERE LOWER(netbiosdomainname) = LOWER('"+nbdomain+"') and LOWER(accountname) = LOWER('"+account+"');"


	return genericReadQuery(db,_query)


def delListEntry(db, tabletype, tablename, delentry):

	if tabletype == "url":
		_query = "DELETE FROM "+tablename+" WHERE url = '"+delentry+"'"
	if tabletype == "domain":
		_query = "DELETE FROM "+tablename+" WHERE domain = '"+delentry+"'"
	if tabletype == "ip":
		_query = "DELETE FROM "+tablename+" WHERE ip = '"+delentry+"'"

        return genericWriteQuery(db,_query)

def createAllListTables(db):

        _query="SELECT create_all_list_tables()"

        return genericWriteQuery(db,_query)

def delProfile(db,profilename):

        _query = "DELETE FROM profiles where profile = '"+profilename+"'"

        return genericWriteQuery(db,_query)

def delNewUaSnException(db, uarx, sn):

        _query="DELETE FROM useragents WHERE useragentrx='"+uarx+"' AND subnet = '"+sn+"'"

        return genericWriteQuery(db,_query)

def delAdConfig(db, addomain):

        _query="DELETE FROM cfg_activedirectory WHERE domain='"+addomain+"'"

        return genericWriteQuery(db,_query)

def addNewGpm(db, gpmldapgroup, gpmprofile, gpmdomain, gpmnetbiosdomain, gpmpriority):

        _query = """
                        INSERT INTO cfg_activedirectory_group_profile (
                        ldapgroup,
                        profile,
                        domain,
                        netbiosdomainname,
                        priority
                        ) 
                        VALUES (
                        '"""+gpmldapgroup+"""',
                        '"""+gpmprofile+"""',
                        '"""+gpmdomain+"""',
                        '"""+gpmnetbiosdomain+"""',
                        '"""+gpmpriority+"""'
                        )
                """

        return genericWriteQuery(db,_query)

def delGpm(db, gpmldapgroup, gpmprofile):

        _query="DELETE FROM cfg_activedirectory_group_profile WHERE ldapgroup='"+gpmldapgroup+"' AND profile='"+gpmprofile+"'"

        return genericWriteQuery(db,_query)


def addNewAdConfig(db, addomain, adnetbiosdomain, adbasedn, aduser, adpass):

        _query = """
                        INSERT INTO cfg_activedirectory (
                        domain,
                        netbiosdomainname,
                        basedn,
                        username,
                        password
                        ) 
                        VALUES (
                        '"""+addomain+"""',
                        '"""+adnetbiosdomain+"""',
                        '"""+adbasedn+"""',
                        '"""+aduser+"""',
                        '"""+adpass+"""'
                        )
                """

        return genericWriteQuery(db,_query)

def addNewUaSnException(db, uarx, sn, uasnprofile, uasnpseudousername):

	_query = """
                        INSERT INTO useragents (
                        useragentrx,
                        subnet,
                        accountname,
                        profile
                        ) 
                        VALUES (
                        '"""+uarx+"""',
                        '"""+sn+"""',
                        '"""+uasnpseudousername+"""',
                        '"""+uasnprofile+"""'
                        )
                """

        return genericWriteQuery(db,_query)


def addNewProfile(db,profilename,profiledesc,mode):

	_query = """
			INSERT INTO profiles (
			profile,
			profiledesc,
			mode,
			list_domains_table_name,
			list_urls_table_name,
			list_ips_table_name,
			list_custom_domains_table_name,
			list_custom_urls_table_name,
			list_custom_ips_table_name 
			) 
			VALUES (
			'"""+profilename+"""',
			'"""+profiledesc+"""',
			'"""+mode+"""',
			'list_domains_"""+profilename+"""',
			'list_urls_"""+profilename+"""',
			'list_ips_"""+profilename+"""',
			'list_custom_domains_"""+profilename+"""',
			'list_custom_urls_"""+profilename+"""',
			'list_custom_ips_"""+profilename+"""'
			)
		"""

        return genericWriteQuery(db,_query)


def addListEntry(db, tabletype, tablename, newentry, allowed):

	allowedstr="FALSE"
	if allowed:
		allowedstr="TRUE"

	if tabletype == "url":
		_query="INSERT INTO "+tablename+" (url, allowed) VALUES ('"+newentry+"', "+allowedstr+")"
	if tabletype == "domain":
		_query="INSERT INTO "+tablename+" (domain, allowed) VALUES ('"+newentry+"', "+allowedstr+")"
	if tabletype == "ip":
		_query="INSERT INTO "+tablename+" (ip, allowed) VALUES ('"+newentry+"', "+allowedstr+")"


        return genericWriteQuery(db,_query)



def getListContent(db,tabletype,tablename):

	if tabletype == "url":
		_query="select url, allowed from "+tablename
	if tabletype == "domain":
		_query="select domain, allowed from "+tablename
	if tabletype == "ip":
		_query="select ip, allowed from "+tablename

        return genericReadQuery(db,_query)

def getProfiles(db):

        db_profiles={}
        db_profiles_mode={}

	_query = "select * from profiles"

	db_profiles = genericReadQuery(db,_query)

	for pro in db_profiles:
		if db_profiles_mode.keys().count(pro["profile"]) <= 0:
			db_profiles_mode[pro["profile"]]=pro["mode"]
		
        return db_profiles, db_profiles_mode

def getProfileToCategory(db):

	profile_to_category={}
	profile_mode={}

        cfg_profile_category={}

	_query = "select profile, mode, category from cfg_profile_category"

	cfg_profile_category = genericReadQuery(db,_query)

	for cfg_row in cfg_profile_category:
		if profile_to_category.keys().count(cfg_row["profile"]) <= 0:
			profile_to_category[cfg_row["profile"]]=[cfg_row["category"]]
		else:
			profile_to_category[cfg_row["profile"]].append(cfg_row["category"])

	return profile_to_category


def getLdapUsers(user, password, domain,basedn, group, netbiosdomainname, profile, priority):

        logger.info("starting query for domain "+domain+" @basedn: "+basedn+" for group: "+group)

        try:
                l = ldap.initialize("ldap://"+domain+":389")
                l.simple_bind_s(user, password)
                l.set_option(ldap.OPT_REFERRALS, 0)
        except ldap.LDAPError, e:
                logger.error("ldap-open: "+str(e))
                return

        searchScope = ldap.SCOPE_SUBTREE
        retrieveAttributes = ["extensionAttribute1", "sAMAccountName", "cn", "displayName", "mail", "dn", "extensionAttribute14", "lastLogonTimestamp", "telephoneNumber", "pwdLastSet"]
        searchFilter = "(&(objectClass=user)(memberOf="+group+")(!(UserAccountControl:1.2.840.113556.1.4.803:=2)))"
        PAGE_SIZE = 10


        paged_results_control = SimplePagedResultsControl(ldap.LDAP_CONTROL_PAGE_OID, True, (PAGE_SIZE, ''))

        accounts = []

        pages = 0

        while True:
                serverctrls = [paged_results_control]


                try:

                        msgid = l.search_ext(basedn,searchScope,searchFilter,retrieveAttributes,serverctrls=serverctrls)

                except ldap.LDAPError, e:
                        logger.error('Error performing user paged search: ' + str(e) + '\n')
                        sys.exit(1)

                try:

                        unused_code, results, unused_msgid, serverctrls = l.result3(msgid)

                except ldap.LDAPError, e:

                        logger.error('Error getting user paged search results: ' + str(e) + '\n')
                        sys.exit(1)

                for result in results:
                      pages += 1
                      accounts.append(result)

                cookie = None

                for serverctrl in serverctrls:

                        if serverctrl.controlType == ldap.LDAP_CONTROL_PAGE_OID:
                                unused_est, cookie = serverctrl.controlValue
                                if cookie:
                                        paged_results_control.controlValue = (PAGE_SIZE, cookie)
                                break
                if not cookie:
                        break



        l.unbind_s()


        userrecords = []
        for entry in accounts:
	  try:
           if entry[1].has_key('cn') and \
             entry[1].has_key('displayName') and \
             entry[1].has_key('sAMAccountName'):


                userrecord = {}
                if entry[1].has_key('extensionAttribute1'):
                        userrecord["extensionAttribute1"] = entry[1]['extensionAttribute1'][0].decode('unicode_escape').encode('iso8859-9').decode('utf8')
                else:
                        userrecord["extensionAttribute1"] = ""
                if entry[1].has_key('mail'):
                        userrecord["mail"] = entry[1]['mail'][0].decode('unicode_escape').encode('iso8859-9').decode('utf8')
                else:
                        userrecord["mail"] = ""
                if entry[1].has_key('extensionAttribute14'):
                        userrecord["extensionAttribute14"] = entry[1]['extensionAttribute14'][0].decode('unicode_escape').encode('iso8859-9').decode('utf8')
                else:
                        userrecord["extensionAttribute14"] = ""
                if entry[1].has_key('lastLogonTimestamp'):
                        userrecord["lastLogonTimestamp"] = entry[1]['lastLogonTimestamp'][0].decode('unicode_escape').encode('iso8859-9').decode('utf8')
                else:
                        userrecord["lastLogonTimestamp"] = ""
                if entry[1].has_key('pwdLastSet'):
                        userrecord["pwdLastSet"] = entry[1]['pwdLastSet'][0].decode('unicode_escape').encode('iso8859-9').decode('utf8')
                else:
                        userrecord["pwdLastSet"] = ""
                if entry[1].has_key('telephoneNumber'):
                        userrecord["telephoneNumber"] = entry[1]['telephoneNumber'][0].decode('unicode_escape').encode('iso8859-9').decode('utf8')
                else:
                        userrecord["telephoneNumber"] = ""
                userrecord["cn"] = entry[1]['cn'][0].decode('unicode_escape').encode('iso8859-9').decode('utf8')
                userrecord["displayName"] = entry[1]['displayName'][0].decode('unicode_escape').encode('iso8859-9').decode('utf8')
                userrecord["dn"] = entry[0].decode('unicode_escape').encode('iso8859-9').decode('utf8')
                userrecord["sAMAccountName"] = entry[1]['sAMAccountName'][0].decode('unicode_escape').encode('iso8859-9').decode('utf8')
                userrecord["profile"] = profile
                userrecord["netbiosdomainname"] = netbiosdomainname
                userrecord["priority"] = priority
                userrecords.append(userrecord)

	  except:
		logging.error("ldap-error: "+str(sys.exc_info()[0])+" "+str(sys.exc_info()[1])+" "+str(entry[1]))


        logger.info("finished query for "+domain+" @ "+basedn+" loaded users: "+str(len(userrecords)))


        return userrecords



def getAdDomains(db):

        _query = "select domain,netbiosdomainname,basedn,username,password from cfg_activedirectory"

        return genericReadQuery(db,_query)

def getUserToProfileMappings(db):

	_query = "select ldapgroup,profile,domain,netbiosdomainname,priority from cfg_activedirectory_group_profile order by priority"

	return genericReadQuery(db,_query)

def updateUrllist(workdir,inkdb,blacklist_fetch_url_shalla,fetch):

	profile_to_category={}
	profile_mode={}

	profiles,profile_mode = getProfiles(inkdb)

	profile_to_category = getProfileToCategory(inkdb)

	updateList(workdir,inkdb,profiles,blacklist_fetch_url_shalla,fetch,profile_to_category,profile_mode)


def insertUserProfileMapping(workdir, db, userlists, minaccounts):

	_cnt = 0
	_csv_file_users = workdir+os.sep+"temp"+os.sep+"userlist"

	# delete old temp files
	try:
		if os.path.isfile(_csv_file_users):
			os.remove(_csv_file_users)

	except:
		pass
	
	
	tempfile = codecs.open(_csv_file_users, 'w', encoding='utf-8')

	try:

		for userlist in userlists:

			for user in userlist:


				_cnt += 1
				tempfile.write(user["netbiosdomainname"]+"|"+user["sAMAccountName"]+"|"+user["mail"]+"|"+user["profile"]+"|"+str(user["priority"])+"\n")


	except:
		reordered=[]
                logging.error("error on filling user list: "+str(sys.exc_info()[0])+" "+str(sys.exc_info()[1]))
						

	tempfile.close()
				



        transactionStatement="begin;"

        transactionStatement+="delete from temp_accounts;"

        transactionStatement+="copy temp_accounts (netbiosdomainname,accountname,email,profile,priority) from '"+_csv_file_users+"' (FORMAT CSV, DELIMITER('|'));"

        transactionStatement+="commit;"


        transactionStatement2="begin;"

        transactionStatement2+="delete from accounts;"

        transactionStatement2+="insert into accounts select distinct * from clean_temp_accounts;"

        transactionStatement2+="commit;"

	if _cnt < minaccounts:
		logger.error("not enough users found by ldap queries, specified min. user count is "+str(minaccounts)+" got "+str(_cnt)+".")
		return


        try:
                pgcon = pg.connect(db["name"],db["host"],int(db["port"]),None,None,db["user"],db["password"])

                returnval1 = pgcon.query(transactionStatement)

                returnval2 = pgcon.query(transactionStatement2)


		logging.info(str(_cnt)+" account records inserted.")

                pgcon.close()

        except:
                logging.error("error on inserting to database: "+str(sys.exc_info()[0])+" "+str(sys.exc_info()[1]))
                error=True
                try:
                        pgcon.close()
                except UnboundLocalError:
                        pass




def updateAd(workdir,db,minaccount):


	_minaccounts=0
	try:
		_minaccounts=int(minaccount)
	except:
		_minaccounts=0

	user_to_profile_map = []
	user_to_profile_map = getUserToProfileMappings(db)

	ad_domain_settings = []
	ad_domain_settings = getAdDomains(db)

	users = []

	for map in user_to_profile_map:


		_ldapqueryuser = None
		_ldapquerypassword = None
		_ldapbasedn = None


		for ad_domain_setting in ad_domain_settings:
			if ad_domain_setting["domain"] == map["domain"]:
				_ldapqueryuser=ad_domain_setting["username"]
				_ldapquerypassword=ad_domain_setting["password"]
				_ldapbasedn=ad_domain_setting["basedn"]

		if not _ldapqueryuser == None and not _ldapquerypassword == None and not _ldapbasedn == None:

			users.append(getLdapUsers(_ldapqueryuser, _ldapquerypassword, map["domain"],_ldapbasedn, map["ldapgroup"],map["netbiosdomainname"],map["profile"],map["priority"]))

		


	insertUserProfileMapping(workdir, db, users,_minaccounts)

def printNewExplain():

	print """
	1) you need all python modules installed used in this and in the ink-acl.py script, see head of the files

	2) you need a postgres database server >= 9.1.19 
           apt-get install postgresql-9.1

	   you need to create at least 2 postgres users for ink:
             inkupdater (superuser and write permissions, superuser because otherwise the COPY from file is not allowed)
	     inkquerier

           CREATE ROLE inkquerier;
	   CREATE ROLE inkupdater;
 	   ALTER ROLE inkquerier WITH NOSUPERUSER NOINHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION CONNECTION LIMIT 500 PASSWORD 'YOURPASSHERE' VALID UNTIL 'infinity';
	   ALTER ROLE inkupdater WITH SUPERUSER NOINHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION CONNECTION LIMIT 2 PASSWORD 'YOURSUPERPASSHERE' VALID UNTIL 'infinity';

	3) run ink-manage.py as postgres user with ./ink-manage.py --create-database /tmp/ink/sql/ 

	4) fill all cfg_ tables and the profiles tables with your data, for some parts ink-manage.py can be used.

	5) bring ink-acl.py in place for the use with squid, if you want user-authentication + user-authorization based on ink plus exceptions by user-agent and-subnets here is a quick example config:

           auth_param ntlm program /usr/bin/ntlm_auth --diagnostics --helper-protocol=squid-2.5-ntlmssp
           auth_param ntlm children 20
           auth_param ntlm keep_alive off
           auth_param basic program /usr/bin/ntlm_auth --helper-protocol=squid-2.5-basic
           auth_param basic children 5
           auth_param basic realm Squid proxy-caching web server
           auth_param basic credentialsttl 2 hours


           external_acl_type ink_ext_acl_default ipv4 children-startup=3 children-max=4 ttl=10 negative_ttl=10 concurrency=1 protocol=2.5 %SRC %DST %LOGIN %URI /usr/local/bin/ink-acl.py

           external_acl_type ink_ext_acl_useragent ipv4 children-startup=3 children-max=4 ttl=10 negative_ttl=10 concurrency=1 protocol=2.5 %SRC %DST %SRC %URI %>{User-Agent} /usr/local/bin/ink-acl.py --useragent-mode

           acl ink_dyn_default external ink_ext_acl_default
           acl ink_dyn_useragent external ink_ext_acl_useragent

           http_access allow ink_dyn_useragent
           http_access allow !ink_dyn_useragent ink_dyn_default


"""
	
def printExplain():

	print """
	Fetch new Url-List from shallalist.de and fill the ink-database tables:
	  ink-manage.py -f -u

	Update Url-List from already downloaded shallalist .tar.gz:
	  ink-manage.py -u

	Update AD-Account-Cache:
	  ink-manage.py -a

	Update AD-Account-Cache and specify min. number of users:
	  ink-manage.py -a --min-account-count=19000

        Lookup account cache for a specific user:
          ink-manage.py --print-account --account mustermannm --netbiosdomain DOMAIN

         List all accounts in cache:
          ink-manage.py --print-accounts 

         List all pseudo accounts User-Agent+Subnet:
          ink-manage.py --print-uasn

         List all profiles:
          ink-manage.py --print-profiles 

         List Ldap/Ad group to profile map (map is used to pull member of the ldap group and create a user -> profile cache):
          ink-manage.py --print-ldapgroupmap

	Add new User-Agent+Subnet Excpetion and Pseudo-Account:
          ink-manage.py --add-ua-sn-exception --uarx='.+Wget/.+' --sn='10.16.16.101/32' --uasn-profile='T01S01' --uasn-pseudousername='Wget_PC_PP'

	Add New Profile (allowed modes: blacklist, whitelist):
	   ink-manage.py --add-profile=TEST --new-profile-desc="TEST Profile Desc"  --new-profile-mode=blacklist

	Delete User-Agent+Subnet Excpetion and Pseudo-Account:
	   ink-manage.py --del-ua-sn-exception --uarx='.+Wget/.+' --sn='10.16.16.101/32'

	Delete Profile (doesn't delete the filter list tables):
           ink-manage.py  --del-profile=TEST

	Create All LIST tables used by configured profiles:
           ink-manage.py --create-all-list-tables

	Add URL to Custom URL-List:
          allow:
            ink-manage.py --add-custom-url=<PROFILENAME> --allow --newentry='example.org/allowthis'
          deny:
            ink-manage.py --add-custom-url=<PROFILENAME> --newentry='example.org/denythis'


	Add IP to Custom IP-List:
          allow:
            ink-manage.py --add-custom-ip=<PROFILENAME> --allow --newentry='1.100.1.100'
          deny:
            ink-manage.py --add-custom-ip=<PROFILENAME> --newentry='1.100.1.100'

        Add DOMAIN to Custom DOMAIN-List:
          allow:
            ink-manage.py --add-custom-domain=<PROFILENAME> --allow --newentry='example.local'
          deny:
            ink-manage.py --add-custom-domain=<PROFILENAME> --newentry='example.local'


	Delete URL from Custom URL-List:
	    ink-manage.py --del-custom-url=<PROFILENAME> --delentry='example.org/denythis' 

	Delete IP from Custom IP-List:
	    ink-manage.py --del-custom-ip=<PROFILENAME> --delentry='1.100.1.100' 

	Delete DOMAIN from Custom DOMAIN-List:
	    ink-manage.py --del-custom-domain=<PROFILENAME> --delentry='example.local' 

	List Custom URL/IP/DOMAIN Lists:
	   ink-manage.py --print-custom-url-list=<PROFILENAME>
	   ink-manage.py --print-custom-ip-list=<PROFILENAME>
	   ink-manage.py --print-custom-domain-list=<PROFILENAME>



	"""



def main():

        parser = OptionParser()
	parser.add_option("", "--debug", action="store_true", dest="debug", default=False, help="enable debug logging")
	parser.add_option("", "--help-examples", action="store_true", dest="explain", default=False, help="custom help info")
	parser.add_option("", "--help-setup", action="store_true", dest="newexplain", default=False, help="explain howto setup a new instance of ink (database)")
	parser.add_option("", "--add-ad", action="store_true", dest="addadconfig", default=False, help="add Ad config, use with --addomain, --adnetbiosdomain, --adbasedn, --aduser, --adpass")
	parser.add_option("", "--del-ad", action="store_true", dest="deladconfig", default=False, help="delete Ad config, use with --addomain, --adnetbiosdomain, --adbasedn, --aduser, --adpass")
	parser.add_option("", "--print-ad", action="store_true", dest="printadconfig", default=False, help="print current Ad config")
	parser.add_option("", "--addomain", dest="addomain", help="dns-domain name of the Ad, use with --add-ad or --del-ad")
	parser.add_option("", "--adnetbiosdomain", dest="adnetbiosdomain", help="netbios-domain name of the Ad, use with --add-ad or --del-ad")
	parser.add_option("", "--adbasedn", dest="adbasedn", help="Ldap base-dn of the Ad, use with --add-ad or --del-ad")
	parser.add_option("", "--aduser", dest="aduser", help="Ldap/ad bind user, use with --add-ad or --del-ad")
	parser.add_option("", "--adpass", dest="adpass", help="Ldap/ad bind user password, use with --add-ad or --del-ad")
	parser.add_option("", "--print-gpm", action="store_true", dest="printldapgroupmap", default=False, help="print Ldap/Ad group to profile map")
	parser.add_option("", "--add-gpm", action="store_true", dest="addgroupprofilemapping", default=False, help="add Ad/Ldap group to profile mapping, use with --gpm-ldapgroup, --gpm-profile, --gpm-domain, --gpm-netbiosdomain, --gpm-priority")
	parser.add_option("", "--del-gpm", action="store_true", dest="delgroupprofilemapping", default=False, help="delete Ad/Ldap group to profile mapping, use with --gpm-ldapgroup, --gpm-profile")
	parser.add_option("", "--gpm-ldapgroup", dest="gpmldapgroup", help="Ldap DN of the group which should be mapped to the profile specified by --gpm-profile, use with --add-gpm")
	parser.add_option("", "--gpm-profile", dest="gpmprofile", help="Profile which should be use fot the Ldap Group specified by --gpm-ldapgroup, use with --add-gpm")
	parser.add_option("", "--gpm-domain", dest="gpmdomain", help="Dns domain name of the AD, use with --add-gpm")
	parser.add_option("", "--gpm-netbiosdomain", dest="gpmnetbiosdomain", help="Netbios domain name of the AD, use with --add-gpm")
	parser.add_option("", "--gpm-priority", dest="gpmpriority", help="Priority of the mapping the mapping with the highest priority will be applied to the user, use with --add-gpm")
	parser.add_option("", "--create-database", dest="createdatabase", help="create a new databse, make sure you have read --help-setup")
	parser.add_option("", "--print-profiles", action="store_true", dest="printprofile", default=False, help="print list of profiles")
	parser.add_option("", "--print-accounts", action="store_true", dest="printaccounts", default=False, help="print list of accounts (Ldap/Ad cached users)")
	parser.add_option("", "--print-account", action="store_true", dest="printaccount", default=False, help="print specific account use --account and --netbiosdomain to specify")
	parser.add_option("", "--print-accounts-pseudo", action="store_true", dest="printuasn", default=False, help="print list of pseudo accounts (User-Agent+Subnet)")
	parser.add_option("", "--print-custom-url-list", dest="printcustomurllist", help="print custom URL list for specified profile")
	parser.add_option("", "--print-custom-domain-list", dest="printcustomdomainlist", help="print custom DOMAIN list for specified profile")
	parser.add_option("", "--print-custom-ip-list", dest="printcustomiplist", help="print custom IP list for specified profile")
	parser.add_option("", "--add-profile", dest="addnewprofile", help="add new profile to the profiles table, use with --new-profile-desc, --new-profile-mode")
	parser.add_option("", "--add-ua-sn-exception", action="store_true", dest="adduasnexception", default=False, help="add User-Agent+IP-Subnet Exception, use with -uarx, --sn, --uasn-profile, --uasn-pseudousername ")
	parser.add_option("", "--del-ua-sn-exception", action="store_true", dest="deluasnexception", default=False, help="delete User-Agent+IP-Subnet Exception, use with -uarx, --sn")
	parser.add_option("", "--uarx", dest="uarx", help="User-Agent Regex, use with --add-ua-sn-exception")
	parser.add_option("", "--sn", dest="sn", help="IP-Subnet, use with --add-ua-sn-exception")
	parser.add_option("", "--uasn-profile", dest="uasnprofile", help="Profile to use for the User-Agent+Subnet, use with --add-ua-sn-exception")
	parser.add_option("", "--uasn-pseudousername", dest="uasnpseudousername", help="Pseudo-Username for User-Agent+Subnet, use with --add-ua-sn-exception")
	parser.add_option("", "--create-all-list-tables", action="store_true", dest="createalllisttables", default=False, help="stored proc to create all list tables (if not existing) used by configured profiles, should be called after adding new profiles")
	parser.add_option("", "--del-profile", dest="delprofile", help="delete  profile from profiles table")
	parser.add_option("", "--new-profile-desc", dest="addnewprofiledesc", help="desc of the new profile, use with --add-profile")
	parser.add_option("", "--new-profile-mode", dest="addnewprofilemode", help="mode of the new profile, use with --add-profile")
	parser.add_option("", "--add-custom-url", dest="addcustomurl", help="add custom URL for specified profile, use with --allow and --newentry")
	parser.add_option("", "--add-custom-domain", dest="addcustomdomain", help="add custom DOMAIN for specified profile, use with --allow and --newentry")
	parser.add_option("", "--add-custom-ip", dest="addcustomip", help="add custom IP for specified profile, use with --allow and --newentry")
	parser.add_option("", "--newentry", dest="newentry", help="new entry, url, domain or ip, use with --add-custom-url or --add-custom-domain or --add-custom-ip")
        parser.add_option("", "--del-custom-url", dest="delcustomurl", help="delete custom URL for specified profile, use with --allow and --delentry")
        parser.add_option("", "--del-custom-domain", dest="delcustomdomain", help="delete custom DOMAIN for specified profile, use with --delentry")
        parser.add_option("", "--del-custom-ip", dest="delcustomip", help="delete custom IP for specified profile, use with --delentry")
	parser.add_option("", "--delentry", dest="delentry", help="delete entry, url, domain or ip, use with --del-custom-url or --del-custom-domain or --del-custom-ip")
	parser.add_option("", "--allow", action="store_true", dest="allow", default=False, help="use with --add-custom-url or --add-custom-domain or --add-custom-ip")
	parser.add_option("", "--account", dest="account", help="account name")
	parser.add_option("", "--netbiosdomain", dest="netbiosdomainname", help="netbiosdomainname")
	parser.add_option("", "--fetch", action="store_true", dest="fetch", default=False, help="fetch external urllists")
	parser.add_option("", "--update-urllist", action="store_true", dest="update_urllist", default=False, help="update urllist in ink database")
	parser.add_option("", "--update-ad", action="store_true", dest="update_ad", default=False, help="update active directory group to profile mappings")
	parser.add_option("", "--min-account-count", dest="minaccount", help="abort if a less number of accounts found than specified by this arg")
	parser.add_option("", "--working-dir", dest="workingdir", help="working dir for temp files, default: /tmp/ink-update")
	parser.add_option("", "--write-example-config", action="store_true", dest="writeexampleconfig", default=False, help="write example config to /etc/ink/ink.cfg")
	parser.add_option("", "--shallaurl", dest="shallaurl", help="shallalist url, default: http://www.shallalist.de/Downloads/shallalist.tar.gz")
        (options, args) = parser.parse_args()

	if options.explain:
		printExplain()
		sys.exit(0)

	if options.newexplain:
		printNewExplain()
		sys.exit(0)

	if options.debug:
		logger.setLevel(logging.DEBUG)

        inkdb={}

	if options.createdatabase:
		if os.path.isdir(options.createdatabase):

			sqlfiles = [options.createdatabase+os.sep+"db.sql", options.createdatabase+os.sep+"types.sql", options.createdatabase+os.sep+"help_functions.sql", options.createdatabase+os.sep+"functions.sql", options.createdatabase+os.sep+"tables.sql", options.createdatabase+os.sep+"views.sql", options.createdatabase+os.sep+"data_category.sql"]

			for sqf in sqlfiles:
				if os.path.isfile(sqf):

					stdout, stderr = execute("psql < "+sqf)

					for l in stdout:
						print l

					for l in stderr:
						print l

			sys.exit(0)
		else:
			print "given sql file "+options.createdatabase+" doesn't exist"
			sys.exit(1)

	if options.writeexampleconfig:

		config = ConfigParser.RawConfigParser()
		config.add_section('database')
		config.set('database', 'type', 'pg')
		config.set('database', 'name', 'ink')
		config.set('database', 'host', '127.0.0.1')
		config.set('database', 'port', '5432')
		config.set('database', 'updateuser', 'inkupdater')
		config.set('database', 'updatepassword', 'inkUpt8r')
		config.set('database', 'queryuser', 'inkquerier')
		config.set('database', 'querypassword', 'someInk9871')

		if not os.path.isdir("/etc/ink"):
			os.makedirs("/etc/ink")

		with open('/etc/ink/ink.cfg', 'wb') as configfile:
			config.write(configfile)
	
		sys.exit(0)

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
		inkdb["user"]=config.get("database", "updateuser")
		inkdb["password"]=config.get("database", "updatepassword")


	workdir="/tmp/ink-update"

	if options.workingdir:
		workdir = options.workingdir

	blacklist_fetch_url_shalla="http://www.shallalist.de/Downloads/shallalist.tar.gz"

	if options.shallaurl:
		blacklist_fetch_url_shalla = options.shallaurl

	if not os.path.exists(workdir):
		os.makedirs(workdir)
	if not os.path.exists(workdir+os.sep+"temp"):
		os.makedirs(workdir+os.sep+"temp")

	if options.deluasnexception:
		if options.uarx and options.sn:
			delNewUaSnException(inkdb, options.uarx, options.sn)
		else:
			print "specify --uarx --sn"

		sys.exit(0)


        if options.printadconfig:
		x = PrettyTable(["domain", "netbiosdomain", "basedn", "username", "password"])

		adconfigs = getAdDomains(inkdb)

		for up in adconfigs:
			x.add_row([up["domain"],up["netbiosdomainname"],up["basedn"],up["username"],up["password"]])

		print x

		sys.exit(0)



	if options.addadconfig:
		if options.addomain and options.adnetbiosdomain and options.adbasedn and options.aduser and options.adpass:
			addNewAdConfig(inkdb, options.addomain, options.adnetbiosdomain, options.adbasedn, options.aduser, options.adpass)
			sys.exit(0)
		else:
			print "specify --addomain --adnetbiosdomain --adbasedn --aduser --adpass"
			sys.exit(1)


        if options.deladconfig:
                if options.addomain:
                        delAdConfig(inkdb, options.addomain)
                        sys.exit(0)
                else:
                        print "specify --addomain"
                        sys.exit(1)


	if options.adduasnexception:
		if options.uarx and options.sn and options.uasnprofile and options.uasnpseudousername:
			addNewUaSnException(inkdb, options.uarx, options.sn, options.uasnprofile, options.uasnpseudousername)
		else:
			print "specify --uarx --sn --uuasn-profile and --uasn-pseudousername"

		sys.exit(0)


	if options.printldapgroupmap:
		x = PrettyTable(["nbdomain", "domain", "ldapgroup", "profile", "prio"])
        	user_to_profile_map = getUserToProfileMappings(inkdb)
		for up in user_to_profile_map:
			x.add_row([up["netbiosdomainname"],up["domain"],up["ldapgroup"],up["profile"],up["priority"]])

		print x

		sys.exit(0)

	if options.addgroupprofilemapping:
		if options.gpmldapgroup and options.gpmprofile and options.gpmdomain and options.gpmnetbiosdomain and options.gpmpriority:
			addNewGpm(inkdb, options.gpmldapgroup, options.gpmprofile, options.gpmdomain, options.gpmnetbiosdomain, options.gpmpriority)
			sys.exit(0)
		else:
			print "specify --gpm-ldapgroup, --gpm-profile, --gpm-domain, --gpm-netbiosdomain, --gpm-priority"
			sys.exit(1)

        if options.delgroupprofilemapping:
                if options.gpmldapgroup and options.gpmprofile:
                        delGpm(inkdb, options.gpmldapgroup, options.gpmprofile)
                        sys.exit(0)
                else:
                        print "specify --gpm-ldapgroup, --gpm-profile"
                        sys.exit(1)


	if options.printcustomurllist:
		x = PrettyTable(["url", "allowed"])
		_found=False
		profilelist = getProfiles(inkdb)

		for profiles in profilelist:
			for profile in profiles:
				try:
					if str(profile["profile"]).lower() == str(options.printcustomurllist).lower():
						print "FOUND"
						_found = True
					
						customlisttable=profile["list_custom_urls_table_name"]
						_list = getListContent(inkdb,"url",customlisttable)
						for entry in _list:
							x.add_row([entry["url"],entry["allowed"]])
				except:
					pass

		if _found == False:
			print "Profile "+options.printcustomurllist+" not found."
		else:
			print x


		sys.exit(0)


	if options.addcustomurl and options.newentry: 
		_allow = False
		_newentry=options.newentry
		_profilelookedup=options.addcustomurl
		if options.allow == True:
			_allow = True

                _found = False

                _found = False

                profilelist = getProfiles(inkdb)

                for profiles in profilelist:
                        for profile in profiles:
                                try:
                                        if str(profile["profile"]).lower() == str(_profilelookedup).lower():
                                                _found = True
                                                customlisttable=profile["list_custom_urls_table_name"]
                                except:
                                        pass

                if _found == False:
                        print "Profile "+_profilelookedupt+" not found."
                else:
			addListEntry(inkdb, "url", customlisttable, _newentry,_allow)


		sys.exit(0)

        if options.addcustomdomain and options.newentry:
                _allow = False
                _newentry=options.newentry
                _profilelookedup=options.addcustomdomain
                if options.allow == True:
                        _allow = True

                _found = False

                profilelist = getProfiles(inkdb)

                for profiles in profilelist:
                        for profile in profiles:
                                try:
                                        if str(profile["profile"]).lower() == str(_profilelookedup).lower():
                                                _found = True
                                                customlisttable=profile["list_custom_domains_table_name"]
                                except:
                                        pass

                if _found == False:
                        print "Profile "+_profilelookedupt+" not found."
                else:
                        addListEntry(inkdb, "domain", customlisttable, _newentry,_allow)


                sys.exit(0)

        if options.addcustomip and options.newentry:
                _allow = False
                _newentry=options.newentry
                _profilelookedup=options.addcustomip
                if options.allow == True:
                        _allow = True

                _found = False

                profilelist = getProfiles(inkdb)

                for profiles in profilelist:
                        for profile in profiles:
                                try:
                                        if str(profile["profile"]).lower() == str(_profilelookedup).lower():
                                                _found = True
                                                customlisttable=profile["list_custom_ips_table_name"]
                                except:
                                        pass

                if _found == False:
                        print "Profile "+_profilelookedupt+" not found."
                else:
                        addListEntry(inkdb, "ip", customlisttable, _newentry,_allow)


                sys.exit(0)

	if options.delprofile:

		delProfile(inkdb,options.delprofile)

		sys.exit(0)

	if options.createalllisttables:

		createAllListTables(inkdb)

		sys.exit(0)

	if options.addnewprofile:

		if options.addnewprofiledesc and options.addnewprofilemode:

			addNewProfile(inkdb,options.addnewprofile,options.addnewprofiledesc,options.addnewprofilemode)
		
		else:

			print "specify profile desc and profile mode with --new-profile-desc, --new-profile-mode"

		sys.exit(0)

		
        if options.delcustomip and options.delentry:
                _delentry=options.delentry
                _profilelookedup=options.delcustomip

                _found = False

                profilelist = getProfiles(inkdb)

                for profiles in profilelist:
                        for profile in profiles:
                                try:
                                        if str(profile["profile"]).lower() == str(_profilelookedup).lower():
                                                _found = True
                                                customlisttable=profile["list_custom_ips_table_name"]
                                except:
                                        pass

                if _found == False:
                        print "Profile "+_profilelookedupt+" not found."
                else:
                        delListEntry(inkdb, "ip", customlisttable, _delentry)


                sys.exit(0)

        if options.delcustomurl and options.delentry:
                _delentry=options.delentry
                _profilelookedup=options.delcustomurl

                _found = False

                profilelist = getProfiles(inkdb)

                for profiles in profilelist:
                        for profile in profiles:
                                try:
                                        if str(profile["profile"]).lower() == str(_profilelookedup).lower():
                                                _found = True
                                                customlisttable=profile["list_custom_urls_table_name"]
                                except:
                                        pass

                if _found == False:
                        print "Profile "+_profilelookedupt+" not found."
                else:
                        delListEntry(inkdb, "url", customlisttable, _delentry)


                sys.exit(0)

        if options.delcustomdomain and options.delentry:
                _delentry=options.delentry
                _profilelookedup=options.delcustomdomain

                _found = False

                profilelist = getProfiles(inkdb)

                for profiles in profilelist:
                        for profile in profiles:
                                try:
                                        if str(profile["profile"]).lower() == str(_profilelookedup).lower():
                                                _found = True
                                                customlisttable=profile["list_custom_domains_table_name"]
                                except:
                                        pass

                if _found == False:
                        print "Profile "+_profilelookedupt+" not found."
                else:
                        delListEntry(inkdb, "domain", customlisttable, _delentry)


                sys.exit(0)

	


        if options.printcustomdomainlist:
		_found = False
                x = PrettyTable(["domain","allowed"])
                profilelist = getProfiles(inkdb)

                for profiles in profilelist:
                        for profile in profiles:
                                try:
                                        if str(profile["profile"]).lower() == str(options.printcustomdomainlist).lower():
						_found = True
                                                customlisttable=profile["list_custom_domains_table_name"]
                                                _list = getListContent(inkdb,"domain",customlisttable)
                                                for entry in _list:
                                                        x.add_row([entry["domain"],entry["allowed"]])
                                except:
                                        pass

		if _found == False:
			print "Profile "+options.printcustomurllist+" not found."
		else:
			print x


                sys.exit(0)

        if options.printcustomiplist:
		_found = False
                x = PrettyTable(["ip","allowed"])
                profilelist = getProfiles(inkdb)

                for profiles in profilelist:
                        for profile in profiles:
                                try:
                                        if str(profile["profile"]).lower() == str(options.printcustomiplist).lower():
						_found = True
                                                customlisttable=profile["list_custom_ips_table_name"]
                                                _list = getListContent(inkdb,"ip",customlisttable)
                                                for entry in _list:
                                                        x.add_row([entry["ip"],entry["allowed"]])
                                except:
                                        pass

		if _found == False:
			print "Profile "+options.printcustomurllist+" not found."
		else:
			print x


                sys.exit(0)
		
		

	if options.printprofile:
		x = PrettyTable(["profil", "profiledesc", "mode"])
		profilelist = getProfiles(inkdb)
		for profiles in profilelist:
			for profile in profiles:
				try:
					x.add_row([profile["profile"],profile["profiledesc"],profile["mode"]])
				except:
					pass
		print x
		sys.exit(0)

	if options.printuasn:
		x = PrettyTable(["accountname", "profile", "useragentrx", "subnet"])
		uasnlist = getUaSn(inkdb)
                for a in uasnlist:
                    x.add_row([a["accountname"],a["profile"],a["useragentrx"],a["subnet"]])
                print x

		sys.exit(0)



	if options.printaccount:
		if options.account and options.netbiosdomainname:
			x = PrettyTable(["netbiosdomainname", "accountname", "profile", "enabled", "email", "prio"])
			accountlist = getAccounts(inkdb,options.account, options.netbiosdomainname)
	                for a in accountlist:
                        	x.add_row([a["netbiosdomainname"],a["accountname"],a["profile"],a["enabled"],a["email"],a["priority"]])
			print x
			sys.exit(0)
			
		else:
			print "specify --account and --netbiosdomain"
			sys.exit(1)

	if options.printaccounts:
		x = PrettyTable(["netbiosdomainname", "accountname", "profile", "enabled", "email", "prio"])
		accountlist = getAccounts(inkdb,"<ALL>", "<ALL>")
		cnt=0
		for a in accountlist:
			cnt += 1
			x.add_row([a["netbiosdomainname"],a["accountname"],a["profile"],a["enabled"],a["email"],a["priority"]])
		print x
		print "Number of Accounts: "+str(cnt)
		sys.exit(0)

	if options.update_urllist:

		updateUrllist(workdir,inkdb,blacklist_fetch_url_shalla,options.fetch)
		

	if options.update_ad:

		updateAd(workdir,inkdb,options.minaccount)

	
		

	if not options.update_urllist and not options.update_ad:
		printExplain()








	

if __name__ == '__main__':
        main()
