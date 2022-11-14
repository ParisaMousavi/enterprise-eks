module "rg_name_for_arc" {
  source             = "github.com/ParisaMousavi/az-naming//rg?ref=2022.10.07"
  prefix             = var.prefix
  name               = "for-arc"
  stage              = var.environment
  location_shortname = var.az_location_shortname
}

module "resourcegroup_for_arc" {
  # https://{PAT}@dev.azure.com/{organization}/{project}/_git/{repo-name}
  source   = "github.com/ParisaMousavi/az-resourcegroup?ref=2022.10.07"
  count    = var.connect_to_arc == false ? 0 : 1
  location = var.az_location
  name     = module.rg_name_for_arc.result
  tags = {
    CostCenter = "ABC000CBA"
    By         = "parisamoosavinezhad@hotmail.com"
  }
}

resource "null_resource" "arc-connection" {
  depends_on = [
    module.eks,
    null_resource.get_eks_credentials,
    module.eks_node
  ]
  count = var.connect_to_arc == false ? 0 : 1
  triggers = {
    always_run = timestamp()
    hash       = sha256(file("${path.module}/arc-connection/bash.sh"))
  }
  // The order of input values are important for bash
  provisioner "local-exec" {
    command     = "chmod +x ${path.module}/arc-connection/bash.sh ;${path.module}/arc-connection/bash.sh ${module.eks.name} ${var.az_location} ${var.region} ${module.resourcegroup_for_arc[0].name}"
    interpreter = ["bash", "-c"]
  }
}

resource "azurerm_role_assignment" "thre" {
  depends_on = [
    null_resource.arc-connection
  ]
  count                = var.connect_to_arc == false ? 0 : 1
  principal_id         = data.azuread_group.aks_cluster_admin.object_id
  role_definition_name = "Azure Arc Kubernetes Cluster Admin"
  scope                = "/subscriptions/${var.az_subscription_id}/resourceGroups/${module.resourcegroup_for_arc[0].name}/providers/Microsoft.Kubernetes/connectedClusters/${module.eks.name}"
}

resource "azurerm_role_assignment" "four" {
  depends_on = [
    null_resource.arc-connection
  ]
  count                = var.connect_to_arc == false ? 0 : 1
  principal_id         = data.azuread_group.aks_cluster_admin.object_id
  role_definition_name = "Kubernetes Cluster - Azure Arc Onboarding"
  scope                = "/subscriptions/${var.az_subscription_id}/resourceGroups/${module.resourcegroup_for_arc[0].name}/providers/Microsoft.Kubernetes/connectedClusters/${module.eks.name}"
}

resource "azurerm_role_assignment" "five" {
  depends_on = [
    null_resource.arc-connection
  ]
  count                = var.connect_to_arc == false ? 0 : 1
  principal_id         = data.azuread_group.aks_cluster_admin.object_id
  role_definition_name = "Microsoft.Kubernetes connected cluster role"
  scope                = "/subscriptions/${var.az_subscription_id}/resourceGroups/${module.resourcegroup_for_arc[0].name}/providers/Microsoft.Kubernetes/connectedClusters/${module.eks.name}"
}

resource "azurerm_role_assignment" "six" {
  depends_on = [
    null_resource.arc-connection
  ]
  count                = var.connect_to_arc == false ? 0 : 1
  principal_id         = data.azuread_group.aks_cluster_admin.object_id
  role_definition_name = "Azure Arc Kubernetes Admin"
  scope                = "/subscriptions/${var.az_subscription_id}/resourceGroups/${module.resourcegroup_for_arc[0].name}/providers/Microsoft.Kubernetes/connectedClusters/${module.eks.name}"
}

resource "azurerm_role_assignment" "seven" {
  depends_on = [
    null_resource.arc-connection
  ]
  count                = var.connect_to_arc == false ? 0 : 1
  principal_id         = data.azuread_group.aks_cluster_admin.object_id
  role_definition_name = "Azure Arc Enabled Kubernetes Cluster User Role"
  scope                = "/subscriptions/${var.az_subscription_id}/resourceGroups/${module.resourcegroup_for_arc[0].name}/providers/Microsoft.Kubernetes/connectedClusters/${module.eks.name}"
}


resource "null_resource" "arc-extension-flux" {
  depends_on = [
    module.eks,
    null_resource.get_eks_credentials,
    module.eks_node,
    null_resource.arc-connection,
    azurerm_role_assignment.seven
  ]
  count = var.install_arc_flux == false ? 0 : 1
  triggers = {
    always_run = timestamp()
    hash       = sha256(file("${path.module}/arc-extension-flux/bash.sh"))
  }
  // The order of input values are important for bash
  provisioner "local-exec" {
    command     = "chmod +x ${path.module}/arc-extension-flux/bash.sh ;${path.module}/arc-extension-flux/bash.sh ${module.eks.name} ${module.resourcegroup_for_arc[0].name}"
    interpreter = ["bash", "-c"]
  }
}


resource "null_resource" "arc-extension-monitor" {
  depends_on = [
    module.eks,
    null_resource.get_eks_credentials,
    module.eks_node,
    null_resource.arc-connection,
    azurerm_role_assignment.seven
  ]
  count = var.install_arc_monitor == false ? 0 : 1
  triggers = {
    always_run = timestamp()
    hash       = sha256(file("${path.module}/arc-extension-monitoring/bash.sh"))
  }
  // The order of input values are important for bash
  provisioner "local-exec" {
    command     = "chmod +x ${path.module}/arc-extension-monitoring/bash.sh ;${path.module}/arc-extension-monitoring/bash.sh ${module.eks.name} ${module.resourcegroup_for_arc[0].name}"
    interpreter = ["bash", "-c"]
  }
}

resource "null_resource" "arc-extension-policy" {
  depends_on = [
    module.eks,
    null_resource.get_eks_credentials,
    module.eks_node,
    null_resource.arc-connection,
    azurerm_role_assignment.seven
  ]
  count = var.install_arc_policy == false ? 0 : 1
  triggers = {
    always_run = timestamp()
    hash       = sha256(file("${path.module}/arc-extension-policy/bash.sh"))
  }
  // The order of input values are important for bash
  provisioner "local-exec" {
    command     = "chmod +x ${path.module}/arc-extension-policy/bash.sh ;${path.module}/arc-extension-policy/bash.sh ${module.eks.name} ${module.resourcegroup_for_arc[0].name} ${var.region}"
    interpreter = ["bash", "-c"]
  }
}

module "arc_custom_location" {
  source           = "github.com/ParisaMousavi/aws-naming?ref=main"
  prefix           = var.prefix
  name             = var.name
  environment      = var.environment
  region_shortname = var.region_shortname
  purpose          = "cloc"
}

module "arc_dc_extension" {
  source           = "github.com/ParisaMousavi/aws-naming?ref=main"
  prefix           = var.prefix
  name             = var.name
  environment      = var.environment
  region_shortname = var.region_shortname
  purpose          = "dcext"
}

# arc_custom_location arc_dc_extension
resource "null_resource" "arc-extension-custome-location" {
  depends_on = [
    module.eks,
    null_resource.get_eks_credentials,
    module.eks_node,
    null_resource.arc-connection,
    azurerm_role_assignment.seven
  ]
  count = var.install_arc_custom_location == false ? 0 : 1
  triggers = {
    always_run = timestamp()
    hash       = sha256(file("${path.module}/arc-extension-location/bash.sh"))
  }
  // The order of input values are important for bash
  provisioner "local-exec" {
    command     = "chmod +x ${path.module}/arc-extension-location/bash.sh ;${path.module}/arc-extension-location/bash.sh ${module.eks.name} ${module.resourcegroup_for_arc[0].name} ${var.region} ${module.arc_dc_extension.arc_dc_extension} ${module.arc_custom_location.arc_custom_location}"
    interpreter = ["bash", "-c"]
  }
}
