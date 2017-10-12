
variable "aws_region" {
  default = "eu-west-1"
}

variable "cloudflare_email" {
  default = ""
}

variable "cloudflare_token" {
  default = ""
}

data "aws_caller_identity" "current" {

}

provider "aws" {
  region  = "${var.aws_region}"
  version = "1.0"
}
