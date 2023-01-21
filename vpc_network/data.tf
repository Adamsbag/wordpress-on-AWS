data "terraform_remote_state" "vpc_network" {
  backend = "s3"

  config = {
    bucket = "wordpress-aws-adamab"
    key    = "vpc_network.tfstate"
    region = "us-east-1"
  }
}
