
resource "aws_vpc_peering_connection" "server_database_vpc_peering" {
  peer_owner_id = var.peer_owner_id
  peer_vpc_id   = aws_vpc.demo_database.id
  vpc_id        = aws_vpc.demo_admin.id
  auto_accept   = false
  peer_region   = var.peer_region

  tags = {
    Name = "VPC Peering between server and database"
    Infra = var.infra_env
  }

}