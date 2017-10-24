#!/bin/bash

echo "*************************************************************"
echo "*************************************************************"
echo 'Updating'

sudo apt-get update

echo "*************************************************************"
echo "*************************************************************"
echo 'Installing Git'
sudo apt-get install -y git

echo "*************************************************************"
echo "*************************************************************" 
echo 'Installing Python and some helpers'
# sudo apt-get install libffi-dev libssl-dev # not sure this is necessary.
sudo apt-get install python-dev python-pip -y
sudo pip install --upgrade pip
sudo pip install --upgrade ipython
sudo pip install --upgrade pyOpenSSL

echo "*************************************************************"
echo "*************************************************************"
echo "Install dev tools"

sudo apt-get install -y emacs

echo "*************************************************************"
echo "*************************************************************"
echo 'Installing virtualenvwrapper'
mkdir -p /home/vagrant/.virtualenvs
sudo pip install --upgrade virtualenvwrapper

cat >> /home/vagrant/.bash_profile << EOF
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

export PATH=$PATH:$HOME/bin:.

export WORKON_HOME=/home/vagrant/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python
export VIRTUALENVWRAPPER_VIRTUALENV=/usr/local/bin/virtualenv
source /usr/local/bin/virtualenvwrapper.sh
EOF

source /home/vagrant/.bash_profile && mkvirtualenv junk
echo 'workon junk' >> /home/vagrant/.bash_profile

source /home/vagrant/.bash_profile

# Install Chrome
#Add Key:
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -

#Set repository:
echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list

#Install package:
sudo apt-get update 
sudo apt-get install google-chrome-stable

# Node JS
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install -y nodejs