# Infrastructure Platform

Terraform + Ansible based AWS infrastructure platform provisioning networking, compute (ASG + EKS), load balancing, secrets, monitoring, and automated configuration across multiple environments (dev, staging, prod).

## Repository Structure

```
.
├── environments/           # Per-environment Terraform root modules
│   ├── dev/
│   ├── staging/
│   └── prod/
├── modules/                 # Reusable Terraform modules
│   ├── networking/          # VPC, subnets, NAT, route tables
│   ├── compute-asg/         # Launch template, ASG, security groups, IAM
│   ├── alb/                 # Application Load Balancer + target groups
│   ├── bastion/              # Bastion host for SSH access
│   ├── eks/                  # EKS cluster, node group, LB controller, manifests
│   ├── secrets/               # KMS + SSM Parameter Store
│   ├── monitoring/            # CloudWatch alarms + SNS
│   ├── ansible-config/         # Generates ansible.cfg / dynamic inventory
│   └── ansible_provisioner/     # Triggers Ansible via local-exec after apply
├── ansible/
│   ├── inventory/            # Dynamic AWS EC2 inventory
│   ├── playbooks/             # site.yml — main playbook
│   └── roles/
│       ├── common/             # Base packages, timezone
│       ├── security_hardening/  # SSH hardening, fail2ban, auto-updates
│       └── app_server/           # Node.js app + Nginx reverse proxy
├── global/
│   └── backend-bootstrap/     # One-time S3 + DynamoDB backend setup
└── scripts/
    ├── wait_for_instances.sh   # Polls EC2 instance status checks
    └── run_ansible.sh           # Runs Ansible playbook against dynamic inventory
```

## Architecture Overview

- **Networking**: A VPC per environment with public and private subnets spread across Availability Zones, an Internet Gateway, and either a single shared NAT Gateway or one per AZ (`nat_strategy` variable).
- **Compute**: Auto Scaling Groups launch EC2 instances (Amazon Linux 2023 and Ubuntu pools) behind an Application Load Balancer, using per-environment instance type/count/sizing maps.
- **Kubernetes (EKS)**: A managed EKS cluster with a managed node group, OIDC provider for IRSA, the AWS Load Balancer Controller (via Helm), and a demo Nginx deployment exposed through a Network Load Balancer.
- **Secrets**: A per-environment KMS key encrypts an SSM `SecureString` parameter (e.g. DB connection string), with a least-privilege IAM policy scoped to that specific parameter and key.
- **Bastion**: A public bastion host is used for SSH access into private-subnet instances.
- **Monitoring**: CloudWatch alarms on ASG CPU utilization publish to an SNS topic with an email subscription.
- **Configuration Management**: Ansible, driven by a dynamic `aws_ec2` inventory plugin, applies `common`, `security_hardening`, and `app_server` roles to tagged EC2 instances. Instances are provisioned automatically post-`terraform apply` via a `null_resource` + `local-exec` provisioner chain (`wait_for_instances.sh` → `run_ansible.sh`).
- **State Management**: Terraform state is stored remotely in S3 (versioned, encrypted) with DynamoDB-based state locking, bootstrapped once via `global/backend-bootstrap`.

## Prerequisites

- Terraform >= 1.5.0
- AWS CLI, configured with credentials for the target account (`ap-south-1` region)
- Ansible (with the `amazon.aws` collection) for configuration management
- An SSH key pair generated locally for EC2 access (path referenced via `public_key_path` variables)

## Getting Started

### 1. Bootstrap the remote backend (one-time, per AWS account)

```bash
cd global/backend-bootstrap
terraform init
terraform apply
```

This creates the S3 bucket and DynamoDB table referenced by every environment's `backend.tf`.

### 2. Provision an environment

```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

This provisions the VPC, bastion host, ALB, ASG-based compute pools, EKS cluster, secrets, and monitoring for the environment.

### 3. Configure instances with Ansible

Instances are configured automatically via the `ansible_provisioner` module after `terraform apply`. This can also be run manually:

```bash
export ENV_TAG=dev
export AWS_REGION=ap-south-1
./scripts/wait_for_instances.sh
./scripts/run_ansible.sh
```

`run_ansible.sh` flushes the dynamic inventory cache and runs `ansible/playbooks/site.yml` (`common` → `security_hardening` → `app_server`) against instances tagged for that environment.

### 4. Access the EKS cluster

```bash
aws eks update-kubeconfig --name dev-eks-cluster --region ap-south-1
kubectl get nodes
```

The demo Nginx deployment and its LoadBalancer service manifests live under `modules/eks/manifests/`.

## Module Reference

| Module                        | Purpose                                                                                                 | Key Inputs                                                                            |
| ----------------------------- | ------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| `modules/networking`          | VPC, public/private subnets, IGW, NAT Gateway(s), route tables                                          | `cidr_block`, `az_count`, `nat_strategy`                                              |
| `modules/compute-asg`         | Launch template, ASG with target-tracking scaling, app security group, IAM instance role                | `env_name`, `role`, `ami_id`, `vpc_id`, `private_subnet_ids`, `alb_security_group_id` |
| `modules/alb`                 | ALB, security group, weighted target groups (AL2023 / Ubuntu), HTTP listener                            | `env_name`, `vpc_id`, `public_subnet_ids`                                             |
| `modules/bastion`             | Public bastion EC2 instance for SSH access                                                              | `env_name`, `vpc_id`, `public_subnet_id`                                              |
| `modules/eks`                 | EKS cluster, managed node group, OIDC provider, AWS Load Balancer Controller (Helm), demo Nginx service | `environment`, `cluster_name`, `vpc_id`, `private_subnet_ids`, `node_instance_type`   |
| `modules/secrets`             | KMS key + SSM SecureString parameter with scoped read IAM policy                                        | `environment`, `iam_role_names`                                                       |
| `modules/monitoring`          | CloudWatch CPU alarms + SNS topic/subscription                                                          | `environment`, `asg_names`, `alert_email`, `cpu_threshold`                            |
| `modules/ansible-config`      | Generates `ansible.cfg` and dynamic inventory file for bastion-proxied SSH                              | `env_name`, `bastion_public_ip`, `region`                                             |
| `modules/ansible_provisioner` | Runs post-apply provisioning scripts via `local-exec`                                                   | `aws_region`, `environment`, `ansible_dir`                                            |

## Ansible Roles

- **`common`**: Sets system timezone, updates packages, installs base tooling (curl, unzip, git, htop, awscli). OS-aware (Amazon Linux vs Ubuntu).
- **`security_hardening`**: Hardens `sshd_config` (disables root login and password auth, enables pubkey auth), installs and configures `fail2ban`, and enables automatic OS security updates.
- **`app_server`**: Installs Node.js and Nginx, deploys a minimal Node app as a systemd service (`nodeapp`) reverse-proxied by Nginx, and fetches the environment's DB connection string from SSM Parameter Store into a local `.env` file.

## Secrets Handling

Sensitive values are never stored in plaintext in the repo:

- Application secrets live in SSM Parameter Store as `SecureString`, encrypted with a per-environment KMS key.
- IAM policies grant `ssm:GetParameter` and `kms:Decrypt` scoped to the specific parameter ARN and key ARN — not wildcarded.
- The `app_server` Ansible role fetches the secret at configuration time and writes it to `/etc/app/.env` with `0600` permissions; the fetch task uses `no_log: true` to avoid leaking the value into Ansible logs.

## Notes

- EKS Kubernetes version and node instance types are pinned explicitly in `modules/eks/variables.tf` rather than using `latest`.
- Each environment under `environments/<env>/` is a self-contained Terraform root module with its own `provider.tf`, `backend.tf`, `main.tf`, and `outputs.tf`.
