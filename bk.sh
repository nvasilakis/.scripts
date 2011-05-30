#!/bin/bash
# File: Script that keeps weekly bk
#	of the edutubeplus svn repo.
#	http://etpsrv.cti.gr/svn/etp
# Author: Nikos Vasilakis	
# email:  n.c.vasilakis@gmail.com	

cp -R /usr/local/svn/edutubeplus /home/etp/bk/repos
echo "|EduTubePlus LS Tool Backup|" > /home/etp/bk/repos/info.txt
echo "`date`" >> /home/etp/bk/repos/info.txt
echo " - " >> /home/etp/bk/repos/info.txt
sudo svn checkout --username=nvasilakis --password=pitsa http://etpsrv.cti.gr/svn/etp /var/www/build/v2
svn info /var/www/build/v2  >> /home/etp/bk/repos/info.txt
tar -pczf etp-repos-bk.tar.gz /home/etp/bk/repos
mv etp-repos-bk.tar.gz /var/www
