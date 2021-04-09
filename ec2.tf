data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }

  owners = ["amazon"]
}

resource "aws_key_pair" "developer" {
  public_key = var.public_key
}

# Define our VPC
resource "aws_vpc" "default" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true

}

# Define the public subnet
resource "aws_subnet" "public-subnet" {
  vpc_id = aws_vpc.default.id
  cidr_block = var.public_subnet_cidr
  availability_zone = "us-east-1a"

}

# Define the internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.default.id

}
# Define the route table
resource "aws_route_table" "web-public-rt" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  
}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "web-public-rt" {
  subnet_id = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.web-public-rt.id


}

resource "aws_instance" "machine" {
  ami = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.machine.id
  key_name = aws_key_pair.developer.key_name
  associate_public_ip_address = true
  subnet_id = aws_subnet.public-subnet.id
  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }

  tags = {
    Name = local.system_name
  }

  vpc_security_group_ids = [aws_security_group.machine_access.id]
  user_data_base64 = data.cloudinit_config.init.rendered
}

resource "aws_security_group" "machine_access" {
  name_prefix = local.system_name

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  vpc_id= aws_vpc.default.id
}

data "cloudinit_config" "init" {
  part {
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/upload_machine_data.sh",{SYSTEM_NAME=local.system_name})
    filename = "upload_machine_data.sh"
  }
}
