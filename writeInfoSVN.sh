#!/bin/bash

##
# 2010, Nikos Vasilakis
# n.c.vasilakis@gmail.com
#
# A tiny reporting automation script. It generates a web page presenting
# the build  results, revision  numbers and latest  stats, in  order for
# external teams  to cooperate based  on latest revision  statistics. It
# needs two  "raw" files to  theme the output: i1  and i2. These  can be
# thought as the html header and footer.
#
# It  is  an  automation  script  for  use  with  continues  integration
# environments like Hudson/Jenkins.
#
# Usage: ./writeInfoSVN.sh
#
# TODO:  *  Output also xml and better formatted html.
##

# Set env variable
export JAVA_HOME="/usr/lib/jvm/jdk1.6.0_21"

# This is the root folder.
cd /var/www/build;

# Starting script
 pwd

# Check out latest revision.
svn co http://etpsrv.cti.gr/svn/etp --username=nvasilakis --password=pitsa
cd etp;
echo "<pre>" > web/etp/index.html
svn info --revision HEAD --username=nvasilakis --password=pitsa >> web/etp/index.html
echo "</pre>" >> web/etp/index.html;
svn info --revision HEAD --username=nvasilakis --password=pitsa >> web/etp/components/build.properties

# Build 3 required WAR instances
ant send-apache -DbuildOption=etpPROD;
ant send-apache -DbuildOption=etpDEV;
ant send-ftp -DbuildOption=etpDEV -DftpU=nvasilakis -DftpP=test;
ant send-apache -DbuildOption=etpRACTI;

cd ..
# Create the report file
cat i1 > index.html
svn info etp/ --revision HEAD --username=nvasilakis --password=pitsa >> index.html
cat i2 >> index.html

# Delete all resources
#rm etp/ -Rf;
