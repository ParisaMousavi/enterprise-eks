
eksclustername=$1
resourcegroupnameforarc=$2

az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID

az k8s-configuration flux create \
--resource-group $resourcegroupnameforarc \
--cluster-name $eksclustername \
--name cluster-config \
--namespace cluster-config \
--cluster-type connectedClusters \
--scope cluster \
--kind git \
-u https://github.com/Azure/gitops-flux2-kustomize-helm-mt \
--branch main  \
--kustomization name=infra path=./infrastructure prune=true \
--kustomization name=apps path=./apps/staging prune=true dependsOn=\["infra"\] 