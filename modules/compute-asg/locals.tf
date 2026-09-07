locals {
  user_data_script = <<-EOF
    #!/bin/bash
    set -e

    # Disable interactive prompts
    export DEBIAN_FRONTEND=noninteractive

    # --- OS Detection & Package Installation ---
    if command -v dnf &> /dev/null; then
      dnf update -y
      dnf install -y python3 amazon-ssm-agent nginx
      systemctl enable --now amazon-ssm-agent
    elif command -v apt-get &> /dev/null; then
      # Wait for apt locks to clear on Ubuntu boot
      while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do sleep 2; done
      
      apt-get update -y
      apt-get install -y python3 python3-pip snapd nginx
      snap install amazon-ssm-agent --classic || true
      systemctl enable --now snap.amazon-ssm-agent.amazon-ssm-agent.service || true

      # Ubuntu ships with ufw enabled by default, which blocks SSH at the OS level
      # even when the AWS security group already allows it. SG restricts SSH source
      # to the bastion SG only, so disabling ufw here doesn't weaken access control —
      # it just removes a redundant, misconfigured second firewall layer.
      ufw disable || true
    fi

    # --- Web Root Setup ---
    WEB_DIR="/var/www/html"
    mkdir -p "$${WEB_DIR}"

    # Setup index page
    echo "<h1>Host OS: $(uname -s -r -m) | Pool: ${local.prefix_name}</h1>" > "$${WEB_DIR}/index.html"

    # Setup /health file directly (prevents 301 redirect)
    echo "OK" > "$${WEB_DIR}/health"

    # Fallback for AL2023 path
    if [ -d "/usr/share/nginx/html" ]; then
      cp "$${WEB_DIR}/index.html" /usr/share/nginx/html/index.html
      cp "$${WEB_DIR}/health" /usr/share/nginx/html/health 2>/dev/null || true
    fi

    systemctl enable nginx
    systemctl restart nginx
  EOF
}

locals {
  instance_count_map = {
    dev     = 1
    staging = 2
    prod    = 4
  }

  instance_type_map = {
    dev     = "t3.micro"
    staging = "t3.small"
    prod    = "t3.medium"
  }

  min_size_map = {
    dev     = 1
    staging = 1
    prod    = 2
  }

  max_size_map = {
    dev     = 3
    staging = 4
    prod    = 8
  }

  desired_capacity = var.desired_capacity != null ? var.desired_capacity : lookup(local.instance_count_map, var.env_name, 2)
  instance_type    = var.instance_type != null ? var.instance_type : lookup(local.instance_type_map, var.env_name, "t3.micro")
  min_size         = var.min_size != null ? var.min_size : lookup(local.min_size_map, var.env_name, 1)
  max_size         = var.max_size != null ? var.max_size : lookup(local.max_size_map, var.env_name, 3)

  prefix_name = "${var.env_name}-${var.role}"
}
