

#general info#
aws_demo_tag_env = "splunkdigibank"
aws_demo_tag_owner = "ledeoiv"
aws_profile = "default"
aws_account = "992382551156"
aws_cloudwatch_region = "us-east-1"

ecs_cluster_name = "otel-collector"


#ecs api
ecs_api_cluster_name = "digibank_payments"
OTEL_SERVICE_NAMESPACE = "digibankAWS"

#splunk o11y variables
DEPLOYMENT_ENVIRONMENT = "digibankAWS"
splunk_realm = "us1"
splunk_access_token = "iQt9qOWrOwkWHil6wj-KXg"

#apigtw lambda --check AWS Region!!!
otel_layer = "arn:aws:lambda:us-east-1:254067382080:layer:splunk-apm:109"




