USER=${USER:-false}

if [[ $USER == 'false' ]]; then
  echo '$USER not set; exiting..'
fi

sudo adduser $USER
sudo mkdir ~/../$USER/.ssh

# This assumes you have id_rsa.pub -- maybe check?

sudo cp id_rsa.pub ~/../$USER/.ssh/authorized_keys
sudo chmod 600 ~/../$USER/.ssh/authorized_keys
sudo chown "${USER}":"${USER}" ~/../$USER/.ssh/authorized_keys
