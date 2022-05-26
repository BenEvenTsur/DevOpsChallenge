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
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}