locals {
  wildcard_address = "0.0.0.0"
  default_route    = "${local.wildcard_address}/0"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}

data "aws_availability_zones" "zones" {
  state = "available"
}

resource "aws_subnet" "subnets" {
  count             = var.subnets_quantity
  availability_zone = data.aws_availability_zones.zones.names[count.index]
  cidr_block        = "10.0.${1 + count.index}.0/24"
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
    key                 = "autoscaling_group_key"
    value               = "autoscaling_group_value"
    propagate_at_launch = true
  }
}