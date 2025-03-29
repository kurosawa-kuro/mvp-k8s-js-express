variable "aws_region" {
  default = "ap-northeast-1"
}

variable "availability_zone" {
  default = "ap-northeast-1a"
}

variable "db_name" {
  default = "my-postgres"
}

variable "bundle_id" {
  default = "micro_1_0" # 最小構成 (1GB RAM)
}

variable "blueprint_id" {
  default = "postgres_13"
}

variable "master_database_name" {
  default = "appdb"
}

variable "master_username" {
  default = "dbuser"
}

variable "master_password" {
  default = "CHANGEME_strongpassword123" # 適宜変更
}
