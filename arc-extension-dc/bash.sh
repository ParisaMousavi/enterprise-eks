eksclustername=$1
resourcegroupnameforarc=$2
region=$3

aws eks update-kubeconfig --region $region --name $eksclustername

az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID

echo "Checking if you have up-to-date Azure Arc AZ CLI 'connectedk8s' extension..."
echo "--------------------------------------\n"
az extension show --name "connectedk8s" &> extension_output
if cat extension_output | grep -q "not installed"; then
az extension add --name "connectedk8s"
rm extension_output
else
az extension update --name "connectedk8s"
rm extension_output
fi
echo ""

echo "Checking if you have up-to-date Azure Arc AZ CLI 'k8s-extension' extension..."
echo "--------------------------------------\n"
az extension show --name "k8s-extension" &> extension_output
if cat extension_output | grep -q "not installed"; then
az extension add --name "k8s-extension"
rm extension_output
else
az extension update --name "k8s-extension"
rm extension_output
fi
echo ""

echo "Checking if you have up-to-date Azure Arc AZ CLI 'customlocation' extension..."
echo "--------------------------------------\n"
az extension show --name "customlocation" &> extension_output
if cat extension_output | grep -q "not installed"; then
az extension add --name "customlocation"
rm extension_output
else
az extension update --name "customlocation"
rm extension_output
fi
echo ""

echo "Checking if you have up-to-date Azure Arc AZ CLI 'k8s-configuration' extension..."
echo "--------------------------------------\n"
az extension show --name "k8s-configuration" &> extension_output
if cat extension_output | grep -q "not installed"; then
az extension add --name "k8s-configuration"
rm extension_output
else
az extension update --name "k8s-configuration"
rm extension_output
fi
echo ""

echo "Register Microsoft.ExtendedLocation provider"
echo "--------------------------------------\n"
az provider register --namespace Microsoft.ExtendedLocation

echo "Verification of Microsoft.ExtendedLocation provider installaion"
echo "--------------------------------------\n"
az provider show -n Microsoft.ExtendedLocation -o table

echo "Enable custom locations on your cluster"
echo "1- Get Custom Locations RP (Enterprise Application) Id"
echo "--------------------------------------\n"
# Custom Locations RP (Enterprise Application)
customLocationSpId=$(az ad sp show --id bc313c14-388c-4e7d-a58e-70017303ee3b --query id -o tsv)

echo "2- Enable Custom Locations feature"
echo "--------------------------------------"
# az connectedk8s enable-features must be run on a machine where the kubeconfig file is pointing to the cluster on which the features are to be enabled.
az connectedk8s enable-features -n $eksclustername \
-g $resourcegroupnameforarc \
--features cluster-connect custom-locations \
--custom-locations-oid $customLocationSpId

# deploy the data controller / extension in direct connectivity mode 
echo "3- Create the Arc data services extension"
echo "--------------------------------------"
adsExtensionName="tname-eks-cdext-myproj-env-euc1"
# dc's namespace must be the same as custom location's namespace
# namespace="myproj-arcdataservices-ns"
# reference link for creating a custom location : https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/custom-locations
customLocationName="tname-eks-cloc-myproj-env-euc1"

az k8s-extension create --cluster-name ${eksclustername} --resource-group ${resourcegroupnameforarc} --name ${adsExtensionName} --cluster-type connectedClusters --extension-type microsoft.arcdataservices --auto-upgrade false --scope cluster --release-namespace ${customLocationName} --config Microsoft.CustomLocation.ServiceAccount=sa-arc-bootstrapper

# Get the Azure Resource Manager identifier of the Azure Arc-enabled Kubernetes cluster
provisionedClusterId=$(az connectedk8s show -n $eksclustername -g $resourcegroupnameforarc  --query id -o tsv)

# Get the Azure Resource Manager identifier of the cluster extension deployed on top of Azure Arc-enabled Kubernetes cluster
extensionId=$(az k8s-extension show --name ${adsExtensionName} --cluster-type connectedClusters -c ${eksclustername} -g ${resourcegroupnameforarc}   --query id -o tsv)

# reference link : https://github.com/fengzhou-msft/azure-cli/blob/ea149713de505fa0f8ae6bfa5d998e12fc8ff509/doc/use_cli_with_git_bash.md
# MSYS_NO_PATHCONV=1 because of Git bash auto translate
# Create the custom location
MSYS_NO_PATHCONV=1 az customlocation create -n ${customLocationName} -g ${resourcegroupnameforarc} --namespace ${customLocationName} --host-resource-id ${provisionedClusterId} --cluster-extension-ids ${extensionId}

az customlocation show -n ${customLocationName} -g ${resourcegroupnameforarc}



echo "Checking if you have up-to-date Azure Arc AZ CLI 'arcdata' extension..."
echo "--------------------------------------\n"
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


deploymentProfile="azure-arc-eks"
dataControllerName="myproj-arcdataservices-dc"
az arcdata dc create --name ${dataControllerName} -g ${resourcegroupnameforarc} --custom-location ${customLocationName} --cluster-name ${eksclustername} --connectivity-mode direct --profile-name ${deploymentProfile}



# extensionName="myproj-appservice-ext" # Name of the App Service extension
# namespace="myproj-appservice-ns" # Namespace in your cluster to install the extension and provision resources
# kubeEnvironmentName="myproj" # Name of the App Service Kubernetes environment resource


# az k8s-extension create \
#     --resource-group $resourcegroupnameforarc \
#     --name $extensionName \
#     --cluster-type connectedClusters \
#     --cluster-name $eksclustername \
#     --extension-type 'Microsoft.Web.Appservice' \
#     --release-train stable \
#     --auto-upgrade-minor-version true \
#     --scope cluster \
#     --release-namespace $namespace \
#     --configuration-settings "Microsoft.CustomLocation.ServiceAccount=default" \
#     --configuration-settings "appsNamespace=${namespace}" \
#     --configuration-settings "clusterName=${kubeEnvironmentName}" \
#     --configuration-settings "keda.enabled=true" \
#     --configuration-settings "buildService.storageClassName=default" \
#     --configuration-settings "buildService.storageAccessMode=ReadWriteOnce" \
#     --configuration-settings "customConfigMap=${namespace}/kube-environment-config" 



eksclustername=tname-eks-myproj-env-euc1
resourcegroupnameforarc=tname-rg-for-arc-env-weu
region=eu-central-1