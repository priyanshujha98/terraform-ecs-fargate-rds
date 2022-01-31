locals {
  common_tags = {

    owner = "demo"
    tags  = var.infra_env
  }

}


resource "aws_vpc" "demo_admin" {
  cidr_block       = var.vpc_server_cidr
  instance_tenancy = "default"

  tags = {
    Name:" ${var.infra_env}-demo VPC"
  }
  tags_all = local.common_tags
}

resource "aws_subnet" "public" {
  for_each   = var.public_subnet_numbers

  vpc_id     = aws_vpc.demo_admin.id

  cidr_block = cidrsubnet(aws_vpc.demo_admin.cidr_block, 4, each.value)

  availability_zone = each.key

  tags = {
      Subnet = "${each.key} - ${each.value}"
      Name = "${var.infra_env}-public - ${each.key}"
  }

  tags_all = local.common_tags

}

resource "aws_subnet" "private" {

    for_each = var.private_subnet_numbers

    vpc_id = aws_vpc.demo_admin.id
    
    cidr_block = cidrsubnet(aws_vpc.demo_admin.cidr_block, 4, each.value)

    availability_zone = each.key

    tags = {
      Subnet = "${each.key} - ${each.value}"
      Name = "${var.infra_env}-private - ${each.key}"
    }

    tags_all = local.common_tags
    
}

resource "aws_internet_gateway" "main_gateway" {
    vpc_id = aws_vpc.demo_admin.id

    tags = {
        Name = "${var.infra_env}-main_gateway"
    }
    tags_all = local.common_tags
  
}

resource "aws_eip" "elastic_ip_nat" {
  depends_on = [
    aws_internet_gateway.main_gateway
  ]
  vpc = true

}


resource "aws_nat_gateway" "main_nat_gateway" {
    
    depends_on = [
      aws_subnet.private
    ]


    allocation_id = aws_eip.elastic_ip_nat.id


    subnet_id = aws_subnet.public[element(keys(aws_subnet.public),0)].id

    tags = {
        Name: "${var.infra_env}-Nat gateway"
    }
    
    tags_all = local.common_tags
}

resource "aws_route_table" "public_route_table" {

    vpc_id  = aws_vpc.demo_admin.id

    route{
        cidr_block =  "0.0.0.0/0"

        gateway_id = aws_internet_gateway.main_gateway.id
    }
    
    tags = {
        Name = "${var.infra_env}-Public route table"
    }

    tags_all = local.common_tags
}

resource "aws_route_table" "private_route_table" {

    vpc_id  = aws_vpc.demo_admin.id

    

    route{  
        cidr_block = "0.0.0.0/0"

        gateway_id = aws_nat_gateway.main_nat_gateway.id
        
    }

    route{
      cidr_block = aws_vpc.demo_database.cidr_block
      vpc_peering_connection_id = aws_vpc_peering_connection.server_database_vpc_peering.id
    }
    
    tags = {
        Name = "${var.infra_env}-Private route table"
    }

    tags_all = local.common_tags
}

resource "aws_route_table_association" "public_subnet_associaltion" {

    route_table_id = aws_route_table.public_route_table.id

    for_each = aws_subnet.public

    subnet_id = aws_subnet.public[each.key].id

}

resource "aws_route_table_association" "private_subnet_associaltion" {

    

    route_table_id = aws_route_table.private_route_table.id
    
    for_each = aws_subnet.private

    subnet_id = aws_subnet.private[each.key].id


  
}