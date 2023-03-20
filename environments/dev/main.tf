# Copyright 2019 Google LLC
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
# Added comment


locals {
  env = "dev"
}

provider "google" {
  project = "${var.project}"
}

module "vpc" {
  source  = "../../modules/vpc"
  project = "${var.project}"
  env     = "${local.env}"
}

module "http_server" {
  source  = "../../modules/http_server"
  project = "${var.project}"
  subnet  = "${module.vpc.subnet}"
  desired_status = "TERMINATED"
}

module "firewall" {
  source  = "../../modules/firewall"
  project = "${var.project}"
  subnet  = "${module.vpc.subnet}"
}

resource "google_compute_firewall_policy" "test_policy" {
  parent		= "organizations/490866986856"
  short_name		= "testpolicy"
  description		= "Test Policy"
  target_resources	= "${module.vpc.subnet}"
}

resource "google_compute_firewall_policy_rule" "test_policy_rule" {
  firewall_policy 	= google_compute_firewall_policy.test_policy.id
  description 		= "Test Policy Rule"
  priority 		= 9000
  enable_logging 	= true
  action 		= "allow"
  direction 		= "INGRESS"
  disabled 		= false
  match {
    layer4_configs {
      ip_protocol = "tcp"
      ports = [1521, 3306]
    }
    src_ip_ranges = ["0.0.0.0/0"]
  }
}
