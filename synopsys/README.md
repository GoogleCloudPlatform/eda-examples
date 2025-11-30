# Cluster Toolkit for Synopsys run and details

The page has a sample blueprint synopsys-blueprint.yaml which is design for EDA. It includes the following components: 

- Slurm cluster with H4D instances 
- Managed Lustre service - for apps directory
- Filestore service - for Home directory 
- License server
- Chrome Remote Desktop 

Please update the blueprint with the correct Project ID . Then use the following command to deploy the cluster: 

```
./gcluster deploy -w synopsys-blueprint.yaml
```

At finish, the cluster shall be up and running. It may take about an hour for the whole deployment: 

# Synopsys installation  

## List of files downloaded from Synopsys:

Download all these files from Synopsys SolvNetPlus Website:

- Installer binary: 
```
SynopsysInstaller_v5.9.run
```
- Synopsys Common Licensing (SCL) binary:
```
scl_v2025.03-SP2_common.spf
scl_v2025.03-SP2_linux64.spf
scl_v2025.03-SP2_linuxaarch64.spf
```
- hspice binary: 
```
hspice_vX-2025.06-SP1_linux64.spf
```
- VCS binary: 
```
vcs_vW-2024.09-SP2-5_common.spf
vcs_vW-2024.09-SP2-5_linux64.spf
vcs_vW-2024.09-SP2-5_linux64.spf.part00
vcs_vW-2024.09-SP2-5_linux64.spf.part01
vcs_vW-2024.09-SP2-5_linux64.spf.part02
```

## Installation of Synopsys software:

```
sudo yum install -y tcsh
sudo mkdir /apps/synopsys
sudo chmod 777 /apps/synopsys
sudo mkdir /apps/synopsys-source
sudo chmod 777 /apps/synopsys-source
cd /apps/synopsys-source
gcloud storage cp gs://<your-software-bucket>/* .
chmod 755 SynopsysInstaller_v5.9.run
./SynopsysInstaller_v5.9.run
./installer
```

Prompt will ask site ID, location of the spf files and installation location
It will find all spf files and install everything 


## License:

SSH to the license server:

Please make the Installer and Synopsys Common Licensing (SCL) binary available in the license server. Run the installer application at finish: one will see this message: 

Synopsys tools require that a supported version of Synopsys Common
Licensing (SCL) be installed and serving the necessary licenses.

There are couple pre-requisites and steps needed to activate the license server: 

```
sudo yum install -y fuse tcsh
```

use tcsh instead of bash and change to the binary location:
```
tcsh
cd /usr/synopsys/scl/2025.03-SP2/linux64/bin
```

As root: Run the following command:
```
./install_fnp.sh --cert
```
Output: 
Starting FNPLicensingService daemon as user thxxxxx
Licensing Service daemon activated

Checking FNPLicensingService is running
Configuration completed successfully.

Then running the lmhostid command to obtain the lmhostid for license file generation:
```
lmhostid -ptype VM -uuid
```

Output: 
lmhostid - Copyright (c) 1989-2024 Flexera. All Rights Reserved.
The FlexNet host ID of this machine is "VM_UUID=1xxxxxxxxxxxxxxxxxxxx"

This UUID needs to be given to Synopsys for license file generation. 

### Applying license file:

WIP

## Sample hspice job:

User can submit the job by leveaging the hspice-sample.job file in this repo: 

Submit the job: 

```batch
sbatch hspice-sample.job
```
