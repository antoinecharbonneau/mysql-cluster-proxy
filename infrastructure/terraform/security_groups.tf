module "sg" {
  source     = "cloudposse/security-group/aws"
  attributes = ["primary"]

  # Allow unlimited egress
  allow_all_egress = true

  rules = [
    {
      key         = "ssh"
      type        = "ingress"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      self        = null
      description = "Allow SSH from anywhere"
    },
    {
      key         = "HTTP"
      type        = "ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      self        = null
      description = "Allow HTTP from anywhere"
    },
    {
      key         = "Internal"
      type        = "ingress"
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/24"]
      self        = null
      description = "Allow all ports within the security group"
    },
    {
      key         = "Ping"
      type        = "ingress"
      from_port   = 8
      to_port     = 0
      protocol    = "icmp"
      cidr_blocks  = ["10.0.0.0/24"]
      self        = null
      description = "Allow pings from within the security group"
    }
  ]

  vpc_id = module.vpc.vpc_id
}