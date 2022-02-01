resource "aws_ecr_repository" "backend_ecr_repo" {

  name                 = "${var.infra_env}-demo-backend-adminapp"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name  = "${var.infra_env} demo-backend-adminapp"
    Infra = "${var.infra_env}"
  }
}

resource "aws_ecr_lifecycle_policy" "backend_ecr_repo_lifecycle" {
  repository = aws_ecr_repository.backend_ecr_repo.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 10 images"
      action = {
        type = "expire"
      }
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
    }]
  })
}
