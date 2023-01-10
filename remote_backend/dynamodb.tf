# Create the S3 Bucket for the remote states storage
resource "aws_s3_bucket" "terraform_remote_state" {
  bucket = "wordpress-aws-adamab"
}

# Create a Dynamodb table to Lock the state file
resource "aws_dynamodb_table" "terraform_remote_state" {
  name           = "wordpress-remote-state-db"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
