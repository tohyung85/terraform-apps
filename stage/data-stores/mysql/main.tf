terraform {
  # Require Terraform at least 1.0
  required_version = ">= 1.0"
}

provider "aws" {
  region = "us-east-2"

  # Allow any 3.x version of the AWS provider 
  version = "~> 3.0"
}

# Partial configuration . The other settings (e.g bucket, region) will be
# passed in from a file via --backend-config arguments to 'terraform init'
terraform {
  backend "s3" {
    key = "stage/data-stores/mysql/terraform.tfstate"
  }
}

# Set up secret in AWS SSM - Other types enter secret as plaintext with name as per secret_id below
# aws_ssm_parameter to use Parameter Store instead => Cheaper
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "mysql-master-password-stage"
}

module "mysql_db" {
  source = "github.com/tohyung85/terraform-modules//data-stores/mysql?ref=v0.0.3"
  # source = "../../../../modules/data-stores/mysql"

  db_instance_prefix   = "stage"
  db_instance_type     = "db.t2.micro"
  db_allocated_storage = 10
  db_name              = "example_database"

  db_password = data.aws_secretsmanager_secret_version.db_password.secret_string
}

output "address" {
  value       = module.mysql_db.address
  description = "Connect to the database at this endpoint"
}

output "port" {
  value       = module.mysql_db.port
  description = "The port the database is listening on"
}
