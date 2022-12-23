

#Creating VPC - iops-terraformvpc only local terraform name

resource "aws_vpc" "iops-terraformvpc" {
  cidr_block = var.aws_vpc_cidr 

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
  
  map_public_ip_on_launch = true

  tags = {
    Name = var.PublicSubnet-A_tags
  }
}

resource "aws_subnet" "iops-PublicSubnet-B" {
  vpc_id            = aws_vpc.iops-terraformvpc.id
  cidr_block        = var.PublicSubnet-B_cidr
  availability_zone = var.availability_zone_b
  
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

resource "aws_route_table" "iops_terraform_rtb_pub" {
  vpc_id = aws_vpc.iops-terraformvpc.id

  #igw
  route {
    cidr_block = var.aws_route_table_cidr
    gateway_id = aws_internet_gateway.iops-terraform-ig.id
  }

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


#Route table association

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




