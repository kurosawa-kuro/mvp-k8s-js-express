# variables.tf - 変数の定義
variable "database_url" {
  description = "データベース接続文字列"
  type        = string
  sensitive   = true  # ログやコンソール出力で値を隠す
}

variable "environment" {
  description = "デプロイ環境（production, staging, development）"
  type        = string
  default     = "production"
}

variable "application_name" {
  description = "アプリケーション名"
  type        = string
  default     = "app"
}

# 他のSSMパラメータ用の変数
variable "node_env" {
  description = "Node.js環境変数"
  type        = string
  default     = "production"
}

variable "backend_port" {
  description = "バックエンドアプリケーションポート"
  type        = string
  default     = "8080"
}

variable "frontend_port" {
  description = "フロントエンドアプリケーションポート"
  type        = string
  default     = "3000"
}

variable "jwt_secret_key" {
  description = "JWT認証用シークレットキー"
  type        = string
  sensitive   = true
}

variable "upload_dir" {
  description = "アップロードディレクトリパス"
  type        = string
  default     = "uploads"
}

variable "next_public_asset_prefix" {
  description = "Next.js静的アセット配信用のプレフィックス"
  type        = string
  default     = ""
}

variable "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  type        = string
}

variable "cognito_client_id" {
  description = "Cognito Client ID"
  type        = string
}

variable "cognito_region" {
  description = "AWS Cognito Region"
  type        = string
}

variable "cognito_client_secret" {
  description = "Cognito Client Secret"
  type        = string
  sensitive   = true
}

variable "aws_access_key_id" {
  description = "AWS Access Key ID"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
}

# セキュリティ設定
variable "cors_allowed_origins" {
  description = "許可されるCORSオリジン"
  type        = string
  default     = "*"
}

variable "rate_limit_window" {
  description = "レート制限の時間枠（秒）"
  type        = string
  default     = "3600"
}

variable "rate_limit_max_requests" {
  description = "レート制限の最大リクエスト数"
  type        = string
  default     = "100"
}

# ログ設定
variable "log_level" {
  description = "アプリケーションのログレベル"
  type        = string
  default     = "info"
}

variable "log_retention_days" {
  description = "ログの保持期間（日）"
  type        = string
  default     = "30"
}

# メール設定
variable "smtp_host" {
  description = "SMTPサーバーホスト"
  type        = string
}

variable "smtp_port" {
  description = "SMTPサーバーポート"
  type        = string
  default     = "587"
}

variable "smtp_username" {
  description = "SMTPユーザー名"
  type        = string
  sensitive   = true
}

variable "smtp_password" {
  description = "SMTPパスワード"
  type        = string
  sensitive   = true
}

variable "mail_from_address" {
  description = "送信元メールアドレス"
  type        = string
}

# キャッシュ設定
variable "redis_host" {
  description = "Redisホスト"
  type        = string
}

variable "redis_port" {
  description = "Redisポート"
  type        = string
  default     = "6379"
}

variable "redis_password" {
  description = "Redisパスワード"
  type        = string
  sensitive   = true
}

# ファイルストレージ設定
variable "s3_bucket_name" {
  description = "S3バケット名"
  type        = string
}

variable "s3_region" {
  description = "S3リージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "s3_access_key_id" {
  description = "S3アクセスキーID"
  type        = string
  sensitive   = true
}

variable "s3_secret_access_key" {
  description = "S3シークレットアクセスキー"
  type        = string
  sensitive   = true
}

# 監視設定
variable "sentry_dsn" {
  description = "Sentry DSN"
  type        = string
  sensitive   = true
}

variable "new_relic_license_key" {
  description = "New Relicライセンスキー"
  type        = string
  sensitive   = true
}