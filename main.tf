#
provider "aws" {
  region = var.aws_region
}

# Create the IAM role for lambda
resource "aws_iam_role" "lambda_role" {
  name = var.lambda_role

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# Attach the basic execution role policy
resource "aws_iam_policy_attachment" "lambda_basic_execution_policy" {
  name       = var.execution_policy
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Attach the S3 full access policy
resource "aws_iam_policy_attachment" "lambda_s3_full_access_policy" {
  name       = var.s3_policy
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Attach the RDS full access policy
resource "aws_iam_policy_attachment" "lambda_rds_full_access_policy" {
  name       = var.rds_policy
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

# Attach the CloudWatch full access policy
resource "aws_iam_policy_attachment" "lambda_cloudwatch_full_access_policy" {
  name       = var.cloudwatch_policy
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

# State the ECR repository name to get the uri of the pushed image 
data "aws_ecr_repository" "my_ecr_repo" {
  name = var.my_ecr_repo  
}

# Create the lambda function
resource "aws_lambda_function" "my_lambda" {
  function_name = var.lambda_name
  role          = aws_iam_role.lambda_role.arn
  package_type = "Image"
  image_uri    = "${data.aws_ecr_repository.my_ecr_repo.repository_url}:latest"

  timeout = 60
}

# Lambda permission to allow S3 to invoke the function
resource "aws_lambda_permission" "s3_invocation" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.s3_bucket_name}"
}

# Create the S3 bucket notification to trigger the Lambda function for .csv files in csvdata/ prefix
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.s3_bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.my_lambda.arn
    events              = ["s3:ObjectCreated:*"]

    filter_prefix = var.prefix
    filter_suffix = var.suffix
  }
}
