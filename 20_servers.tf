
resource "aws_lightsail_key_pair" "devternity_dashboard_key" {
  name = "devternity-dashboard-key" 
  public_key = "${file("dashboard.pub")}"
}

variable "provision_commands" {
  type = "list"
  default = [
    "sudo bash -c 'apt-get -y -qq update -o=Dpkg::Use-Pty=0'",
    "sudo bash -c 'apt-get -y -qq install -o=Dpkg::Use-Pty=0 linux-image-extra-$(uname -r) linux-image-extra-virtual'",
    "sudo bash -c 'curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -'",
    "sudo bash -c 'add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"'",
    "sudo bash -c 'apt-get -y -qq update -o=Dpkg::Use-Pty=0'",
    "sudo bash -c 'apt-get -y -qq install -o=Dpkg::Use-Pty=0 docker-ce'",
    "sudo bash -c 'apt-get -y -qq install -o=Dpkg::Use-Pty=0 sqlite3 libsqlite3-dev ruby ruby-dev nodejs g++ bundler'",
    "sudo bash -c 'gem install smashing unf_ext'",
    "sudo bash -c 'apt-get -y -qq install -o=Dpkg::Use-Pty=0 nginx'"
  ]
}

resource "aws_lightsail_instance" "devternity_internal_dashboard" {
  name              = "devternity_internal_dashboard"
  availability_zone = "eu-west-1a"
  blueprint_id      = "ubuntu_16_04"
  bundle_id         = "nano_1_0"
  key_pair_name     = "${aws_lightsail_key_pair.devternity_dashboard_key.name}"
  connection {
    host        = "${aws_lightsail_instance.devternity_internal_dashboard.public_ip_address}"
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("dashboard.key")}"
  }
  provisioner "remote-exec" {
    inline = "${var.provision_commands}"
  }
}

resource "aws_lightsail_instance" "devternity_public_dashboard" {
  name              = "devternity_public_dashboard"
  availability_zone = "eu-west-1a"
  blueprint_id      = "ubuntu_16_04"
  bundle_id         = "nano_1_0"
  key_pair_name     = "${aws_lightsail_key_pair.devternity_dashboard_key.name}"
  connection {
    host        = "${aws_lightsail_instance.devternity_public_dashboard.public_ip_address}"
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("dashboard.key")}"
  }
  provisioner "remote-exec" {
    inline = "${var.provision_commands}"
  }
}
