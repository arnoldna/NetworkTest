$projectName = "[TEMPLATE_PROJECT_NAME]"
$resourceGroupName = "Prod-Network"
$storageAccountName = "[STORAGE_ACCOUNT_NAME]"
$containerName = "[CONTAINER_NAME]"

Set-AzureRmCurrentStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName

$templates = Get-ChildItem .\src\$projectName\Templates\*.json -Exclude ("base-*.json", "master-*.json", "*.params.json")
foreach($template in $templates)
{
  $filePath = $template.FullName
  Set-AzureStorageBlobContent -Container $containerName -File $filePath -Force
}


$nsgList = az network nsg list --resource-group 'Prod-Network' --query "[].name"
az group deployment create --resource-group Prod-Network --parameters $nsgList --template-uri "https://raw.githubusercontent.com/arnoldna/NetworkTest/user/arnoldna/DevTest/azuredeploy.json" 