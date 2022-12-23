data "aws_region" "current" {}

# get access to aws acc ID, user ID arn
data "aws_caller_identity" "this" {}

# Configure the Providers
provider "aws" {
  region = "us-east-1"
}

locals {
  app_id              = "projet-log8415"
  build_version       = "1.0.0"
  ubuntu_ami          = "ami-0a6b2839d44d781b2"
  slave_group = toset(["1", "2", "3"])
}

# Proxy
module "ec2_instance_proxy" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "mysql-single-node"

  ami                         = local.ubuntu_ami
  instance_type               = "t2.large"
  key_name                    = module.key_pair.key_pair_name
  monitoring                  = true
  vpc_security_group_ids      = [module.sg.id]
  subnet_id                   = module.vpc.public_subnets[0]
  private_ip                  = "10.0.0.64"
  associate_public_ip_address = true

  user_data = templatefile("../install-proxy-node.sh", {
    SSH-KEY             = module.key_pair.private_key_openssh
  })

  tags = {
    Terraform       = "true"
    Environment     = "dev"
  }
}

# Single-node
module "ec2_instance_single_node" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "mysql-single-node"

  ami                         = local.ubuntu_ami
  instance_type               = "t2.micro"
  key_name                    = module.key_pair.key_pair_name
  monitoring                  = true
  vpc_security_group_ids      = [module.sg.id]
  subnet_id                   = module.vpc.public_subnets[0]
  private_ip                  = "10.0.0.128"
  associate_public_ip_address = true

  user_data = templatefile("../install-single-node.sh", {})

  tags = {
    Terraform       = "true"
    Environment     = "dev"
  }
}

# Master node
module "ec2_instance_master" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "mysql-master"

  ami                         = local.ubuntu_ami
  instance_type               = "t2.small"
  key_name                    = module.key_pair.key_pair_name
  monitoring                  = true
  vpc_security_group_ids      = [module.sg.id]
  subnet_id                   = module.vpc.public_subnets[0]
  private_ip                  = "10.0.0.10"
  associate_public_ip_address = true

  user_data = templatefile("../install-master-node.sh", {
  })

  tags = {
    Terraform       = "true"
    Environment     = "dev"
  }
}

# Slaves
module "ec2_instance_slaves" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = local.slave_group

  name = "mysql-slave-${each.key}"

  ami                         = local.ubuntu_ami
  instance_type               = "t2.small"
  key_name                    = module.key_pair.key_pair_name
  monitoring                  = true
  vpc_security_group_ids      = [module.sg.id]
  subnet_id                   = module.vpc.public_subnets[0]
  private_ip                  = "10.0.0.1${each.key}"
  associate_public_ip_address = true

  user_data = templatefile("../install-slave-node.sh", {
    MASTER_IP = module.ec2_instance_master.private_ip
  })

  tags = {
    Terraform       = "true"
    Environment     = "dev"
    Instance_number = "${each.key}"
  }
}
