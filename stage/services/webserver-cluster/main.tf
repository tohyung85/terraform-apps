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
    key = "stage/services/hello-world-app/terraform.tfstate"
  }
}

module "webserver_cluster" {
  source = "github.com/tohyung85/terraform-modules//services/hello-world-app?ref=v0.0.3"
  # source = "../../../../modules/services/hello-world-app"

  cluster_name           = "webservers-stage"
  db_remote_state_bucket = "tohyung-learning-terraform"
  db_remote_state_key    = "stage/data-stores/mysql/terraform.tfstate"

  instance_type = "t2.micro"
  min_size      = 2
  max_size      = 10

  enable_autoscaling = false

  ami         = "ami-0c55b159cbfafe1f0"
  server_text = "Hello, World"
}
