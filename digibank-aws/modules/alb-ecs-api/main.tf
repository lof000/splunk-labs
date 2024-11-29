
resource "aws_iam_policy" "AppDynamicsInframonECSPolicy" {
  name        = "AppDynamicsInframonECSPolicy"
  description = "AppDynamcis ECS Policy "

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": "*",
      "Action": [
        "ecs:Describe*",
        "ecs:List*"
      ]
    }
  ]
}

EOF
}

#resource "aws_iam_role_policy_attachment" "test-attach" {
#  role       = "ecsTaskExecutionRole"
#  policy_arn = "${aws_iam_policy.AppDynamicsInframonECSPolicy.arn}"
#}

data "aws_availability_zones" "available_zones" {
  state = "available"
}

resource "aws_vpc" "default" {
  cidr_block = "10.32.0.0/16"
}

resource "aws_subnet" "public" {
  count                   = 2
  cidr_block              = cidrsubnet(aws_vpc.default.cidr_block, 8, 2 + count.index)
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id                  = aws_vpc.default.id
  map_public_ip_on_launch = true

  
}

resource "aws_subnet" "private" {
  count             = 2
  cidr_block        = cidrsubnet(aws_vpc.default.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id            = aws_vpc.default.id
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.default.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}

resource "aws_eip" "gateway" {
  count      = 2
  vpc        = true
  depends_on = [aws_internet_gateway.gateway]
}

resource "aws_nat_gateway" "gateway" {
  count         = 2
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  allocation_id = element(aws_eip.gateway.*.id, count.index)
}

resource "aws_route_table" "private" {
  count  = 2
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.gateway.*.id, count.index)
  }
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_security_group" "lb" {
  name        = "api-alb-security-group"
  vpc_id      = aws_vpc.default.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    demoenv = "${var.aws_demo_tag_env}",
    demoowner = "${var.aws_demo_tag_owner}"
  }

}

resource "aws_lb" "default" {
  name            = "payments-api-lb"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.lb.id]

  tags = {
    demoenv = "${var.aws_demo_tag_env}",
    demoowner = "${var.aws_demo_tag_owner}"
  }
}

resource "aws_lb_target_group" "credit_card" {
  name        = "api-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.default.id
  target_type = "ip"
  health_check {
    enabled = true
    path = "/v3.1/nodes/atms?zip=14758&radius=10"
    interval = 120
    timeout = 60
    unhealthy_threshold = 10
  }
}

resource "aws_lb_listener" "credit_card" {
  load_balancer_arn = aws_lb.default.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.credit_card.id
    type             = "forward"
  }
}

resource "aws_cloudwatch_log_group" "credit" {
  name = "credit"

}

resource "aws_ecs_task_definition" "credit_card" {
  family                   = "credit-card-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 3072
  execution_role_arn = "arn:aws:iam::${var.aws_account}:role/ecsTaskExecutionRole"
  task_role_arn = "arn:aws:iam::${var.aws_account}:role/ecsTaskExecutionRole"

  tags = {
    demoenv = "${var.aws_demo_tag_env}",
    demoowner = "${var.aws_demo_tag_owner}"
  }

#      "image":"leandrovo/digitalbank-backends-otel-agent:aws",
#            "value":"-javaagent:/opt/agent/opentelemetry-javaagent.jar"

  container_definitions = <<DEFINITION
[
   {
      "image":"leandrovo/digitalbank-backends-otel-agent:splunk",
      "cpu":1024,
      "memory":2048,
      "name":"credit-card-app",
      "networkMode":"awsvpc",
      "essential":true,
      "logConfiguration":{
         "logDriver":"awslogs",
         "options":{
            "awslogs-create-group":"True",
            "awslogs-group":"credit",
            "awslogs-region":"${var.aws_cloudwatch_region}",
            "awslogs-stream-prefix":"ecs"
         }
      },
      "portMappings":[
         {
            "name":"backend_api-8081-tcp",
            "containerPort":8081,
            "hostPort":8081,
            "protocol":"tcp",
            "appProtocol":"http"
         }
      ],
      "environment":[
         {
            "name":"OTEL_EXPORTER_OTLP_ENDPOINT",
            "value":"${var.OTEL_EXPORTER_OTLP_ENDPOINT}"
         },
         {
            "name":"OTEL_RESOURCE_ATTRIBUTES",
            "value":"service.name=${var.OTEL_ECS_SERVICE_NAME},service.namespace=${var.OTEL_SERVICE_NAMESPACE},deployment.environment=${var.DEPLOYMENT_ENVIRONMENT},service.version=1"
         },
         {
            "name":"OTEL_EXPORTER_OTLP_PROTOCOL",
            "value":"http/protobuf"
         },
         {
            "name":"OTEL_LOGS_EXPORTER",
            "value":"none"
         },
         {
            "name":" SLOW_REGION",
            "value":"SP"
         },
         {
            "name":"SLOW_TIME",
            "value":"5000"
         },
         {
            "name":"JAVA_TOOL_OPTIONS",
            "value":"-javaagent:/opt/agent/opentelemetry-javaagent.jar -Dsplunk.profiler.enabled=true -Dsplunk.profiler.memory.enabled=true "
         },
         {
            "name":"SLOW_ZIP",
            "value":"14759"
         },
         {
            "name":"ERROR_ZIP",
            "value":"15000"
         }
      ]
   },
   {
      "image":"quay.io/signalfx/splunk-otel-collector:latest",
      "name":"splunk-otel-collector",
      "networkMode":"awsvpc",
      "essential":true,
      "logConfiguration":{
         "logDriver":"awslogs",
         "options":{
            "awslogs-create-group":"True",
            "awslogs-group":"credit",
            "awslogs-region":"${var.aws_cloudwatch_region}",
            "awslogs-stream-prefix":"ecs"
         }
      },
      "environment":[
          {
            "name": "SPLUNK_ACCESS_TOKEN",
            "value": "${var.splunk_access_token}"
          },
          {
            "name": "SPLUNK_REALM",
            "value": "${var.splunk_realm}"
          },
          {
            "name": "SPLUNK_CONFIG",
            "value": "/etc/otel/collector/fargate_config.yaml"
          },
          {
            "name": "ECS_METADATA_EXCLUDED_IMAGES",
            "value": "[\"quay.io/signalfx/splunk-otel-collector:latest\"]"
          },
          {
            "name": "METRICS_TO_EXCLUDE",
            "value": "[]"
          }
      ]
   }
]
DEFINITION

}

resource "aws_security_group" "credit_card_task" {
  name        = "example-task-security-group"
  vpc_id      = aws_vpc.default.id

  ingress {
    protocol        = "tcp"
    from_port       = 4317
    to_port         = 8081
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "main" {
  name = "${var.ecs_api_cluster_name}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    demoenv = "${var.aws_demo_tag_env}",
    demoowner = "${var.aws_demo_tag_owner}"
  }
}

resource "aws_ecs_service" "credit_card" {
  name            = "credit-card-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.credit_card.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.credit_card_task.id]
    subnets         = aws_subnet.private.*.id
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.credit_card.id
    container_name   = "credit-card-app"
    container_port   = 8081
  }

  depends_on = [aws_lb_listener.credit_card]
}


