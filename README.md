# ink

## Quickstart

apt-get install apt-get install postgresql-9[x]

apt-get install python-prettytable python-ldap python-pygresql python-netaddr

ink-manage.py --help-setup

su - postgres

psql

CREATE ROLE inkquerier;
CREATE ROLE inkupdater;
ALTER ROLE inkquerier WITH NOSUPERUSER NOINHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION CONNECTION LIMIT 500 PASSWORD 'YOURPASSHERE' VALID UNTIL 'infinity';
ALTER ROLE inkupdater WITH SUPERUSER NOINHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION CONNECTION LIMIT 2 PASSWORD 'YOURSUPERPASSHERE' VALID UNTIL 'infinity';

\q


ink-manage.py --create-database=/tmp/ink.sql

or

psql < /tmp/ink.sql

psql

postgres=# \c ink
You are now connected to database "ink" as user "postgres".
ink=# \dt
                       List of relations
 Schema |               Name                | Type  |  Owner   
--------+-----------------------------------+-------+----------
 public | accounts                          | table | postgres
 public | cfg_activedirectory               | table | postgres
 public | cfg_activedirectory_group_profile | table | postgres
 public | cfg_categories                    | table | postgres
 public | cfg_profile_category_link         | table | postgres
 public | profiles                          | table | postgres
 public | temp_accounts                     | table | postgres
 public | useragents                        | table | postgres
 
 \q
 
 exit
 
 ink-manage.py --write-example-config 
 
 change /etc/ink/ink.cfg
 
 run 
 
 ink-manage.py --help
 
 and 
 
 ink-manage.py --help-examples
 
 
 
 

