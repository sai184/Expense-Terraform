module "vpc" {
  source = "./env-dev"
  vpc_cidr      = var.vpc_cidr
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets
  azs = var.azs
}