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

# wordpress-on-AWS
