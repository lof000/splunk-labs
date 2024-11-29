
variable "aws_demo_tag_env" {
  type = string
  default =  "xx-xx"
}

variable "aws_demo_tag_owner" {
  type = string
  default =  "xx"
}

variable "aws_profile" {
  type = string
  default =  "default"
}

variable "aws_account" {
  type = string
  default =  "xxx"
}

variable "aws_cloudwatch_region" {
  type = string
  default =  "us-xxx-1"
}

variable "otel_layer" {
  description = "OTEL agent layer ARN"

  type    = string
  default = "arn:aws:lambda:us-east-1:254067382080:layer:splunk-apm:109"

}

variable "otel_otlp_endpoint" {
  description = "OTEL agent layer ARN"

  type    = string
  default = "http://localhost:4318"
  
}

variable "OTEL_LAMBDA_SERVICE_NAME" {
  type = string
  default =  "refund"
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

variable "OTEL_SERVICE_NAMESPACE" {
  type = string
  default =  "digibank-backends"
}

variable "DEPLOYMENT_ENVIRONMENT" {
  type = string
  default =  "digibank-backends"
}

