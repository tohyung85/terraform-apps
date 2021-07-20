provider "aws" {
  region = "us-east-2"
}

# Partial configuration . The other settings (e.g bucket, region) will be
# passed in from a file via --backend-config arguments to 'terraform init'
terraform {
  backend "s3" {
    key = "global/iam/terraform.tfstate"    
  }
}

variable "user_names" {
  description = "Create IAM users with these names"
  type = list(string)
  default = ["neo", "trinity" ,"morpheus"]
}

variable "give_neo_cloudwatch_full_access" {
  description = "If true, neo gets full access to Cloudwatch"
  type = bool
}
# resource "aws_iam_user" "example" {
#   count = length(var.user_names)
#   name = var.user_names[count.index]
# }

resource "aws_iam_user" "example" {
  for_each = toset(var.user_names)
  name = each.value
}

resource "aws_iam_user_policy_attachment" "neo_cloudwatch_full_access" {
  count = var.give_neo_cloudwatch_full_access ? 1 : 0
  user = values(aws_iam_user.example)[0].name
  policy_arn = aws_iam_policy.cloudwatch_full_access.arn
}

resource "aws_iam_user_policy_attachment" "neo_cloudwatch_read_only" {
  count = var.give_neo_cloudwatch_full_access ? 0: 1
  user = values(aws_iam_user.example)[0].name
  policy_arn = aws_iam_policy.cloudwatch_read_only.arn
}

resource "aws_iam_policy" "cloudwatch_read_only" {
  name = "cloudwatch-read-only"
  policy = data.aws_iam_policy_document.cloudwatch_read_only.json
}

data "aws_iam_policy_document" "cloudwatch_read_only" {
  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cloudwatch_full_access" {
  name = "cloudwatch-full-access"
  policy = data.aws_iam_policy_document.cloudwatch_full_access.json
}

data "aws_iam_policy_document" "cloudwatch_full_access" {
  statement {
    effect = "Allow"
    actions = ["cloudwatch:*"]
    resources = ["*"]
  }
}

output "all_arns" {
  value = values(aws_iam_user.example)[*].arn
  description = "The ARNs for all users"
}