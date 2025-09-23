resource "aws_instance" "web1" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private_a.id
  vpc_security_group_ids = [var.private_subnet_a_cidr]
  key_name               = aws_key_pair.web_key.key_name

  user_data = <<-EOF
              #!/bin/bash
              yum install -y httpd
              systemctl enable httpd
              systemctl start httpd

              # Add a simple default index.html
              echo "<h1>Welcome to Web1 - Served by Apache</h1>" > /var/www/html/index.html

              # Install Node Exporter
              useradd --no-create-home --shell /bin/false node_exporter
              cd /tmp
              wget https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux-amd64.tar.gz
              tar xvf node_exporter-1.8.1.linux-amd64.tar.gz
              cp node_exporter-1.8.1.linux-amd64/node_exporter /usr/local/bin/

              cat <<EOC >/etc/systemd/system/node_exporter.service
              [Unit]
              Description=Node Exporter
              Wants=network-online.target
              After=network-online.target

              [Service]
              User=node_exporter
              Group=node_exporter
              Type=simple
              ExecStart=/usr/local/bin/node_exporter

              [Install]
              WantedBy=multi-user.target
              EOC

              systemctl daemon-reload
              systemctl enable node_exporter
              systemctl start node_exporter
              EOF

  tags = { Name = "web1" }
}

resource "aws_instance" "web2" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private_b.id
  vpc_security_group_ids = [var.private_subnet_b_cidr]
  key_name               = aws_key_pair.web_key.key_name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y

              # Install Apache
              yum install -y httpd
              systemctl enable httpd
              systemctl start httpd

              # Add a simple default index.html
              echo "<h1>Welcome to Web2 - Served by Apache</h1>" > /var/www/html/index.html

              # Install Node Exporter
              useradd --no-create-home --shell /bin/false node_exporter
              cd /tmp
              wget https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux-amd64.tar.gz
              tar xvf node_exporter-1.8.1.linux-amd64.tar.gz
              cp node_exporter-1.8.1.linux-amd64/node_exporter /usr/local/bin/

              cat <<EOC >/etc/systemd/system/node_exporter.service
              [Unit]
              Description=Node Exporter
              Wants=network-online.target
              After=network-online.target

              [Service]
              User=node_exporter
              Group=node_exporter
              Type=simple
              ExecStart=/usr/local/bin/node_exporter

              [Install]
              WantedBy=multi-user.target
              EOC

              systemctl daemon-reload
              systemctl enable node_exporter
              systemctl start node_exporter
              EOF

  tags = { Name = "web2" }
}
