variable "build_version" {
  type    = string
  default = "1.0.0"
}

variable "ecr_lifecycle_max_image_count" {
  type    = number
  default = 2
}

variable "region" {
  type    = string
  default = "us-east-1"
}
