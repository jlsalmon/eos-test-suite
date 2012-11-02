#!/bin/bash
source /etc/XrdTest/utils/functions.sh

##################################

CLUSTER_NAME=cluster_008_eos_nogsi
CONFIG_FILE=eos_nogsi.xrd.cf.mgm
CONFIG_PATH=/etc/xrd.cf.mgm

##################################

#---------------------------------------------------------------------------------------------------------
log "Initializing test suite on slave" @slavename@ "..."

log "Fetching stable xrootd build ..."

XRD_VERSION_SCRIPT=get_xrd_stable.py

mkdir -p tmp_initsh
cd tmp_initsh

curl -sSkO "@proto@://master.xrd.test:@port@/showScript/utils/$XRD_VERSION_SCRIPT" > /dev/null
chmod 755 $XRD_VERSION_SCRIPT
rm -rf xrd_rpms
python $XRD_VERSION_SCRIPT
rm -rf xrd_rpms/slc-6-x86_64/xrootd-*.src.*.rpm
rm -rf xrd_rpms/slc-6-x86_64/xrootd-*-devel-*.rpm

#---------------------------------------------------------------------------------------------------------
log "Installing xrootd packages ..."

COMMAND=(rpm -U \
xrd_rpms/slc-6-x86_64/xrootd-libs-3*.rpm \
xrd_rpms/slc-6-x86_64/xrootd-client-3*.rpm \
xrd_rpms/slc-6-x86_64/xrootd-client-admin-perl-3*.rpm \
xrd_rpms/slc-6-x86_64/xrootd-fuse-3*.rpm \
xrd_rpms/slc-6-x86_64/xrootd-server-3*.rpm \
xrd_rpms/slc-6-x86_64/xrootd-debuginfo-3*.rpm)

if "${COMMAND[@]}"; then log "xrootd packages upgraded."; fi

stamp rpm -qa | grep xroot

cd ..

#---------------------------------------------------------------------------------------------------------
log "Fetching stable eos build ..."

EOS_VERSION_SCRIPT=get_eos_stable.py

mkdir -p tmp_initsh
cd tmp_initsh

curl -sSkO "@proto@://master.xrd.test:@port@/showScript/utils/$EOS_VERSION_SCRIPT" > /dev/null
chmod 755 $EOS_VERSION_SCRIPT
rm -rf eos_rpms
python $EOS_VERSION_SCRIPT
rm -rf eos_rpms/slc-6-x86_64/eos-*.src.*.rpm

#---------------------------------------------------------------------------------------------------------
log "Installing eos packages ..."

yum -y -q install perl-TermReadKey perl-Time-HiRes

COMMAND=(rpm -U \
eos_rpms/slc-6-x86_64/eos-client-*.rpm \
eos_rpms/slc-6-x86_64/eos-server-*.rpm \
eos_rpms/slc-6-x86_64/eos-fuse-*.rpm \
eos_rpms/slc-6-x86_64/eos-test-*.rpm \
eos_rpms/slc-6-x86_64/eos-testkeytab-*.rpm \
eos_rpms/slc-6-x86_64/eos-debuginfo-*.rpm)

if "${COMMAND[@]}"; then log "eos packages upgraded."; fi

stamp rpm -qa | grep eos

cd ..

# extracting machine name from hostname
arr=($(echo @slavename@ | tr "." " "))
NAME=${arr[0]}

#---------------------------------------------------------------------------------------------------------
log "Mounting storage disks for machine $NAME ..."

# Will be replaced by appropriate mount commands for each slave
@diskmounts@

#---------------------------------------------------------------------------------------------------------
log "Configuring eos ..."

if [[ @slavename@ =~ ds ]]; then

echo "
DAEMON_COREFILE_LIMIT=unlimited
XRD_ROLES=\"fst\"
export EOS_BROKER_URL=root://manager.xrd.test:1097//eos/
" > /etc/sysconfig/eos

elif [[ @slavename@ =~ manager ]]; then

echo "
DAEMON_COREFILE_LIMIT=unlimited
export XRD_ROLES=\"mq mgm\"
export EOS_INSTANCE_NAME=eostest
export EOS_AUTOLOAD_CONFIG=\"default\"
export EOS_BROKER_URL=\"root://localhost:1097//eos/\"
export EOS_MGM_MASTER1=manager.xrd.test
export EOS_MGM_MASTER2=manager.xrd.test
export EOS_MGM_ALIAS=manager.xrd.test
export EOS_MGM_FAILOVERTIME=300
export KRB5RCACHETYPE=none #disable krb5 replay cache      
" > /etc/sysconfig/eos

fi 

curl -sSkO "@proto@://master.xrd.test:@port@/downloadScript/clusters/${CLUSTER_NAME}/${CONFIG_FILE}" > /dev/null
mv $CONFIG_FILE $CONFIG_PATH

mkdir -p /var/eos/config/@slavename@
touch /var/eos/config/@slavename@/default.eoscf
chown daemon:daemon /var/eos/config/@slavename@/default.eoscf

if [[ @slavename@ =~ ds ]]; then
    
    log "Cleaning up ..."
    test -e /data/.eosfsuuid && unlink /data/.eosfsuuid
    test -e /data/.eosfsid && unlink /data/.eosfsid
    rm -rf /data/*
    
    log "Starting eos ..."
    stamp service eos restart
    chown -R daemon:daemon /data/
    
elif [[ @slavename@ =~ manager ]]; then
    
    log "Cleaning up ..."    
    service eos stop
    rm -rf /var/eos/md/files*.mdlog
    rm -rf /var/eos/md/directores*.mdlog
    
    log "Starting eos ..."
    stamp service eos restart
    
    eos -b config reset
    eos -b space define default 4 4
    eos -b group set default on
    eos -b space set default on 
    eos -b vid enable sss
    eos -b node set ds1.xrd.test on
    eos -b node set ds2.xrd.test on
    eos -b node set ds3.xrd.test on
    eos -b node set ds4.xrd.test on
    eos -b node config * publish.interval=60
    
fi


log "Suite initialization complete."
