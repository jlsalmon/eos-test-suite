#!/bin/bash
source /etc/XrdTest/utils/functions.sh

log "Running test case on slave" @slavename@ "..."

if [[ @slavename@ =~ manager ]]; then
    
    log "Running eos tests ..."
    eos -b space set default on 
    eos -b fs ls -l 
    
    sleep 30
    env CONSOLETYPE=serial eos-instance-test

else
	log "Nothing to do this time." 
fi


