resource "aws_ecs_cluster" "demo_ecs_cluster" {
  name = "${var.infra_env}-demo-admin-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "demo_task_definition" {
  depends_on = [
    aws_ecr_repository.backend_ecr_repo
  ]
  network_mode             = "awsvpc"
  family                   = "${var.infra_env}-demo-task-definition"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([{
    name      = "adminBackend"
    image     = "${aws_ecr_repository.backend_ecr_repo.repository_url}:latest"
    essential = true
    portMappings = [{
      protocol      = "tcp"
      containerPort = 5000
      hostPort      = 5000
    }]
    "logConfiguration": {
      "logDriver": "awslogs",
      "secretOptions": null,
      "options": {
        "awslogs-group": "/ecs/${var.infra_env}-demo-task-definition",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    } 

  }])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

}

resource "aws_ecs_service" "demo_ecs_service" {
  depends_on = [
    aws_lb.backend_load_balancer, aws_lb_target_group.backend_load_balancer_target_group, aws_ecr_repository.backend_ecr_repo
  ]
  name                               = "${var.infra_env}-demo-ecs-service"
  cluster                            = aws_ecs_cluster.demo_ecs_cluster.id
  task_definition                    = aws_ecs_task_definition.demo_task_definition.arn
  desired_count                      = var.container_desired_count
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  health_check_grace_period_seconds  = 5

  network_configuration {
    security_groups  = [aws_security_group.demo_cluster_service_security_group.id]
    subnets          = [for subnet in aws_subnet.private : subnet.id]
    assign_public_ip = true

  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend_load_balancer_target_group.arn
    container_name   = "adminBackend"
    container_port   = 5000
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}
