
# Spring Boot Observability with AWS ECS Fargate and Splunk

This repository contains the necessary configurations and steps to deploy a Spring Boot application on AWS ECS Fargate with observability enabled via Splunk. This setup includes integrating the Splunk OpenTelemetry Collector and the Splunk Java Agent to send metrics, traces, and logs to the Splunk Observability Platform.

## Architecture

The architecture involves deploying the Splunk OpenTelemetry Collector within the same ECS cluster as your application. The Spring Boot application, instrumented with the Splunk Java Agent, sends observability data to the local OpenTelemetry Collector, which then forwards it to Splunk. AWS metrics are also pushed to Splunk.

![Architecture Diagram](architecture_diagram.png)

## Prerequisites

To implement this solution, ensure you have the following prerequisites:

* [cite_start]Active Splunk Cloud instance [cite: 5]
* [cite_start]Active Splunk o11y instance [cite: 5]
* [cite_start]AWS Permissions [cite: 5]
* [cite_start]Terraform [cite: 5]
* [cite_start]Docker [cite: 5]
* [cite_start]AWS CLI [cite: 5]

## Setup Steps

[cite_start]To get an overview of all the components in this environment, follow these steps[cite: 2]:

### 1. Add the Splunk OTel Collector to the ECS Cluster

[cite_start]For this Proof of Concept (PoC), the Splunk OTel Collector will be deployed within the same cluster where the application is running[cite: 6]. [cite_start]We will modify the existing Terraform script that deploys the application container to include the OTel Collector[cite: 7].

[cite_start]Add the following lines to your Terraform script (specifically, after the application container definition) that creates your ECS cluster[cite: 8]:

```terraform
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
            "name": "SPLUNK_HEC_URL",
            "value": "${var.SPLUNK_HEC_URL}"
          },
          {
            "name": "SPLUNK_HEC_TOKEN",
            "value": "${var.SPLUNK_HEC_TOKEN}"
          },
          {
            "name": "METRICS_TO_EXCLUDE",
            "value": "[]"
          }
      ]
}
````

[cite\_start][cite: 9]

[cite\_start]Add these variables to your `variables.tf` file[cite: 10]:

```terraform
variable "SPLUNK_HEC_TOKEN" {
  description = "splunk HEC token. Send logs to splunk cloud"
  type = string
  default =  " your_hec_token "
}

variable "SPLUNK_HEC_URL" {
  description = "splunk HEC URL. Send logs to splunk cloud"
  type = string
  default =  "https ://<your_cloud_stack>: 8088/services/collector/event"
}

variable "splunk_access_token" {
  description = "splunk token"
  type    = string
  default = " your_splunk_o11y_ingestion_token "
}

variable "splunk_realm" {
  description = "splunk realm"
  type    = string
  default =  "<realm>"
}
```

[cite\_start][cite: 11]

### 2\. Insert and Configure the Splunk Java Agent in the Spring Boot Application

[cite\_start]Next, you need to include the Splunk Java agent in your Spring Boot application[cite: 12]. [cite\_start]For this PoC, we will directly include the agent in the Docker image[cite: 14].

[cite\_start]First, download the agent[cite: 15, 16]:

```bash
curl -L [https://github.com/signalfx/splunk-otel-java/releases/latest/download/splunk-otel-javaagent.jar](https://github.com/signalfx/splunk-otel-java/releases/latest/download/splunk-otel-javaagent.jar) \
-o splunk-otel-javaagent.jar
```

[cite\_start][cite: 16]

[cite\_start]Then, modify your Dockerfile used to build the application image by adding the following line[cite: 17, 18]:

```dockerfile
FROM....,...,...,,
ADD splunk-otel-javaagent.jar /opt/agent/opentelemetry-javaagent.jar
....,....,
```

[cite\_start][cite: 18]

[cite\_start]Build and push the new version of your image to your repository[cite: 19].

[cite\_start]Edit your Terraform file and add these environment variables directly under your application container definition[cite: 20]:

```terraform
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
            "name":"JAVA_TOOL_OPTIONS",
            "value":"-javaagent:/opt/agent/opentelemetry-javaagent.jar -Dsplunk.profiler.enabled=true -Dsplunk.profiler.memory.enabled=true "
         }
```

[cite\_start][cite: 21]

[cite\_start]Add these variables to your `variables.tf` file[cite: 22]:

```terraform
variable "OTEL_EXPORTER_OTLP_ENDPOINT" {
  type = string
  default =  "http://localhost:4318"
}

variable "OTEL_ECS_SERVICE_NAME" {
  type = string
  default =  "<your service name>"
}

variable "OTEL_SERVICE_NAMESPACE" {
  type = string
  default =  "<your namespace>"
}

variable "DEPLOYMENT_ENVIRONMENT" {
  type = string
  default =  "<your deployment>"
}
```

[cite\_start][cite: 23]

### 3\. Configure Splunk o11y Connection with AWS CloudWatch

[cite\_start]For the purpose of this PoC, we will use the Polling method to establish the connection with AWS[cite: 25].

Open the following link and follow the instructions to configure the connection:
[cite\_start][https://app.us1.signalfx.com/\#/gdi/aws/create/integration-summary?category=all\&gdiState=%7B%22integrationId%22:%22FfhrrZoAYAA%22%7D\&utm\_source=login.signalfx.com](https://app.us1.signalfx.com/#/gdi/aws/create/integration-summary?category=all&gdiState=%7B%22integrationId%22:%22FfhrrZoAYAA%22%7D&utm_source=login.signalfx.com) [cite: 26]

-----

**Note:** Remember to replace placeholder values like `<your_cloud_stack>`, `<realm>`, `<your service name>`, `<your namespace>`, `<your deployment>`, and tokens with your actual Splunk and AWS-specific values.


