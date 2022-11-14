eksclustername=$1
resourcegroupnameforarc=$2

az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID

logAnalyticsWorkspaceResourceID=$(az monitor log-analytics workspace show --resource-group projn-rg-monitoring-dev-weu --workspace-name projn-log-monitoring-dev-weu --query id -o tsv)
logAnalyticsWorkspaceResourceID="logAnalyticsWorkspaceResourceID="$logAnalyticsWorkspaceResourceID
echo $logAnalyticsWorkspaceResourceID

az k8s-extension create --name azuremonitor-containers \
--cluster-name $eksclustername \
--resource-group $resourcegroupnameforarc \
--cluster-type connectedClusters \
--extension-type Microsoft.AzureMonitor.Containers \
--configuration-settings $logAnalyticsWorkspaceResourceID


eksclustername="tname-eks-myproj-env-euc1"
resourcegroupnameforarc="tname-rg-for-arc-env-weu"

# Links
# - https://www.techtarget.com/searchitoperations/tutorial/How-to-use-Azure-Arc-enabled-Kubernetes-step-by-step
# - https://www.codeproject.com/Articles/5334363/Azure-Arc-Enabled-Kubernetes-Part-2-Adding-Securit
# - https://entwickler.de/azure/devops-azure-arc
# - https://www.oreilly.com/library/view/azure-arc-enabled/9781098102647/ch04.html
# - https://www.programmingwithwolfgang.com/monitor-on-premises-k3s-cluster-with-azure-monitor-and-azure-arc/
# - https://learn.microsoft.com/en-us/azure/aks/monitor-aks
# - https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-prometheus?tabs=cluster-wide
# - https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-analyze