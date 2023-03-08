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
    command     = "chmod +x ${path.module}/arc-extension-monitoring/bash.sh ;${path.module}/arc-extension-monitoring/bash.sh"
    interpreter = ["bash", "-c"]
    environment = {
      logAnalyticsWorkspaceResourceID = data.terraform_remote_state.monitoring.outputs.log_analytics_workspace_id
      eksclustername                  = module.eks.name
      resourcegroupnameforarc         = module.resourcegroup_for_arc[0].name
    }
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


# in kheili be dard nakhord ta bad roosh kar konam
# reference link : https://learn.microsoft.com/en-us/azure/templates/microsoft.extendedlocation/customlocations?pivots=deployment-language-terraform
# resource "azapi_resource" "arc_custom_location" {
#   type = "Microsoft.ExtendedLocation/customLocations@2021-08-31-preview"
#   name = module.arc_custom_location.arc_custom_location
#   location = var.location
#   parent_id = module.rg_name_for_arc.id
#   tags = {
#     CostCenter = "ABC000CBA"
#     By         = "parisamoosavinezhad@hotmail.com"
#   }
#   identity {
#     type =  "SystemAssigned"
#   }
#   body = jsonencode({
#     properties = {
#       clusterExtensionIds = [
#         "/subscriptions/e75710b2-d656-4ee7-bc64-d1b371656208/resourceGroups/tname-rg-for-arc-env-weu/providers/Microsoft.Kubernetes/connectedClusters/tname-eks-myproj-env-euc1/providers/Microsoft.KubernetesConfiguration/extensions/tname-dcext-myproj-env-euc1"
#       ]
#       displayName = module.arc_custom_location.arc_custom_location
#       hostResourceId = "/subscriptions/e75710b2-d656-4ee7-bc64-d1b371656208/resourceGroups/tname-rg-for-arc-env-weu/providers/Microsoft.Kubernetes/connectedClusters/tname-eks-myproj-env-euc1"
#       hostType = "Kubernetes"
#       namespace = "tname-cloc-myproj-env-euc1"
#     }
#   })
# }


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

data "azapi_resource" "arc_custom_location" {
  depends_on = [
    module.eks,
    null_resource.get_eks_credentials,
    module.eks_node,
    null_resource.arc-connection,
    azurerm_role_assignment.seven,
    null_resource.arc-extension-custome-location
  ]
  count     = var.install_arc_custom_location == false ? 0 : 1
  name      = module.arc_custom_location.arc_custom_location
  parent_id = module.resourcegroup_for_arc[0].id
  type      = "Microsoft.ExtendedLocation/customLocations@2021-08-31-preview"
}

# resource "azurerm_role_assignment" "custom_location_contributor" {
#   count                = var.install_arc_custom_location == false && length(data.azapi_resource.arc_custom_location) == 0 ? 0 : 1
#   principal_id         = data.azapi_resource.arc_custom_location[0].identity[0].principal_id
#   role_definition_name = "Contributor"
#   scope                = module.resourcegroup_for_arc[0].id
# }

# resource "null_resource" "arc-extension-data-controller" {
#   depends_on = [
#     module.eks,
#     null_resource.get_eks_credentials,
#     module.eks_node,
#     null_resource.arc-connection,
#     azurerm_role_assignment.seven,
#     null_resource.arc-extension-custome-location
#   ]
#   count = var.install_arc_data_controller == false ? 0 : 1
#   triggers = {
#     always_run = timestamp()
#     hash       = sha256(file("${path.module}/arc-extension-dc/bash.sh"))
#   }
#   // The order of input values are important for bash
#   provisioner "local-exec" {
#     command     = "chmod +x ${path.module}/arc-extension-dc/bash.sh ;${path.module}/arc-extension-dc/bash.sh ${module.eks.name} ${module.resourcegroup_for_arc[0].name} ${var.region} ${module.arc_dc_extension.arc_dc_extension} ${module.arc_custom_location.arc_custom_location}"
#     interpreter = ["bash", "-c"]
#   }
# }

