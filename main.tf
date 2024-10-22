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

    ingress{
    from_port = 22
    to_port = 22
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
  key_name = "hisham_mental"
  #user_data = file("${path.module}/app.sh")
  
  user_data = <<-EOF
  #!/bin/bash
  yum update -y
  yum install nginx -y
  echo "<h1>This is my new server</h1>" > /usr/share/nginx/html/index.html
  systemctl enable nginx
  systemctl start nginx
  EOF

  tags = {
    Name = "HishamVPCExample"
  }
}

#create private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.hisham_vpc.id
  cidr_block = "10.0.1.0/24"
  
  map_public_ip_on_launch = false 
  
  tags = {
    Name = "private-subnet-hisham"
  }
}


#route table for private subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.hisham_vpc.id

  tags = {
    Name = "private-route-table"
  }
}

# 4. Associate Private Subnet with Route Table
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

#
resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.hisham_vpc.id

  ingress {
    from_port   = 3306   # MySQL port (adjust for other DB types)
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Allow only VPC-internal traffic
  }

  ingress {
    from_port   = 22    # SSH access (optional, only from within VPC or bastion)
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Limit SSH access within the VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-sg"
  }
}

resource "aws_instance" "db_instance" {
  ami                    = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 (use correct AMI for your region)
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private_subnet.id
  security_groups        = [aws_security_group.db_sg.name]
  associate_public_ip_address = false # Private subnet, no public IP

  key_name               = "hisham-db-key" 

  tags = {
    Name = "db-instance-hisham"
  }
}

#install sql with provisioner
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "hisham-db-key"
      host        = self.private_ip
    }

    inline = [
      # Install MySQL and start the service (Amazon Linux example)
      "sudo yum update -y",
      "sudo yum install -y mysql-server",
      "sudo systemctl start mysqld",
      "sudo systemctl enable mysqld",
      # Set a root password (this is just an example, consider better security practices)
      "sudo mysqladmin -u root password 'your-strong-password'"
    ]
  }



resource "aws_instance" "php_server" {
  ami           = "ami-0592c673f0b1e7665"
  instance_type = "t2.micro"

  subnet_id = aws_subnet.hisham_test_subnet.id
  vpc_security_group_ids = [aws_security_group.hish_sg.id]
  associate_public_ip_address = true
  key_name = "hisham_php_app"
  #user_data = file("${path.module}/app.sh")
  
  user_data = <<-EOF
  #!/bin/bash
  #!/bin/bash
  yum update -y
  amazon-linux-extras install -y php7.2
  yum install -y httpd
  systemctl start httpd
  systemctl enable httpd
  usermod -a -G apache ec2-user
  chown -R ec2-user:apache /var/www
  chmod 2775 /var/www
  find /var/www -type d -exec chmod 2775 {} \;
  find /var/www -type f -exec chmod 0664 {} \;
  cd /var/www/html
  cp file("${path.module}/index.php")
  EOF

  tags = {
    Name = "HishamVPCWithPHP"
  }
}