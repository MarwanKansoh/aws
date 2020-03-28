provider "aws" {
  region = "ap-southeast-2"
}
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_subnet" "public-a" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "ap-southeast-2a"
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public-b" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "ap-southeast-2b"
  cidr_block        = "10.0.2.0/24"
  map_public_ip_on_launch = true
}

resource "aws_directory_service_directory" "main" {
  name     = "cloud.contino.io"
  password = "put some default password here"
  size     = "Small"
  vpc_settings {
    vpc_id     = "${aws_vpc.main.id}"
    subnet_ids = ["${aws_subnet.public-a.id}", "${aws_subnet.public-b.id}"]
  }
}

resource "aws_workspaces_directory" "main" {
  directory_id = "${aws_directory_service_directory.main.id}"
  subnet_ids   = ["${aws_subnet.public-a.id}", "${aws_subnet.public-b.id}"]
}

resource "aws_workspaces_ip_group" "main" {
  name        = "main"
  description = "IP Access Control Example"

  rules {
    source = "10.0.0.0/16"
    description = "VPC internal"
  }

  rules {
    source      = "0.0.0.0/0"
    description = "External Users"
  }
}
