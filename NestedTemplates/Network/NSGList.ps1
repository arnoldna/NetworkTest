
$projectName = "[TEMPLATE_PROJECT_NAME]"
$resourceGroupName = "[RESOURCE_GROUP_NAME]"
$storageAccountName = "[STORAGE_ACCOUNT_NAME]"
$containerName = "[CONTAINER_NAME]"
$segments = $resourceGroupName.Split("-")
$envName = $segments[$segments.Count - 1]

Set-AzureRmCurrentStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName

$templates = Get-ChildItem .\src\$projectName\Templates\*.params.json -Exclude ("base-*.json", "master-*.json")
foreach($template in $templates)
{
  $filePath = $template.FullName

  $json = Get-Content -Path $filePath | ConvertFrom-Json
  $json.parameters | Add-Member -MemberType NoteProperty -Name environment -Value @{ value = $envName }

  $json | ConvertTo-Json -Depth 999 | Out-File -FilePath $filePath -Encoding utf8

  Set-AzureStorageBlobContent -Container $containerName -File $filePath -Force
}


$templates = Get-ChildItem .\$projectName\azuredeploy.json  
foreach($template in $templates)
{
  $filePath = $template.FullName

  $json = Get-Content -Path $filePath | ConvertFrom-Json
  $json
$json.parameters | Add-Member -MemberType NoteProperty -Name nsgList -Value @{ value = $nsglist} -Force
$json | ConvertTo-Json -Depth 999 | Out-File -FilePath $filePath -Encoding utf8

  #Set-AzureStorageBlobContent -Container $containerName -File $filePath -Force
}

$nsgList = az network nsg list --resource-group 'Prod-Network' --query "[].name"

[string]$a = $null
$a = $nsgList -join "",""
$a
az group deployment create --resource-group Prod-Network --parameters nsgList=$a --template-uri "https://raw.githubusercontent.com/arnoldna/NetworkTest/user/arnoldna/DevTest/azuredeploy.json" --debug