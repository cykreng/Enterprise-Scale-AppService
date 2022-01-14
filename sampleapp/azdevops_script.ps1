# Credit to Colin Dembovsky for this blog https://colinsalmcorner.com/az-devops-like-a-boss/ - much of the script below leverages that blog

$SERVICE_PRINCIPAL_NAME=''
$SP_PASSWD=az ad sp create-for-rbac --name $SERVICE_PRINCIPAL_NAME --role Contributor --query password --output tsv
$CLIENT_ID=az ad sp list --display-name $SERVICE_PRINCIPAL_NAME --query "[].appId" --output tsv

$orgUrl='https://dev.azure.com/XXX'
$ProjectName ='ASETest'
$RepoName='ASELandingZone'
$sourceRepoURL='https://github.com/cykreng/Enterprise-Scale-AppService.git'
$AzureSubscriptionID= az account show --query id --output tsv
$AzureSubscriptionName =az account show --query name --output tsv
$TenantID=  az account show --query tenantId --output tsv
$SPNClientID =az ad sp list --display-name $SERVICE_PRINCIPAL_NAME --query "[].appId" --output tsv
$ServiceEndpointName='ASEServiceEndPoint'
$PipelineName='ASESampleAppPipeline'
$PipelineDescription='ASESampleAppPipeline'
$YmlPath='sampleapp/azure-pipelines.yaml'


az devops login --org $orgUrl

az devops project create --org $orgUrl --name  $ProjectName 

az repos create --name $RepoName -p $ProjectName --org $orgUrl
az repos import create --git-url $sourceRepoURL -p $ProjectName --org $orgUrl --repository $RepoName 
az repos update --repository $RepoName --default-branch main -p $ProjectName --org $orgUrl

$env:AZURE_DEVOPS_EXT_AZURE_RM_SERVICE_PRINCIPAL_KEY=$SP_PASSWD

az devops service-endpoint azurerm create --azure-rm-service-principal-id $SPNClientID --azure-rm-subscription-id $AzureSubscriptionID --azure-rm-subscription-name $AzureSubscriptionName --azure-rm-tenant-id $TenantID --name $ServiceEndpointName -p $ProjectName --org $orgUrl

$epId = az devops service-endpoint list --org $orgUrl -p $ProjectName --query "[?name=='$ServiceEndpointName'].id" -o tsv
az devops service-endpoint update --id $epId --enable-for-all true --org $orgUrl -p $ProjectName

az pipelines create -p $ProjectName --org $orgUrl --name $PipelineName --description $PipelineDescription --repository $RepoName --repository-type tfsgit --branch main --skip-first-run --yml-path $YmlPath

az repos delete --name $RepoName -p $ProjectName --org $orgUrl


$YmlPath='/sampleapp/azure-pipelines.yml'
$PipelineName='ASESampleAppPipeline4'
az pipelines create -p $ProjectName --org $orgUrl --name $PipelineName --description $PipelineDescription --repository $RepoName --repository-type tfsgit --branch main --skip-first-run --yml-path $YmlPath

