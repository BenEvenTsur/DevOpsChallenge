locals {
  default_route            = "0.0.0.0/0"
  internal_ip_prefix       = "10.0"
  http_protocol            = "HTTP"
  alb_listener_action_type = "forward"
}

resource "aws_vpc" "vpc" {
  cidr_block = "${local.internal_ip_prefix}.0.0/16"
}

data "aws_availability_zones" "zones" {
  state = "available"
}

resource "aws_subnet" "subnets" {
  count             = var.subnets_quantity
  availability_zone = data.aws_availability_zones.zones.names[count.index]
  cidr_block        = "${local.internal_ip_prefix}.${1 + count.index}.0/24"
  vpc_id            = aws_vpc.vpc.id
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "route" {
  route_table_id         = aws_vpc.vpc.main_route_table_id
  destination_cidr_block = local.default_route
  gateway_id             = aws_internet_gateway.gateway.id
}

resource "aws_security_group" "security_group" {
  vpc_id = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.default_route]
  }

  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = [local.default_route]
  }
}

data "template_file" "httpd_script" {
  template = file("${path.module}/httpd_execute.sh")

  vars = {
    http_port = "${var.http_port}"
  }
}

resource "aws_launch_configuration" "launch_configuration" {
  image_id                    = var.ami_id
  instance_type               = var.instance_type
  user_data                   = data.template_file.httpd_script.rendered
  security_groups             = [aws_security_group.security_group.id]
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "autoscaling_group" {
  launch_configuration = aws_launch_configuration.launch_configuration.id
  vpc_zone_identifier  = [for subnet in aws_subnet.subnets : subnet.id]
  min_size             = var.ec2_instances_quantity
  max_size             = var.ec2_instances_quantity

  tag {
    key                 = "asg_k"
    value               = "asg_v"
    propagate_at_launch = true
  }
}

resource "aws_alb" "alb" {
  subnets         = [for subnet in aws_subnet.subnets : subnet.id]
  security_groups = [aws_security_group.security_group.id]
  internal        = false
}

resource "aws_alb_target_group" "alb_target_group" {
  port     = var.http_port
  protocol = local.http_protocol
  vpc_id   = aws_vpc.vpc.id
}

resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = var.http_port
  protocol          = local.http_protocol

  default_action {
    target_group_arn = aws_alb_target_group.alb_target_group.arn
    type             = local.alb_listener_action_type
  }
}

resource "aws_alb_listener_rule" "listener_rule" {
  depends_on   = [aws_alb_target_group.alb_target_group]
  listener_arn = aws_alb_listener.alb_listener.arn

  action {
    target_group_arn = aws_alb_target_group.alb_target_group.id
    type             = local.alb_listener_action_type
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}

resource "aws_autoscaling_attachment" "autoscaling_attachment" {
  lb_target_group_arn    = aws_alb_target_group.alb_target_group.arn
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.id
}