data "aws_iam_policy_document" "ecs_tasks_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
    name = "${var.infra_env}_ecs_task_execution_role"
    assume_role_policy = "${data.aws_iam_policy_document.ecs_tasks_execution_role.json}"
  
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
    role = "${aws_iam_role.ecs_task_execution_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  
}

resource "aws_iam_role" "ecs_task_role"{
    name = "${var.infra_env}_ecs_task_role"
    assume_role_policy = "${data.aws_iam_policy_document.ecs_tasks_execution_role.json}"
    
}

resource "aws_iam_role_policy_attachment" "ecs_task_policy" {
    role = "${aws_iam_role.ecs_task_role.name}"
    count = length(var.ecs_task_policy)
    policy_arn = element(var.ecs_task_policy, count.index)

  
}