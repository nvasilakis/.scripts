##############################################
#
# Supporting Script for Hudson Build Files.
#
# It generates a web page presenting the 
# build results, revision numbers and latest
# stats, in order for external teams to coop
#
# Author:  basilakn@cti.gr
# Version: 0.2
##############################################

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
