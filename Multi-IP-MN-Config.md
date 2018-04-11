## Running More Than One Reden Masternode Daemon On Same VPS is Not Recommended, Not Endorsed and Not Supported by Reden team!

NOTE: This process is more involving than the regular MN setup and is geared towards more experienced Linux user. This guide is provided as is with no warranties of any kind. 

The objective of this configuration is to consolidate masternodes into fewer number of servers hosting them. Each instance of a masternode requires one dedicated static IP address, for which Vultr charges $2/mo on $5/mo VPS SKU. The limit is two additional Ips per VPS. So, in total you would be able to run three masternodes per VPS (possibly more on bigger servers).

**Prerequisities**

```bash
- What you need to know: What is an IP address; how to perform basic text editing and file operations in Linux
- At least one masternode successfully deployed and running on VPS @ Vultr (Ubuntu 16.04 $5/mo 1xCPU/1GB RAM/25GB SSD)
```

If you dont yet have a masternode running successfully on Vultr VPS, refer to the Setup Guide, deploy one VPS and perform scripted installation per guide. If you are new to Vultr, feel free to use my afilliate link: https://www.vultr.com/?ref=7363317

Masternode requires its own individual daemon with its own data directory and eden.conf file. The approach is to create several home folders (one for each masternode) and configure settings by entering IP addresses and private keys manually into each eden.conf file. Config templates are provided below.

As the result you will create up to two more home folders and two more copies of the daemon binary. Cron jobs will be added to perform automatic startup upon reboot and periodic sentinel pingig.

**Steps:**

0) In Vultr control panel go into Settings tab for your VPS and add up to two additional IPv4 addresses

1) While still on Settings/Public Network page, click on Need assistance? View our networking configuration tips and examples. Scroll down and copy into clipboard the section of the sample network configuration called Ubuntu 16.xx, Ubuntu 17.04 which may look like example below. It contains your actual IP addresses and interfaces and you don't have to change anything in it.

```bash

auto lo
iface lo inet loopback

auto ens3
iface ens3 inet static
	address 45.76.240.188
	netmask 255.255.254.0
	gateway 45.76.240.1
	dns-nameservers 108.61.10.10
	post-up ip route add 169.254.0.0/16 dev ens3

auto ens3:1
iface ens3:1 inet static
	address 45.63.34.190
	netmask 255.255.254.0

auto ens3:2
iface ens3:2 inet static
	address 144.202.87.177
	netmask 255.255.254.0
```

2) Connect to your VPS via PuTTY as root. Navigate to /etc/network and edit 'interfaces' text file after renaming existing one to interfaces_old. Paste the configuration text you copied from Vultr control panel into now empty new 'interfaces' file. 

```bash
cd /etc/network
sudo mv interfaces interfaces_old
sudo nano interfaces
```

__Save the changes by exiting nano: Ctrl-X + Y + Enter. Right after this you need to RESTART YOUR VPS from Vultr Control Panel. Not from Linux!__

3) After a few minutes re-connect PuTTY and confirm that your single masternode is running.

4) Create a new home directory for new edend and create a copy of the daemon binary. Note that in this example we are adding number '7' to the edend. For each additional daemon we will need to create a new copy with a different name and a respective data directory:

```bash

sudo cp /usr/bin/edend /usr/bin/edend7 

cd ~
sudo mkdir .eden7
cd .eden7
sudo nano eden.conf

```

5) Copy/paste the following configuration into the new eden.cong and modify IP addresses to match your IP configuration:

```bash

# Masternode Private Key (keep it safe!)
masternodeprivkey=kjhsd^%834uieTisIsnotMyPrivateKeyGLJKGHdugf356

# Login credentials used by eden-cli and other clients such as Sentinel etc.
# Can be identical across all Masternodes
rpcuser=edenrpc
rpcpassword=6E3LEfahULWrongPassw0rdp4CqZPTpI2p

# List all IP addresses assigned to this VPS server
# Adding other public servers or networks is not recommended as 
# login credentials (above) are transmitted in clear text.
# Order does not matter.
rpcallowip=127.0.0.1
rpcallowip=45.76.240.188
rpcallowip=144.202.87.177
rpcallowip=45.63.34.190

# This will restrict RPC server binding only this IP and port
# Each masternode will be using its own IP address which it will 
# advertise on the network. For this particular eden.conf we use
# 144.202.87.177 out of three addresses assigned to this server.
# RPC ports need to be unique among all daemons. 
# This particular daemon will listen for commands on 3592 (default is 3594).
# Arbitrary port numbers can be used as long as they are not 
# conflicting with other systens on this VPS
rpcbind=144.202.87.177
rpcport=3592

# This will restrict RPC server binding only this IP.
# By default it will bind to all interfaces on the server
externalip=144.202.87.177
bind=144.202.87.177

listen=1
server=1
daemon=1
masternode=1
rpctimeout=16
maxconnections=256

logips=1
logtimestamps=1

# Optional known good masternodes for initial seeding
addnode=45.76.12.139
addnode=144.202.81.111
```

Exit and save eden.conf (Ctrl-X + Y + Enter)

Restrict permissions for the eden.conf:
```bash
sudo chmod 0600 ~/.eden7/eden.conf
```

*** Repeat Steps (4) and (5) for each additional IP address remembering to change the number '7' to something different ***
*** In addition you can modify the original ~/.eden/eden.conf to match the style of these new configs. ***

6) Add cron jobs for automatic startup and periodic pings. In this example we will add jobs for one extra daemon:

```bash

(
  crontab -l 2>/dev/null
  echo '@reboot sleep 30 && edend7 -datadir=/root/.eden7'
) | crontab
(
  crontab -l 2>/dev/null
  echo '*/10 * * * * eden-cli -datadir=/root/.eden7 -rpcconnect=144.202.87.177 sentinelping 1.1.0'
) | crontab

crontab -l

```

Example of 'crontab -l' output:
```
@reboot sleep 60 && edend  -datadir=/root/.eden
@reboot sleep 60 && edend6 -datadir=/root/.eden6
@reboot sleep 60 && edend7 -datadir=/root/.eden7
*/10 * * * * eden-cli -datadir=/root/.eden6 -rpcconnect=45.63.34.190 sentinelping 1.1.0
*/10 * * * * eden-cli -datadir=/root/.eden -rpcconnect=45.76.240.188 sentinelping 1.1.0
*/10 * * * * eden-cli -datadir=/root/.eden7 -rpcconnect=144.202.87.177 sentinelping 1.1.0
```

*** Repeat step (6) for each additional IP and daemon or edit crontab config directly (crontab -e)

7) On your Windows machine which runs QT wallet, open masternode.conf with Notepad and add one line for each masternode added. Save and restart the wallet and wait a few minutes for network sync before moving forward.

8) Reboot your VPS (type reboot) and after several minutes reconnect with PuTTY. Verify the status of all masternodes. Note that with additional daemons you now must use extra command line parameters for the eden-cli to specify the instance of the edend daemon:
```bash

(Primary IP)
eden-cli -datadir=/root/.eden -rpcconnect=45.76.240.188 mnsync status
eden-cli -datadir=/root/.eden -rpcconnect=45.76.240.188 masternodelist full 45.76.240
eden-cli -datadir=/root/.eden -rpcconnect=45.76.240.188 masternodelist info 45.76.240.188

(Secondary IP)
eden-cli -datadir=/root/.eden7 -rpcconnect=144.202.87.177 mnsync status
eden-cli -datadir=/root/.eden7 -rpcconnect=144.202.87.177 masternodelist full 144.202
eden-cli -datadir=/root/.eden7 -rpcconnect=144.202.87.177 masternodelist info 144.202.87.177

# Debug log:
sudo tail -f ~/.eden7/debug.log

# To start the daemon:
edend7 -datadir=/root/.eden7

# To stop the daemon:
eden-cli -datadir=/root/.eden7 -rpcconnect=144.202.87.177 stop

# CPU/RAM utilization of all daemons
htop

# To kill the daemon if it refuses to stop (this is where we leverage different daemon names)
pkill edend7

```

9) Finally start all added masternodes in your windows QT wallet as usual and wait at least 10-20 minutes for sync. As usual, payments won't start until after ~10 hours.

**The End**


P.S. 
If this guide worked well for you and
you really enjoyed the process,
you know what to do with these:

EbShbYatMRezVTWJK9AouFWzczkTz5zvYQ

https://www.vultr.com/?ref=7363317

https://fasterpool.com :)

--Allroad
