# terraform {
#   required_providers {
#      aws = {
#       source  = "hashicorp/aws"
#       version = "~> 3.0"
#     }
#   }
# }
provider "aws" {
    region = "ap-northeast-1"
    access_key = "<user_access_key>"
    secret_key = "<user_secret_key>"
  
}

resource "aws_vpc" "cloud1" {
   cidr_block = "10.0.0.0/16"

   tags = {
    Name = "cloud1"
   }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.cloud1.id

  tags = {
    Name = "gw"
  }
}

resource "aws_route_table" "tables" {
    vpc_id = aws_vpc.cloud1.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id

    }

    tags = {
      Name = "tables"
    }
  
}

resource "aws_subnet" "prod_subnet" {
   vpc_id = aws_vpc.cloud1.id
   cidr_block = "10.0.0.0/24"

   tags = {
     Name = "prod_subnet"
   }
}

resource "aws_route_table_association" "table-group" {
  subnet_id = aws_subnet.prod_subnet.id
  route_table_id = aws_route_table.tables.id
  
}

resource "aws_security_group" "allow_web" {
  name = "allow-web_traffic"
  description = "Allow TLS inbound traffic"
  vpc_id = aws_vpc.cloud1.id

  ingress {
    description = "HTTPS web traffic"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH web traffic"
    from_port = 2
    to_port = 2
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP web traffic"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "allow_web"
    }
}

resource "aws_network_interface" "devOps-server" {
  subnet_id = aws_subnet.prod_subnet.id
  security_groups = [aws_security_group.allow_web.id]
  private_ip = "10.0.1.50"
}

resource "aws_instance" "EC2_instance" {
    ami = "ami-02a2700d37baeef8b"
    instance_type = "t2.micro"
    key_name = "terraform-project"
    #subnet_id = aws_subnet.prod_subnet.id since we are using network_interface

    network_interface {
      device_index = 0
      network_interface_id = aws_network_interface.devOps-server.id
    }

    # Assign a public IP address to the instance
    #associate_public_ip_address = true

    tags = {
      Name = "EC2_instance"
    }

    user_data = <<-EOF
                #!/bin/bash
                sudo apt-get update
                sudo apt-get install docker.io -y
                sudo usermod -aG docker $USER && newgrp docker
                EOF
}

resource "aws_eip" "eip" {
  vpc = true

  tags = {
    Name = "eip"
  }  
}

# The aws_eip_association resource in Terraform is used to associate an Elastic IP address with an EC2 instance or a network interface
resource "aws_eip_association" "eip_association" {
  instance_id = aws_instance.EC2_instance.id
  allocation_id = aws_eip.eip.id
  network_interface_id = aws_network_interface.devOps-server.id
}
