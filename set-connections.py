import xml.etree.ElementTree
import os
from shutil import copyfile

def merge_two_dicts(x, y):
    z = x.copy()
    z.update(y)
    return z

# ---------------------------------------------
#  context.xml
# ---------------------------------------------

# CONSTANTS
DEFAULT_PROPS = {
  "validationQuery": "select 1"
}
hotfile = 'tomcat/webapps/pentaho/META-INF/context.xml'
bkpfile = 'tomcat/webapps/pentaho/META-INF/context.xml.BKP'
DB_NAMES_MAP = {
  "jdbc/Hibernate" : "${PENTAHO_REPO_JDBC_URL_HIBERNATE}",
  "jdbc/Audit" : "${PENTAHO_REPO_JDBC_URL_HIBERNATE}",
  "jdbc/Quartz" : "${PENTAHO_REPO_JDBC_URL_QUARTZ}",
  "jdbc/PDI_Operations_Mart" : "${PENTAHO_REPO_JDBC_URL_HIBERNATE}",
  "jdbc/pentaho_operations_mart" : "${PENTAHO_REPO_JDBC_URL_HIBERNATE}",
  "jdbc/live_logging_info" : "${PENTAHO_REPO_JDBC_URL_HIBERNATE}?searchpath=pentaho_dilogs",
}

# Makes a backup from the first time run
if not os.path.isfile(bkpfile):
  copyfile(hotfile, bkpfile)

# XML Parsing
tree = xml.etree.ElementTree.parse(bkpfile)
root = tree.getroot()

# Replaces all occurrences from  
for res in tree.findall("Resource"):
  res.set("url", DB_NAMES_MAP[res.attrib["name"]])
  res.set("username", "${PENTAHO_REPO_USERNAME}")
  res.set("password", "${PENTAHO_REPO_PASSWORD}")
  res.set("driverClassName", "${PENTAHO_REPO_JDBC_CLASS}")
  for extraProp in DEFAULT_PROPS.keys():
    res.set(extraProp, DEFAULT_PROPS[extraProp])

# Write back to file
tree.write(hotfile, xml_declaration=True, encoding="UTF-8")

# ---------------------------------------------
#  jackrabbit/repository.xml
# ---------------------------------------------

jcrhotfile = 'pentaho-solutions/system/jackrabbit/repository.xml'
jcrbkpfile = 'pentaho-solutions/system/jackrabbit/repository.xml.BKP'
jcrCommonTags = {
  "driver": "${PENTAHO_REPO_JDBC_CLASS}",
  "url": "${PENTAHO_REPO_JDBC_URL_JCR}",
  "user": "${PENTAHO_REPO_USERNAME}",
  "password": "${PENTAHO_REPO_PASSWORD}"
}
jcrTags = {
  "/FileSystem" : {
    "class": "org.apache.jackrabbit.core.fs.db.DbFileSystem",
    "schemaObjectPrefix": "fs_repos_",
    "schema": "postgresql"
  }, 
  "/Workspace/FileSystem" : {
    "class": "org.apache.jackrabbit.core.fs.db.DbFileSystem",
    "schemaObjectPrefix": "fs_ws_",
    "schema": "postgresql"
  }, 
  "/Versioning/FileSystem" : {
    "class": "org.apache.jackrabbit.core.fs.db.DbFileSystem",
    "schemaObjectPrefix": "pm_ver_",
    "schema": "postgresql"
  }, 
  "/DataStore": {
    "class": "org.apache.jackrabbit.core.data.db.DbDataStore",
    "schemaObjectPrefix": "ds_repos_",
    "databaseType": "postgresql",
    "minRecordLength": "1024",
    "maxConnections": "3",
    "copyWhenReading": "true",
    "tablePrefix": ""
  }, 
  "/Workspace/PersistenceManager": {
    "class": "org.apache.jackrabbit.core.persistence.bundle.PostgreSQLPersistenceManager",
    "schema": "postgresql",
    "schemaObjectPrefix": "${wsp.name}_pm_ws_"
  }, 
  "/Versioning/PersistenceManager": {
    "class": "org.apache.jackrabbit.core.persistence.bundle.PostgreSQLPersistenceManager",
    "schema": "postgresql",
    "schemaObjectPrefix": "pm_ver_"
  }, 
  "/Cluster/Journal": {
    "class": "org.apache.jackrabbit.core.journal.DatabaseJournal",
    "revision": "${rep.home}/revision.log",
    "schema": "postgresql",
    "schemaObjectPrefix": "cl_j_",
    "janitorEnabled": "true",
    "janitorSleep": "86400",
    "janitorFirstRunHourOfDay": "3"
  }
}

# Makes a backup from the first time run
if not os.path.isfile(jcrbkpfile):
  copyfile(jcrhotfile, jcrbkpfile)

# XML Parsing
jcrtree = xml.etree.ElementTree.parse(jcrbkpfile)
relevantTags = []
for tag in jcrTags.keys():
  root = jcrtree.getroot()
  elmt = root.find("./"+tag)
  elmt.clear()
  props = merge_two_dicts(jcrTags[tag], jcrCommonTags)
  
  elmt.set("class", props.pop("class"))
  for propKey in props:
    xml.etree.ElementTree.SubElement(elmt, "param", {"name": propKey, "value": props[propKey]})

# Write back to file
jcrtree.write(jcrhotfile, xml_declaration=True, encoding="UTF-8")
