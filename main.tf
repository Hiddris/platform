#VPC
resource "aws_vpc" "hisham_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "HishamSecureVPC"
  }
}

#Subnet
resource "aws_subnet" "hisham_test_subnet" {
 vpc_id = aws_vpc.hisham_vpc.id
 cidr_block = "10.0.1.0/24"

 tags={
  Name = "HishTestSubnet"
 }
}

#Creates a route to the internet
resource "aws_internet_gateway" "hish_gw" {
  vpc_id = aws_vpc.hisham_vpc.id
  
  tags = {
    Name = "Hish IGW"
  }
}

#Create new route table with IGW
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.hisham_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.hish_gw.id
  }
  tags = {
    Name = "Hish IGW"
  }
}

#Associates route table with subnet
resource "aws_route_table_association" "public_1_rt_assoc" {
  subnet_id = aws_subnet.hisham_test_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

#creates new security group open to HTTP traffic
resource "aws_security_group" "hish_sg"{
  name = "HTTP"
  vpc_id = aws_vpc.hisham_vpc.id

  ingress{
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks= ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#create EC2 instance
resource "aws_instance" "app_server" {
  ami           = "ami-0592c673f0b1e7665"
  instance_type = "t2.micro"

  subnet_id = aws_subnet.hisham_test_subnet.id
  vpc_security_group_ids = [aws_security_group.hish_sg.id]
  associate_public_ip_address = true

  #user_data = file("${path.module}/app.sh")
  
  user_data = <<-EOF
  #!/bin/bash -ex
 
  amazon-linux-extras install nginx1 -y
  echo "<h1>This is my new server</h1>" > /usr/share/nginx/html/index.html
  systemctl enable nginx
  systemctl start nginx
  EOF

  tags = {
    Name = "HishamVPCExample"
  }
}