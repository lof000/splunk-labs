

resource "random_pet" "lambda_bucket_name" {
  prefix = "learn-terraform-functions"
  length = 4
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = random_pet.lambda_bucket_name.id
}


data "archive_file" "lambda_payment" {
  type = "zip"

  source_dir  = "${path.module}/hello-world"
  output_path = "${path.module}/hello-world.zip"
}

resource "aws_s3_object" "lambda_payment" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "hello-world.zip"
  source = data.archive_file.lambda_payment.output_path

  etag = filemd5(data.archive_file.lambda_payment.output_path)

  tags = {
    demoenv = "${var.aws_demo_tag_env}",
    demoowner = "${var.aws_demo_tag_owner}"
  }

}

resource "aws_lambda_function" "lambdaConfirmPayment" {
  function_name = "lambdaConfirmPayment"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_payment.key

  runtime = "nodejs16.x"
  handler = "hello.handler"

  #adding otel instrumentation layer
  layers = [ var.otel_layer ]

  #adding otel instrumentation variables
  environment {
    variables = {
      AWS_LAMBDA_EXEC_WRAPPER = "/opt/nodejs-otel-handler"
      SPLUNK_ACCESS_TOKEN = "${var.splunk_access_token}"
      SPLUNK_REALM = "${var.splunk_realm}"
      OTEL_SERVICE_NAME = "${var.OTEL_LAMBDA_SERVICE_NAME}"
      OTEL_RESOURCE_ATTRIBUTES = "deployment.environment=${var.DEPLOYMENT_ENVIRONMENT},service.version=1"
      OTEL_TRACES_SAMPLER = "always_on"
    }
  }
  
  source_code_hash = data.archive_file.lambda_payment.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  tags = {
    demoenv = "${var.aws_demo_tag_env}",
    demoowner = "${var.aws_demo_tag_owner}"
  }

}

resource "aws_cloudwatch_log_group" "lambdaConfirmPayment" {
  name = "/aws/lambda/${aws_lambda_function.lambdaConfirmPayment.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_apigatewayv2_api" "lambda" {
  name          = "serverless_lambda_gw"
  protocol_type = "HTTP"
  
  tags = {
    demoenv = "${var.aws_demo_tag_env}",
    demoowner = "${var.aws_demo_tag_owner}"
  }

}

resource "aws_apigatewayv2_stage" "lambda" {
  api_id = aws_apigatewayv2_api.lambda.id

  name        = "serverless_lambda_stage"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }


}

resource "aws_apigatewayv2_integration" "lambdaConfirmPayment" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = aws_lambda_function.lambdaConfirmPayment.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "lambdaConfirmPayment" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "GET /confirmPayment"
  target    = "integrations/${aws_apigatewayv2_integration.lambdaConfirmPayment.id}"
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"

  retention_in_days = 30
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambdaConfirmPayment.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}
