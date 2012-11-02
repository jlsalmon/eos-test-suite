#!/bin/bash
source /etc/XrdTest/utils/functions.sh

log "Initializing test case on slave" @slavename@ "..."

if [[ @slavename@ =~ ds ]]; then 
    
    log "Registering filesystems ..."
    hostname `hostname`.xrd.test
    eosfstregister -r manager /data default:1
    eosadmin root://manager node set @slavename@ on 
    
else
	log "Nothing to initialize." 
fi


