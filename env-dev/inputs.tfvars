env = "dev"

vpc_cidr               = "10.0.0.0/16"
public_subnets         = ["10.0.0.0/24", "10.0.1.0/24"]
private_subnets        = ["10.0.2.0/24", "10.0.3.0/24"]
azs                    = ["us-east-1a", "us-east-1b"]
account_id             = "221453714752"
default_vpc_id         = "vpc-0c8040dc69ef7d5e2"
default_vpc_id_cidr    = "172.31.0.0/16"
default_route_table_id = "rtb-0709be1921d4a4598"
bastion_node_cidr     = [ "172.31.29.106/32" ] #security group expects list only /32 means one ip
desired_capacity       = 1
max_size               = 1
min_size               = 1
