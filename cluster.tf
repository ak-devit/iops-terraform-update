#Cluster

resource "aws_ecs_cluster" "terraform_cluster" {
  name = var.aws_ecs_cluster
}


#Docker image resource


resource "docker_image" "wordpress_image" {
  name = var.docker_image
}



#Service aws_ecs_service

resource "aws_ecs_service" "terraform_service" {
  name                = var.aws_ecs_service
  cluster             = aws_ecs_cluster.terraform_cluster.id
  task_definition     = aws_ecs_task_definition.iops_terraform_td.arn
  desired_count       = 1
  scheduling_strategy = var.scheduling_strategy

  load_balancer {
    target_group_arn = aws_lb_target_group.iops_terraform_tg.arn
    container_name   = var.load_balancer
    container_port   = 80
  }
  deployment_controller {
    type = var.deployment_controller
  }

  #To prevent a race condition during service deletion, make sure to set 
  #depends_on to the related aws_iam_role_policy; otherwise, the policy 
  #may be destroyed too soon and the ECS service will then get stuck in 
  #the DRAINING state
  # depends_on = [ aws_iam_role_policy ..]
}

# resource "aws_ecs_service" "my_service" {
#   name            = "my_service"
#   cluster         = "${aws_ecs_cluster.my_cluster.id}"
#   task_definition = "${aws_ecs_task_definition.my_tf.arn}"
#   desired_count   = 1
#   iam_role        = "${aws_iam_role.ecs-service-role.id}"
# }





#Task definition
#Revision of an ECS task definition to be used in aws_ecs_service

resource "aws_ecs_task_definition" "iops_terraform_td" {
  #A unique name for your task definition.
  family       = "iops_terraform_td"
  network_mode = "bridge"
  container_definitions = jsonencode([
    {
      name      = "terraform-container"
      image     = docker_image.wordpress_image.name
      cpu       = 0 #/ 1
      memory    = 512
      essential = true
      portMappings = [
        {
          name          = "terraform-container-80-tcp"
          containerPort = 80,
          hostPort      = 80,
          protocol      = "tcp"
        }
        # ,
        # {
        #   name          = "terraform-container-443-tcp"
        #   containerPort = 443,
        #   hostPort      = 443,
        #   protocol      = "tcp"
        # },
      ]
    }
  ])
  #ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume.
  #execution_role_arn = aws_iam_role.ecs_agent.arn
  # or task_role_arn

  #Set of launch types required by the task. The valid values are EC2 and FARGATE.
  requires_compatibilities = var.requires_compatibilities
  

  # volume {
  #   name      = "service-storage"
  #   host_path = "/ecs/service-storage"
  # }

}







#Capasity provider 

resource "aws_ecs_cluster_capacity_providers" "terrafform_esc_cps" {
  cluster_name = aws_ecs_cluster.terraform_cluster.name #cluster name

  capacity_providers = [aws_ecs_capacity_provider.terrafform_esc_cp.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.terrafform_esc_cp.name
  }
}

resource "aws_ecs_capacity_provider" "terrafform_esc_cp" {
  name = var.aws_ecs_capacity_provider
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.iops_terraform_ag.arn
  }
}



#Autoscaling group + launch configuration

resource "aws_autoscaling_group" "iops_terraform_ag" {
  name = var.aws_autoscaling_group

  desired_capacity = 1
  max_size         = 1
  min_size         = 1

  #(Optional) List of subnet IDs to launch resources in.
  # Subnets automatically determine which avail. zones the group will reside.
  vpc_zone_identifier = [aws_subnet.iops-PublicSubnet-A.id, aws_subnet.iops-PublicSubnet-B.id]

  #min sec to keep new instance before terminate
  health_check_grace_period = 300
  health_check_type         = "EC2"

  target_group_arns    = [aws_lb_target_group.iops_terraform_tg.arn, aws_lb_target_group.iops_terraform_tg_ssh.arn]
  launch_configuration = aws_launch_configuration.terraform_ecs_lc.name

  depends_on = [
    aws_launch_configuration.terraform_ecs_lc
  ]

  # tag {
  #         key                 = "AmazonECSManaged" 
  #         propagate_at_launch = true  
  #       }
    
}
#Find Latest AMI id of:
#    - Amazon Linux 2
data "aws_ami" "latest_amazon_linux" {
  owners      = var.aws_ami
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*"]
  }
}



#Provides a resource to create a new launch configuration
#used for autoscaling groups
resource "aws_launch_configuration" "terraform_ecs_lc" {
  name = var.launch_configuration
  #- (Required) The EC2 image ID to launch.
  image_id             = data.aws_ami.latest_amazon_linux.id
  iam_instance_profile = aws_iam_instance_profile.ecs.name
  security_groups      = [aws_security_group.iops-terraform-public-sg.id]
  user_data            = var.user_data 
  instance_type        = var.instance_type
  ebs_optimized        = "false"
  key_name             = var.key_name

  

  
  # DEVICE STORADGE 
  #The root_block_device is the EBS volume provided by the AMI that will contain 
  #the operating system. If you don't configure it, AWS will use the default values from the AMI.

  #ebs_block_device supports the following:
  #device_name - (Required) The name of the device to mount.
  # ebs_block_device {
  #   device_name = "/dev/xvda"
  # }

  # root_block_device {
  #   device_name = "/dev/xvda"
  #   volume_type = "EBS"
  #   delete_on_termination = "true"
  #   volume_size = "30"
  #   encrypted = false
  # }
  # ebs_optimized = false
  # --------------------------------<
}



#Target group 

resource "aws_lb_target_group" "iops_terraform_tg" {
  name        = var.aws_lb_target
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.iops-terraformvpc.id
}

resource "aws_lb_target_group" "iops_terraform_tg_ssh" {
  name        = var.aws_lb_target_group
  port        = 22
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = aws_vpc.iops-terraformvpc.id
}

# resource "aws_lb_target_group" "iops_terraform_tg_443" {
#   name        = "iops-terraform-tg-ec2-ssh"
#   port        = 443
#   protocol    = "TCP"
#   target_type = "instance"
#   vpc_id      = aws_vpc.iops-terraformvpc.id
# }


resource "aws_lb" "iops_terraform_alb" {
  name               = var.aws_lb
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.iops-terraform-public-sg.id]
  subnets            = [aws_subnet.iops-PublicSubnet-A.id, aws_subnet.iops-PublicSubnet-B.id]

  enable_deletion_protection = false
  ip_address_type            = "ipv4"

}

resource "aws_lb_listener" "iops_terraform_lb_80_list" {
  load_balancer_arn = aws_lb.iops_terraform_alb.arn
  port              = "80"
  protocol          = "HTTP"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = var.certificate_arn

  default_action {
   
    type             = "forward"
    target_group_arn = aws_lb_target_group.iops_terraform_tg.arn
  }
}



#Create an IAM role for instances to use when they are launched

data "aws_iam_policy_document" "ecs" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs" {
  name               = var.aws_iam_role
  assume_role_policy = data.aws_iam_policy_document.ecs.json
}


resource "aws_iam_role_policy_attachment" "ecs" {
  role       = aws_iam_role.ecs.name
  policy_arn = var.aws_iam_role_policy
}

resource "aws_iam_instance_profile" "ecs" {
  name = var.aws_iam_instance_profile
  role = aws_iam_role.ecs.name
}


// Store Password in SSM Parameter Store
resource "aws_ssm_parameter" "db_password" {
  name        = var.aws_ssm
  description = "Password for RDS MySQL"
  type        = "SecureString"
  value       = var.aws_ssm_parameter
}

// Get Password from SSM Parameter Store
data "aws_ssm_parameter" "my_db_password" {
  name       = var.aws_ssm
  depends_on = [aws_ssm_parameter.db_password]
}
