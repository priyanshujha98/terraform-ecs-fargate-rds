locals {
  infraInfo = {
    Infra = "Database Infra"
    
  }

}


resource "aws_vpc" "demo_database" {
  cidr_block       = var.vpc_database_cidr
  instance_tenancy = "default"

  tags = {
    Name:" ${var.infra_env}-demo Database VPC"
  }
  tags_all = local.infraInfo
}

resource "aws_subnet" "db_public" {
  for_each   = var.public_subnet_numbers

  vpc_id     = aws_vpc.demo_database.id

  cidr_block = cidrsubnet(aws_vpc.demo_database.cidr_block, 4, each.value)

  availability_zone = each.key

  tags = {
      Subnet = "${each.key} - ${each.value}"
      Name = "${var.infra_env}-db-public - ${each.key}"
  }

  tags_all = local.infraInfo

}

resource "aws_subnet" "db_private" {

    for_each = var.private_subnet_numbers

    vpc_id = aws_vpc.demo_database.id
    
    cidr_block = cidrsubnet(aws_vpc.demo_database.cidr_block, 4, each.value)

    availability_zone = each.key

    tags = {
      Subnet = "${each.key} - ${each.value}"
      Name = "${var.infra_env}-db-private - ${each.key}"
    }

    tags_all = local.infraInfo
    
}

resource "aws_internet_gateway" "db_main_gateway" {
    vpc_id = aws_vpc.demo_database.id

    tags = {
        Name = "${var.infra_env}-main_db_gateway"
    }
    tags_all = local.infraInfo
  
}

resource "aws_eip" "db_elastic_ip_nat" {
  depends_on = [
    aws_internet_gateway.db_main_gateway
  ]
  vpc = true

}


resource "aws_nat_gateway" "db_main_nat_gateway" {
    
    depends_on = [
      aws_subnet.db_private
    ]


    allocation_id = aws_eip.db_elastic_ip_nat.id


    subnet_id = aws_subnet.db_public[element(keys(aws_subnet.db_public),0)].id

    tags = {
        Name: "${var.infra_env}-Nat gateway db"
    }
    
    tags_all = local.infraInfo
}

resource "aws_route_table" "db_public_route_table" {

    vpc_id  = aws_vpc.demo_database.id

    route{
        cidr_block =  "0.0.0.0/0"

        gateway_id = aws_internet_gateway.db_main_gateway.id
    }
    
    tags = {
        Name = "${var.infra_env}-Public db route table"
    }

    tags_all = local.infraInfo
}

resource "aws_route_table" "db_private_route_table" {

    vpc_id  = aws_vpc.demo_database.id

    

    route{  
        cidr_block = "0.0.0.0/0"

        gateway_id = aws_nat_gateway.db_main_nat_gateway.id
    }

    route{
      cidr_block = aws_vpc.demo_admin.cidr_block
      vpc_peering_connection_id = aws_vpc_peering_connection.server_database_vpc_peering.id
    }
    
    
    tags = {
        Name = "${var.infra_env}-Private db route table"
    }

    tags_all = local.infraInfo
}

resource "aws_route_table_association" "db_public_subnet_associaltion" {

    route_table_id = aws_route_table.db_public_route_table.id

    for_each = aws_subnet.db_public

    subnet_id = aws_subnet.db_public[each.key].id

}

resource "aws_route_table_association" "db_private_subnet_associaltion" {

    

    route_table_id = aws_route_table.db_private_route_table.id
    
    for_each = aws_subnet.db_private

    subnet_id = aws_subnet.db_private[each.key].id


  
}