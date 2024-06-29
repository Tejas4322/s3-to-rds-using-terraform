variable "aws_region" {
       description = "The AWS region to create things in." 
       default     = "us-east-1" # Replace with your refion name
}

variable "lambda_role" { 
    description = "Name of security group" 
    default     = "s3_to_rds_lambda_role"
}

variable "execution_policy" { 
    description = "Name of security group" 
    default     = "lambda_basic_execution_policy"
}

variable "s3_policy" { 
    description = "Name of security group" 
    default     = "lambda_s3_full_access_policy"
}

variable "rds_policy" { 
    description = "Name of security group" 
    default     = "lambda_rds_full_access_policy"
}

variable "cloudwatch_policy" { 
    description = "Name of security group" 
    default     = "lambda_cloudwatch_full_access_policy"
}

variable "my_ecr_repo" {
    description = "Name of ECR repository"
    default = "s3-to-rds" # Replace with your ECR repository name
}

variable "lambda_name" {
    description = "Name of lambda function"
    default = "s3-to-rds" # Replace with your ECR repository name
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  default     = "devops-tejas-new"
}

variable "prefix" {
    description = "Prefix for lambda trigger"
    default = "csvdata/" # Replace with your ECR repository name
}

variable "suffix" {
    description = "Suffix for lambda trigger"
    default = ".csv" # Replace with your ECR repository name
}
