resource "aws_security_group" "load_balancer_security_group" {
    name = "${var.infra_env} loadbalancer security group"
    description = "Allow internet traffic"
    vpc_id = aws_vpc.demo_admin.id

    ingress {
        description = " Allow inbound port 443"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = " Allow inbound port 80"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress{
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.infra_env} loadbalancer security group"
        Infra = var.infra_env
    }
  
}

resource "aws_security_group" "demo_cluster_service_security_group" {

    name = "${var.infra_env} cluster security group"
    description = "Allow task created by service to reach loadbalancer"
    vpc_id = aws_vpc.demo_admin.id

    ingress {
        description = "Allow access to load balancer"
        from_port = 0
        to_port = 65535
        protocol = "tcp"
        security_groups = [aws_security_group.load_balancer_security_group.id]
    }

    egress{
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      "Name" = "${var.infra_env} cluster service security group"
      "Infra" = "${var.infra_env}"
    }
  
}

resource "aws_security_group" "bastion_host_security_group" {

    name = "${var.infra_env} bastion security group"
    description = "Allow connection to database"
    vpc_id = aws_vpc.demo_database.id

    ingress {
      cidr_blocks = ["0.0.0.0/0"]
      description = "Open for ssh tunneling"
      from_port = 22
      protocol = "tcp"
      to_port = 22
    }
    ingress{
      cidr_blocks = ["0.0.0.0/0"]
      description = "MySql Aurora connection port opening"
      from_port = 3306
      protocol = "tcp"
      to_port = 3306
    }

    egress{
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      "Name" = "${var.infra_env} bastion security group"
      "Infra" = "${var.infra_env}"
    }

}

resource "aws_security_group" "database_security_group" {
    name = "${var.infra_env} database security group"
    description = "Allow database connection to bastion host and peering connection"
    vpc_id = aws_vpc.demo_database.id

    ingress{
        description = "Open for bastion host connection"
        from_port = 3306
        protocol = "tcp"
        to_port = 3306
        security_groups = [aws_security_group.bastion_host_security_group.id]
    }
    ingress{
        description = "Open for peering connection"
        from_port = 3306
        protocol = "tcp"
        to_port = 3306
        cidr_blocks = [aws_vpc.demo_admin.cidr_block]
    }

    egress{
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      "Name" = "${var.infra_env} database security group"
      "Infra" = "${var.infra_env}"
    }
  
}