#!/bin/bash
clear
if false; then
echo "REDEN Masternode setup script will detect your Public IP Address\n
and generate masternode Private Key automatically!\n\n
Updating system and installing required packages...\n"
sleep 3

Port='13058'

# update packages and upgrade Ubuntu
cd ~
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get dist-upgrade -y
sudo apt-get -y autoremove
sudo apt-get -y install wget nano htop git jq
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
sudo ufw allow $Port/tcp
sudo ufw --force enable


#Generating Random Password
rpcpassword=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

#Find Server Public IP Address
PublicIP=$(dig +short myip.opendns.com @resolver1.opendns.com)

#Create 2GB swap file
if [ ! -f /var/swap.img ]; then
	echo 'Create 2GB disk swap file...'
	free -h
	cd /var
	touch swap.img
	chmod 600 swap.img
	dd if=/dev/zero of=/var/swap.img bs=1024k count=2000
	mkswap /var/swap.img
	swapon /var/swap.img
	echo “/var/swap.img none swap sw 0 0” >> /etc/fstab 
	free -h
fi

#Installing Daemon
cd ~
#sudo rm reden_ubuntu16_1.0.0_linux.gz
#wget https://github.com/NicholasAdmin/Reden/releases/download/Wallet/reden_ubuntu16_1.0.0_linux.gz
#sudo tar -xzvf reden_ubuntu16_1.0.0_linux.gz --strip-components 1 --directory /usr/bin
#sudo rm reden_ubuntu16_1.0.0_linux.gz

# Copy binaries to /usr/bin
sudo cp RedenMasternodeSetup/Reden-v1.0-Ubuntu16.04/reden* /usr/bin/ > /dev/null

sudo chmod 755 /usr/bin/reden*

#Stop daemon if it's already running
if pgrep -x 'redend' > /dev/null; then
	reden-cli stop
	echo 'sleep for 10 seconds...'
	sleep 10
fi

#Create reden.conf
if [ ! -f ~/.redencore/reden.conf ]; then 
	sudo mkdir ~/.redencore
fi

echo 'Creating reden.conf...'
cat <<EOF > ~/.redencore/reden.conf
rpcuser=redenrpc
rpcpassword=$rpcpassword
EOF

sudo chmod 755 -R ~/.redencore/reden.conf

#Starting daemon first time
redend -daemon
echo 'sleep for 10 seconds...'
sleep 10

#Generate masternode private key
echo 'Generating masternode key...'
genkey=$(reden-cli masternode genkey)
reden-cli stop

cat <<EOF > ~/.redencore/reden.conf
rpcuser=redenrpc
rpcpassword=$rpcpassword
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
maxconnections=256
externalip=$PublicIP
masternode=1
masternodeprivkey=$genkey
EOF

#Starting daemon second time
redend
echo 'sleep for 10 seconds...'
sleep 10

#Setting auto star for daemon
echo 'Configuring crontab job...'
cronjob='@reboot sleep 30 && redenddd'
crontab -l > tempcron
if ! grep -q "$cronjob" tempcron; then
	echo $cronstr >> tempcron
	crontab tempcron
fi
rm tempcron

#clear

echo "========================================================================\n
Masternode setup complete!\n
========================================================================\n
\n
Masternode was installed with VPS IP Address: $PublicIP\n
\n
Masternode Private Key: $genkey\n
\n
Now you can add the following string to the masternode.conf file\n
for your Hot Wallet (the wallet with your Reden collateral funds):\n
========================================================================\n"
echo "mn1 $PublicIP:$Port $genkey TxId TxIdx"
echo "========================================================================\n
\n
    Use your mouse to copy the whole string above into the clipboard by\n
    tripple-click + single-click and paste it into your masternodes.conf\n
    Then replace:\n
        'mn1' - with your desired masternode name (alias)\n
        'TxId' - with Transaction Id from masternode outputs\n
        'TxIdx' - with Transaction Index (0 or 1)\n
         Remember to save the masternode.conf and restart the wallet!\n
    \n
    To introduce your new masternode to the Reden network, you need to
    issue a masternode start command from your wallet, which proves that\n
    the collateral for this node is secured.\n
    \n
    1) Wait for the node wallet on this VPS to sync with the other nodes\n
    on the network. Eventually the 'IsSynced' status will change\n
    to 'true', which will indicate a comlete sync, although it may take\n
    from several minutes to several hours depending on the network state.\n
    Your initial Masternode Status may read:\n
        'Node just started, not yet activated' or\n
        'Node  is not in masternode list', which is normal and expected.\n
    \n
    2) Wait at least until 'IsBlockchainSynced' status becomes 'true'.\n
    At this point you can go to your wallet and issue a start\n
    command by either using Debug Console:\n
        Tools->Debug Console-> enter: masternode start-alias mn1\n
        where 'mn1' is the name of your masternode (alias)\n
        as it was entered in the masternode.conf file\n
        \n
    or by using wallet GUI:\n
        Masternodes -> Select masternode -> RightClick -> start alias\n
    \n
    Once completed step (2), return to this VPS console and wait for the\n
    Masternode Status to change to: 'Masternode successfully started'.\n
    This will indicate that your masternode is fully functional and\n
    you can celebrate this achievement!\n
    \n
    Currently your masternode is syncing with the Reden network...\n
    Once you press any key to continue, this message will self-destruct!\n
    Take a moment to re-read it now if anything is not clear...\n
    \n
    The following screen will display in real-time the list of\n
    peer connections, the status of your masternode,\n
    node synchronization status and additional network and node stats.
    \n"
fi
read -p "*** Press any key to continue ***" -n1 -s

echo "...scroll up to previous screens...\n\n
Here are some useful commands and tools for troubleshooting:\n
\n
========================================================================\n
To view Redend debug log showing all MN network activity in realtime:\n
\n
tail -f ~/.redencore/debug.log \n
\n
========================================================================\n
To view masternode configuration produced by this script in reden.conf:\n
\n
cat ~/.redencore/reden.conf
\n
NOTE: To edit reden.conf, first stop the redend daemon and start it when finished:
eden-cli stop\n
nano ~/.redencore/reden.conf\n
edend\n
\n
========================================================================\n
To monitor system resource utilization and running processes:\n
htop\n
========================================================================\n
To view in real-time the list of peer connections, the status of your 
masternode, sync status etc., copy-paste the whole code block below:\n\n

watch -n 1 \"\
echo '\nOutbound connections to peer nodes:\n' && \
reden-cli getpeerinfo | jq -r '.[] | select(.inbound==false) | \
[.addr, .pingtime, .bytessent, .bytesrecv, .startingheight, \
.synced_headers, .synced_blocks, .banscore] | @tsv' && \
echo '\nMasternode Status:' &&  reden-cli masternode status && \
echo '\nSync Status:' &&  reden-cli mnsync status && \
echo '\nCurrent Masternode Information:' && reden-cli getinfo && \
echo '\n\nPress Ctrl-C to Exit...'\"\
\n\n\
reden.conf generated by this script located in ~/.redencore directory:\n
========================================================================"
cat ~/.redencore/reden.conf
echo "\
========================================================================\n
\n\n
Thanks for using Reden masternode setup script!
If you found it helpful, please donate REDEN to:
RCdYg5yq3YfymwrZi8EMBSFHxcwR7acniS\n
\n
Enjoy your Reden Masternode and check back for updates!"

watch -n 1 "echo 'Outbound connections to peer nodes:\n' && 
reden-cli getpeerinfo | jq -r '.[] | select(.inbound==false) | \
[.addr, .pingtime, .bytessent, .bytesrecv, .startingheight, .synced_headers, .synced_blocks, .banscore] | @tsv' && \
echo '\nMasternode Status:' &&  reden-cli masternode status && \
echo '\nSync Status:' &&  reden-cli mnsync status && \
echo '\nCurrent Masternode Information:' && reden-cli getinfo && \
echo '\n\nPress Ctrl-C to Exit...'"
