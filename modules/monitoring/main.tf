resource "aws_sns_topic" "alerts" {
  name = "${var.project}-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# Scale OUT
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${var.project}-scale-out"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  autoscaling_group_name = var.asg_name
}

# Scale IN
resource "aws_autoscaling_policy" "scale_in" {
  name                   = "${var.project}-scale-in"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  autoscaling_group_name = var.asg_name
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.project}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "CPU > 70% triggers scale out"
  dimensions = { AutoScalingGroupName = var.asg_name }
  alarm_actions = [aws_autoscaling_policy.scale_out.arn, aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.project}-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 5
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 20
  alarm_description   = "CPU < 20% triggers scale in"
  dimensions = { AutoScalingGroupName = var.asg_name }
  alarm_actions = [aws_autoscaling_policy.scale_in.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}
