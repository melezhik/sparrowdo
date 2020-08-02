#provider "aws" {
#  profile = "default"
#  region  = "us-east-1"
#}

#/*

resource "aws_instance" "example" {

  ami           = "ami-2757f631"
  instance_type = "t2.micro"
  key_name = "mylaptop"

  tags = {
    Name = "frontend"
  }
}

resource "aws_instance" "example2" {
  ami           = "ami-2757f631"
  instance_type = "t2.micro"
  key_name = "mylaptop"

  tags = {
    Name = "backend"
  }
}

resource "aws_instance" "example3" {
  ami           = "ami-2757f631"
  instance_type = "t2.micro"
  key_name = "mylaptop"

  tags = {
   Name = "database"
  }
}

#*/
