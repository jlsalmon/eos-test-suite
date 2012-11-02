#!/bin/bash
source /etc/XrdTest/utils/functions.sh

log "Finalizing test case on slave" @slavename@ "..."
    
if [[ @slavename@ =~ ds ]]; then
    
    service eos stop
    log "Cleaning up ..."
    test -e /data/.eosfsuuid && unlink /data/.eosfsuuid
    test -e /data/.eosfsid && unlink /data/.eosfsid
    rm -rf /data/*
    log "Finalization complete."
  
else
    log "Nothing to initialize." 
fi