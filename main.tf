module "vpc" {
  source = "./modules/vpc"
  vpc_cidr      = var.vpc_cidr
  env = var.env
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets
  azs = var.azs
  default_vpc_id = var.default_vpc_id
  default_vpc_id_cidr = var.default_vpc_id_cidr
  default_route_table_id = var.default_route_table_id
  account_id = var.account_id
}

 module "public-lb" {
  source            = "./modules/alb"
  alb_sg_allow_cidr = "0.0.0.0/0"
  alb_type          = "public"
  env               = var.env
  internal          = false
  subnets           = module.vpc.public_subnets
  vpc_id            = module.vpc.vpc_id
   #dns_name         = "frontend-${var.env}.rdevopsb72online.online"
   #zone_id          = "Z"
 }

module "private-lb" {
  source            = "./modules/alb"
  alb_sg_allow_cidr = var.vpc_cidr
  alb_type          = "private"
  env               = var.env
  internal          = true
  subnets           = module.vpc.private_subnets
  vpc_id            = module.vpc.vpc_id
 # dns_name          = "backend-${var.env}.rdevopsb72online.online"
 # zone_id           = "Z"
}

module "frontend" {
  source            = "./modules/app"
  app_port          = 80
  component         = "frontend"
  env               = var.env
  instance_type     = "t3.micro"
  vpc_cidr          = var.vpc_cidr
  vpc_id            = module.vpc.vpc_id
  subnets           = module.vpc.private_subnets
  bastion_node_cidr = var.bastion_node_cidr
  desired_capacity  = var.desired_capacity
  max_size          = var.max_size
  min_size          = var.min_size


}
module "backend" {

  source            = "./modules/app"
  app_port          = 80
  component         = "backend"
  env               = var.env
  instance_type     = "t3.micro"
  vpc_cidr          = var.vpc_cidr
  vpc_id            = module.vpc.vpc_id
  subnets           = module.vpc.private_subnets
  bastion_node_cidr = var.bastion_node_cidr
  desired_capacity  = var.desired_capacity
  max_size          = var.max_size
  min_size          = var.min_size

}
