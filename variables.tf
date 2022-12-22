variable "db_name" {
  default = "wordpressdb"
}

variable "db_username" {
  default = "admin"
}


// Store Password in SSM Parameter Store
variable "aws_ssm_parameter" {
  type = string
  default = "admin123456"
}

variable "aws_ssm" {
  type = string
  default = "/iops/mysql"
}



#Cluster
variable "aws_ecs_cluster" {
  type = string
  default = "terraform_cluster"
}

#Docker image resource
variable "docker_image" {
  type    = string
  default = "wordpress:latest"
}

#Service aws_ecs_service
variable "aws_ecs_service" {
  type    = string
  default = "terraform-service"
}

variable "load_balancer" {
  default = "terraform-container"
}

variable "scheduling_strategy" {
  default = "REPLICA"
}

variable "deployment_controller" {
  default = "ECS"
}

variable "requires_compatibilities" {
  default = ["EC2"]
}

variable "aws_iam_instance_profile" {
  default = "iops-terraform-ecs"
}

variable "aws_iam_role_policy" {
  default = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

variable "aws_iam_role" {
  default = "iops-terraform-ecs"
}

#variable "certificate_arn" {
 # default = "arn:aws:acm:eu-central-1:094203224225:certificate/49c02c7d-5ab7-4bcb-8b3e-8b4fe016d55b"
#}

#Target group
variable "aws_lb_target" {
  default = "iops-terraform-tg-ec2"
}

variable "aws_lb_target_group" {
  default = "iops-terraform-tg-ec2-ssh"
}

variable "aws_lb" {
  default = "iops-terraform-alb"
}

#launch configuration
variable "user_data" {
  default = "#!/bin/bash\necho ECS_CLUSTER=terraform_cluster >> /etc/ecs/ecs.config"
}

variable "instance_type" {
  default = "t2.micro"
}
variable "key_name" {
  default = "ubuntuserveraws2204"
}

variable "launch_configuration" {
  default = "terraform-ecs-lc"
}

#Find Latest AMI id of:
#    - Amazon Linux 2
variable "aws_ami" {
  default = ["591542846629"]
}

#Autoscaling group
variable "aws_autoscaling_group" {
  default = "iops-terraform-ag"
}

#Capasity provider

variable "aws_ecs_capacity_provider" {
  default = "terraform_cp"
}

#Task definition

#Creating VPC
variable "aws_vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "aws_vpc_tags" {
  default = "iops-terraformvpc"
}

#Subnets
variable "PublicSubnet-A_cidr" {
  default = "10.0.11.0/24"
}
variable "PublicSubnet-B_cidr" {
  default = "10.0.21.0/24"
}
variable "PrivateSubnet-A_cidr" {
  default = "10.0.12.0/24"
}
variable "PrivateSubnet-B_cidr" {
  default = "10.0.22.0/24"
}

variable "availability_zone_a" {
  default = "eu-central-1a"
}
variable "availability_zone_b" {
  default = "eu-central-1b"
}

variable "PublicSubnet-A_tags" {
  default = "iops-PublicSubnet-A"
}
variable "PublicSubnet-B_tags" {
  default = "iops-PublicSubnet-B"
}
variable "PrivateSubnet-A_tags" {
  default = "iops-PrivateSubnet-A"
}
variable "PrivateSubnet-B_tags" {
  default = "iops-PrivateSubnet-B"
}

#Internet gateway
variable "aws_internet_gateway" {
  default = "iops-terraform-ig"
}

#Route table to route trafic from our subnet to internet gateway
variable "aws_route_table_cidr" {
  default = "0.0.0.0/0"
}
variable "aws_route_table_tags" {
  default = "iops-terraform-rtb-pub"
}

variable "aws_route_table_tags_name" {
  default = "iops-terraform-rtb-private"
}


#security group


#Providers
variable "region" {
  default = "eu-central-1"
}

variable "shared_credentials_files" {
  default = ["/home/andreylviv/.aws/credentials"]
}

variable "profile" {
  default = "terraform"
}

variable "host" {
  default = "unix:///var/run/docker.sock"
}

#RDS instance resource.
variable "identifier" {
  default = "iops-terraform-db"
}

variable "instance_class" {
  default = "db.t2.micro"
}

variable "parameter_group_name" {
  default = "default.mysql8.0"
}

variable "aws_db_subnet_group" {
  default = "terr-db-subnet-group"
}

variable "tags2" {
  default = "terr-db-subnet-group"
}