resource "aws_instance" "monitoring" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"   
  subnet_id     = aws_subnet.public_a.id
  key_name      = aws_key_pair.web_key.key_name
  vpc_security_group_ids = [aws_security_group.monitoring_sg.id]

  tags = { Name = "monitoring-ec2" }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y

              # Install dependencies
              amazon-linux-extras install epel -y
              yum install -y wget tar git

              # Install Prometheus
              useradd --no-create-home --shell /bin/false prometheus
              mkdir /etc/prometheus /var/lib/prometheus
              cd /tmp
              wget https://github.com/prometheus/prometheus/releases/download/v2.48.1/prometheus-2.48.1.linux-amd64.tar.gz
              tar xvf prometheus-2.48.1.linux-amd64.tar.gz
              cp prometheus-2.48.1.linux-amd64/prometheus /usr/local/bin/
              cp prometheus-2.48.1.linux-amd64/promtool /usr/local/bin/
              cp -r prometheus-2.48.1.linux-amd64/consoles /etc/prometheus
              cp -r prometheus-2.48.1.linux-amd64/console_libraries /etc/prometheus

              cat <<EOC >/etc/prometheus/prometheus.yml
              global:
                scrape_interval: 15s
              scrape_configs:
                - job_name: 'prometheus'
                  static_configs:
                    - targets: ['localhost:9090']
                - job_name: 'node_exporter'
                  static_configs:
                    - targets: ['localhost:9100']
              EOC

              chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus

              cat <<EOC >/etc/systemd/system/prometheus.service
              [Unit]
              Description=Prometheus
              Wants=network-online.target
              After=network-online.target

              [Service]
              User=prometheus
              Group=prometheus
              Type=simple
              ExecStart=/usr/local/bin/prometheus \
                --config.file=/etc/prometheus/prometheus.yml \
                --storage.tsdb.path=/var/lib/prometheus/ \
                --web.console.templates=/etc/prometheus/consoles \
                --web.console.libraries=/etc/prometheus/console_libraries

              [Install]
              WantedBy=multi-user.target
              EOC

              systemctl daemon-reload
              systemctl enable prometheus
              systemctl start prometheus

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

              # Install Grafana
              wget -q -O - https://packages.grafana.com/gpg.key | rpm --import -
              cat <<EOC >/etc/yum.repos.d/grafana.repo
              [grafana]
              name=grafana
              baseurl=https://packages.grafana.com/oss/rpm
              repo_gpgcheck=1
              enabled=1
              gpgcheck=1
              gpgkey=https://packages.grafana.com/gpg.key
              EOC

              yum install -y grafana
              systemctl enable grafana-server
              systemctl start grafana-server
              EOF
}
