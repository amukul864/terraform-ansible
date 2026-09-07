resource "null_resource" "ansible_trigger" {
  triggers = var.triggers

  # 1. Wait for instances to pass health checks
  provisioner "local-exec" {
    command     = "bash ${path.module}/../../scripts/wait_for_instances.sh"
    interpreter = ["/bin/bash", "-c"]

    environment = {
      AWS_REGION = var.aws_region
      ENV_TAG    = var.environment
    }
  }

  # 2. Run Ansible playbook
  provisioner "local-exec" {
    command     = "bash ${path.module}/../../scripts/run_ansible.sh"
    interpreter = ["/bin/bash", "-c"]

    environment = {
      AWS_REGION  = var.aws_region
      ENV_TAG     = var.environment
      ANSIBLE_DIR = var.ansible_dir
    }
  }
}
