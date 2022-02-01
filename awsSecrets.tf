resource "aws_secretsmanager_secret" "demo_cognito_secrets_manager" {
  name = "/${var.infra_env}/cognito"
  recovery_window_in_days = 7
  description = "Secret storage for cognito"

}

resource "aws_secretsmanager_secret" "demo_database_secrets_manager" {
  name = "/${var.infra_env}/db"
  recovery_window_in_days = 7
  description = "Secret storage for database"

}

resource "aws_secretsmanager_secret_version" "cognito_secret_version" {
  depends_on = [
    aws_cognito_user_pool.demo_cognito_pool, aws_cognito_user_pool_client.demo_cognito_pool_client
  ]
  secret_id     = aws_secretsmanager_secret.demo_cognito_secrets_manager.id
  secret_string = <<EOF
   {
    "customers_user_pool_id": "${aws_cognito_user_pool.demo_cognito_pool.id}",
    "customers_client_id": "${aws_cognito_user_pool_client.demo_cognito_pool_client.id}"
   }
EOF
}

resource "aws_secretsmanager_secret_version" "database_secret_version" {
  depends_on = [
    aws_db_instance.database_demo
  ]
  secret_id     = aws_secretsmanager_secret.demo_database_secrets_manager.id
  secret_string = <<EOF
   {
    "dbhost": "${aws_db_instance.database_demo.address}",
    "dbuser": "${aws_db_instance.database_demo.username}",
    "dbpass": "${var.database_password}",
    "dbname": "${aws_db_instance.database_demo.name}",
    "dbport": "${aws_db_instance.database_demo.port}",
    "dbdialect":"mysql"
   }
EOF
}
