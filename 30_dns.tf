resource "cloudflare_zone_settings_override" "devternity-com-settings" {
  name   = "devternity.com"
  settings {
    tls_1_3 = "on"
    automatic_https_rewrites = "on"
    always_use_https = "on"
    ssl = "flexible"
  }
}

resource "cloudflare_record" "sales" {
  domain = "devternity.com"
  name   = "internal"
  value  = aws_lightsail_instance.devternity_internal_dashboard.public_ip_address
  type   = "A"
  ttl    = 120
}

resource "cloudflare_record" "dashboard" {
  domain   = "devternity.com"
  name     = "dashboard"
  priority = 1
  value    = aws_lightsail_instance.devternity_public_dashboard.public_ip_address
  type     = "A"
  ttl      = 120
}

resource "cloudflare_record" "dt2018-cname" {
  domain  = "devternity.com"
  name    = "dt2018"
  value   = "gh-travis-master.fqhrnw2tbq.eu-west-1.elasticbeanstalk.com"
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "slackin2018-cname" {
  domain  = "devternity.com"
  name    = "slackin2018"
  value   = "gh-dt2018-slackin.fqhrnw2tbq.eu-west-1.elasticbeanstalk.com"
  type    = "CNAME"
  ttl     = 1
  proxied = true
}
