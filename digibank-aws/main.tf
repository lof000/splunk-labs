

module "ecs_api" {
  source = "./modules/alb-ecs-api"

  aws_profile = "${var.aws_profile}"
  aws_account = "${var.aws_account}"
  aws_cloudwatch_region = "${var.aws_cloudwatch_region}"
  aws_demo_tag_env = "${var.aws_demo_tag_env}"
  aws_demo_tag_owner = "${var.aws_demo_tag_owner}"
  ecs_api_cluster_name = "${var.ecs_api_cluster_name}"
  OTEL_ECS_SERVICE_NAME = "visapayment"
  OTEL_SERVICE_NAMESPACE = "${var.OTEL_SERVICE_NAMESPACE}"
  OTEL_EXPORTER_OTLP_ENDPOINT = "http://localhost:4318"
  splunk_access_token = "${var.splunk_access_token}"
  splunk_realm = "${var.splunk_realm}"
  DEPLOYMENT_ENVIRONMENT = "${var.DEPLOYMENT_ENVIRONMENT}"

}

module "apigtw_lambda" {
  source = "./modules/apigtw-lambda"

  aws_profile = "${var.aws_profile}"
  aws_account = "${var.aws_account}"
  aws_cloudwatch_region = "${var.aws_cloudwatch_region}"
  aws_demo_tag_env = "${var.aws_demo_tag_env}"
  aws_demo_tag_owner = "${var.aws_demo_tag_owner}"  
  otel_layer = "${var.otel_layer}"
  #otel_otlp_endpoint = "http://localhost:4317"
  splunk_access_token = "${var.splunk_access_token}"
  splunk_realm = "${var.splunk_realm}"
  DEPLOYMENT_ENVIRONMENT = "${var.DEPLOYMENT_ENVIRONMENT}"  
  OTEL_LAMBDA_SERVICE_NAME = "lambdaConfirmPayment"
}

module "digibank" {
  source = "./modules/digibank"

  region = "${var.aws_cloudwatch_region}"
  lambda_gtw_endpoint = "${module.apigtw_lambda.base_url}/confirmPayment?Name=Terraform"
  ecs_elb_endpoint = "${module.ecs_api.ecs_alb_api}"

}


module "digibank-load" {
  source = "./modules/load/load"

}

#resource "null_resource" "otelinstrument" {
#  provisioner "local-exec" {
#    command = "./otel_instrument.sh"
#  }
#depends_on = [
#    module.digibank
#  ]
#}
