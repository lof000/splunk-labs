# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "digibank-demo" {
  name       = "digibank-demo"
  chart      = "./modules/digibank/digibank"

  force_update = true
  wait = true

  values = [
    file("${path.module}/digibank/values.yaml")
  ]

  set {
    name  = "configMap.visa.AWS_API_URL"
    value = "${var.lambda_gtw_endpoint}"
  }

  set {
    name  = "configMap.atm.IO_DIGISIC_BANK_ATM_HOST"
    value = "${var.ecs_elb_endpoint}"
  }

}


