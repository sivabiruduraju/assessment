variable "public_key" {
  description = "Public key of the developer to access the EC2 machine"
  type = string
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default = "10.10.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for the public subnet"
  default = "10.10.1.0/24"
}


