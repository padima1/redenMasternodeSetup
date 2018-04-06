## Installation

NOTE: This installation guide is provided as is with no warranties of any kind.

If you follow the steps and use a newly created Ubuntu 16.04 VPS, it will automatically configure and start your Master Node. You will need to input your public VPS IP address and masternode private key.

1) In Windows wallet, create a new receive address and name it mn1 for example.

2) Send exactly 2500 EDEN to this new address.

3) Generate your Masternode Private Key in Windows wallet
```bash
masternode genkey

Write this down or copy it somewhere safe. You will need this key to set up MN on VPS later.
```
4) View your Output transaction ID in Windows wallet console

```bash
masternode outputs
```
Write this down or copy it somewhere safe. You will use this in the masternode.conf file for your Windows wallet later.

5) SSH (Putty Suggested) to your VPS, login to root, and clone the script Github repository. 
(NOTE: Currently this repo contains Linux wallet binaries wich are necessary to run master node on VPS. The location of these binaries will be changed to an official release github folder later)

```bash
git clone https://github.com/fasterpool/EDEN-MN-SETUP
```
6) Navigate to the install folder:

```bash
cd EDEN-MN-SETUP
```

7) Run the bash script which will install & configure your desired master node with all necessary options.

For Ubuntu 16.04 and Ubuntu 17.10

```bash
bash install_ubuntu_17.10.sh
```

When the script asks, input your public VPS IP Address and Private Key created in the very beginning (You can copy your private key and paste into the VPS if connected with Putty by right clicking).

When the script configures the ufw firewall, answer 'y' to proceed with operation.
Once done, the VPS will ask you to start your masternode in your Windows wallet.

8) On your Windows machine, close wallet app. Navigate to %appdata%/roaming/Eden, open masternode.conf with Notepad.

Insert as a new line the following:

```bash
masternodename ipaddress:3595 privatekey output
```

Open up the wallet, unlock with your encryption password, and open up the Debug Console

```bash
masternode start-alias <masternodename>
```
If done correctly, it will indicate that the masternode has been started correctly. 

Go back to your VPS and hit the spacebar. It will say that it needs to sync. You're all done!

Now you just need to wait for the VPS to sync up the blockchain and await your first masternode payment.
