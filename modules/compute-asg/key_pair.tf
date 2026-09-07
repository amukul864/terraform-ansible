resource "aws_key_pair" "app" {
  key_name   = "${local.prefix_name}-key"
  public_key = file(pathexpand(var.public_key_path))

  tags = {
    Name = "${local.prefix_name}-key"
  }
}
