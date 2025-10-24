# SmartRadarKafka setup script - fixed version for Azure for Students

# ==========================
# CONFIGURATION SECTION
# ==========================
$resourceGroupName = "SmartRadarKafkaRG"
$deploymentName = "SmartRadarKafkaDeployment"
$templateFile = "main.bicep"
$Region = "westeurope"  # ✅ Fixed region to avoid RequestDisallowedByAzure
$tags = @{
    Project = "SmartRadarKafka"
    Owner   = $env:USERNAME
    Date    = (Get-Date -Format "yyyy-MM-dd")
}

# ==========================
# START DEPLOYMENT
# ==========================
Write-Host "========================================="
Write-Host " SmartRadarKafka Azure Deployment Script "
Write-Host "=========================================`n"

Write-Host "Using fixed region: $Region"

# Check if user is logged in
Write-Host "`nChecking Azure login status..."
$account = Get-AzContext
if (-not $account) {
    Write-Host "Not logged in. Logging into Azure..."
    Connect-AzAccount -UseDeviceAuthentication
} else {
    Write-Host "Already logged in as $($account.Account)."
}

# Check if the Resource Group exists
Write-Host "`nChecking if resource group '$resourceGroupName' exists..."
$rg = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if ($null -eq $rg) {
    Write-Host "Resource group not found. Creating it now in region: $Region ..."
    New-AzResourceGroup -Name $resourceGroupName -Location $Region -Tag $tags | Out-Null
    Write-Host "Resource group created successfully."
} else {
    Write-Host "Resource group already exists. Skipping creation."
}

# ==========================
# DEPLOY BICEP TEMPLATE
# ==========================
Write-Host "`nStarting Bicep deployment..."
try {
    New-AzResourceGroupDeployment `
        -Name $deploymentName `
        -ResourceGroupName $resourceGroupName `
        -TemplateFile $templateFile `
        -Mode Incremental `
        -Verbose `
        -ErrorAction Stop

    Write-Host "`n✅ Deployment completed successfully!"
} catch {
    Write-Host "`n❌ Deployment failed:"
    Write-Host $_.Exception.Message
    exit 1
}

# ==========================
# SUMMARY
# ==========================
Write-Host "`n========================================="
Write-Host " Deployment Summary"
Write-Host "-----------------------------------------"
Write-Host " Resource Group : $resourceGroupName"
Write-Host " Region          : $Region"
Write-Host " Template File   : $templateFile"
Write-Host " Deployment Name : $deploymentName"
Write-Host "=========================================`n"

Write-Host "You can view your resources in the Azure Portal:"
Write-Host "👉 https://portal.azure.com/#view/HubsExtension/BrowseResourceGroups"
