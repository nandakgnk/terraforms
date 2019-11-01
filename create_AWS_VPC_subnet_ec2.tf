# Configure the AWS Provider
provider "aws" {
  region  = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = "${aws_vpc.my_vpc.id}"
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_network_interface" "nanda" {
  subnet_id   = "${aws_subnet.my_subnet.id}"
  private_ips = ["10.0.1.10"]

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "foo" {
  ami           = "ami-00eb20669e0990cb4" # us-east-1a
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = "${aws_network_interface.nanda.id}"
    device_index         = 0
  }
}

#terraform init
#terraform plan
#terraform apply
