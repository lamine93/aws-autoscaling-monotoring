resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Security group for Load Balancer"
  vpc_id      = var.vpc_id
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  description = "Security group for EC2 instances"
  vpc_id      = var.vpc_id
}

# Inbound HTTP from Internet → LB
resource "aws_vpc_security_group_ingress_rule" "allow_lb_http" {
  security_group_id = aws_security_group.alb_sg.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

# Egress LB to EC2 instances (strict : only toward SG EC2, port app)
resource "aws_vpc_security_group_egress_rule" "allow_lb_to_ec2" {
  security_group_id            = aws_security_group.alb_sg.id
  referenced_security_group_id = aws_security_group.ec2_sg.id
  ip_protocol                  = "tcp"
  from_port                    = var.app_port
  to_port                      = var.app_port
}

# Inbound EC2 from LB (port app)
resource "aws_vpc_security_group_ingress_rule" "allow_ec2_from_lb" {
  security_group_id            = aws_security_group.ec2_sg.id
  referenced_security_group_id = aws_security_group.alb_sg.id
  ip_protocol                  = "tcp"
  from_port                    = var.app_port
  to_port                      = var.app_port
}

# Egress EC2 to Internet (HTTPS) for updates/Logs/etc.
# resource "aws_vpc_security_group_egress_rule" "allow_https_outbound_ecs" {
#   security_group_id = aws_security_group.ec2_sg.id
#   ip_protocol       = "tcp"
#   from_port         = 443
#   to_port           = 443
#   cidr_ipv4         = "0.0.0.0/0"
# }


# EC2 egress: allow all (covers SSM 443 + DNS 53/UDP, package repos, time, etc.)
resource "aws_vpc_security_group_egress_rule" "ec2_all_egress" {
  security_group_id = aws_security_group.ec2_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}


resource "aws_vpc_security_group_ingress_rule" "allow_https_inbound_alb" {
  security_group_id = aws_security_group.alb_sg.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}


