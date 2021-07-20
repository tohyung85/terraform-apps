provider "aws" {
  region = "us-east-2"
}

# Partial configuration . The other settings (e.g bucket, region) will be
# passed in from a file via --backend-config arguments to 'terraform init'
terraform {
  backend "s3" {
    key = "prod/services/webserver-cluster/terraform.tfstate"
  }
}

module "webserver_cluster" {
  # source = "github.com/tohyung85/terraform-modules//services/webserver-cluster?ref=v0.0.2"
  source = "../../../../modules/services/webserver-cluster"

  cluster_name = "webservers-prod"
  db_remote_state_bucket = "tohyung-learning-terraform"
  db_remote_state_key = "prod/data-stores/mysql/terraform.tfstate"

  instance_type = "t2.micro"
  min_size = 2
  max_size = 10

  custom_tags = {
    Owner = "team-foo"
    DeployedBy = "terraform"
  }

  enable_autoscaling = true

  ami = "ami-0c55b159cbfafe1f0" 
  server_text = "Hello, World" 
}