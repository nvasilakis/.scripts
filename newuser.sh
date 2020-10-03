NUSER=${NUSER:-false}

if [[ $NUSER == 'false' ]]; then
  echo '$NUSER not set; exiting..'
fi

sudo adduser $NUSER
sudo mkdir ~/../$NUSER/.ssh

# This assumes you have id_rsa.pub -- maybe check?
sudo mkdir ../$NUSER/.ssh
sudo cp $NUSER.pub ~/../$NUSER/.ssh/authorized_keys
sudo chmod 600 ~/../$NUSER/.ssh/authorized_keys
sudo chown "${NUSER}":"${NUSER}" ~/../$NUSER/.ssh/authorized_keys
