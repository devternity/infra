
variable "aws_region" {
  default = "eu-west-1"
}

data "aws_caller_identity" "current" {

}

provider "aws" {
  region  = "${var.aws_region}"
}
