variable "app_count" {
  type = number
  default = 1
}

variable "aws_profile" {
  type = string
  default =  "default"
}

variable "aws_account" {
  type = string
  default =  "xxxx"
}

variable "aws_cloudwatch_region" {
  type = string
  default =  "us-east-1"
}

variable "ecs_api_cluster_name" {
  type = string
  default =  "payments_cluster"
}

variable "OTEL_EXPORTER_OTLP_ENDPOINT" {
  type = string
  default =  "http://localhost:4318"
}

variable "OTEL_ECS_SERVICE_NAME" {
  type = string
  default =  "payment"
}

variable "OTEL_SERVICE_NAMESPACE" {
  type = string
  default =  "digibank-backends"
}


variable "aws_demo_tag_env" {
  type = string
  default =  "demo-dev"
}

variable "aws_demo_tag_owner" {
  type = string
  default =  "ledeoliv"
}

variable "splunk_realm" {
  description = "splunk realm"

  type    = string
  default = ""
  
}

variable "splunk_access_token" {
  description = "splunk token"

  type    = string
  default = ""
  
}

variable "DEPLOYMENT_ENVIRONMENT" {
  type = string
  default =  "digibank-backends"
}