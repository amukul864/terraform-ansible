resource "aws_key_pair" "bastion" {
  key_name   = "${var.env_name}-bastion-key"
  public_key = file(pathexpand(var.public_key_path))

  tags = {
    Name        = "${var.env_name}-bastion-key"
    Environment = var.env_name
  }
}

resource "aws_security_group" "bastion" {
  name        = "${var.env_name}-bastion-sg"
  description = "Allow inbound SSH traffic to Bastion host"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.env_name}-bastion-sg"
    Environment = var.env_name
  }
}

resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.bastion.key_name
  vpc_security_group_ids      = [aws_security_group.bastion.id]

  tags = {
    Name        = "${var.env_name}-bastion"
    Environment = var.env_name
  }
}
