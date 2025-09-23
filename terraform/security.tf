# NAT Security Group
resource "aws_security_group" "nat_sg" {
  vpc_id = aws_vpc.main.id
  name   = "nat-sg"

  # Allow SSH from your IP only
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  # Outbound traffic for NAT
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ALB Security Group
resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.main.id
  name   = "alb-sg"

  # Inbound HTTP from internet
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound: allow all 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Webserver Security Group
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.main.id
  name   = "web-sg"

  # Allow HTTP only from ALB
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Outbound to NAT (for updates)
  egress {
    from_port   = 80
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound to DB
  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.private_subnet_a_cidr, var.private_subnet_b_cidr]
  }
}

# Database Security Group
resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.main.id
  name   = "db-sg"

  # Allow MySQL only from webserver subnets
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.private_subnet_a_cidr, var.private_subnet_b_cidr]
  }

  # Outbound: allow all 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Monitoring Security Group
resource "aws_security_group" "monitoring_sg" {
  vpc_id = aws_vpc.main.id
  name   = "monitoring-sg"

  # Allow SSH from your IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  # Allow Grafana UI from your IP
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  # Allow Prometheus access only inside VPC 
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Outbound: allow all
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "monitoring-sg" }
}

# Key Pair for web servers
resource "aws_key_pair" "web_key" {
  key_name   = "web-key"
  public_key = var.ssh_public_key
}
