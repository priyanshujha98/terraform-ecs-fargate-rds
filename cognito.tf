resource "aws_cognito_user_pool" "demo_cognito_pool" {

  name = "${var.infra_env}-admin-pool"
  
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
  username_attributes = [ "email" ]
  username_configuration {
    case_sensitive = true
  }
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  email_verification_message = "Your verification code is {####}"
  email_verification_subject = "Verification Code"

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 1
  }

  tags = {
    Name  = "${var.infra_env}-admin-pool"
    Infra = "${var.infra_env}"
  }

}

resource "aws_cognito_user_pool_client" "demo_cognito_pool_client" {
  name                = "${var.infra_env}-admin-pool-client"
  user_pool_id        = aws_cognito_user_pool.demo_cognito_pool.id
  generate_secret     = false
  explicit_auth_flows = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]

  id_token_validity      = 2
  access_token_validity  = 2
  refresh_token_validity = 1

  token_validity_units {
    id_token      = "hours"
    access_token  = "hours"
    refresh_token = "days"

  }
  prevent_user_existence_errors = "ENABLED"


}
