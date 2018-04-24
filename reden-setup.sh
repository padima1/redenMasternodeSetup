#!/bin/bash
clear
echo "Make sure you double check before hitting enter! Only one shot at these!"

read -t 1 -n 10000 discard 
read -e -p "Server IP Address : " ip
read -t 1 -n 10000 discard 
read -e -p "Masternode Private Key (e.g. 28L11p9KSUQMyw5z6QYay8q68WnNxuH5BbeyAhWutwav1TSNC4S # THE KEY YOU GENERATED EARLIER) : " key

clear
echo "Updating system and installing required packages..."
sleep 5

# update packages and upgrade Ubuntu
cd ~
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get dist-upgrade -y
sudo apt-get -y autoremove
sudo apt-get -y install wget nano htop git
sudo apt-get -y install libzmq3-dev
sudo apt-get -y install libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev
sudo apt-get -y install libevent-dev

sudo apt -y install software-properties-common

sudo add-apt-repository ppa:bitcoin/bitcoin -y
sudo apt-get -y update
sudo apt-get -y install libdb4.8-dev libdb4.8++-dev

sudo apt-get -y install libminiupnpc-dev

sudo apt-get -y install fail2ban
sudo service fail2ban restart

sudo apt-get install ufw -y
sudo apt-get update -y

sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 13058/tcp
sudo ufw --force enable

#Generating Random Password
rpcpassword=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

#Find Server Public IP Address
PublicIP=$(curl ifconfig.co)

Port='13058'

#Create 2GB swap file
echo 'Create 2GB disk swap...'
free -h
cd /var
touch swap.img
chmod 600 swap.img
dd if=/dev/zero of=/var/swap.img bs=1024k count=2000
mkswap /var/swap.img
swapon /var/swap.img
echo “/var/swap.img none swap sw 0 0” >> /etc/fstab 
free -h

#Installing Daemon
cd ~
#sudo rm reden_ubuntu16_1.0.0_linux.gz
#wget https://github.com/NicholasAdmin/Reden/releases/download/Wallet/reden_ubuntu16_1.0.0_linux.gz
#sudo tar -xzvf reden_ubuntu16_1.0.0_linux.gz --strip-components 1 --directory /usr/bin
#sudo rm reden_ubuntu16_1.0.0_linux.gz

# Copy binaries to /usr/bin
sudo cp RedenMasternodeSetup/Reden-v1.0-Ubuntu16.04/reden* /usr/bin/

sudo chmod 755 /usr/bin/reden*

#Stop daemon if it's already running
reden-cli stop
sleep 30

#Create reden.conf
sudo mkdir ~/.redencore

cat <<EOF > ~/.redencore/reden.conf
rpcuser=redenrpc
rpcpassword='$rpcpassword'
EOF

sudo chmod 755 -R ~/.redencore/reden.conf

#Starting daemon first time
redend -daemon
echo 'sleep for 10 seconds...'
sleep 10

#Generate masternode private key
genkey=$(reden-cli masternode genkey)
reden-cli stop

cat <<EOF > ~/.redencore/reden.conf
rpcuser=redenrpc
rpcpassword='$rpcpassword'
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
logtimestamps=1
maxconnections=256
externalip='$PublicIP'
masternode=1
masternodeprivkey='$genkey'
EOF

#Starting daemon second time
redend
sleep 10

#Setting auto star for daemon
crontab -l > tempcron
echo '@reboot sleep 30 && redend' >> tempcron
crontab tempcron
rm tempcron

cd ~

clear

echo "Coin setup complete..."
echo ""
echo "Masternode installed with VPS IP Address: $PublicIP"
echo "Masternode Private Key: $genkey"
echo "Now, you need to add the following string to the masternode.conf file of your Hot Wallet (the wallet with your Reden funds):"
echo ""
echo "mn1 $PublicIP:$Port $genkey TxId TxIdx"
echo ""
echo "Copy the string above by selecting with mouse followed by Left-Click (Do Not use Ctrl-C) and paste into your masternodes.conf file, then replace mn1 with your desired masternode name TxId with Transaction Id from masternode outputs and TxIdx with Transaction index (0 or 1). Save masternode.conf and restart the wallet."
echo ""
sleep 10
echo "Finally issue a start command for your masternode in the following order:"
echo "1) Wait for the node wallet on this VPS to sync with other nodes on the network. Eventually the IsSynced status will change to 'true'. It may take from several minutes to hours. Initial status may read '...not in masternode list', which is normal."
echo "2) Go to your hot wallet and from debug console (Tools->Debug Console) enter:"
echo ""
echo "    masternode start-alias <mymnalias>"
echo ""
echo "where <mymnalias> is the name of your masternode alias (without brackets) as it was entered in the masternode.conf file."
echo "once completed please return to this VPS console and wait for the masternode status to change to 'Started'. This will indicate that your masternode is fully functional."
echo ""
echo "Your masternode is currently syncing in the background. When you press a key to continue, this message will self-destruct, so please memorize it!"
echo "The following screen will display current status of this masternode and it's synchronization progress. The data will update in real time every 10 seconds. You can interrupt it at any moment by Ctrl-C."
echo ""
echo ""

read -p "Press any key to continue... " -n1 -s
cd ~

echo ""
echo "Here are some useful tools and commands for troubleshooting your masternode:"
echo "(copy/paste without $)"
echo ""
echo "Redend debug log showing all MN network activity in real time:"
echo "$ tail -f ~/.redencore/debug.log"
echo ""
echo "To monitor HW and system resource utilization and running processes:"
echo "$ htop "
echo ""
echo "To monitor MN state and its sync status:"
echo "$ watch -n 10 'reden-cli masternode status && reden-cli mnsync status'"
echo ""
echo "If you found this script and MN setup guide helpful, please donate REDEN to: RCdYg5yq3YfymwrZi8EMBSFHxcwR7acniS"

watch -n 10 'reden-cli masternode status && reden-cli mnsync status && reden-cli getinfo'

