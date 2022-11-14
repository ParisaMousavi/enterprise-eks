
eksclustername=$1
resourcegroupnameforarc=$2
region=$3

az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID

echo "Registering Azure Arc providers for azure policy"
echo "-------------------------------------------\n"
# Log in first with az login if you're not using Cloud Shell
# Provider register: Register the Azure Policy provider
az provider register --namespace 'Microsoft.PolicyInsights'

az provider show -n 'Microsoft.PolicyInsights' -o table

echo "Installing extension on cluster\n"
echo "-------------------------------------------\n"
az k8s-extension create --cluster-type connectedClusters \
--cluster-name $eksclustername \
--resource-group $resourcegroupnameforarc \
--extension-type 'Microsoft.PolicyInsights' \
--name 'azurepolicy'

echo "Verifying extension on cluster"
echo "-------------------------------------------\n"
az k8s-extension show --cluster-type connectedClusters \
--cluster-name $eksclustername \
--resource-group $resourcegroupnameforarc \
--name 'azurepolicy'


export KUBECONFIG=./config
echo "Getting AKS credentials (kubeconfig)"
echo "-------------------------------------------\n"
echo "aws eks update-kubeconfig --region $region --name $eksclustername"
aws eks update-kubeconfig --region $region --name $eksclustername

echo "azure-policy pod is installed in kube-system namespace"
echo "-------------------------------------------\n"
kubectl get pods -n kube-system

echo "gatekeeper pod is installed in gatekeeper-system namespace"
echo "-------------------------------------------\n"
kubectl get pods -n gatekeeper-system