# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "region" {
  default = "us-xxx-2"
}

variable "lambda_gtw_endpoint" {
  type = string
  default = "xxx"
}

variable "ecs_elb_endpoint" {
  type = string
  default = "xxx"
}