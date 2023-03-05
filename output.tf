output "eks_name" {
  value = module.eks.name
}

output "eks_console_group_name" {
  value = module.eks_group_for_console.name
}

output "eks_console_group_arn" {
  value = module.eks_group_for_console.arn
}

output "eks_arc_resourcegroup_name" {
  value = var.connect_to_arc == true ? module.resourcegroup_for_arc[0].name : null
}
