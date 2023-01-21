data "aws_route53_zone" "domain_name" {
  name = "cloud-sata.com"
}

module "acm" {
  source = "terraform-aws-modules/acm/aws"

  domain_name = "www.cloud-sata.com"
  zone_id     = data.aws_route53_zone.domain_name.zone_id

  wait_for_validation = true
}

module "external_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name   = "${var.main_var}-ALB-SG"
  vpc_id = data.terraform_remote_state.vpc_network.outputs.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow Inbound https to ALB from Anywhere"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      description = "Allow Outbound https from ALB"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "elb" {
  source = "terraform-aws-modules/alb/aws"

  name = var.main_var

  load_balancer_type = "application"

  vpc_id          = data.terraform_remote_state.vpc_network.outputs.vpc_id
  internal        = false
  subnets         = data.terraform_remote_state.vpc_network.outputs.public_subnet_id
  security_groups = [module.external_sg.security_group_id]

  target_groups = [
    {
      name_prefix          = var.main_var
      backend_protocol     = "HTTP"
      backend_port         = 80
      deregistration_delay = 10

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 5
        unhealthy_threshold = 2
        timeout             = 5
        protocol            = "HTTP"
        matcher             = "200"
      }
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.acm.acm_certificate_arn
      action_type        = "forward"
      target_group_index = 0
    }
  ]
}

module "dns" {
  source = "terraform-aws-modules/route53/aws//modules/records"

  zone_id = data.aws_route53_zone.domain_name.zone_id

  records = [
    {
      name    = "www"
      type    = "CNAME"
      records = [module.elb.lb_dns_name]
      ttl     = 300
    }
  ]
}
