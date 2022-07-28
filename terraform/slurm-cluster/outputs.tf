#
# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#output "login_network_ips" {
  #value = "${module.slurm_cluster_login.instance_network_ips}"
#}
output "login_message" {
  value = <<-EOS
    Slurm is currently being installed/configured in the background
    Partitions will be marked down until the compute image has been created.
    This usually takes ~5 mins, but depends on cluster settings.

    /home on the controller and login nodes will be mounted over the existing
    /home. Any changes in /home will be hidden. Please wait until the
    installation is complete before making changes in your home directory.

  EOS
}
