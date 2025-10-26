data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter { 
    name = "name" 
    values = ["al2023-ami-*-x86_64"] 
  }
}

# locals {
#   template = file("./user-data.sh")
#   user_data = <<-EOT
#     #!/bin/bash
#     set -eux
#     dnf -y update
#     dnf -y install nginx
#     echo "Hello from $(hostname) — ASG behind ALB" > /usr/share/nginx/html/index.html
#     systemctl enable --now nginx
#   EOT
# }