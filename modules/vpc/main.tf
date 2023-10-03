resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name =  "${var.env}-vpc"
  }
}
resource "aws_subnet" "public_subnets" {
  count =  length(var.public_subnets)
  #count =  var.public_subnets[count.index]
  vpc_id = aws_vpc.main.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.azs[count.index]
  tags = {
    Name = "public-subnet-${count.index + 1}"
  }

}

resource "aws_subnet" "public_subnets" {
  count =  length(var.public_subnets)
  #count =  var.public_subnets[count.index]
  vpc_id = aws_vpc.main.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.azs[count.index]
  tags = {
    Name = "public-subnet-${count.index + 1}"
  }

}
