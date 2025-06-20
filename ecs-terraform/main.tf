# Fetch available availability zones
data "aws_availability_zones" "available_zones" {
  state = "available"
}

# Fetch the default VPC
data "aws_vpc" "default" {
  default = true
}

# Fetch the default subnets associated with the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security group for the load balancer
resource "aws_security_group" "lb" {
  name        = "api-alb-security-group"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    demoenv   = "${var.aws_demo_tag_env}"
    demoowner = "${var.aws_demo_tag_owner}"
  }
}

# Application Load Balancer
resource "aws_lb" "default" {
  name            = "payments-api-lb"
  subnets         = data.aws_subnets.default.ids
  security_groups = [aws_security_group.lb.id]

  tags = {
    demoenv   = "${var.aws_demo_tag_env}"
    demoowner = "${var.aws_demo_tag_owner}"
  }
}

# Load Balancer Target Group
resource "aws_lb_target_group" "credit_card" {
  name        = "api-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"
  health_check {
    enabled             = true
    path                = "/v3.1/nodes/atms?zip=14758&radius=10"
    interval            = 120
    timeout             = 60
    unhealthy_threshold = 10
  }
}

# Load Balancer Listener
resource "aws_lb_listener" "credit_card" {
  load_balancer_arn = aws_lb.default.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.credit_card.id
    type             = "forward"
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "credit" {
  name = "credit"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "credit_card" {
  family                   = "credit-card-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 3072
  execution_role_arn       = "arn:aws:iam::${var.aws_account}:role/ecsTaskExecutionRole"
  task_role_arn            = "arn:aws:iam::${var.aws_account}:role/ecsTaskExecutionRole"

  tags = {
    demoenv   = "${var.aws_demo_tag_env}"
    demoowner = "${var.aws_demo_tag_owner}"
  }

  container_definitions = <<DEFINITION
[
   {
      "image":"leandrovo/digitalbank-backend-java:3.0",
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
            "name":"SLOW_REGION",
            "value":"SP"
         },
         {
            "name":"SLOW_TIME",
            "value":"5000"
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
   }
]
DEFINITION
}

# Security group for the ECS task
resource "aws_security_group" "credit_card_task" {
  name        = "example-task-security-group"
  vpc_id      = data.aws_vpc.default.id

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

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.ecs_api_cluster_name}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    demoenv   = "${var.aws_demo_tag_env}"
    demoowner = "${var.aws_demo_tag_owner}"
  }
}

# ECS Service
resource "aws_ecs_service" "credit_card" {
  name            = "credit-card-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.credit_card.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.credit_card_task.id]
    subnets          = data.aws_subnets.default.ids
    assign_public_ip = true # Enable public IP for Fargate tasks to access internet
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.credit_card.id
    container_name   = "credit-card-app"
    container_port   = 8081
  }

  depends_on = [aws_lb_listener.credit_card]
}