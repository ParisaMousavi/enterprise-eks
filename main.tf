module "name" {
  source           = "github.com/ParisaMousavi/aws-naming?ref=main"
  prefix           = var.prefix
  name             = var.name
  environment      = var.environment
  region_shortname = var.region_shortname
}

module "eks" {
  source                 = "github.com/ParisaMousavi/aws-eks?ref=main"
  name                   = module.name.eks_name
  eks_version            = "1.23"
  endpoint_public_access = true
  subnet_ids             = [data.terraform_remote_state.network.outputs.network.public_subnet_ids["eks_1"], data.terraform_remote_state.network.outputs.network.public_subnet_ids["eks_2"]]
  additional_tags = {
    CostCenter = var.costcenter
    By         = "parisamoosavinezhad@hotmail.com"
    Name       = module.name.eks_name
  }
}
