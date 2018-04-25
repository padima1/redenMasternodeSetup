#It is a one-liner script for now. Refresh time is 1 sec.
dpkg -s jq 2>/dev/null >/dev/null || sudo apt-get -y install jq

watch -ptn 1 "echo '=========================================================================================================
Outbound connections to other peer nodes (from reden-cli getpeerinfo, excluding inbound connections)
1:ID 2:NodeIP 3:Ping,ms 4:Sent,KB 5:Recvd,KB 6:StartBlk 7:HdrsSyncd 8:BlkSyncd 9:ConnTime,min 10:BanScore
========================================================================================================='
reden-cli getpeerinfo | jq -r '.[] | select(.inbound==false) | \"\(.id),\(.addr),\(.pingtime*1000|floor),\
\(.bytessent/1000|floor),\(.bytesrecv/1000|floor),\(.startingheight),\(.synced_headers),\(.synced_blocks),\
\((now-.conntime)/60|floor),\(.banscore)\"' | column -t -s ',' && 
echo '========================================================================================================='
echo 'Your Masternode Status: \n# reden-cli masternode status' && reden-cli masternode status &&
echo '========================================================================================================='
echo 'Sync Status: \n# reden-cli mnsync status' &&  reden-cli mnsync status &&
echo '========================================================================================================='
echo 'Masternode Information: \n# reden-cli getinfo' && reden-cli getinfo &&
echo '========================================================================================================='
echo '\n\nPress Ctrl-C to Exit...'"

