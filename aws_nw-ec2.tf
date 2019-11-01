# Configure the AWS Provider
#for this script export values in bash_profile
#
#provider "aws" {
#    access_key = "{aws_access_key}"
#    secret_key = "{aws_secret_key}"
#    region = "us-east-1"
#}

provider "aws" {
  region  = "us-east-1"
}

resource "aws_vpc" "my_vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    tags = {
        Name = "tf-example"
    }
}

resource "aws_internet_gateway" "my_igw" {
    vpc_id = "${aws_vpc.my_vpc.id}"
	tags = {
        Name = "my_igw"
    }
}

resource "aws_subnet" "my_subnet" {
    vpc_id = "${aws_vpc.my_vpc.id}"
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"

    tags = {
        Name = "tf-example-sub1"
    }
}

resource "aws_route_table" "vpc_route" {
    vpc_id = "${aws_vpc.my_vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.my_igw.id}"
    }

    tags = {
        Name = "tf_example_route"
    }
}

resource "aws_route_table_association" "terraform-public" {
    subnet_id = "${aws_subnet.my_subnet.id}"
    route_table_id = "${aws_route_table.vpc_route.id}"
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.my_vpc.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "web-1" {
    ami = "ami-00eb20669e0990cb4"
    availability_zone = "us-east-1a"
    instance_type = "t2.micro"
    key_name = "knanda"
    subnet_id = "${aws_subnet.my_subnet.id}"
    vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]
    associate_public_ip_address = true	
    tags = {
        Name = "Server-1"
        Env = "Prod"
        Owner = "nanda"
    }
}
