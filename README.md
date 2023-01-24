#### VPC NETWORKING FOR WORDPRESS WEBSITE

List of Components

1- Create the VPC

2- create internet gateway and attach it to vpc

3- Create 4 Subnets -- 2 Public & 2 Private

4- Create 3 Route Tables -- 1 Public & 2 Private

5- Associate the Public RT to 2 Public Subnets & the 2 Private RT to 2 Private Subnets

6- Create 2 Elastic IP and Associate them to the 2 Nat Gateway

7- Create 2 Nat Gateway for the 2 private Subnets

#### Remote State File Configuration

Managing the state of your infrastructure is a crucial component of using Terraform. Information about the resources that Terraform is managing, such as the ID of a newly created EC2 instance or the DNS name of a load balancer, is included in the state of your infrastructure.

Terraform modifies the state of your infrastructure to reflect the desired state specified in your Terraform configuration files when you perform commands like terraform apply. This state is kept locally on your computer in a file with the default name of terraform.tfstate. While this is effective for small, one-person projects, it can cause issues for larger teams with multiple members.

To solve this problem, Terraform has the ability to store the state of your infrastructure in a remote location, such as AWS S3. By using a remote state, multiple people on your team can access and update the state of your infrastructure ONCE AT A TIME, and you can also store the state of your infrastructure in version control for auditing and rollback purposes in case of misconfiguration.

Refering at our last configuration, we can take these next steps to implement remote state to our infrstructure.

1 - Create a new module that contain the configuration file to provision the S3 Bucket and the DynamoDB.

2 - Update the provider.tf file by adding the Remote backend configuration code.

            ###########         ###########

                       ###########

#### Backend

### Route53 - Load Balancer - System Manager - ASG - Secrets Manager - RDS

In the first part of this project, I made use of Self-made modules where I created all the components needed to provision the VPC and its sub-components.

In this section, I will make use of open source modules which are modules that are created by the community and shared publicly. These modules are used to automate the provisioning and management of a wide variety of resources. They are a collection reusable resources across differents project. Using open-source modules is easy and pretty straightforward. To use them, you open a module resource and define the source as these following modules and adjust any argument that correspond to your outputs.

### Open Source Modules Used:

- "terraform-aws-modules/security-group/aws"

  Module called to provision the necessary secruity configuration to allow Inbound and outbound traffic.

- "terraform-aws-modules/rds/aws"

  Module used to provision the Database retaining the App server's data

- "terraform-aws-modules/autoscaling/aws"

  Used to provision the autoscaling group of App servers.

- "terraform-aws-modules/acm/aws"

  Creates the TLS/SSL certificate applying the security over HTTP.

- "terraform-aws-modules/alb/aws"

  Provision the ALB that receives the secured traffic from the Route53 and distribute the traffic through the ASG

- "terraform-aws-modules/route53/aws//modules/records"

  Provision the DNS record that map the domain name to the ASG Target group.

# wordpress-on-AWS

o
