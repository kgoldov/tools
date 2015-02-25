#!/bin/sh

sudo apt-get update

sudo apt-get install mysql-server -y

echo "
 CREATE USER 'kim'@'localhost' IDENTIFIED BY 'kimdb';
 GRANT ALL PRIVILEGES ON *.* TO 'kim'@'localhost';
" | mysql

sudo apt-get install emacs -y
# sudo apt-get install mercurial -y
sudo apt-get install libmysqlclient-dev -y
sudo apt-get install python-mysqldb -y
sudo apt-get install python-dev -y

# sudo apt-get install git -y
# sudo apt-get install unzip -y

sudo apt-get install python-pip -y
sudo apt-get install python-virtualenv -y
sudo pip install virtualenvwrapper


# # For VirtualBox shared folders
# sudo apt-get install dkms

# Install Guest Additions in virtual box
# sudo mount /dev/??? /cdrom
# cd cdrom; sh ./VBoxLinuxAdditions.run
