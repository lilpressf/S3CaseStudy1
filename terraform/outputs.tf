# Private IPs of web servers 
output "web1_private_ip" {
  value       = aws_instance.web1.private_ip
  description = "Private IP of web1"
}

output "web2_private_ip" {
  value       = aws_instance.web2.private_ip
  description = "Private IP of web2"
}

# Load Balancer DNS 
output "alb_dns_name" {
  value       = aws_lb.alb.dns_name
  description = "DNS name of the Application Load Balancer"
}

# Database endpoint
output "db_endpoint" {
  value       = aws_db_instance.db.endpoint
  description = "RDS database endpoint"
}

# NAT instance public IP 
output "nat_public_ip" {
  value       = aws_instance.nat.public_ip
  description = "Public IP of the NAT instance"
}

# Web Key Pair Name 
output "web_key_name" {
  value       = aws_key_pair.web_key.key_name
  description = "Name of the key pair used for web servers"
}