# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "digibank-demo-load" {
  name       = "digibank-demo-load"
  chart      = "./modules/load/load"

  force_update = true
  wait = true

}


