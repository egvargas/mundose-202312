provider "aws" {
  region = "us-east-2"  
}

resource "aws_instance" "webserver_apache" {
  ami           = "ami-0ee4f2271a4df2d7d"  
  instance_type = "t2.micro"
  associate_public_ip_address = true
  key_name                    = "mundose-202312"
  vpc_security_group_ids      = [aws_security_group.apache_security.id]
  subnet_id                   = aws_subnet.public_subnet.id
  user_data                   = "${file("apache.sh")}"
}

resource "aws_vpc" "custom_vpc" {
  cidr_block = "192.168.0.0/16"

  tags = {
    Name = "apache_vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = "192.168.10.0/24"
  availability_zone = "us-east-2c"

}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.custom_vpc.id

}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_security_group" "apache_security" {
  name        = "apache_security"
  description = "Allow Web and SSH traffic."
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    description      = "Allows SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
 ingress {
    description      = "Allows HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
output "WebServer_Apache_IP" {
  value = aws_instance.webserver_apache.public_ip
}
