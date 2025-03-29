provider "aws" {
  region = var.aws_region
}

resource "aws_lightsail_database" "postgres" {
  relational_database_name = var.db_name
  availability_zone        = var.availability_zone
  blueprint_id             = "postgres_13"
  bundle_id                = var.bundle_id
  master_database_name     = var.master_database_name
  master_username          = var.master_username
  master_password          = var.master_password
  publicly_accessible = true

  tags = {
    Name = var.db_name
    Env  = "dev"
  }
}

# aws lightsail get-relational-database --relational-database-name my-postgres \
#   --query 'relationalDatabase.endpoint'