
module "vpc" {
  source          = "../../modules/vpc"
  vpc_cidr        = var.vpc_cidr
  public_cidrs    =  var.public_cidrs
  private_cidrs   = var.private_cidrs
  region          =  var.region
}

module "sg" {
  source = "../../modules/security_groups"
  vpc_id = module.vpc.vpc_id
  app_port = var.app_port
}

module "ec2" {
  source        = "../../modules/ec2"
  project       =  var.project
  ec2_sg_id     = module.sg.ec2_sg_id
  instance_type = var.instance_type
  ami_id = var.ami_id
}

module "alb" {
  source            = "../../modules/alb"
  project           = var.project
  app_port          = var.app_port
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.public_subnet_ids
  alb_sg_id         = module.sg.alb_sg_id
}

module "asg" {
  source            = "../../modules/asg"
  project           = var.project 
  launch_template_id= module.ec2.launch_template_id
  private_subnet_ids= module.vpc.private_subnet_ids
  target_group_arn  = module.alb.target_group_arn
  min_size          = var.min_size
  desired_capacity  = var.desired_capacity
  max_size          = var.max_size
  template_version  = module.ec2.launch_template_version
}

module "monitoring" {
  source     = "../../modules/monitoring"
  project    = var.project
  asg_name   = module.asg.asg_name
  alert_email= var.alert_email
}
