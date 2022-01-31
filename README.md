# terraform-ecs-fargate-rds
Terraform code for ecs fargate with rds

- Services Used
    - Global services
        - Route 53
        - Vpc peering
    - For Frontend
        - CloudFront (as CDN)
        - S3 for react app hosting
    - For Backend
        - Vpc (2 public, 2 private)
        - Loadbalancer
        - Nat Gateway
        - Ecs cluster with fargate
        - Cognito
        - Aws secrets
    - For database
        - Vpc (2 public, 2 private)
        - RDS ( mysql )
        - Bastion host
