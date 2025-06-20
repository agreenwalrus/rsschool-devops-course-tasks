resource "aws_subnet" "subnet" {
  count                   = length(var.cidr_blocks)
  vpc_id                  = var.vpc_id
  cidr_block              = var.cidr_blocks[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = var.is_public

  tags = {
    Name = "${var.name_prefix}-${count.index + 1}"
  }
}

resource "aws_route_table_association" "subnet_association" {
  count          = length(var.cidr_blocks)
  subnet_id      = aws_subnet.subnet[count.index].id
  route_table_id = var.route_table_id
}
