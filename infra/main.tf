provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.48.0"
    }
  }

  backend "s3" {
    bucket = "purescriptlambda"
    key    = "state"
  }
}



module "lambda" {
  source = "./lambda"

  lambda_function_name = "purescript_lambda"
  iam_policy_name = "purescript_lambda_policy"
  iam_role_name = "purescript_lambda_role"
  source_path = "${path.root}/../dist"
  dist_path = "${path.root}/../aws-dist"
  aws_region = var.aws_region
  providers = {
    aws = aws
  }
}