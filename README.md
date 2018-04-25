## Installation

**NOTE:** This installation guide is provided as is with no warranties of any kind.

**NOTE:** Newer version of the script (v1.1) does not ask for IP address or masternode genkey anymore. Instead the __script will detect VPS IP Address and generate the private key automatically__

If you follow the steps and use a newly installed Ubuntu 16.04 VPS, it will automatically configure and start your Master Node. Ubuntu 17.10 and other Linux distros ate not currently supported.

Steps:

**0) Create a new VPS** or use existing one. Recommended VPS resource configuration is similar to the vultr's $5/mo (25GB SSD/1xCPU/1GB RAM, Ubuntu 16.04). It can handle several MNs running simultaneously on the same public IP address but they have to use dirfferent ports. Therefore you cannot easily run more than one REDEN MN on the same box. Different coins are fine.

**1)** In Windows wallet, **create a new receiving address** and name it **mn1** for example.

**2) Send exactly 5000 REDEN to this new address**. NOTE: if you are setting up many msternodes and wish to perform multiple 5k payments in a row before following through steps (3-7), make sure you select correct __inputs__ for each payment or __lock__ your 5k coins manually after each payment using Coin Control Features, otherwise your coins may get reused and only last payment will yield valid masternode output. The wallet will lock your payments automatically after you restart it in step (7).

**3) View masternode outputs** - output transaction ID and transaction index in wallet Debug Console (Tools -> Debug console) by typing:

```bash
masternode outputs
```

Copy it somewhere safe. You will use these in the masternode.conf file for your wallet later.

**4) Connect to your VPS server console** using PuTTY terminal program, login as root and clone the setup script and wallet binaries from github repository.
(NOTE: Currently this script repo contains Linux wallet binaries wich are necessary to run master node on VPS. The location of these binaries will be changed to the official release github folder at a later date)

To download (clone) the script and binaries to your VPS, use the following command in VPS Linux console:

```bash
git clone https://github.com/fasterpool/RedenMasternodeSetup
```

__NOTE:__ in case you will need to re-download this setup script or binaries from github repo, use the following git command:
```
cd ~/RedenMasternodeSetup
git fetch --all
```

**5) Run the install script** which will install and configure your masternode with all necessary options.

```bash
cd ~/RedenMasternodeSetup
bash reden-setup.sh
```
__NOTE:__ This process may take anywhere from 5 to 20 minutes, depending on your VPS HW specs. If it's not your very first ever masternode setup, you may want to speed up the process by doing things in parallel. While the MN setup script is running on the VPS, you can spend this time getting ready to start your new masternode from your Hot Wallet (also referred to as Control Wallet) by following instructions in next step (6).

Once the script completes, it will output your VPS Public IP Address and masternode Private Key which it generated for this masternode. Detailed instructions on what to do next will be provided on the VPS console.

**6) Prepare your Hot Wallet and start the new masternode**. In this step you will introduce your new masternode to the Reden network by issuing a masternode start command from your wallet, which will broadcast information proving that
the collateral for this masternode is secured in your wallet. Without this step your new masternode will function as a regular Reden node (wallet) and will not yield any rewards. Usually you keep your Hot Wallet on your Windows machine where you securely store your funds for the MN collateral.

Basically all you need to do is just edit the __masternode.conf__ text file located in your hot wallet __data directory__ to enter a few masternode parameters, restart the wallet and then issue a start command for this new masternode.

There are two ways to edit __masternode.conf__. The easiest way is to open the file from within the wallet app (Tools -> Open Masternode Configuration File). Optionally, you can open it from the wallet data folder directly by navigating to the %appdata%/roaming/redencore. Just hit Win+R, paste %appdata%/roaming/redencore, hit Enter and then open **masternode.conf** with Notepad for editing. 

It does not matter which way you open the file or how you edit it. In either case you will need to restart your wallet when you are done in order for it to pickup the changes you made in the file. Make sure to save it before you restart your wallet.

__Here's what you need to do in masternode.conf file__. For each masternode you are going to setup, you need to enter one separate line of text  which will look like this:

```bash
mn1 231.321.11.22:13058 27KTCRKgqjBgQbAS2BN9uX8GHBu16wXfr4z4hNDZWQAubqD8fr6 5d46f69f1770cb051baf594d011f8fa5e12b502ff18509492de28adfe2bbd229 0
```

The format for this string is as follow:
```bash
masternodealias publicipaddress:13058 masternodeprivatekey output-tx-ID output-tx-index
```

Where:
__masternodealias__ - your human readable masternode name (alias) which you use to identify the masternode. It can be any unique name as long as you can recognize it. It exists only in your wallet and has no impact on the masternode functionality.

__publicipaddress:13058__ - this must be your masternode public IP address, which is usually the IP address of your VPS, accessible from the Internet. The new script (v1.1) will detect your IP address automatically. The __:13058__ suffix is the predefined and fixed TCP port which is being used in Reden network for node-to-node and wallet-to-node communications. This port needs to be opened on your VPS server firewall so that others can talk to your masternode. The setup script takes care of it. NOTE: some VPS service providers may have additional firewall on their network which you may need to configure to open TCP port  13058. Vultr does not require this.

__masternodeprivatekey__ - this is your masternode private key which script will generate automatically. Each masternode will use its own unique private key to maintain secure communication with your Hot Wallet. You will have to generate a new key for each masternode you are setting up. Only your masternode and your hot wallet will be in possession of this private key. In case if you will need to change this key later for some reason, you will have to update it in your __masternode.conf__ in Hot Wallet as well as in the reden.conf in data directory on the masternode VPS.

__output-tx-ID__ - this is your collateral payment Transaction ID which is unique for each masternode. It can be easily located in the transaction details (Transactions tab) or in the list of your **masternode outputs**. This TxID also acts as unique masternode ID on the Reden network.

__output-tx-index__ - this is a single-digit value (0 or 1) which is shown in the **masternode outputs**

**NOTE:** The new MN setup script will provide this configuration string for your convenience.
You just need to replace:
```bash
	**mn1** - with your desired masternode name (alias)

	**TxId** - with Transaction Id from masternode outputs

	**TxIdx** - with Transaction Index (0 or 1)

```

Use only one space between the elements in each line, don't use TABs.

Once you think you are all done editing masternode.conf file, please make sure you save the changes!

IMPORTANT: Spend some time and double check each value you just entered. Copy/paste mistakes will cause your masternode (or other nodes) to behave erratically and will be extremely difficult to troubleshoot. Make sure you don't have any duplicates in the list of masternodes. Often people tend to speed up the process and copy the previous line and then forget to modify the IP address or copy the IP address partially. If anything goes wrong with the masternode later, the masternode.conf file should be your primary suspect in any investigation.

Finally, you need to either __restart__ the wallet app, unlock it with your encryption password. At this point the wallet app will read your __masternode.conf__ file and populate the Masternodes tab. Newly added nodes will show up as MISSING, which is normal.

Once the wallet is fully synchronized and your masternode setup script on VPS has finished its synchronization with the network, you can **issue a start broadcast** from your hot wallet to tell the others on Reden network about your new masternode.

Todo so you can either run a simple command in Debug Console (Tools -> Debug console):

```bash
masternode start-alias <masternodename>
```

Example:
```bash
masternode start-alias mn1
```

Or, as an alternative, you can issue a start broadcast from the wallet Masternodes tab by right-clicking on the node:

```bash
Masternodes -> Select masternode -> RightClick -> start alias
```

The wallet should respond tith **"masternode started successfully"** as long as the masternode collateral payment was done correctly in step (2) and it had at least 15 confirmations. This only means that the conditions to send the start broadcast are satisfied and that the start command was communicated to peers.

Go back to your VPS and wait for the status of your new masternode to change to "Masternode successfully started". This may take some time and you may need to wait for several hours until your new masternode completes sync process.

Finally, to **monitor your masternode status** you can use the following commands in Linux console of your masternode VPS:

```bash
reden-cli masternode status

reden-cli mnsync status
```

If you are really bored waiting for the sync to complete, you can watch what your masternode is doing on the network at any time by using tail to **monitor the debug.log** file in realtime:

```bash
sudo tail -f ~/.redencore/debug.log
```

And for those who wonder what does **reden.conf** file looks like for a typical masternode which the setup script generates, here's an example below...

Note that both, the __externalip__ should match the IP address and __masternodeprivkey__ should math the private key in your  __masternode.conf__ of your hot wallet in order for the masternode to function properly. If any of these two parameters change, they must be changed in both, the reden.conf file on the masternode VPS (located in /root/.redencore directory) and masternode.conf on Hot Wallet PC (located in %appdata%/redencore folder).

Example: 

**nano /root/.redencore/reden.conf**

```bash
rpcuser=redenrpc
rpcpassword=APQsN6waRANDOMPASSWORDYaFGhecQiAn
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
maxconnections=256
externalip=**144.202.92.85**
masternode=1
masternodeprivkey=**2333H9uMa8wrYGb1hNotRealPKey64vr8BRYjPZP3LAR6WFGg** 
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
  **"status": "Masternode successfully started"**
}
{
  "AssetID": 999,
  "AssetName": **"MASTERNODE_SYNC_FINISHED"**,
  "Attempt": 0,
  "IsBlockchainSynced": true,
  "IsMasternodeListSynced": true,
  "IsWinnersListSynced": true,
  **"IsSynced": true**,
  "IsFailed": false
}
```

**Advanced masternode monitoring script: nodemon.sh**

The main purpose of this simple script is to monitor **masternode status and peer connections** in real-time. It will display all current __outbound__ connections of your masternode with great amount of statistis which can be used for troubleshooting of sync issues.

Typically you should see more than a few nodes listed in the table and the amount of data sent/received should be updating every several seconds on a healthy masternode.

Currently Reden nodes will display most (if not all) peers with IPv6 addresses. This is normal as long as the data is being transferred and peers stay connected for a long time. Initially, when the node is just started, the outbound connection table may not show any peers for quite some time. It may take several hours to build up a healthy and stable list of peers.

Sample output of the script from node 108.61.142.63 on Apr-24th 2018:
```
=========================================================================================================
Outbound connections to other peer nodes (from reden-cli getpeerinfo, excluding inbound connections)
1:ID 2:NodeIP 3:Ping,ms 4:Sent,KB 5:Recvd,KB 6:StartBlk 7:HdrsSyncd 8:BlkSyncd 9:ConnTime,min 10:BanScore
=========================================================================================================
343   [2001:0:9d38:953c:2029:1e04:50fd:b42c]:13058     241   5193  3413  1948  2540  2540  1273  0
491   [2001:0:9d38:90d7:2065:12cd:a69d:4632]:13058     115   5195  3471  1962  2548  2548  1250  0
697   [2001:0:9d38:6abd:28f4:3d6a:a0ae:3275]:13058     148   4159  3022  1987  2548  2548  1206  0
764   [2001:0:4137:9e76:3085:2850:9eb9:dc70]:13058     46    4366  3300  1994  2546  2546  1190  0
768   [2400:2410:8540:b00:215:5dff:fe03:607]:13058     161   3402  2921  1994  2540  2540  1189  0
885   [2001:0:9d38:90d7:2829:fbff:2a2a:24a5]:13058     102   3067  2776  2008  2548  2548  1158  0
914   [2001:0:9d38:6abd:38a4:1f88:ae3a:61b6]:13058     121   3206  2786  2010  2548  2548  1151  0
1198  [2601:803:401:f2c3:22:c243:f4c0:7423]:13058      49    2453  2375  2092  2546  2546  977   0
1212  [2001:0:9d38:6ab8:3c63:2490:3f4b:7194]:13058     59    3279  2595  2094  2540  2540  971   0
1241  [2001:0:9d38:6abd:1817:e3e:86f9:959a]:13058      240   3026  2497  2096  2540  2540  967   0
1375  [2a02:2f0b:a010:851:89ba:6f9e:8119:e34a]:13058   261   2623  2076  2132  2540  2540  877   0
1652  [2405:4800:309f:cf5:518d:b305:cd5e:7b67]:13058   252   2101  1979  2159  2540  2540  826   0
1759  [2001:0:9d38:6abd:201a:665:ad5b:a97f]:13058      120   2597  2210  2160  2548  2548  821   0
1820  [2001:0:9d38:953c:20ab:589d:247a:6365]:13058     236   2585  2156  2169  2540  2540  812   0
2033  [2001:0:9d38:6ab8:800:fa17:9143:567]:13058       255   3065  2112  2222  2540  2540  694   0
2111  [2001:0:9d38:90d7:34b2:8c3:9157:c3f1]:13058      1108  2615  1951  2227  2540  2540  685   0
2130  [2001:0:9d38:6ab8:1c47:3686:a14b:7f62]:13058     145   1894  1707  2231  2548  2548  682   0
2149  [2001:0:9d38:90d7:2432:629:9156:ba63]:13058      255   2788  1941  2234  2540  2540  678   0
2230  [2001:0:5ef5:79fb:2868:4aec:b9ac:8475]:13058     33    2354  1772  2249  2548  2548  639   0
2381  [2001:0:9d38:90d7:cc2:342f:cece:7cd2]:13058      281   1916  1572  2265  2546  2546  602   0
2429  [2001:0:9d38:953c:cac:34db:b49e:9dbe]:13058      95    2624  1799  2268  2501  2501  590   10
2508  [2001:0:9d38:90d7:422:8fdf:2032:cd36]:13058      275   1703  1441  2285  2540  2540  552   0
2540  [2001:0:9d38:953c:c46:f6b4:aeff:e913]:13058      114   1618  1389  2289  2548  2548  542   0
2727  [2001:0:5ef5:79fb:304f:3679:e0f2:12c]:13058      116   1571  1295  2319  2544  2544  485   0
2733  [2001:0:9d38:90d7:78:c01:4b48:968a]:13058        557   1497  1239  2333  2543  2543  468   0
2847  [2405:9800:bc00:2fd8:b984:f685:545b:ddf9]:13058  255   1102  1030  2351  2540  2540  416   0
2865  [2001:0:9d38:90d7:1c24:15b3:48a6:e4b3]:13058     299   1079  1017  2357  2540  2540  408   0
2929  [2001:0:5ef5:79fd:c2:219e:a00b:61d6]:13058       480   1073  952   2377  2548  2548  370   0
3155  [2001:0:9d38:90d7:1cfa:2467:549a:b63d]:13058     273   984   745   2424  2540  2540  256   0
3180  [2001:0:5ef5:79fb:1042:3489:39ab:32b8]:13058     35    828   691   2429  2548  2548  250   0
3222  [2001:0:9d38:953c:1085:dad8:20b5:7386]:13058     238   527   507   2453  2540  2540  200   0
3333  [2001:0:9d38:90d7:1c84:3125:47e9:6b83]:13058     265   671   526   2464  2540  2540  179   0
3431  [2001:0:9d38:90d7:ea:35eb:8951:67f8]:13058       287   415   387   2481  2540  2540  144   0
3433  [2001:0:9d38:953c:cc:37c3:ceb8:d542]:13058       363   424   387   2481  2546  2546  143   0
3584  [2001:0:5ef5:79fb:46d:2512:b171:eb92]:13058      125   251   221   2518  2540  2540  75    0
3617  [2001:0:9d38:6abd:c63:1971:d16a:466b]:13058      119   206   203   2520  2548  2548  69    0
3634  [2001:0:9d38:90d7:3893:35be:2033:cd2]:13058      313   167   170   2528  2540  2540  57    0
3731  [2001:0:9d38:90d7:3806:434b:20e7:4dc4]:13058     303   52    71    2543  2543  2543  16    0
3741  [2001:0:9d38:6ab8:308d:6dfd:437e:ac68]:13058     108   48    58    2545  2548  2548  11    0
3776  [2001:0:9d38:6abd:28e9:ca0:4692:c90d]:13058      187   1     1     2551  2551  2551  0     0
=========================================================================================================
Your Masternode Status:
# reden-cli masternode status
{
  "vin": "CTxIn(COutPoint(7a0fc6d42dfa5952cbe8063558d9ff817d39bcdeb21d49e9da79db8782ae93bb, 0), scriptSig=)",
  "service": "108.61.142.63:13058",
  "payee": "RDDFRkcFiRZc1aXVc6SZUcqKNxgBWMHAbR",
  **"status": "Masternode successfully started"**
}
=========================================================================================================
Sync Status:
# reden-cli mnsync status
{
  "AssetID": 999,
  "AssetName": "MASTERNODE_SYNC_FINISHED",
  "Attempt": 0,
  "IsBlockchainSynced": true,
  "IsMasternodeListSynced": true,
  "IsWinnersListSynced": true,
  **"IsSynced": true**,
  "IsFailed": false
}
=========================================================================================================
Masternode Information:
# reden-cli getinfo
{
  "version": 2000001,
  "protocolversion": 70206,
  "walletversion": 61000,
  "balance": 0.00000000,
  "privatesend_balance": 0.00000000,
  "blocks": 2551,
  "timeoffset": 0,
  **"connections": 256**,
  "proxy": "",
  "difficulty": 343.4593731447172,
  "testnet": false,
  "keypoololdest": 1524553866,
  "keypoolsize": 1001,
  "paytxfee": 0.00000000,
  "relayfee": 0.00010000,
  "errors": ""
}
=========================================================================================================


Press Ctrl-C to Exit...
```

* * *



If you found this script and masternode setup guide helpful...

...please donate REDEN to: RCdYg5yq3YfymwrZi8EMBSFHxcwR7acniS

or just come to our pool to mine REDEN: https://fasterpool.com
We have low 0.5% charity fee, which goes to the REDEN dev fund!

--Allroad
