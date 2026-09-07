output "vpc" {
  description = "All Dev networking module outputs"
  value       = module.vpc
}

output "compute" {
  description = "All Dev compute module outputs"
  value       = module.compute
}

output "alb" {
  description = "All Dev alb module outputs"
  value       = module.alb
}

output "bastion" {
  description = "All Dev bastion module outputs"
  value       = module.bastion
}

output "secrets" {
  description = "All Dev secrets module outputs"
  value       = module.secrets
}

output "monitoring" {
  description = "All Dev monitoring module outputs"
  value       = module.monitoring
}

output "eks" {
  description = "All Dev eks module outputs"
  value       = module.eks
}
