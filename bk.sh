#!/bin/bash

##
# 2010, Nikos Vasilakis
# n.c.vasilakis@gmail.com
#
# Script  that  keeps  weekly  backups  of  the  edutubeplus  subversion
# repository. It is meant to be called via cron.
#
# Usage: ./bk.sh
#
# TODO:  *  make incremental backups (delta), handle multiple targets
##

cp -R /usr/local/svn/edutubeplus /home/etp/bk/repos
echo "|EduTubePlus LS Tool Backup|" > /home/etp/bk/repos/info.txt
echo "`date`" >> /home/etp/bk/repos/info.txt
echo " - " >> /home/etp/bk/repos/info.txt
sudo svn checkout --username=nvasilakis --password=pitsa http://etpsrv.cti.gr/svn/etp /var/www/build/v2
svn info /var/www/build/v2  >> /home/etp/bk/repos/info.txt
tar -pczf etp-repos-bk.tar.gz /home/etp/bk/repos
mv etp-repos-bk.tar.gz /var/www
