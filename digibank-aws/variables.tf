variable "app_count" {
  type = number
  default = 1
}

variable "aws_demo_tag_env" {
  type = string
  default =  "xxx"
}

variable "aws_demo_tag_owner" {
  type = string
  default =  "xxx"
}

variable "aws_profile" {
  type = string
  default =  "xxxx"
}

variable "aws_account" {
  type = string
  default =  "xxx"
}

variable "aws_cloudwatch_region" {
  type = string
  default =  "xxxx"
}

variable "ecs_cluster_name" {
  type = string
  default =  "payments_cluster"
}

variable "OTEL_EXPORTER_OTLP_ENDPOINT" {
  type = string
  default =  "http://localhost:4318"
}

#variable "OTEL_SERVICE_NAME" {
#  type = string
#  default =  "pix"
#}

variable "OTEL_SERVICE_NAMESPACE" {
  type = string
  default =  "digibank-backends"
}

variable "ecs_api_cluster_name" {
  type = string
  default =  "payments_cluster"
}

variable "otel_layer" {
  description = "OTEL agent layer ARN"

  type    = string
  default = "arn:aws:lambda:us-east-1:254067382080:layer:splunk-apm:109"

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
  default =  "digibankAWS"
}

