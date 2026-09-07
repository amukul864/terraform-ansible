#!/usr/bin/env bash
set -e

# Read environment variables passed from caller, fallback to defaults if unset
REGION="${AWS_REGION:-ap-south-1}"
ENV_TAG="${ENV_TAG:-dev}"

echo "==> Polling AWS for running instances with tag Environment=${ENV_TAG} in region ${REGION}..."

# Get Instance IDs for the environment
INSTANCE_IDS=$(aws ec2 describe-instances \
  --region "${REGION}" \
  --filters "Name=tag:Environment,Values=${ENV_TAG}" "Name=instance-state-name,Values=running" \
  --query "Reservations[*].Instances[*].InstanceId" \
  --output text)

if [ -z "$INSTANCE_IDS" ]; then
  echo "ERROR: No running instances found for Environment=${ENV_TAG}!"
  exit 1
fi

echo "Found instances: ${INSTANCE_IDS}"
echo "==> Waiting for EC2 instance status checks to pass..."

# Wait until instance status checks pass
aws ec2 wait instance-status-ok \
  --region "${REGION}" \
  --instance-ids ${INSTANCE_IDS}

echo "==> All instances are healthy and SSH-ready!"