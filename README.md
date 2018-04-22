## Installation

NOTE: This installation guide is provided as is with no warranties of any kind.

If you follow the steps and use a newly created Ubuntu 16.04 VPS, it will automatically configure and start your Master Node. You will need to input your public VPS IP address and masternode private key.

Steps:

0) Create a new VPS or use existing one. Recommended config is similar to vultr's $5/mo (25GB SSD/1xCPU/1GB RAM, Ubuntu 16.04). It can handle several MNs running simultaneously on the same IP address but they have to use dirfferent ports. Therefore you cannot easily run more than one REDEN MN on the same box. Different coins are fine.

1) In Windows wallet, create a new receiving address and name it mn1 for example.

2) Send exactly 5000 REDEN to this new address. NOTE: if you are setting up many msternodes and wish to perform multiple 5k payments in a row before following through steps (3-8), make sure you select correct __inputs__ for each payment or __lock__ your 5k coins manually after each payment using Coin Control Features, otherwise your coins may get reused and only last payment will yield valid masternode output. The wallet will lock your payments automatically after you restart it in step (8).

3) Generate your Masternode Private Key in Windows wallet Debug Console (Tools -> Debug Console)
```bash
masternode genkey
```
Write this down or copy it somewhere safe. You will need this key to set up MN on VPS later.

4) View your Output transaction ID in in Debug Console (Tools -> Debug console):

```bash
masternode outputs
```

Write this down or copy it somewhere safe. You will use this in the masternode.conf file for your Windows wallet later.

5) SSH (Putty Suggested) to your VPS server console, login as root and clone the script Github repository.
(NOTE: Currently this repo contains Linux wallet binaries wich are necessary to run master node on VPS. The location of these binaries will be changed to the official release github folder at a later date)

```bash
git clone https://github.com/fasterpool/RedenMasternodeSetup
```
6) Navigate to the cloned install folder:

```bash
cd RedenMasternodeSetup
```

7) Run the bash script which will install & configure your master node with all necessary options.

For Ubuntu 16.04 (not compatible with Ubuntu 17.10!)

```bash
bash reden-setup.sh
```

When the script asks, input your public VPS IP Address and Private Key created in the very beginning (You can copy your private key and paste into the VPS if connected with Putty by right clicking).

Once done, the VPS will ask you to start your masternode in your Windows wallet. Follow instructions on the VPS console.

NOTE: If it's not your very first ever masternode setup, you may speed up the process by doing things in parallel. While the MN setup script is running on the VPS, which may take anywhere from 5 to 20 minutes, depending on your VPS HW specs, you can spend this time getting ready to start your new masternode from your Hot Wallet (also referred to as Control Wallet) by following instructions in next step (8).

8) Now it's time to prepare your Hot Wallet and start the new masternode. Without this step your new masternode will function as a regular node and not yield any rewards. Usually you keep this Hot Wallet on your Windows machine where you store your funds for MN collateral. 
Basically, all you need to do is just enter masternode parameters into the __masternode.conf__ text file located in your wallet __data directory__. There are two ways to find this file. The easiest way is to open the file in Notepad from within the wallet (Tools -> Open Masternode Configuration File). Optionally, you can open it from the wallet datafolder directly in Windows Explorer by navigating to the %appdata%/roaming/redencore (hit Win+R, paste %appdata%/roaming/redencore, hit Enter) and then just opening masternode.conf with Notepad for editing. 

It does not matter which way you open the file or how you edit it. In either case you will need to restart your wallet when you are done in order for it to pickup the changes you made in the file. Just make sure to save it before you restart your wallet.

Here's what you need to do in masternode.conf file. For each masternode you are going to setup, you need to enter one separate line of text  which will look like this:

Example:
```bash
mn1 231.321.11.22:13058 27KTCRKgqjBgQbAS2BN9uX8GHBu16wXfr4z4hNDZWQAubqD8fr6 5d46f69f1770cb051baf594d011f8fa5e12b502ff18509492de28adfe2bbd229 0
```

NOTE: use only one space between the elements in each line, don't use TABs.

Line format is as follow:
```bash
masternodealias publicipaddress:13058 masternodeprivatekey output-tx-ID output-tx-index
```
Where:
__masternodealias__ - your human readable masternode name (alias) which you use to address the masternode. It can be any unique name as long as you can recognize it. It exists only in your wallet and has no impact on MN functionality.

__publicipaddress:13058__ - this must be your masternode public IP address, which is usually the IP address of your VPS, accessible from the Internet. The __:13058__ suffix is the predefined and fixed TCP port which is used in Reden network for node-to-node and wallet-to-node communications. This port needs to be opened on your VPS server firewall so that others can talk to your masternode. The setup script takes care of it. NOTE: some VPS service providers may have additional firewall on their network which you may need to configure to open TCP port  13058. Vultr does not require this.

__masternodeprivatekey__ - this is your masternode private key which you generated earlier in step (3). Each masternode will use its own unique private key to maintain secure communication with your Hot Wallet. You will have to generate a new key for each masternode you are setting up. Only your masternode and your hot wallet will be in possession of this private key. In case if you will need to change this key later for some reason, you will have to update it in your __masternode.conf__ in Hot Wallet as well as in the reden.conf in data directory on the masternode VPS.

__output-tx-ID__ - this is your collateral payment Transaction ID which is unique for each masternode. It can be easily located in the transaction details (Transactions tab) or in the list of your **masternode outputs**. This TxID also acts as unique masternode ID on the Reden network.

__output-tx-index__ - this is a single-digit value (0 or 1) which is shown in the **masternode outputs**

Once you think you are all done editing masternode.conf file, please make sure you save the changes!

IMPORTANT: Spend some time and double check each value you just entered. Copy/paste mistakes will cause your masternode (or other nodes) to behave erratically and will be extremely difficult to troubleshoot. Make sure you don't have any duplicates in the list of masternodes. Often people tend to speed up the process and copy the previous line and then forget to modify the IP address or copy the IP address partially. If anything goes wrong with the masternode later, the masternode.conf file should be your primary suspect in any investigation.

Finally, you need to either restart or open up the wallet app, unlock with your encryption password. At this point the wallet app will read your __masternode.conf__ file and populate the Masternodes tab. Newly added nodes will show up as MISSING, which is normal.

If your masternode setup script has finished synchronization with the network, you can issue a start broadcast from your hot wallet to tell the others on Reden network about your new masternode.

Todo so you can either run a simple command in Debug Console (Tools -> Debug console):

```bash
masternode start-alias <masternodename>
```

Example:
```bash
masternode start-alias mn1
```

Or, as an alternative, you can issue a start broadcast from the wallet Masternodes tab by right-clicking on the node.

If masternode collateral payment was done properly, it will indicate that the masternode has been started successfully. This only means that the conditions to start were met and that start command was communicated to peers.

Go back to your VPS and wait for the status of your new masternode to change to "Masternode successfully started". This may take some time and you may need to wait for several hours until your new masternode completes sync process.

Finally, to monitor your masternode status you can use the following commands in Linux console of your masternode VPS:

```bash
reden-cli masternode status

reden-cli mnsync status
```

If you are really bored waiting for the sync to complete, you can watch what your masternode is doing on the network at any time by using tail to monitor the debug.log file in realtime:

```bash
sudo tail -f ~/.redencore/debug.log
```

And for those who wonder what does reden.conf file looks like for a typical masternode which the setup script generates, here's an example below...

Note that both, the __externalip__ should match the IP address and __masternodeprivkey__ should math the private key in your  __masternode.conf__ of your hot wallet in order for the masternode to function properly. If any of these two parameters change, they must be changed in both, the reden.conf on VPS (located in /root/.redencore directory) and masternode.conf on Hot Wallet PC (located in %appdata%/redencore folder).

Example: 

$ nano /root/.redencore/reden.conf

```
rpcuser=rRXlZyarf0RANDOMUSERNAMEVA4xAeLvQA4ly
rpcpassword=APQsN6waRANDOMPASSWORDYaFGhecQiAn
rpcallowip=127.0.0.1

onlynet=ipv4

listen=1
server=1
daemon=1
logtimestamps=1
maxconnections=32

externalip=144.202.92.85

masternode=1
masternodeprivkey=2333H9uMa8wrYGb1hNotRealPKey64vr8BRYjPZP3LAR6WFGg 
```

**In conclusion**

The script adds a cron job which starts redend daemon upon reboot. Try restarting your VPS server (just type reboot in Linux console) and see if your masternode comes back online automatically in a few minutes. Log back in using PuTTY and run the following command to monitor your masternode status:

```
watch -n 10 'reden-cli masternode status && reden-cli mnsync status'
```

The expected output for a functioning masternode will eventually look like this:

```
{
  "vin": "CTxIn(COutPoint(cbe3c99bed2c874a14675c54004a5b5bfda8473b98bfbd80a15743c2a1117d4f, 1), scriptSig=)",
  "service": "104.207.157.213:13058",
  "payee": "RN3ZoisQkdsCuXj7799kEcvJkWk6Bhc4uJ",
  "status": "Masternode successfully started"
}
{
  "AssetID": 999,
  "AssetName": "MASTERNODE_SYNC_FINISHED",
  "Attempt": 0,
  "IsBlockchainSynced": true,
  "IsMasternodeListSynced": true,
  "IsWinnersListSynced": true,
  "IsSynced": true,
  "IsFailed": false
}
```


* * *



If you found this script and masternode setup guide helpful...

...please donate REDEN to: RCdYg5yq3YfymwrZi8EMBSFHxcwR7acniS

or just come to our pool to mine REDEN: https://fasterpool.com
We have low 0.5% charity fee, which goes to the REDEN dev fund!

--Allroad


