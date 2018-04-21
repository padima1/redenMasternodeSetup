#!/bin/bash
clear
echo "Make sure you double check before hitting enter! Only one shot at these!"

read -e -p "Server IP Address : " ip
read -e -p "Masternode Private Key (e.g. 7rVTLnLh9GFFrwFrudxMNcikVbf3uQTwH7PrqhTxdWzUfGtdC9f # THE KEY YOU GENERATED EARLIER) : " key

clear
"Updating system and installing required packages..."
sleep 5

# update packages and upgrade Ubuntu
cd ~
sudo apt-get update -y && apt-get upgrade -y && apt-get autoremove -y
sudo apt-get -y install wget nano htop git
sudo apt-get -y install libzmq3-dev
sudo apt-get -y install libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev
sudo apt-get -y install libevent-dev

sudo apt -y install software-properties-common

sudo add-apt-repository ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get -y install libdb4.8-dev libdb4.8++-dev

sudo apt-get -y install libminiupnpc-dev

sudo apt-get -y install fail2ban
sudo service fail2ban restart

sudo apt-get install ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 13058/tcp
sudo ufw --force enable

#Generating Random Passwords
password=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
password2=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

#Installing Daemon
cd ~
sudo rm reden_ubuntu16_1.0.0_linux.gz
wget https://github.com/NicholasAdmin/Reden/releases/download/Wallet/reden_ubuntu16_1.0.0_linux.gz
sudo tar -xzvf reden_ubuntu16_1.0.0_linux.gz --strip-components 1 --directory /usr/bin
sudo rm reden_ubuntu16_1.0.0_linux.gz

sudo chmod 775 /usr/bin/redend
sudo chmod 775 /usr/bin/reden-cli

#Starting daemon first time
redend -daemon
echo "sleep for 10 seconds..."
sleep 10
reden-cli stop

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

masternode=1
masternodeprivkey='$key'

addnode=45.76.127.252
addnode=35.178.15.243
' | sudo -E tee ~/.redencore/reden.conf >/dev/null 2>&1

#Starting daemon second time
redend

sleep 10

#Starting coin
(
  crontab -l 2>/dev/null
  echo '@reboot sleep 30 && redend'
) | crontab

echo "Coin setup complete."

cd ~

echo "Now, you need to finally issue a start command for your masternode in the following order:"
echo "1) Wait for the node wallet on this VPS to sync with other nodes on the network. Eventually the IsSynced status will change to 'true'. It may take several minutes."
echo "2) Go to your windows wallet (hot wallet with your Reden funds) and from debug console (Tools->Debug Console) enter:"
echo "    masternode start-alias <mymnalias>"
echo "where <mymnalias> is the name of your masternode alias (without brackets) as it was entered in the masternode.conf file."
echo "once completed please return to this VPS console and wait for the masternode status to change to 'Started'. This will indicate that your masternode is fully functional."
echo ""
echo "Your masternode is currently syncing in the background. When you press a key to continue, this message will self-destruct, so please memorize it!"
echo "The following screen will display current status of this masternode and it's synchronization progress. The data will update in real time every 10 seconds. You can interrupt it at any moment by Ctrl-C."
echo ""
echo "If you found this script and MN setup guide helpful, please donate REDEN to: RCdYg5yq3YfymwrZi8EMBSFHxcwR7acniS"
read -p "Press any key to continue... " -n1 -s

watch -n 10 'reden-cli masternode status && reden-cli mnsync status'


