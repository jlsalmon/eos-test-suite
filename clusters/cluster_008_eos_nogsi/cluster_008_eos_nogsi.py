from XrdTest.ClusterUtils import Cluster, Network, Host, Disk 

def getCluster():
    cluster = Cluster()
    #---------------------------------------------------------------------------
    # Global names
    #---------------------------------------------------------------------------
    cluster.name = 'cluster_008_eos_nogsi' 
    network_name = cluster.name + '_net'
    
    #---------------------------------------------------------------------------
    # Cluster defaults
    #---------------------------------------------------------------------------
    cluster.defaultHost.bootImage = 'slc6_testslave_ref.img'
    cluster.defaultHost.cacheBootImage = True
    cluster.defaultHost.arch = 'x86_64'
    cluster.defaultHost.ramSize = '1048576'
    cluster.defaultHost.net = network_name
    
    #---------------------------------------------------------------------------
    # Network definition
    #---------------------------------------------------------------------------
    net = Network()
    net.bridgeName = 'virbr_008'
    net.name = network_name
    net.ip = '192.168.134.1'
    net.netmask = '255.255.255.0'
    net.DHCPRange = ('192.168.134.2', '192.168.134.254')

    #---------------------------------------------------------------------------
    # Host definitions
    #---------------------------------------------------------------------------
    manager = Host('manager.xrd.test', '192.168.134.4')
    ds1 = Host('ds1.xrd.test', '192.168.134.5')
    ds2 = Host('ds2.xrd.test', '192.168.134.6')
    ds3 = Host('ds3.xrd.test', '192.168.134.7')
    ds4 = Host('ds4.xrd.test', '192.168.134.8')
    client = Host('client.xrd.test', '192.168.134.9')
    
    #---------------------------------------------------------------------------
    # Additional host disk definitions
    #
    # As per the libvirt docs, the device name given here is not guaranteed to 
    # map to the same name in the guest OS. Incrementing the device name works
    # (i.e. disk1 = vda, disk2 = vdb etc.).
    #
    # Disk sizes should be larger than 10GB for data server nodes, otherwise 
    # the node might not be selected by the cmsd.
    #---------------------------------------------------------------------------
    manager.disks =  [Disk('disk1', '10G', device='vda', mountPoint='/data')]
    ds1.disks =  [Disk('disk1', '50G', device='vda', mountPoint='/data')]
    ds2.disks =  [Disk('disk1', '50G', device='vda', mountPoint='/data')]
    ds3.disks =  [Disk('disk1', '50G', device='vda', mountPoint='/data')]
    ds4.disks =  [Disk('disk1', '50G', device='vda', mountPoint='/data')]
    client.disks =  [Disk('disk1', '20G', device='vda', mountPoint='/data')]


    # Hosts to be included in the cluster
    hosts = [manager, ds1, ds2, ds3, ds4, client]

    net.addHosts(hosts)
    cluster.network = net
    cluster.addHosts(hosts)
    return cluster 
 
