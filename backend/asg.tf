module "private_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.main_var}-ASG-SG"
  description = "Allow inbound HTTP port 80 to ec2 instances in ASG from ALB-SG"
  vpc_id      = data.terraform_remote_state.vpc_network.outputs.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.external_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      description = "https to ELB"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

data "aws_ami" "amazonlinux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"]
}

module "autoscaling" {
  source = "terraform-aws-modules/autoscaling/aws"

  name                      = var.main_var
  min_size                  = 2
  max_size                  = 4
  desired_capacity          = 3
  health_check_grace_period = 400
  health_check_type         = "EC2"
  vpc_zone_identifier       = data.terraform_remote_state.vpc_network.outputs.private_subnet_id
  target_group_arns         = module.elb.target_group_arns
  force_delete              = true
  depends_on                = [module.rds]

  launch_template_name        = var.main_var
  launch_template_description = "Launch template example"
  update_default_version      = true
  launch_template_version     = "$Latest"

  image_id        = data.aws_ami.amazonlinux.id
  instance_type   = "t2.micro"
  key_name        = "DevOpsKP"
  security_groups = [module.private_sg.security_group_id]
  user_data       = filebase64("user-data.sh")

  create_iam_instance_profile = true
  iam_role_name               = var.main_var
  iam_role_path               = "/ec2/"
  iam_role_description        = "IAM role for Sessions Manager"
  iam_role_tags = {
    CustomIamRole = "No"
  }
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}
