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

# 1
# for consol permission
# The permissions are copy & paste from this link
# https://docs.aws.amazon.com/eks/latest/userguide/view-kubernetes-resources.html#view-kubernetes-resources-permissions
resource "aws_iam_policy" "eks_policy_for_console" {
  name = format("%s-eks-console", module.name.policy_name)
  path = "/"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "eks:ListFargateProfiles",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:ListUpdates",
          "eks:AccessKubernetesApi",
          "eks:ListAddons",
          "eks:DescribeCluster",
          "eks:DescribeAddonVersions",
          "eks:ListClusters",
          "eks:ListIdentityProviderConfigs",
          "iam:ListRoles"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "ssm:GetParameter",
        "Resource" : "arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:parameter/*"
      }
    ]
  })
}


#-------------------------------------------------------
# 2
# Create a group For Cluster permissions via aws portal
# https://docs.aws.amazon.com/eks/latest/userguide/view-kubernetes-resources.html#view-kubernetes-resources-permissions
#-------------------------------------------------------
module "eks_group_for_console" {
  depends_on = [
    aws_iam_policy.eks_policy_for_console
  ]
  source = "github.com/ParisaMousavi/aws-iam-group?ref=main"
  name   = format("%s-eks-console", module.name.group_name)
}

resource "aws_iam_group_policy_attachment" "eks_group_policy_for_console" {
  group      = module.eks_group_for_console.name
  policy_arn = aws_iam_policy.eks_policy_for_console.arn
}

resource "null_resource" "get_eks_credentials" {
  depends_on = [module.eks]
  triggers   = { always_run = timestamp() }
  // The order of input values are important for bash
  provisioner "local-exec" {
    command     = "chmod +x ${path.module}/get-credentials/bash.sh ;${path.module}/get-credentials/bash.sh"
    interpreter = ["bash", "-c"]
  }
}


module "eks_node" {
  source          = "github.com/ParisaMousavi/aws-eks-node?ref=main"
  node_group_name = format("%s-node-1", module.name.eks_name)
  cluster_name    = module.eks.name
  instance_types  = ["t3.medium"]
  disk_size       = 5
  subnet_ids      = [data.terraform_remote_state.network.outputs.network.public_subnet_ids["public_1"], data.terraform_remote_state.network.outputs.network.public_subnet_ids["public_2"]]
}
