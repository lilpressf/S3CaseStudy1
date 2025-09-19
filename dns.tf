# Private Route 53 hosted zone
resource "aws_route53_zone" "private" {
  name = "internal.daan.internal"

  vpc {
    vpc_id = aws_vpc.main.id
  }
}

# Private DNS record for web1
resource "aws_route53_record" "web1_private" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "web1.internal.daan.internal"
  type    = "A"
  ttl     = 300
  records = [aws_instance.web1.private_ip]
}

# Private DNS record for web2
resource "aws_route53_record" "web2_private" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "web2.internal.daan.internal"
  type    = "A"
  ttl     = 300
  records = [aws_instance.web2.private_ip]
}

# Private DNS record for RDS
resource "aws_route53_record" "db_private" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "db.internal.daan.internal"
  type    = "CNAME"
  ttl     = 300
  records = [aws_db_instance.db.endpoint]
}
