# Get your public IP (optional, can be used for SSH whitelisting)
data "http" "my_ip" {
  url = "http://checkip.amazonaws.com/"
}

# Get latest Ubuntu 22.04 AMI from Canonical (not needed if you use a custom AMI via var.ami_id)
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

# EC2 Security Group: allow only ALB to access app port, and SSH from anywhere
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  description = "Allow app access from ALB and SSH from anywhere"
  vpc_id      = aws_vpc.custom_vpc.id

  # App port access only from ALB
  ingress {
    description     = "Allow traffic from ALB on app port"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # SSH for debugging (optional)
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EC2 Security Group"
  }
}
