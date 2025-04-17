################
##### VPC  #####
################


resource "aws_vpc" "myvpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "MY-VPC"
  }
}

################
##### IGW  #####
################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "IGW"
  }
}

######################
## Public Subnet- 1 ##
#####################

resource "aws_subnet" "public-web-subnet-1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.public-web-subnet-1-cidr
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Web-Subnet-1"
  }
}

######################
## Public Subnet- 2 ##
#####################

resource "aws_subnet" "public-web-subnet-2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.public-web-subnet-2-cidr
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Web-Subnet-2"
  }
}

##########################
###    Route Table  ##
##########################

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public-Route-Table"
  }
}

##################################
###    Route table association  ##
#################################

resource "aws_route_table_association" "public-subnet-1-route-table-association" {
  subnet_id      = aws_subnet.public-web-subnet-1.id
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_route_table_association" "public-subnet-2-route-table-association" {
  subnet_id      = aws_subnet.public-web-subnet-2.id
  route_table_id = aws_route_table.public-route-table.id
}

##########################
###    Private Subnet-1  ##
##########################

resource "aws_subnet" "private-app-subnet-1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.private-app-subnet-1-cidr
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private-App-Subnet-1 | App Tier"
  }
}

##########################
###    Private Subnet-2  ##
##########################

resource "aws_subnet" "private-app-subnet-2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.private-app-subnet-2-cidr
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private-App-Subnet-2 | App Tier"
  }
}

##########################
###    Private Subnet-db 1 ##
##########################

resource "aws_subnet" "private-db-subnet-1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.private-db-subnet-1-cidr
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private-Db-Subnet-1 | Db Tier"
  }
}

##########################
###    Private Subnet-db 2  ##
##########################

resource "aws_subnet" "private-db-subnet-2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.private-db-subnet-2-cidr
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private-Db-Subnet-2 | Db Tier"
  }
}

#####################
#   NAT Gateway #
#####################

resource "aws_eip" "eip_nat" {
  domain = "vpc"

  tags = {
    Name = "eip-nat"
  }
}

resource "aws_nat_gateway" "nat_1" {
  allocation_id = aws_eip.eip_nat.id
  subnet_id     = aws_subnet.public-web-subnet-2.id

  tags = {
    "Name" = "nat1"
  }
}

##########################
###    Route Table      ##
##########################

resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1.id
  }

  tags = {
    Name = "Private-Route-Table"
  }
}

##############################
#  Route Assoc. for App tier #
##############################
resource "aws_route_table_association" "nat_route_1" {
  subnet_id      = aws_subnet.private-app-subnet-1.id
  route_table_id = aws_route_table.private-route-table.id
}

resource "aws_route_table_association" "nat_route_2" {
  subnet_id      = aws_subnet.private-app-subnet-2.id
  route_table_id = aws_route_table.private-route-table.id
}

##############################
#  Route Assoc. for DB tier #
##############################

resource "aws_route_table_association" "nat_route_db_1" {
  subnet_id      = aws_subnet.private-db-subnet-1.id
  route_table_id = aws_route_table.private-route-table.id
}


resource "aws_route_table_association" "nat_route_db_2" {
  subnet_id      = aws_subnet.private-db-subnet-2.id
  route_table_id = aws_route_table.private-route-table.id
}















