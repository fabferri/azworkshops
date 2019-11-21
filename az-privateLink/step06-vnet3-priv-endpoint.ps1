#
# powershell script to run the ARM template
#

################# Input parameters #################
$subscriptionName  = "AzDev"     
$location          = "eastus"
$rgDeployment      = "dep01"
$armTemplateFile   = "step06-vnet3-priv-endpoint.json"
####################################################

$pathFiles      = Split-Path -Parent $PSCommandPath
$templateFile   = "$pathFiles\$armTemplateFile"

If (Test-Path -Path $pathFiles\init.txt) {
        Get-Content $pathFiles\init.txt | Foreach-Object{
        $var = $_.Split('=')
        Try {New-Variable -Name $var[0].Trim() -Value $var[1].Trim() -ErrorAction Stop}
        Catch {Set-Variable -Name $var[0].Trim() -Value $var[1].Trim()}}}
Else {Write-Warning "init.txt file not found, please change to the directory where these scripts reside ($pathFiles) and ensure this file is present.";Return}


$subscr=Get-AzSubscription -SubscriptionName $subscriptionName
Select-AzSubscription -SubscriptionId $subscr.Id

# compose the resource group name

$resourceGroupVNet3 ="Company"+ $companyId+"-03"
$resourceGroupVNet4 ="Company"+ $companyId+"-04"
$vnet3Name = "vnet3"
$vnet4Name = "vnet-service"
####
####
Write-Host (Get-Date)' - ' -NoNewline
Write-Host "checking Resource Group $resourceGroupVNet3" -ForegroundColor Cyan
Try {$rg = Get-AzResourceGroup -Name $resourceGroupVNet3  -ErrorAction Stop
     Write-Host '  resource group $resourceGroupVNet3 found!' -ForegroundColor Yellow}
Catch {write-host "resource group $resourceGroupVNet3 does not exit"; Exit}

Try {$vnet3 = Get-AzVirtualNetwork -ResourceGroupName $resourceGroupVNet3 -Name $vnet3Name -ErrorAction Stop
     Write-Host "  vnet $vnet3Name found! " -ForegroundColor Yellow}
Catch {write-host "vnet $vnet3Name does not exit"; Exit} 
####
####
Write-Host (Get-Date)' - ' -NoNewline
Write-Host "checking Resource Group $resourceGroupVNet4" -ForegroundColor Cyan
Try {$rg = Get-AzResourceGroup -Name $resourceGroupVNet4  -ErrorAction Stop
     Write-Host '  resource group $resourceGroupVNet4 found!' -ForegroundColor Yellow}
Catch {write-host "resource group $resourceGroupVNet4 does not exit"; Exit}

Try {$vnet4 = Get-AzVirtualNetwork -ResourceGroupName $resourceGroupVNet4 -Name $vnet4Name -ErrorAction Stop
     Write-Host "  vnet $vnet4Name found! " -ForegroundColor Yellow}
Catch {write-host "vnet $vnet4Name does not exit"; Exit} 
####
write-host "location3......: "$vnet3.Location -ForegroundColor Green
write-host "location4......: "$vnet4.Location -ForegroundColor Green
write-host "Resource Group3: $resourceGroupVNet3 vnet: "$vnet3.Name  -ForegroundColor Green
write-host "Resource Group4: $resourceGroupVNet4 vnet: "$vnet4.Name  -ForegroundColor Green



$parameters=@{
              "location" = $vnet3.Location;
              "resourceGroupVNet3" = $resourceGroupVNet3;
              "vnetName" = $vnet3Name
              "privateLinkService_ResourceGroup" =$resourceGroupVNet4
              }

$runTime=Measure-Command {
  write-host "running ARM template:"$templateFile -ForegroundColor Cyan
  New-AzResourceGroupDeployment  -Name $rgDeployment -ResourceGroupName $resourceGroupVNet3 -TemplateFile $templateFile -TemplateParameterObject $parameters -Verbose
}

write-host -ForegroundColor Yellow "runtime: "$runTime.ToString()