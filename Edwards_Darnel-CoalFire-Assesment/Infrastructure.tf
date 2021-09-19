###Darnel Edwards assesment for Coalfire##

# company is looking to create a proof-of-concept environment in AWS. They want a simple VPC as
# outlined below. The company would also like to use Terraform to manage their infrastructure via code.
# Done   1 VPC – 10.1.0.0/16
# DONE 4 subnets (spread across two availability zones for high availability)
# DONE o Sub1 – 10.1.0.0/24 (should be accessible from internet)
# DONEo Sub2 – 10.1.1.0/24 (should be accessible from internet)
# DONEo Sub3 – 10.1.2.0/24 (should NOT be accessible from internet)
# DOENo Sub4 – 10.1.3.0/24 (should NOT be accessible from internet)
#  1 compute instance running RedHat in subnet sub2
# o 20 GB storage
# o t2.micro
#  1 ASG running RedHat in subnet sub4
# o 20 GB storage
# o Script the installation of apache on these instances
# o 2 minimum, 6 maximum hosts
# o t2.micro
#  1 alb that listens on port 80 and forwards traffic to the instance in sub4
#  Subnets should have security groups in place
#  1 S3 bucket with lifecycle policies
# o Images folder move to glacier after 90 days
# o Logs folder cleared after 90 days 

################ NETWORK_INFRASTRUCTURE_LAYER ##################
##                                                            ## 
##                                                            ##
################################################################


data "aws_availability_zones" "available" {
  state = "available"
}
###VPC#####################################
resource "aws_vpc" "CoalFire_VPC" {
  cidr_block           = var.VPC_CIDR
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Coalfire_VPC"
  }
}


###Public SN 1 ##############################
resource "aws_subnet" "PublicSubnet1" {
  cidr_block              = var.SN1
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.CoalFire_VPC.id
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "Sub1"
    Type = "Public"
    Zone = "AZ_A"
  }
}


##Public SN 2################################
resource "aws_subnet" "PublicSubnet2" {
  cidr_block              = var.SN2
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.CoalFire_VPC.id
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "Sub2"
    Type = "Public"
    Zone = "AZ_B"
  }
}


###Private SN1 #####################################
resource "aws_subnet" "PrivateSubnet1" {
  cidr_block              = var.PRI_SN_1
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.CoalFire_VPC.id
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "Sub3"
    Type = "Private"
    Zone = "AZ_A"
  }
}


###Private SN2 ########################################
resource "aws_subnet" "PrivateSubnet2" {
  cidr_block              = var.PRI_SN_2
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.CoalFire_VPC.id
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "Sub4"
    Type = "Public"
    Zone = "AZ_B"
  }
}


### PublicRT ###########################################
resource "aws_route_table" "PublicRT" {
  vpc_id     = aws_vpc.CoalFire_VPC.id
  depends_on = [aws_internet_gateway.Igw]

  tags = {
    Name = "Public Route Table"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Igw.id
  }
}

resource "aws_route_table_association" "Public_RT1_Association" {
  subnet_id      = aws_subnet.PublicSubnet1.id
  route_table_id = aws_route_table.PublicRT.id
}

resource "aws_route_table_association" "Public_RT2_Association" {
  subnet_id      = aws_subnet.PublicSubnet2.id
  route_table_id = aws_route_table.PublicRT.id
}

resource "aws_internet_gateway" "Igw" {
  vpc_id = aws_vpc.CoalFire_VPC.id
}

###Private RouteTable ##################################
resource "aws_route_table" "RouteTablePrivate1" {
  vpc_id = aws_vpc.CoalFire_VPC.id

  tags = {
    Name = "Private Route Table"
  }
}


resource "aws_route_table_association" "Private_RT_Association_1" {
  subnet_id      = aws_subnet.PrivateSubnet1.id
  route_table_id = aws_route_table.RouteTablePrivate1.id
}

resource "aws_route_table" "RouteTablePrivate2" {
  vpc_id = aws_vpc.CoalFire_VPC.id

  tags = {
    Name = "Private Route Table 2"
  }
}

resource "aws_route_table_association" "Private_RT_Association_2" {
  subnet_id      = aws_subnet.PrivateSubnet2.id
  route_table_id = aws_route_table.RouteTablePrivate2.id
}

##Security group for Single EC2########################
resource "aws_security_group" "RHEL_EC2" {
  name        = "RHEL_EC2"
  vpc_id      = aws_vpc.CoalFire_VPC.id
  description = "Allow inbound SSH"

  ingress {
    description      = "Alow_SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "RHEL_EC2"
  }
}

###Security group for ASG###############################
resource "aws_security_group" "Web-ASG-SG" {
  name        = "Web-ASG2"
  vpc_id      = aws_vpc.CoalFire_VPC.id
  description = "Allow inbound SSH"

  ingress {
    description      = "Allow http, https"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Web-ASG-SG"
  }
}
### I used 1 RT for public and 2 Route Table for private.Reasoning behind this 
### is to (1) illustrate that multiple Subnets can be tied to 1 Routetable (2) and  
### for the private Subnets I created 1 route table per subnet, since the subnets are 
### private they may be other routes that need to be introduced in the future
### creating a seperate route table makes managing the subnet easier as the routes grow 
### (however) this is subjective :-)  
 