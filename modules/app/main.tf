resource "aws_security_group" "security_group" {
  name        = "${var.env}-${var.component}-sg"
  description = "${var.env}-${var.component}-sg"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]

  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.bastion_node_cidr  #for baston node which is workstation we are allowing SSH connection

  }

  ingress {
    description = "PROMETHEUS"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = var.prometheus_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-${var.component}-sg"
  }
}


resource "aws_iam_role" "role" {
  name = "${var.env}-${var.component}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "${var.env}-${var.component}-policy"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "VisualEditor0",
          "Effect" : "Allow",
          "Action" : [
            "ssm:DescribeParameters",
            "ssm:GetParameterHistory",
            "ssm:GetParametersByPath",
            "ssm:GetParameters",
            "ssm:GetParameter"
          ],
          "Resource" : "*"
        }
      ]
    })
  }

  tags = {
    tag-key = "${var.env}-${var.component}-role"         #this role i am attaching to my ec2 instance like frontend etc.
  }
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.env}-${var.component}-role"                   #for roles when you create manually we will get instance profiles for that we need to enable in automation also
  role = aws_iam_role.role.name
}                                                             #this instance profile will be used for ec2 not for IAM




resource "aws_launch_template" "template" {
  name                   = "${var.env}-${var.component}"
  image_id               = data.aws_ami.ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.security_group.id]

 iam_instance_profile {
   name = aws_iam_instance_profile.instance_profile.name
 }

  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    role_name = var.component,
    env       = var.env
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.env}-${var.component}"
    }
  }
}




resource "aws_autoscaling_group" "asg" {
  name                = "${var.env}-${var.component}"
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  vpc_zone_identifier = var.subnets
  target_group_arns   = [aws_lb_target_group.tg.arn]

  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }
  tag {
    key                 = "project"
    propagate_at_launch = true
    value               = "expense"
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "${var.env}-${var.component}-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id                             #creating  target group for private load balancer
  health_check {
    enabled             = true
    healthy_threshold   = 2 #how many times it will go and detect
    interval            = 5  #reg response time
    unhealthy_threshold = 2                       # how fast it detects healthy is also important so healthy modules using
    port                = var.app_port
    path                = "/health"  #end point
    timeout             = 3
  }
}
