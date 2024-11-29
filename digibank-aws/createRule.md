Option 1: Creating the ecsTaskExecutionRole Manually
Go to the IAM console in AWS.
Click on Roles and then click Create role.
In the Select trusted entity section, choose AWS service and select Elastic Container Service.
For the Use case, select Elastic Container Service Task and click Next.
Attach the AmazonECSTaskExecutionRolePolicy policy. This policy gives the role permissions to pull container images from Amazon ECR and store logs in CloudWatch.
Click Next, add a Role name (use ecsTaskExecutionRole), and then Create role.

Option 2: Letting AWS Create the Role Automatically

If you don’t have an ecsTaskExecutionRole, AWS can automatically create it when you create a new ECS service with Fargate:

Go to the ECS console.
Try to create a new service or task definition.
When setting up, if ecsTaskExecutionRole is missing, ECS will prompt you with an option to create it automatically.