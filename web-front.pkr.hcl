# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/packer
packer {
  required_plugins {
    amazon = {
      version = ">= 1.3"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/source
source "amazon-ebs" "ubuntu" {
  ami_name      = "web-nginx-aws"
  instance_type = "t2.micro"
  region        = "us-west-2"

  source_ami_filter {
    filters = {
		  # COMPLETE ME complete the "name" argument below to Ubuntu 24.04
      name = "ubuntu-*-24.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"] 
	}

  ssh_username = "ubuntu"
}

# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build
build {
  name = "web-nginx"
  sources = [
    # COMPLETE ME Use the source defined above
    "source.amazon-ebs.ubuntu"
  ]
  
  # https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build/provisioner
  provisioner "shell" {
    inline = [
      "echo creating directories - web/html",
      # COMPLETE ME add inline scripts to create necessary directories and change directory ownership.
      "sudo mkdir -p /web/html",
      "sudo chown -R ubuntu:ubuntu /web",

      "echo creating directories - tmp/web",
      "sudo mkdir -p /tmp/web",
      "sudo chown -R ubuntu:ubuntu /tmp"
    ]
  }

  provisioner "file" {
    # COMPLETE ME add the HTML file to your image
    source      = "files/index.html"
    destination = "/tmp/web/index.html"
  }

  provisioner "file" {
    # COMPLETE ME add the nginx.conf file to your image
    source      = "files/nginx.conf"
    destination = "/tmp/web/nginx.conf" 
  }

  # COMPLETE ME add additional provisioners to run shell scripts and complete any other tasks

  provisioner "file" {
    source      = "scripts/install-nginx"
    destination = "/tmp/web/install-nginx.sh"
  }

  provisioner "file" {
    source      = "scripts/setup-nginx"
    destination = "/tmp/web/setup-nginx.sh"
  }

  provisioner "shell" {
    inline = [
      "echo installing Nginx",
      "sudo rm -f /var/lib/apt/lists/lock",
      "cat /tmp/web/install-nginx.sh",
      "sudo chmod +x /tmp/web/install-nginx.sh",
      "sudo chmod +x /tmp/web/setup-nginx.sh",
      "bash /tmp/web/install-nginx.sh",  
      "bash /tmp/web/setup-nginx.sh", 
      "echo moving index.html to /web/html",
      "sudo mv /tmp/web/index.html /web/html/index.html",  
    ]
  }

}

