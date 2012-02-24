#!/bin/bash

# A simple script to create git repos
if [[ $1 == "" ]]; then
  echo " You have to provide the name of the repository"
  echo "$0 <repository name>"
  exit -1;
fi

iPath="/usr/local/git/$1";
echo "creating repository in $iPath"
mkdir $iPath;
cd $iPath;
git init --bare;
cp $iPath/hooks/post-update.sample $iPath/hooks/post-update;
chmod +x $iPath/hooks/post-update;
cd ..;
chown -R www-data:www-data $1;

echo "configuring apache for $1 project"
cat >> /etc/apache2/httpd.conf << EOFAPACHECONF
<Location /projects/$1>
  AuthType Basic
  AuthName "Private Git Access"
  AuthUserFile /etc/apache2/.passwd-files/$1.passwd
  Require valid-user
</Location>
EOFAPACHECONF

touch /etc/apache2/.passwd-files/$1.passwd
echo "please add project user or EXIT"
username="";
until [[ $username == "EXIT" ]]; do
  read username;
  case $username in
    "EXIT")
      echo "exiting.."
      ;;
    "")
      echo "no input!"
      ;;
    *)
      htpasswd /etc/apache2/.passwd-files/$1.passwd $username;
  esac
  #if [[ $username != "EXIT" -a $username !="" ]]; then
  #  echo $username;
  #  # htpasswd /etc/apache2/.passwd-files/$1.passwd;
  #fi
done

echo "restarting apache.."
/etc/init.d/apache2 restart;
