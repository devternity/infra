
resource "cloudflare_record" "sales" {
  domain = "devternity.com"
  name   = "sales"
  value  = "${aws_lightsail_instance.devternity_internal_dashboard.public_ip_address}"
  type   = "A"
  ttl    = 120
}

resource "cloudflare_record" "dashboard" {
  domain = "devternity.com"
  name   = "dashboard"
  value  = "${aws_lightsail_instance.devternity_public_dashboard.public_ip_address}"
  type   = "A"
  ttl    = 120
}