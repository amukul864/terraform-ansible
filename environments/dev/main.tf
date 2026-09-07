module "vpc" {
  source       = "../../modules/networking"
  env_name     = "dev"
  cidr_block   = "10.0.0.0/16"
  az_count     = null
  nat_strategy = "single"
}

module "bastion" {
  source           = "../../modules/bastion"
  env_name         = "dev"
  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_ids[0]
  public_key_path  = "~/.ssh/id_rsa_aws_dev.pub"
}

module "ansible_config" {
  source            = "../../modules/ansible-config"
  env_name          = "dev"
  bastion_public_ip = module.bastion.bastion_public_ip
  private_key_path  = "~/.ssh/id_rsa_aws_dev"
  region            = "ap-south-1"
}

locals {
  os_pools = {
    al2023 = {
      name   = "al2023"
      ami_id = "ami-00d2dbb426772b03a" # Amazon Linux 2023
    }
    ubuntu = {
      name   = "ubuntu"
      ami_id = "ami-01a00762f46d584a1" # Ubuntu 26.04 LTS
    }
  }
}

module "alb" {
  source            = "../../modules/alb"
  env_name          = "dev"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}

module "compute" {
  for_each                  = local.os_pools
  source                    = "../../modules/compute-asg"
  env_name                  = "dev"
  role                      = each.value.name
  vpc_id                    = module.vpc.vpc_id
  private_subnet_ids        = module.vpc.private_subnet_ids
  public_key_path           = "~/.ssh/id_rsa_aws_dev.pub"
  ami_id                    = each.value.ami_id
  alb_security_group_id     = module.alb.alb_security_group_id
  bastion_security_group_id = module.bastion.bastion_security_group_id
  target_group_arns = [
    each.key == "al2023" ? module.alb.al2023_target_group_arn : module.alb.ubuntu_target_group_arn
  ]
}

module "ansible_provisioner" {
  source      = "../../modules/ansible_provisioner"
  ansible_dir = "${path.module}/../../ansible"

  triggers = {
    ubuntu_lt_version = tostring(module.compute["ubuntu"].launch_template_latest_version)
    al2023_lt_version = tostring(module.compute["al2023"].launch_template_latest_version)
  }

  depends_on = [
    module.compute
  ]
}

module "secrets" {
  source         = "../../modules/secrets"
  environment    = "dev"
  iam_role_names = [for instance in module.compute : instance.iam_role_name]
}

module "monitoring" {
  source        = "../../modules/monitoring"
  environment   = "dev"
  alert_email   = "amukul864@gmail.com"
  cpu_threshold = 85
  asg_names     = [for instance in module.compute : instance.asg_name]

  depends_on = [
    module.compute
  ]
}

module "eks" {
  source = "../../modules/eks"

  environment        = "dev"
  cluster_name       = "dev-eks-cluster"
  eks_version        = "1.36"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  node_instance_type = "t3.medium"
  desired_node_count = 2

  depends_on = [
    module.vpc
  ]
}
