
variable "aws_region" {
  default = "eu-west-1"
}

variable "access_key_id" {
  default = ""
}

variable "secret_key" {
  default = ""
}

variable "cloudflare_email" {
  default = ""
}

variable "cloudflare_token" {
  default = ""
}

data "aws_caller_identity" "current" {

}
