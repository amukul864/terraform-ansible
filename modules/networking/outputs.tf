output "vpc_id" {
  value       = aws_vpc.this.id
  description = "The ID of the created VPC"
}

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "List of public subnet IDs"
}

output "private_subnet_ids" {
  value       = aws_subnet.private[*].id
  description = "List of private subnet IDs"
}

output "nat_gateway_ips" {
  value       = aws_eip.nat[*].public_ip
  description = "List of Elastic IPs associated with NAT Gateways"
}