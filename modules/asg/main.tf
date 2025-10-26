resource "aws_autoscaling_group" "this" {
  name = "${var.project}-asg"
  desired_capacity = var.desired_capacity
  min_size = var.min_size
  max_size = var.max_size
  vpc_zone_identifier = var.private_subnet_ids
  health_check_type = "EC2"

  launch_template {
    id = var.launch_template_id
    version = var.template_version
  }
  
  target_group_arns = [ var.target_group_arn ]

  tag {
    key                 = "Name"
    value               = "${var.project}-asg"
    propagate_at_launch = true
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      max_healthy_percentage = 100
      instance_warmup =  60
    }
    triggers = [ "launch_template" ]
  }
}