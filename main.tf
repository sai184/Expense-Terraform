module "vpc" {
  source = "./env-dev"
  vpc_cidr      = var.vpc_cidr
}