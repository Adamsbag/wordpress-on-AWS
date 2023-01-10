# Terraform configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  # Configure the Remote Bakend on AWS S3
  backend "s3" {
    bucket         = "wordpress-aws-adamab"
    key            = "vpc_network.tfstate"
    region         = "us-east-1"
    dynamodb_table = "wordpress-remote-state-db"
  }

}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
