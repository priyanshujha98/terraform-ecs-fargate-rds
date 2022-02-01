data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

resource "aws_network_interface" "bastion_network_interface" {
  subnet_id = aws_subnet.public[element(keys(aws_subnet.public), 0)].id

  tags = {
    Name = "primary_network_interface"
  }

}

resource "aws_key_pair" "bastion_host_key" {
  key_name   = "${var.infra_env}_bastion_key"
  public_key = var.bastion_public_RSA_key
}

resource "aws_instance" "bastion_host" {
  ami                         = data.aws_ami.amazon-linux-2.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.db_public[element(keys(aws_subnet.db_public), 0)].id
  vpc_security_group_ids      = [aws_security_group.bastion_host_security_group.id]
  key_name                    = aws_key_pair.bastion_host_key.id
  associate_public_ip_address = true

  tags = {
    "Name" = "${var.infra_env}-bastion-host"
  }
}
