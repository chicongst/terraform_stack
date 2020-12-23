resource "aws_vpc" "vpc_for_test" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "tf-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc_for_test.id
    tags = {
        Name = "f igw"
    }
}

resource "aws_subnet" "subnet_for_test" {
  vpc_id            = aws_vpc.vpc_for_test.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "tf-subnet"
  }
}


resource "aws_route_table" "tf-public-route-table" {
    vpc_id = aws_vpc.vpc_for_test.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "tf route table"
    }
}

resource "aws_route_table_association" "public-subnet-test" {
    subnet_id = aws_subnet.subnet_for_test.id
    route_table_id = aws_route_table.tf-public-route-table.id
}


resource "aws_security_group" "allow_web_ssh" {
  name        = "allow_web_ssh"
  description = "Allow Web and SSH inbound traffic"
  vpc_id      = aws_vpc.vpc_for_test.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web_ssh"
  }
}

resource "aws_instance" "ansible" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  count = var.number_of_instances
  associate_public_ip_address = "true"
  subnet_id = aws_subnet.subnet_for_test.id
  vpc_security_group_ids = [
    aws_security_group.allow_web_ssh.id
  ]
  key_name = "pairplay1"
  tags = {
    created_by = "${lookup(var.tags,"created_by")}"
    Name = "${var.instance_name}-${count.index + 1}"
  }
}


output "ip" {
  value = aws_instance.ansible.*.public_ip
}
