# VPC creation
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.vpc_name}"
  }
}

# Creating 4 public subnets
resource "aws_subnet" "public" {
  count = 2
  #count                   = length(var.public_subnets)
  vpc_id = aws_vpc.main.id
  # cidr_block              = element(var.public_subnets, count.index)
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(var.availability_zones, count.index)

  tags = {
    Name = "${var.public-subnet}-${count.index + 1}"
  }
}


# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.igw_name}"
  }
}
# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.public-route-table}"
  }
}

# Associate route table with subnets
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "allow_ssh" {
  vpc_id = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      description = "Allow SSH"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  #ingress {
  #    description = "Allow SSH"
  #    from_port   = 22
  #    to_port     = 22
  #    protocol    = "tcp"
  #    cidr_blocks = ["0.0.0.0/0"]
  #  }
  #  ingress {
  #    description = "Allow SSH"
  #    from_port   = 389
  #    to_port     = 389
  #    protocol    = "tcp"
  #    cidr_blocks = ["0.0.0.0/0"]
  #  }
  #ingress {
  #    description = "Allow SSH"
  #    from_port   = 80
  #    to_port     = 80
  #    protocol    = "tcp"
  #    cidr_blocks = ["0.0.0.0/0"]
  #  }
  #  egress {
  #    from_port   = 0
  #    to_port     = 0
  #    protocol    = "-1"
  #    cidr_blocks = ["0.0.0.0/0"]
  #  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.SG_allow-ssh}"
  }
}

# Key Pair
resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "main" {
  key_name = "main-key"
  #public_key = tls_private_key.main.public_key_openssh
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPmlw08/iYkTYG+YKyyFBcuwl9QH5V9oXQ/bJekxGZ/y admin@DESKTOP-PS0OIPE"

}

resource "local_file" "private_key" {
  content         = tls_private_key.main.private_key_pem
  filename        = "${path.module}/main-key.pem"
  file_permission = "0400"
}
# EC2 Instance
resource "aws_instance" "Master" {
  ami           = var.ami_id
  instance_type = lookup(var.instance_type, terraform.workspace)

  # Upload a file using the file provisioner

  provisioner "remote-exec" {
    inline = ["sudo yum update -y",
      "sudo yum install nginx -y",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx",
      "sudo useradd ravi2"
    ]
  }
  provisioner "file" {
    on_failure  = continue
    source      = "hello.txt"
    destination = "/tmp/hello.txt"
  }

  provisioner "local-exec" {
    on_failure = continue
    command    = "echo ${aws_security_group.allow_ssh.id} >> E:/cluster/all terraformcode/m2_terraform-workspace"
  }
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("E:/cluster/all terraformcode/m2_terraform-workspace/keys") # Replace with the path to your private key
    host        = self.public_ip

  }
  count                       = length(var.Master-servers)
  subnet_id                   = element(aws_subnet.public[*].id, 0)
  key_name                    = aws_key_pair.main.key_name
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  associate_public_ip_address = true

  tags = {
    Name = var.Master-servers[count.index]
    #Environment = "${var.environment}"

  }

}



