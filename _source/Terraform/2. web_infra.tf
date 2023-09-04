# VPC / Subnet / SG 등 리소스 별로 .tf 파일 구분해도 됨

# VPC 생성
resource "aws_vpc" "kjh-vpc-terr" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "kjh-terr-vpc"
  }
}

# Subnet 생성
resource "aws_subnet" "kjh-subnet-public-terr" {
  vpc_id            = aws_vpc.kjh-vpc-terr.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "kjh-terr-public"
  }
}

# SG 생성
resource "aws_security_group" "kjh-sg-terr" {
  name        = "kjh-sg-terr"
  description = "kjh-sg-terr"
  tags = {
    Name = "kjh-terr-sg"
  }
  vpc_id      = aws_vpc.kjh-vpc-terr.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# NIC 생성
resource "aws_network_interface" "kjh-nic-terr" {
  for_each        = var.kubernetes
  subnet_id       = aws_subnet.kjh-subnet-public-terr.id
  private_ips     = [each.value["ips"]]
  security_groups = [aws_security_group.kjh-sg-terr.id]
  tags            = each.value["tags"]
}

# IG 생성
resource "aws_internet_gateway" "kjh-igw" {
  vpc_id = aws_vpc.kjh-vpc-terr.id
  tags = {
    Name = "kjh-ig-test"
  }
}

# Route Table 생성
resource "aws_route_table" "kjh-route-table-terr" {
  vpc_id = aws_vpc.kjh-vpc-terr.id
  tags = {
    Name = "main-public-1"
  }
}

# Route 생성
resource "aws_route" "kjh-route-terr" {
  route_table_id         = aws_route_table.kjh-route-table-terr.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.kjh-igw.id
}

# Route 연결 생성
resource "aws_route_table_association" "kjh-route-table-asso-terr" {
  subnet_id      = aws_subnet.kjh-subnet-public-terr.id
  route_table_id = aws_route_table.kjh-route-table-terr.id
}
