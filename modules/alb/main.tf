resource "random_string" "tg" { 
  length = 5 
  special = false 
}

# elastic load balancer
resource "aws_lb" "alb" {
    name               = "${var.project}-alb"
    load_balancer_type = "application"
    internal           = false 
    security_groups    = [var.alb_sg_id]
    subnets            = var.subnet_ids
    tags               = { Name = "${var.project}-alb" }

}


# target group 
resource "aws_lb_target_group" "tg" {
    name_prefix   = "tg-"
    port          = var.app_port
    protocol      = "HTTP"
    target_type   = "instance"
    vpc_id        = var.vpc_id

    lifecycle {
        create_before_destroy = true
    }

    health_check {
        path                = "/"
        protocol            = "HTTP"
        matcher             = "200-399"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
    }

    tags = { Name = "${var.project}-tg" }

    depends_on = [ aws_lb.alb ]
}


resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

