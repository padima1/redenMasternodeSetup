#It is a one-liner script for now. Refresh time is 1 sec.
dpkg -s jq 2>/dev/null >/dev/null || sudo apt-get -y install jq

watch -ptn 1 "echo '=============================================================================
Outbound connections to other nodes (source: getpeerinfo, inbound excluded)
=============================================================================
ID    Node IP             Ping   Rx/Tx     Since  Hdrs   Height  Time   Ban
      Address             (ms)  (KBytes)   Block  Syncd  Blocks  (min)  Score
============================================================================='
reden-cli getpeerinfo | jq -r '.[] | select(.inbound==false) | \"\(.id),\(.addr),\(.pingtime*1000|floor),\
\(.bytesrecv/1024|floor)/\(.bytessent/1024|floor),\(.startingheight) ,\(.synced_headers) ,\(.synced_blocks)  ,\
\((now-.conntime)/60|floor) ,\(.banscore)\"' | column -t -s ',' && 
echo '============================================================================='
echo 'Your Masternode Status: \n# reden-cli masternode status' && reden-cli masternode status &&
echo '============================================================================='
echo 'Sync Status: \n# reden-cli mnsync status' &&  reden-cli mnsync status &&
echo '============================================================================='
echo 'Masternode Information: \n# reden-cli getinfo' && reden-cli getinfo &&
echo '============================================================================='
echo '\n\nPress Ctrl-C to Exit...'"

