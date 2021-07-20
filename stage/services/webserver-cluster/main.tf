provider "aws" {
  region = "us-east-2"
}

# Partial configuration . The other settings (e.g bucket, region) will be
# passed in from a file via --backend-config arguments to 'terraform init'
terraform {
  backend "s3" {
    key = "stage/services/webserver-cluster/terraform.tfstate"    
  }
}

module "webserver_cluster" {
  # source = "github.com/tohyung85/terraform-modules//services/webserver-cluster?ref=v0.0.2"
  source = "../../../../modules/services/webserver-cluster"

  cluster_name = "webservers-stage"
  db_remote_state_bucket = "tohyung-learning-terraform"
  db_remote_state_key = "stage/data-stores/mysql/terraform.tfstate"

  instance_type = "t2.micro"
  min_size = 2
  max_size = 10

  enable_autoscaling = false

  ami = "ami-0c55b159cbfafe1f0" 
  server_text = "Hello, World" 
}

resource "aws_security_group_rule" "allow_testing_inbound" {
  type = "ingress"
  security_group_id = module.webserver_cluster.alb_security_group_id

  from_port = 12345
  to_port = 12345
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}