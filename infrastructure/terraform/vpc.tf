module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc-cluster-benchmark"

  cidr = "10.0.0.0/16"

  azs             = ["${data.aws_region.current.name}a"]
  public_subnets  = ["10.0.0.0/24"]

  enable_nat_gateway         = true
  enable_vpn_gateway         = true
  enable_dns_hostnames       = true
  enable_dns_support         = true
  manage_default_route_table = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}