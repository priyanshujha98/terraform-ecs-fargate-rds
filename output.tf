output "cloudfront_domain_name" {
    value = aws_cloudfront_distribution.demo_cloudfront_distribution.domain_name
}

output "s3_config" {
  value = aws_s3_bucket.demo_s3_bucket
}

output "database_config" {
    sensitive = true
  value = aws_db_instance.database_demo
}

output "loadbalancer" {
  value = aws_lb.backend_load_balancer
}

output "secrets_cognito" {
    value = aws_secretsmanager_secret.demo_cognito_secrets_manager
}

output "secrets_db" {
    value = aws_secretsmanager_secret.demo_database_secrets_manager
}

output "bastion_confid" {
    value = aws_instance.bastion_host
}

output "cognito_config" {
    value = aws_cognito_user_pool.demo_cognito_pool
}
