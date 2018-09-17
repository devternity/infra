
provider "aws" {
  region  = "${var.aws_region}"
  access_key = "${var.access_key_id}"
  secret_key = "${var.secret_key}"
}

provider "cloudflare" {
  email = "${var.cloudflare_email}"
  token = "${var.cloudflare_token}"
}


