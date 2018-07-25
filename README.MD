# NFS as service
Exposing NFS as service using HAPROXY with Active/Passive mode.

# Prerequisites :
    1. Kuberneties Environment
    2. NFS 

# POC:
    Assuming we are not having NFS & exposing it throgh docker containers.
    
    $ docker run -d --name nfs0 --privileged -v /tmp/nfs0:/nfsshare -e SHARED_DIRECTORY=/nfsshare itsthenetwork/nfs-server-alpine:latest
    $ docker run -d --name nfs1 --privileged -v /tmp/nfs1:/nfsshare -e SHARED_DIRECTORY=/nfsshare itsthenetwork/nfs-server-alpine:latest
    $ docker run -d --name nfs2 --privileged -v /tmp/nfs2:/nfsshare -e SHARED_DIRECTORY=/nfsshare itsthenetwork/nfs-server-alpine:latest

    1] Create/Update nfs.txt:
        Create/Update nfs.txt with ip of nfs0, nfs1 and nfs2 each on one line
        eg.
        172.17.0.4:2049
        172.17.0.6:2049
        172.17.0.8:2049
    
    2] Keep haproxy.cnf as it is.

    3] Build HAPROXY docker image.
        $ docker build -t "haproxy" .
    
    4] Deploy HAPROXY:
        $ kubectl create -f app.yaml
        This will create StatefulSet in kubernets.
    
    5] Mount nfs:
        $ sudo mount -t nfs -v -o port=80 -o vers=4,loud <HAPROXY POD IP>:/ <MOUNT POINT>

# Deployment Architecture:

    haproxy-0 ----- nfs-0
    haproxy-1 ----- nfs-2
    :
    :
    haproxy-n ----- nfs-n
    
    Every HAPROXY pod has its own primary NFS and rest will be secondary. For haproxy-0 server nfs-0 is primary and rest are secondary. Secondary servers will be used only when primary is down.
    nfs-n will be used only when nfs-0 and nfs-1 are down. If we want to use all backup servers when primary is down we can do it by enabling the option allbackups in HAProxy configuration.
    
    HAPROXY configration is taken care by entrypoint.sh which take nfs.txt as input and create appropriate haproxy.cfg for every HAPROXY POD (replica) to get above discussed architecture.

# References:
	https://www.haproxy.com/blog/failover-and-worst-case-management-with-haproxy/
	https://hub.docker.com/r/itsthenetwork/nfs-server-alpine/