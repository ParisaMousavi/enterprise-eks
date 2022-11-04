
# resource "azapi_resource" "flux" {
#   type = "Microsoft.KubernetesConfiguration/fluxConfigurations@2022-03-01"
#   name = "string"
#   parent_id = "string"
#   body = jsonencode({
#     properties = {
#       bucket = {
#         accessKey = "string"
#         bucketName = "string"
#         insecure = bool
#         localAuthRef = "string"
#         syncIntervalInSeconds = int
#         timeoutInSeconds = int
#         url = "string"
#       }
#       configurationProtectedSettings = {}
#       gitRepository = {
#         httpsCACert = "string"
#         httpsUser = "string"
#         localAuthRef = "string"
#         repositoryRef = {
#           branch = "string"
#           commit = "string"
#           semver = "string"
#           tag = "string"
#         }
#         sshKnownHosts = "string"
#         syncIntervalInSeconds = int
#         timeoutInSeconds = int
#         url = "string"
#       }
#       kustomizations = {}
#       namespace = "string"
#       scope = "string"
#       sourceKind = "string"
#       suspend = bool
#     }
#   })
# }