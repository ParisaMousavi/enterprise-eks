eksclustername=$1
resourcegroupnameforarc=$2
region=$3
# Arc Data Service Extension Name
adsExtensionName=$4
# Custom Location name is used for custom-location's and data-extension's namespace.
customLocationName=$5

echo "--------------------------------------"
echo "eksclustername="$eksclustername
echo "resourcegroupnameforarc="$resourcegroupnameforarc
echo "region="$region
echo "adsExtensionName="$adsExtensionName
echo "customLocationName="$customLocationName
echo "--------------------------------------"

aws eks update-kubeconfig --region $region --name $eksclustername

az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID

# reference link : https://learn.microsoft.com/en-us/azure/azure-arc/data/plan-azure-arc-data-services
echo "Register Microsoft.AzureArcData provider"
echo "--------------------------------------\n"
az provider register --namespace Microsoft.AzureArcData

echo "Monitor registration Microsoft.AzureArcData provider"
echo "--------------------------------------"
az provider show -n Microsoft.AzureArcData -o table

echo "Checking if you have up-to-date Azure Arc AZ CLI 'arcdata' extension..."
echo "--------------------------------------"
az extension show --name "arcdata" &> extension_output
if cat extension_output | grep -q "not installed"; then
az extension add --name "arcdata"
rm extension_output
else
az extension update --name "arcdata"
rm extension_output
fi
echo ""

# get the available profiles
az arcdata dc config list

kubectl cluster-info

# reference link for parameters : https://learn.microsoft.com/en-us/cli/azure/arcdata/dc?view=azure-cli-latest#az-arcdata-dc-create
echo "Create Arc Data Contoller Resource in direct connectivity mode"
echo "--------------------------------------"
deploymentProfile="azure-arc-eks"
az arcdata dc create --name ${adsExtensionName} \
    --subscription ${ARM_SUBSCRIPTION_ID} -g ${resourcegroupnameforarc} \
    --custom-location ${customLocationName} --cluster-name ${eksclustername} \
    --connectivity-mode direct --profile-name ${deploymentProfile} \
    --location westeurope --infrastructure aws --k8s-namespace ${customLocationName} \
    --storage-class gp2 --auto-upload-logs false --auto-upload-metrics false

