
#=====================================================================
#Creating VPC - iops-terraformvpc only local terraform name
#=====================================================================

resource "aws_vpc" "iops-terraformvpc" {
  cidr_block = var.aws_vpc_cidr #65,536

  enable_dns_hostnames = true
  enable_dns_support   = true


  tags = {
    Name = var.aws_vpc_tags
  }
}


#Subnets (2 availability zone)
#Public 
resource "aws_subnet" "iops-PublicSubnet-A" {
  vpc_id            = aws_vpc.iops-terraformvpc.id
  cidr_block        = var.PublicSubnet-A_cidr #256
  availability_zone = var.availability_zone_a
  #- (Optional) Specify true to indicate that instances 
  #launched into the subnet should be assigned a public IP address.
  map_public_ip_on_launch = true

  tags = {
    Name = var.PublicSubnet-A_tags
  }
}

resource "aws_subnet" "iops-PublicSubnet-B" {
  vpc_id            = aws_vpc.iops-terraformvpc.id
  cidr_block        = var.PublicSubnet-B_cidr
  availability_zone = var.availability_zone_b
  #- (Optional) Specify true to indicate that instances 
  #launched into the subnet should be assigned a public IP address.
  map_public_ip_on_launch = true

  tags = {
    Name = var.PublicSubnet-B_tags
  }
}

#Private for RDS
resource "aws_subnet" "iops-PrivateSubnet-A" {
  vpc_id            = aws_vpc.iops-terraformvpc.id
  cidr_block        = var.PrivateSubnet-A_cidr #256
  availability_zone = var.availability_zone_a

  tags = {
    Name = var.PrivateSubnet-A_tags
  }
}

#Private for RDS
resource "aws_subnet" "iops-PrivateSubnet-B" {
  vpc_id            = aws_vpc.iops-terraformvpc.id
  cidr_block        = var.PrivateSubnet-B_cidr #256
  availability_zone = var.availability_zone_b

  tags = {
    Name = var.PrivateSubnet-B_tags
  }
}



#Internet gateway 
resource "aws_internet_gateway" "iops-terraform-ig" {
  vpc_id = aws_vpc.iops-terraformvpc.id
  tags = {
    Name = var.aws_internet_gateway
  }
}

#Route table to route trafic from our subnet to internet gateway
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
#The destination for the route is 0.0.0.0/0, which represents all IPv4 addresses. 
#The target is the internet gateway that's attached to VPC.
resource "aws_route_table" "iops_terraform_rtb_pub" {
  vpc_id = aws_vpc.iops-terraformvpc.id

  #igw
  route {
    cidr_block = var.aws_route_table_cidr
    gateway_id = aws_internet_gateway.iops-terraform-ig.id
  }

  #local target
  #The default route, mapping the VPC's CIDR block to "local", 
  #is created implicitly and cannot be specified.

  tags = {
    Name = var.aws_route_table_tags
  }
}

resource "aws_route_table" "iops_terraform_rtb_private" {
  vpc_id = aws_vpc.iops-terraformvpc.id

  tags = {
    Name = var.aws_route_table_tags_name
  }
}

#==============================================================
#Route table association
#Asociation b/w a route table and a subnet
#Provides a resource to create an association between a route 
#table and a subnet or a route table and an internet gateway or
# virtual private gateway.

#===============================================================
#public a
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.iops-PublicSubnet-A.id
  route_table_id = aws_route_table.iops_terraform_rtb_pub.id
}
#public b
resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.iops-PublicSubnet-B.id
  route_table_id = aws_route_table.iops_terraform_rtb_pub.id
}

#private a
resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.iops-PrivateSubnet-A.id
  route_table_id = aws_route_table.iops_terraform_rtb_private.id
}

#private b
resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.iops-PrivateSubnet-B.id
  route_table_id = aws_route_table.iops_terraform_rtb_private.id
}



# #aws_main_route_table_association
# resource "aws_default_route_table" "terr_public_assosiation" {
#   vpc_id         = aws_vpc.terr_vpc.id
#   default_route_table_id = aws_route_table.terr_rtb_public.id
# }

# #aws_main_route_table_association
# resource "aws_default_route_table" "terr_private_assosiation" {
#   vpc_id         = aws_vpc.terr_vpc.id
#   default_route_table_id = aws_route_table.terr_rtb_private.id  #route_table_id instead if aws_main_route_table_association is used
# }


