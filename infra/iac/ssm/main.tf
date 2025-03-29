#########################################
# プロバイダ設定 & ローカル変数
#########################################
provider "aws" {
  region = "ap-northeast-1"  # 東京リージョン
}

locals {
  account_id    = "503561449641"
  region        = "ap-northeast-1"
  
  # SSMパラメータのパス接頭辞
  ssm_prefix    = "/${var.application_name}/${var.environment}"
  prefix        = "${var.application_name}-${var.environment}"

  # 1.2 SSM パラメータを一括管理（キー名＝環境変数名）
  # type = "SecureString" などパラメータごとに必要なものを指定
  ssm_parameters = {
    BACKEND_PORT = {
      type        = "String"
      description = "Backend application port"
      value       = var.backend_port
    },
    FRONTEND_PORT = {
      type        = "String"
      description = "Frontend application port"
      value       = var.frontend_port
    },
    DATABASE_URL = {
      type        = "SecureString"
      description = "Database connection URL"
      value       = var.database_url
    },
    JWT_SECRET_KEY = {
      type        = "SecureString"
      description = "JWT secret key for authentication"
      value       = var.jwt_secret_key
    },
    NODE_ENV = {
      type        = "String"
      description = "Node environment"
      value       = var.node_env
    },
    UPLOAD_DIR = {
      type        = "String"
      description = "Upload directory path"
      value       = var.upload_dir
    },
    NEXT_PUBLIC_ASSET_PREFIX = {
      type        = "String"
      description = "Next.js static assets prefix"
      value       = var.next_public_asset_prefix
    },
    COGNITO_USER_POOL_ID = {
      type        = "String"
      description = "Cognito User Pool ID"
      value       = var.cognito_user_pool_id
    },
    COGNITO_CLIENT_ID = {
      type        = "String"
      description = "Cognito Client ID"
      value       = var.cognito_client_id
    },
    COGNITO_REGION = {
      type        = "String"
      description = "AWS Cognito Region"
      value       = var.cognito_region
    },
    COGNITO_CLIENT_SECRET = {
      type        = "SecureString"
      description = "Cognito Client Secret"
      value       = var.cognito_client_secret
    },
    AWS_ACCESS_KEY_ID = {
      type        = "SecureString"
      description = "AWS Access Key ID"
      value       = var.aws_access_key_id
    },
    AWS_SECRET_ACCESS_KEY = {
      type        = "SecureString"
      description = "AWS Secret Access Key"
      value       = var.aws_secret_access_key
    },
    # セキュリティ設定
    CORS_ALLOWED_ORIGINS = {
      type        = "String"
      description = "Allowed CORS origins"
      value       = var.cors_allowed_origins
    },
    RATE_LIMIT_WINDOW = {
      type        = "String"
      description = "Rate limit window in seconds"
      value       = var.rate_limit_window
    },
    RATE_LIMIT_MAX_REQUESTS = {
      type        = "String"
      description = "Maximum number of requests per rate limit window"
      value       = var.rate_limit_max_requests
    },
    # ログ設定
    LOG_LEVEL = {
      type        = "String"
      description = "Application log level"
      value       = var.log_level
    },
    LOG_RETENTION_DAYS = {
      type        = "String"
      description = "Log retention period in days"
      value       = var.log_retention_days
    },
    # メール設定
    SMTP_HOST = {
      type        = "String"
      description = "SMTP server host"
      value       = var.smtp_host
    },
    SMTP_PORT = {
      type        = "String"
      description = "SMTP server port"
      value       = var.smtp_port
    },
    SMTP_USERNAME = {
      type        = "SecureString"
      description = "SMTP username"
      value       = var.smtp_username
    },
    SMTP_PASSWORD = {
      type        = "SecureString"
      description = "SMTP password"
      value       = var.smtp_password
    },
    MAIL_FROM_ADDRESS = {
      type        = "String"
      description = "Mail sender address"
      value       = var.mail_from_address
    },
    # キャッシュ設定
    REDIS_HOST = {
      type        = "String"
      description = "Redis host"
      value       = var.redis_host
    },
    REDIS_PORT = {
      type        = "String"
      description = "Redis port"
      value       = var.redis_port
    },
    REDIS_PASSWORD = {
      type        = "SecureString"
      description = "Redis password"
      value       = var.redis_password
    },
    # ファイルストレージ設定
    S3_BUCKET_NAME = {
      type        = "String"
      description = "S3 bucket name"
      value       = var.s3_bucket_name
    },
    S3_REGION = {
      type        = "String"
      description = "S3 region"
      value       = var.s3_region
    },
    S3_ACCESS_KEY_ID = {
      type        = "SecureString"
      description = "S3 access key ID"
      value       = var.s3_access_key_id
    },
    S3_SECRET_ACCESS_KEY = {
      type        = "SecureString"
      description = "S3 secret access key"
      value       = var.s3_secret_access_key
    },
    # 監視設定
    SENTRY_DSN = {
      type        = "SecureString"
      description = "Sentry DSN"
      value       = var.sentry_dsn
    },
    NEW_RELIC_LICENSE_KEY = {
      type        = "SecureString"
      description = "New Relic license key"
      value       = var.new_relic_license_key
    }
  }
}


#########################################
# SSM パラメータ (for_each)
#########################################
resource "aws_ssm_parameter" "parameters" {
  for_each    = local.ssm_parameters

  name        = "${local.ssm_prefix}/${each.key}"
  type        = each.value.type
  description = each.value.description
  value       = each.value.value
  
}

# SSMポリシー (SSM パラメータへのアクセス)
resource "aws_iam_policy" "ssm_parameter_access" {
  name        = "${local.prefix}-ssm-parameter-access"
  description = "Allow access to SSM parameters"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["ssm:GetParameters", "ssm:GetParameter"],
        Effect   = "Allow",
        Resource = "arn:aws:ssm:${local.region}:${local.account_id}:parameter${local.ssm_prefix}/*"
      }
    ]
  })
}