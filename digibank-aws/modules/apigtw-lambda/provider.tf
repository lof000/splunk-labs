provider "aws" {
  region  = var.aws_cloudwatch_region
  profile = var.aws_profile
}

data "aws_region" "current" {
}

data "aws_availability_zones" "available" {
}

data "aws_caller_identity" "current" {
}

