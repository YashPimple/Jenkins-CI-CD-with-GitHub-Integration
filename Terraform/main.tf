terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
    region = "ap-northeast-1"
    access_key = "<user_access_key>"
    secret_key = "<user_secret_key"
  
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
   map_public_ip_on_launch = true
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
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP web traffic"
    from_port = 8000
    to_port = 8000
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
resource "aws_instance" "EC2_instance" {
    ami = "ami-0d979355d03fa2522"
    instance_type = "t2.micro"
    key_name = "terraform-project"
    subnet_id = aws_subnet.prod_subnet.id
    vpc_security_group_ids = [ aws_security_group.allow_web.id ]

  connection {
  type = "ssh"
  host = self.public-ip
  user = EC2_user
  private_key = file("./terraform-project.pem") #add your .pem file path

  tags = {
    Name = "Web -server"
  }
  }
  
    tags = {
      Name = "EC2_instance"
    }

    user_data = <<-EOF
                #!/bin/bash
                sudo apt-get update
                EOF
}



resource "aws_eip" "eip" {
  instance = aws_instance.EC2_instance.id
  vpc = true

  tags = {
    Name = "eip"
  }  
}

output "instance_ip_addr" {
  value = aws_instance.EC2_instance.private_ip
}
