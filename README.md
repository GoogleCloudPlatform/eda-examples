# Google Cloud Platform EDA Example 

This github repo contains examples for deploying common EDA applications with Google Cloud Platform Cluster Toolkit. 

1. Creating the HPC cluster for EDA workload
    1. Slurm Cluster - with latest H4D instance(s)
    2. Storage - Managed Lustre and Filestore
        1. Managed Lustre
        2. Filestore
2. Synopsys application
    1. Installation of software
    2. VCS sample run
    3. HSPICE sample run

## Cluster setup

We are using the Google Cloud Platform Cluster Toolkit to create a new cluster. 

By using the Cluster Toolkit blueprint yaml:
```
h4d-slurm-lustre-crd.yaml
```

This sample blueprint has Slurm setup with Managed Lustre for H4D instances. Chrome Remote Desktop node is also added to this blueprint. 

Once the setup of the Cluster Toolkit, one can run the following 

```
./gcluster deploy -w hpc-slurm-h4d.yaml
```
After the cluster setup (about 45mins), login to the slurm login node and we can see the sinfo and lustre file system: 

Slurm cluster:
```
$ sinfo
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
h4d*         up   infinite      2  down# slurmh4d-h4dnodeset-[0-1]
```

Storage: 
```
$ df -h
Filesystem                     Size  Used Avail Use% Mounted on
devtmpfs                       7.7G     0  7.7G   0% /dev
tmpfs                          7.7G     0  7.7G   0% /dev/shm
tmpfs                          7.7G  8.5M  7.7G   1% /run
tmpfs                          7.7G     0  7.7G   0% /sys/fs/cgroup
/dev/sda2                       50G   20G   31G  39% /
/dev/sda1                      200M  5.9M  194M   3% /boot/efi
tmpfs                          1.6G     0  1.6G   0% /run/user/0
10.x.x.x@tcp:/lustrefs         35T   22M   35T   1% /data
10.x.x.x:/homeshare        2.5T     0  2.4T   0% /home
slurmh4d-controller:/opt/apps   50G   20G   31G  39% /opt/apps
tmpfs                          1.6G     0  1.6G   0% /run/user/1911945234
```

