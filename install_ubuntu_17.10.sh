#!/bin/bash
clear

STRING1="Make sure you double check before hitting enter! Only one shot at these!"
STRING2="If you found this helpful, please donate to EDEN Donation: "
STRING3="EbShbYatMRezVTWJK9AouFWzczkTz5zvYQ"
STRING4="Updating system and installing required packages..."
STRING5="Switching to Aptitude"
STRING6="Some optional installs"
STRING7="Starting your masternode"
STRING8="Now, you need to finally start your masternode in the following order:"
STRING9="Go to your windows wallet and from the Control wallet debug console please enter"
STRING10="masternode start-alias <mymnalias>"
STRING11="where <mymnalias> is the name of your masternode alias (without brackets)"
STRING12="once completed please return to VPS and press the space bar"
STRING13=""
STRING14="Please Wait a minimum of 5 minutes before proceeding, the node wallet must be synced"

echo $STRING1

read -e -p "Server IP Address : " ip
read -e -p "Masternode Private Key (e.g. 7rVTLnLh9GFFrwFrudxMNcikVbf3uQTwH7PrqhTxdWzUfGtdC9f # THE KEY YOU GENERATED EARLIER) : " key
#read -e -p "Install Fail2ban? [Y/n] : " install_fail2ban
#read -e -p "Install UFW and configure ports? [Y/n] : " UFW

clear
echo $STRING2
echo $STRING13
echo $STRING3
echo $STRING13
echo $STRING4
sleep 10

# update package and upgrade Ubuntu
cd ~
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y autoremove
sudo apt-get install wget nano htop -y
sudo apt-get install build-essential -y && sudo apt-get install libtool autotools-dev autoconf automake -y && sudo apt-get install libssl-dev -y && sudo apt-get install libboost-all-dev -y && sudo apt install software-properties-common -y && sudo add-apt-repository ppa:bitcoin/bitcoin -y && sudo apt update -y && sudo apt-get install libdb4.8-dev -y && sudo apt-get install libdb4.8++-dev -y && sudo apt-get install libminiupnpc-dev -y && sudo apt-get install libqt4-dev libprotobuf-dev protobuf-compiler -y && sudo apt-get install libqrencode-dev -y && sudo apt-get install -y git -y && sudo apt-get install pkg-config -y
sudo apt-get -y install libzmq3-dev
clear
echo $STRING5
sudo apt-get -y install aptitude

#Generating Random Passwords
password=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
password2=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

echo $STRING6
#if [[ ("$install_fail2ban" == "y" || "$install_fail2ban" == "Y" || "$install_fail2ban" == "") ]]; then
  cd ~
  sudo aptitude -y install fail2ban
  sudo service fail2ban restart
#fi
#if [[ ("$UFW" == "y" || "$UFW" == "Y" || "$UFW" == "") ]]; then
  sudo apt-get install ufw
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw allow ssh
  sudo ufw allow 3595/tcp
  sudo ufw --force enable
#fi

#Install Daemon
#wget https://github.com/NicholasAdmin/EDEN/releases/download/Linux/eden-ubu1604.tar.gz
#sudo tar -xzvf eden-ubu1604.tar.gz --directory /usr/bin
#sudo rm eden-ubu1604.tar.gz
sudo cp -v ~/EDEN-MN-SETUP/Eden-v1.0.0.1-ubuntu16/edend /usr/bin/
sudo cp -v ~/EDEN-MN-SETUP/Eden-v1.0.0.1-ubuntu16/eden-cli /usr/bin/
chmod +x /usr/bin/edend
chmod +x /usr/bin/eden-cli

#Start Daemon so it will create coin directory (~/.eden)
edend -daemon

echo "sleep for 30 seconds..."
sleep 30

#Stop Daemon
eden-cli stop

echo "sleep for 30 seconds..."
sleep 30

#Setting up coin
echo "Setting up coin..."
echo $STRING13
echo $STRING3
echo $STRING13
echo $STRING4
sleep 10

#Create eden.conf
echo '
rpcuser='$password'
rpcpassword='$password2'
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
logtimestamps=1
maxconnections=32
externalip='$ip'
bind='$ip':3595
masternodeprivkey='$key'
masternode=1
addnode=45.76.12.139
addnode=144.202.81.111
' | sudo -E tee ~/.eden/eden.conf >/dev/null 2>&1
sudo chmod 0600 ~/.eden/eden.conf

#Starting coin
(
  crontab -l 2>/dev/null
  echo '@reboot sleep 30 && edend'
) | crontab
(
  crontab -l 2>/dev/null
  echo '* * * * * eden-cli sentinelping 1.1.0'
) | crontab

echo "Coin setup complete."

cd ~

#Start Daemon with newly created conf file (daemon=1)
edend

echo $STRING2
echo $STRING13
echo $STRING3
echo $STRING13
sleep 10
echo $STRING7
echo $STRING13
echo $STRING8
echo $STRING13
echo $STRING9
echo $STRING13
echo $STRING10
echo $STRING13
echo $STRING11
echo $STRING13
echo $STRING12
echo $STRING14
sleep 5m

read -p "Press any key to continue... " -n1 -s
eden-cli masternode start
eden-cli masternode status
