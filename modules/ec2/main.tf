resource "aws_iam_role" "ssm_role" {
  name = "${var.project}-ec2-ssm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_managed_core" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "${var.project}-ec2-ssm-profile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.project}-lt-"
  image_id      = coalesce(var.ami_id, data.aws_ami.amazon_linux.id)
  instance_type = var.instance_type
  user_data     = filebase64("${path.module}/user-data.sh")

  vpc_security_group_ids = [var.ec2_sg_id]


  iam_instance_profile {
    arn = aws_iam_instance_profile.ssm_profile.arn
  }
  tag_specifications {
    resource_type = "instance"
    tags = { Name = "${var.project}-ec2" }
  }

   monitoring {
    enabled = true
  }
}


