

output "ecs_api_endpoint" {
  value = module.ecs_api.ecs_alb_api
}

output "lambda_function_name" {
  description = "Name of the Lambda function."

  value = module.apigtw_lambda.function_name
}

output "lambda_base_url" {
  description = "Base URL for API Gateway stage."

  value = module.apigtw_lambda.base_url
}

