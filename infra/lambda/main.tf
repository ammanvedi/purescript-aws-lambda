terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.48.0"
    }
  }
}

locals {
  source_archive = "${var.dist_path}/bundle.zip"
}


resource "aws_iam_role" "lambda_role" {
  name   = var.iam_role_name
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_policy" "iam_policy_for_lambda" {

  name         = var.iam_policy_name
  path         = "/"
  description  = "AWS IAM Policy for managing aws lambda role"
  policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents"
     ],
     "Resource": "arn:aws:logs:*:*:*",
     "Effect": "Allow"
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role        = aws_iam_role.lambda_role.name
  policy_arn  = aws_iam_policy.iam_policy_for_lambda.arn
}

data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_dir  = "${var.source_path}/"
  output_path = local.source_archive
}

resource "aws_lambda_function" "terraform_lambda_func" {
  filename                       = local.source_archive
  function_name                  = var.lambda_function_name
  role                           = aws_iam_role.lambda_role.arn
  handler                        = "index.handler"
  runtime                        = "nodejs16.x"
  depends_on                     = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
}