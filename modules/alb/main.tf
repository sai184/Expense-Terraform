
#need to create security group check in for resource in terraform registry
resource "aws_security_group" "security_group" {
  name        = "${var.env}-${var.alb_type}-sg"
  description = "${var.env}-${var.alb_type}-sg"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 443
    to_port     = 443        #80
    protocol    = "tcp"
    cidr_blocks = [var.alb_sg_allow_cidr]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-${var.alb_type}-sg"
  }
}

resource "aws_lb" "alb" {
  name               = "${var.env}-${var.alb_type}"
  internal           = var.internal                           #
  load_balancer_type = "application"
  security_groups    = [aws_security_group.security_group.id]
  subnets            = var.subnets
  tags = {
    Environment = "${var.env}-${var.alb_type}"
  }
}
resource "aws_route53_record" "www" {
  zone_id = var.zone_id
  name    = var.dns_name
  type    = "CNAME"            #address need to points to one address to another adddress is called CNAME
  ttl     = 300
  records = [aws_lb.alb.dns_name]   #to this dns name we are creating cname record
}


resource "aws_lb_listener" "listener-http-public" {
  count             = var.alb_type == "public" ? 1 : 0
  load_balancer_arn = aws_lb.alb.arn                          #adding listeners to load balamcer
                                                   #listener to check for incoming traffic from load balancer while tarfet group will route requests to one or more targets
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


resource "aws_lb_listener" "listener-http-private" {
  count             = var.alb_type == "private" ? 1 : 0
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = var.tg_arn
  }
}


resource "aws_lb_listener" "listener-https" {
  count             = var.alb_type == "public" ? 1 : 0
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-1:221453714752:certificate/e837e0fa-3161-4fbd-877b-2bca9c52a218"


  default_action {
    type             = "forward"
    target_group_arn = var.tg_arn
  }
}