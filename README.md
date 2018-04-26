## Reden Masternode Installation

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
cd ~
git clone https://github.com/fasterpool/RedenMasternodeSetup
```

__NOTE:__ in case you will need to re-download this setup script or binaries from github repo, use the following git command:
```bash
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
	mn1 - with your desired masternode name (alias)

	TxId - with Transaction Id from masternode outputs

	TxIdx - with Transaction Index (0 or 1)

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

**Advanced masternode monitoring script: nodemon.sh**

The main purpose of this simple script is to monitor **masternode status and peer connections** in real-time. It will display all current __outbound__ connections of your masternode with great amount of statistis which can be used for troubleshooting of sync issues.

Typically you should see more than a few nodes listed in the table and the amount of data sent/received should be updating every several seconds on a healthy masternode.

Currently Reden nodes will display most (if not all) peers with IPv6 addresses. This is normal as long as the data is being transferred and peers stay connected for a long time. Initially, when the node is just started, the outbound connection table may not show any peers for quite some time. It may take several hours to build up a healthy and stable list of peers.

Sample output of the script from node 108.61.142.63 on Apr-24th 2018:
```
====================================================================================================
Outbound connections to other peer nodes (from reden-cli getpeerinfo, excluding inbound connections)
====================================================================================================
ID     Node IP                                        Ping   Rx/Tx    Since Hdrs  Height Time  Ban
       Address                                        (ms)  (KBytes)  Block Syncd Blocks (min) Score
====================================================================================================
697   [2001:0:9d38:6abd:28f4:3d6a:a0ae:3275]:13058     157  6348/9614  1987  3211  3211  2605  0
764   [2001:0:4137:9e76:3085:2850:9eb9:dc70]:13058     78   6943/9801  1994  3206  3206  2588  0
885   [2001:0:9d38:90d7:2829:fbff:2a2a:24a5]:13058     96   6016/6619  2008  3206  3206  2557  0
914   [2001:0:9d38:6abd:38a4:1f88:ae3a:61b6]:13058     136  6086/6948  2010  3206  3206  2550  0
1198  [2601:803:401:f2c3:22:c243:f4c0:7423]:13058      115  5716/5981  2092  3216  3216  2376  0
1212  [2001:0:9d38:6ab8:3c63:2490:3f4b:7194]:13058     334  6171/7774  2094  3206  3206  2370  0
1241  [2001:0:9d38:6abd:1817:e3e:86f9:959a]:13058      252  6055/7458  2096  3211  3211  2365  0
1375  [2a02:2f0b:a010:851:89ba:6f9e:8119:e34a]:13058   115  5211/6410  2132  3204  3204  2276  0
1652  [2405:4800:309f:cf5:518d:b305:cd5e:7b67]:13058   285  5228/5630  2159  3211  3211  2225  0
2033  [2001:0:9d38:6ab8:800:fa17:9143:567]:13058       249  5689/7521  2222  3211  3211  2092  0
2130  [2001:0:9d38:6ab8:1c47:3686:a14b:7f62]:13058     138  4938/5291  2231  3206  3206  2081  0
2230  [2001:0:5ef5:79fb:2868:4aec:b9ac:8475]:13058     32   5272/6697  2249  3206  3206  2038  0
2429  [2001:0:9d38:953c:cac:34db:b49e:9dbe]:13058      84   5229/6632  2268  3216  3216  1989  10
2929  [2001:0:5ef5:79fd:c2:219e:a00b:61d6]:13058       125  4322/4879  2377  3206  3206  1769  0
3180  [2001:0:5ef5:79fb:1042:3489:39ab:32b8]:13058     47   4219/5173  2429  3216  3216  1649  0
4214  [2001:0:9d38:6ab8:2cf1:67a:8da9:20cd]:13058      313  3011/3361  2633  3215  3215  1234  0
4566  [2001:0:9d38:953c:45d:b7d3:8eb8:d408]:13058      219  3397/4185  2696  3211  3211  1099  0
5061  [2001:0:5ef5:79fb:3016:2260:4b69:f6f5]:13058     241  2241/2686  2764  3211  3211  952   0
5078  [2001:0:5ef5:79fb:18b2:1417:e748:bbca]:13058     56   2485/3004  2765  3209  3209  948   0
5521  [2001:0:9d38:953c:1c9c:1f9d:77c1:d36b]:13058     51   1875/2199  2868  3185  3185  735   0
5530  [2001:0:9d38:953c:5a:1fdf:93c7:3ef6]:13058       14   2164/3050  2868  3199  3199  733   0
5743  [2001:0:9d38:90d7:3474:fbff:47e9:aa96]:13058     936  1723/2279  2916  3211  3211  628   0
5827  [2001:0:9d38:6ab8:c1c:2a01:d15a:c180]:13058      165  1640/2078  2927  3211  3211  609   0
5842  [2001:0:9d38:90d7:2065:12cd:a69d:4632]:13058     102  1656/2162  2932  3186  3186  602   0
5847  [2001:0:5ef5:79fd:30ba:3ba6:4dac:3f74]:13058     99   1578/1945  2933  3184  3184  598   0
5884  [2001:0:9d38:90d7:422:8fdf:2032:cd36]:13058      279  1404/1612  2952  3211  3211  558   0
5886  [2001:0:9d38:6abd:c63:1971:d16a:466b]:13058      112  1528/1986  2954  3186  3186  557   0
5905  [2001:0:9d38:6abd:3c12:17ab:3e4d:1ba6]:13058     117  1464/1829  2958  3184  3184  547   0
5969  [2001:0:9d38:78cf:2c5f:295e:4319:d124]:13058     123  1353/1662  2969  3184  3184  519   0
6184  [2001:0:9d38:953c:384a:21e:4d6b:8a48]:13058      121  1188/1543  3013  3184  3184  437   0
6365  141.101.14.64:13058                              132  837/831    3055  3211  3211  343   0
6463  [2001:0:9d38:90d7:343d:38c7:b4b8:d023]:13058     74   762/860    3077  3199  3199  295   0
6467  [2001:0:9d38:953c:205e:83f:be80:a25d]:13058      48   788/935    3077  3213  3213  293   0
6533  144.202.90.200:13058                             74   644/661    3098  3210  3210  257   0
6823  [2001:0:9d38:90d7:1cfa:2467:549a:b63d]:13058     262  282/353    3175  3211  3211  91    0
6958  [2001:0:9d38:78cf:141e:1e2b:a842:5b65]:13058     112  130/127    3204  3213  3213  40    0
6994  [2001:0:9d38:90d7:34b2:8c3:9157:c3f1]:13058      272  84/72      3210  3211  3211  20    0
7016  [2001:0:9d38:90d7:3893:35be:2033:cd2]:13058      307  67/42      3213  3213  3213  17    0
7052  [2405:9800:bc00:2fd8:b984:f685:545b:ddf9]:13058  251  45/17      3213  3213  3213  6     0
7069  [2001:0:5ef5:79fb:46d:2512:b171:eb92]:13058      185  34/5       3215  3215  3215  1     0
====================================================================================================
Your Masternode Status:
# reden-cli masternode status
{
  "vin": "CTxIn(COutPoint(7a0fc6d42dfa5952cbe8063558d9ff817d39bcdeb21d49e9da79db8782ae93bb, 0), scriptSig=)",
  "service": "108.61.142.63:13058",
  "payee": "RDDFRkcFiRZc1aXVc6SZUcqKNxgBWMHAbR",
  "status": "Masternode successfully started"
}
====================================================================================================
Sync Status:
# reden-cli mnsync status
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
====================================================================================================
Masternode Information:
# reden-cli getinfo
{
  "version": 2000001,
  "protocolversion": 70206,
  "walletversion": 61000,
  "balance": 0.00000000,
  "privatesend_balance": 0.00000000,
  "blocks": 3216,
  "timeoffset": 0,
  "connections": 256,
  "proxy": "",
  "difficulty": 429.6716693131179,
  "testnet": false,
  "keypoololdest": 1524553866,
  "keypoolsize": 1001,
  "paytxfee": 0.00000000,
  "relayfee": 0.00010000,
  "errors": ""
}
====================================================================================================


Press Ctrl-C to Exit...
```

* * *



If you found this script and masternode setup guide helpful...

...please donate REDEN to: **RCdYg5yq3YfymwrZi8EMBSFHxcwR7acniS**

or just come to our pool to mine REDEN: https://fasterpool.com 
We have low 0.5% charity fee, which goes to the REDEN dev fund!

--Allroad
