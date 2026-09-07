# File 1: Generate ../../ansible/ansible.cfg
resource "local_file" "ansible_cfg" {
  filename = "${path.module}/${var.ansible_dir_path}/ansible.cfg"

  content = <<EOF
[defaults]
inventory = ./inventory/aws_ec2.yml
host_key_checking = False
deprecation_warnings = False
private_key_file = ${var.private_key_path}
roles_path = ./roles

[inventory]
enable_plugins = amazon.aws.aws_ec2

[ssh_connection]
pipelining = True
ssh_args = -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -i ${var.private_key_path} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p ec2-user@${var.bastion_public_ip}"
EOF
}

# File 2: Generate ../../ansible/inventory/aws_ec2.yml
resource "local_file" "aws_ec2_yml" {
  filename = "${path.module}/${var.ansible_dir_path}/inventory/aws_ec2.yml"

  content = <<EOF
plugin: amazon.aws.aws_ec2

regions:
  - ${var.region}

filters:
  instance-state-name: running
  tag:Environment: ${var.env_name}

hostnames:
  - private-ip-address

keyed_groups:
  - key: ec2_tags.Role
    prefix: role
    separator: "_"

  - key: ec2_tags.Environment
    prefix: env
    separator: "_"

groups:
  app_servers: "ec2_tags.Role is defined"

compose:
  ansible_user: "'ubuntu' if ec2_tags.Role == 'ubuntu' else 'ec2-user'"
EOF
}
