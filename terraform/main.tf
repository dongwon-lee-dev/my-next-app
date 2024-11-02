resource "aws_vpc" "nextjs_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "nextjs_vpc"
  }
}

resource "aws_subnet" "nextjs_subnet" {
  vpc_id            = aws_vpc.nextjs_vpc.id
  cidr_block        = "172.16.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "nextjs_igw" {
  vpc_id = aws_vpc.nextjs_vpc.id
}

resource "aws_route_table" "nextjs_rtb" {
  vpc_id = aws_vpc.nextjs_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nextjs_igw.id
  }
}

resource "aws_route_table_association" "nextjs_rta" {
  subnet_id      = aws_subnet.nextjs_subnet.id
  route_table_id = aws_route_table.nextjs_rtb.id
}

resource "aws_security_group" "nextjs_sg" {
  name        = "nextjs_sg"
  description = "Allow SSH, HTTP, and HTTPS inbound traffic"
  vpc_id      = aws_vpc.nextjs_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nextjs_instance" {
  ami           = "ami-0866a3c8686eaeeba"  
  instance_type = "t2.small"

  subnet_id     = aws_subnet.nextjs_subnet.id
  vpc_security_group_ids = [aws_security_group.nextjs_sg.id]

  key_name      = "devops-pipeline-project"
  user_data = file("${path.module}/install-docker.sh")

  tags = {
    Name = "nextjs_instance"
  }
}
