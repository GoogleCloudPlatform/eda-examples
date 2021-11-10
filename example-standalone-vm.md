# Using Standalone VMs to optimize performance and cost for EDA

Google cloud provides a broad set of [machine types](https://cloud.google.com/compute/docs/machine-types#machine_type_comparison), [GPUs](https://cloud.google.com/compute/docs/gpus), and [storage options](https://cloud.google.com/compute/docs/disks). 
Lots of folks want to test various "shapes" of compute and storage to determine the best number
of cores, memory, and storage type and amount for a particular EDA job. 

In this tutorial, we provide Terraform templates to help you quickly and easily stand up the following types of resources to test different sizes and types of instances for your own experiments. 

| Template Name | `machine-type` | Chipset | vCpus | Memory (GB) | Available Storage |
| --- | --- | --- | --- | --- | --- |
| eda-n2-0 | `n2-standard-2` | Cascade Lake | 2 | 8 | PersistentDisk, LocalSSD, NFS |
| eda-n2d-0 | `n2d-highmem-2` | EPYC Rome | 2 | 16 | PersistentDisk, LocalSSD, NFS |
| eda-c2-0 | `c2-standard-4` | Cascade Lake | 4 | 16 | PersistentDisk, LocalSSD, NFS |
| ... | ... | ... | ... | ... | ... |


The current templates provided start the specified machine types and mount the
various storage volumes that are created.

You can adjust these templates to your own interests by adding different sizes and classes of
machine types `m2`, `e2`, etc. using the
[GCP machine type comparison](https://cloud.google.com/compute/docs/machine-types#machine_type_comparison)
for reference. Machine types should be finalized after validation in production or
pre-production environment. Machine recommendations in this document are
provided to guide infrastructure planning. They are deliberately simplified for
clarity and lack significant details required for production-worthy
infrastructure implementation. _NOTE:_ You will need to check for machine type availability in the region you're intending to run EDA workloads in, as well as potentially ask for more quota for certain machine types before production runs. 


## Costs

If you run the example commands below, you will use billable components of
Google Cloud Platform, including:

- Compute Engine
- Cloud Filestore

You can use the
[Pricing Calculator](https://cloud.google.com/products/calculator)
to generate a cost estimate based on your projected usage.


## Before you begin

Start by opening
[https://console.cloud.google.com/](https://console.cloud.google.com/)
in a browser.

Create a new GCP Project using the
[Cloud Resource Manager](https://console.cloud.google.com/cloud-resource-manager).
The project you create is just for this example, so you'll delete it below
when you're done.

You will need to
[enable billing](https://support.google.com/cloud/answer/6293499#enable-billing)
for this project.

You will also need to enable the Compute Engine (GCE) service for this account

[Enable Example Services](https://console.cloud.google.com/flows/enableapi?apiid=compute.googleapis.com,file.googleapis.com,cloudresourcemanager.googleapis.com)
    
Next, make sure the project you just created is selected in the top of the
Cloud Console.

Then open a Cloud Shell associated with the project you just created

[Launch Cloud Shell](https://console.cloud.google.com/?cloudshell=true)

It's important that the current Cloud Shell project is the one you just
created.  Verify that

```bash
echo $GOOGLE_CLOUD_PROJECT
```

shows that new project.

All example commands below run from this Cloud Shell.


## Example source

Get the source

```bash
git clone https://github.com/GoogleCloudPlatform/eda-examples
cd eda-examples
```

All example commands below are relative to this top-level directory of the
examples repo.


## Tools

We use [Terraform](terraform.io) for these examples which is
already installed in your GCP Cloudshell. The version of Terraform that has been tested with these templates is `v0.12.24`. 

## Create a license server

Create an instance used to run a license manager in GCP.

```bash
cd terraform/licensing
terraform init
terraform plan
```
The output from above will show the resources that Terraform will create. This shows creation of an example instance and shows how license manager binaries and
dependencies can be installed using `provision.sh` during instance creation.

Once you review the plan, execute the following to apply the plan and launch the license server VM.

```bash
terraform apply
```

## Create NFS volumes

Create two NFS volumes using Google Cloud Filestore.  One for `/home` (3TB) and
one for `/tools` (3TB).

```bash
cd ../storage
terraform init
terraform plan
terraform apply
```

**Note:** if you get an error that the Google Cloud Filestore API has not been used, navigate to the [Cloud Filestore console page](https://console.cloud.google.com/filestore) and enable the API. Once the API has been enabled, run the `terraform apply` command once again. 

**Note:** It can take a few minutes for the volume creation to complete. Wait for the resources to be created before taking the next steps.  


## Create a test matrix of standalone VMs

Next, you will spin up the following test matrix of VM configurations:

| Name | `machine-type` | Chipset | vCpus | Memory (GB) | Available Storage |
| --- | --- | --- | --- | --- | --- |
| eda-n2-0 | `n2-standard-2` | Cascade Lake | 2 | 8 | PersistentDisk, LocalSSD, NFS |
| eda-n2d-0 | `n2d-highmem-2` | EPYC Rome | 2 | 16 | PersistentDisk, LocalSSD, NFS |
| eda-c2-0 | `c2-standard-4` | Cascade Lake | 4 | 16 | PersistentDisk, LocalSSD, NFS |

**Note:** If you would like to test a different set of VMs, edit `main.tf` to create your own test matrix on subsequent example runs.

Change to the standalone compute templates directory and spin  up the VMs:

```bash
cd ../standalone-compute
terraform init
terraform plan
terraform apply
```

Wait for the resources to be created. You can check on what was created using the `gcloud` CLI 
```bash
gcloud compute instances list
```

which should produce output like the following

```
NAME            ZONE           MACHINE_TYPE    PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP     STATUS
eda-c2-0        us-central1-f  c2-standard-4                10.128.0.29  34.67.237.187   RUNNING
eda-n2-0        us-central1-f  n2-standard-2                10.128.0.27  35.224.171.205  RUNNING
eda-n2d-0       us-central1-f  n2d-highmem-2                10.128.0.28  35.232.69.56    RUNNING
license-server  us-central1-f  n2d-standard-2               10.128.0.26  35.184.28.204   RUNNING
```


## Log in and run a common test suite

Once the test nodes are up, you are ready to run various standalone jobs. Here,
we'll use the popular [Phoronix Test
Suite](https://www.phoronix-test-suite.com/) as an example standalone node test
platform.

For each VM, log into that node using the `gcloud` CLI within the console, using the format of 

```bash
gcloud compute ssh $VM_NAME --zone $VM_ZONE
```

As an example, here we log into the `eda-n2-0` instance that was created by terraform in the previous step. 

```bash
gcloud compute ssh eda-n2-0 --zone us-central1-f
```

At the prompt, install some dependencies for the Phoronix test suite

```bash
sudo yum install -y wget php-cli php-xml bzip2
```

then download and install the Phoronix Test Suite

```bash
wget https://phoronix-test-suite.com/releases/phoronix-test-suite-8.4.1.tar.gz
tar xvfz phoronix-test-suite-8.4.1.tar.gz
cd phoronix-test-suite
sudo ./install-sh
```

Once the installation completes, you can see the available tests using the following command

```bash
phoronix-test-suite list-available-tests
```

## Run an EDA job

Here, we'll run an example open source functional verification regression
using an open source simulator (Icarus).

From each VM, install some dependencies for the verification tool-chain

```bash
sudo yum -y install cpp iverilog tcsh glibc.i686 elfutils-libelf-devel perl-Bit-Vector perl-Data-Dumper
```

Next, download an example design project from

```bash
wget https://github.com/PrincetonUniversity/openpiton/archive/openpiton-19-10-23-r13.tar.gz
```

Extract this

```bash
tar xzvf openpiton-19-10-23-r13.tar.gz
cd openpiton-openpiton-19-10-23-r13
```

Next you need to update the environment to set up the execution context:

- Set up the `PITON_ROOT` environment variable

```bash
export PITON_ROOT=`pwd`
```

- Set up simulator home

```bash
export ICARUS_HOME=/usr
```

- Source required settings

```bash
source $PITON_ROOT/piton/piton_settings.bash
```

- Run the simulations on the current node using the following command

```bash
sims -sim_type=icv -group=tile1_mini
```

This creates a directory for results and execution logs which you can use to compare against other instance types and sizes in order to choose the right combinations of instance CPU, memory, and storage. You can also install a [Stackdriver monitoring agent](https://cloud.google.com/monitoring/agent/installation) to send fine-grained metrics to [Cloud Monitoring](https://cloud.google.com/monitoring). 


## Cleaning up

To avoid incurring charges to your Google Cloud Platform account for the
resources used in this tutorial:

### Delete the project using the GCP Cloud Console

The easiest way to clean up all of the resources used in this tutorial is
to delete the project that you initially created for the tutorial.

Caution: Deleting a project has the following effects:

- Everything in the project is deleted. If you used an existing project for
  this tutorial, when you delete it, you also delete any other work you've done
  in the project.

- Custom project IDs are lost. When you created this project, you might have
  created a custom project ID that you want to use in the future. To preserve
  the URLs that use the project ID, such as an appspot.com URL, delete selected
  resources inside the project instead of deleting the whole project.

1. In the GCP Console, go to the Projects page.

    GO TO THE PROJECTS PAGE

2. In the project list, select the project you want to delete and click Delete
   delete.
3. In the dialog, type the project ID, and then click Shut down to delete the
   project.

### Deleting resources using Terraform

Alternatively, if you added the tutorial resources to an _existing_ project, you
can still clean up those resources using Terraform.

From the `eda-examples` git project root directory, run the following in this order:

```bash
cd terraform/standalone-compute
terraform destroy -auto-approve
cd ../storage
terraform destroy -auto-approve
cd ../licensing
terraform destroy -auto-approve
```

## What's next

There are so many exciting directions to take to learn more about what you've
done here!

- Infrastructure.  Learn more about
  [Cloud](https://cloud.google.com/),
  High Performance Computing (HPC) on GCP
  [reference architectures](https://cloud.google.com/solutions/hpc/) and 
  [posts](https://cloud.google.com/blog/topics/hpc).

