#
# Copyright 2020 Google LLC
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

resource "google_compute_network" "tutorial" {
  name          = "tutorial"
}

resource "google_compute_subnetwork" "onprem" {
  name          = "onprem"
  ip_cidr_range = "10.2.1.0/24"
  region        = var.region
  network       = "tutorial"
}

resource "google_compute_subnetwork" "burst" {
  name          = "burst"
  ip_cidr_range = "10.2.2.0/24"
  region        = var.region
  network       = "tutorial"
}

resource "google_compute_router" "tutorial" {
  name    = "tutorial"
  network = "tutorial"
  region  = var.region
}

resource "google_compute_router_nat" "tutorial" {
  name                               = "tutorial"
  router                             = google_compute_router.tutorial.name
  region  = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_firewall" "default-iap-access" {
  name    = "default-iap-access"
  network = "tutorial"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "onprem-allow-internal" {
  name    = "onprem-allow-internal"
  network = "tutorial"
  description = "Allow internal traffic on the onprem network"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = [ "10.2.1.0/24" ]
}
resource "google_compute_firewall" "burst-allow-internal" {
  name    = "burst-allow-internal"
  network = "tutorial"
  description = "Allow internal traffic on the burst network"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = [ "10.2.2.0/24" ]
}
