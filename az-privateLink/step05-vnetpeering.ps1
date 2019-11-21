#
# powershell script to run the ARM template
#
################# Input parameters #################
$subscriptionName  = "AzDev"     
$location          = "eastus"
$rgDeployment      = "dep01"
$armTemplateFile   = "step05-vnetpeering.json"
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
$resourceGroupVNet1 ="Company"+ $companyId+"-01"
$resourceGroupVNet2 ="Company"+ $companyId+"-02"
$resourceGroupVNet3 ="Company"+ $companyId+"-03"
$vnet1Name = "vnet-hub"
$vnet2Name = "vnet2"
$vnet3Name = "vnet3"

####
Write-Host (Get-Date)' - ' -NoNewline
Write-Host "checking Resource Group $resourceGroupVNet1" -ForegroundColor Cyan
Try {$rg = Get-AzResourceGroup -Name $resourceGroupVNet1  -ErrorAction Stop
     Write-Host '  resource group $resourceGroupVNet1 found!' -ForegroundColor Yellow}
Catch {write-host "resource group $resourceGroupVNet1 does not exit"; Exit}


Try {$vnet1 = Get-AzVirtualNetwork -ResourceGroupName $resourceGroupVNet1 -Name $vnet1Name -ErrorAction Stop
     Write-Host "  vnet $vnet1Name exists! " -ForegroundColor Yellow}
Catch {write-host "vnet $vnet1Name does not exit"; Exit} 
####
####
Write-Host (Get-Date)' - ' -NoNewline
Write-Host "checking Resource Group $resourceGroupVNet2" -ForegroundColor Cyan
Try {$rg = Get-AzResourceGroup -Name $resourceGroupVNet2  -ErrorAction Stop
     Write-Host '  resource group $resourceGroupVNet2 found!' -ForegroundColor Yellow}
Catch {write-host "resource group $resourceGroupVNet2 does not exit"; Exit}

Try {$vnet2 = Get-AzVirtualNetwork -ResourceGroupName $resourceGroupVNet2 -Name $vnet2Name -ErrorAction Stop
     Write-Host "  vnet $vnet2Name exists! " -ForegroundColor Yellow}
Catch {write-host "vnet $vnet2Name does not exit"; Exit} 
####
####
Write-Host (Get-Date)' - ' -NoNewline
Write-Host "checking Resource Group $resourceGroupVNet3" -ForegroundColor Cyan
Try {$rg = Get-AzResourceGroup -Name $resourceGroupVNet3  -ErrorAction Stop
     Write-Host '  resource group $resourceGroupVNet3 found!' -ForegroundColor Yellow}
Catch {write-host "resource group $resourceGroupVNet3 does not exit"; Exit}

Try {$vnet3 = Get-AzVirtualNetwork -ResourceGroupName $resourceGroupVNet3 -Name $vnet3Name -ErrorAction Stop
     Write-Host "  vnet $vnet3Name faound! " -ForegroundColor Yellow}
Catch {write-host "vnet $vnet3Name does not exit"; Exit} 
####
####
write-host "location1......: "$vnet1.Location -ForegroundColor Green
write-host "location2......: "$vnet2.Location -ForegroundColor Green
write-host "location3......: "$vnet3.Location -ForegroundColor Green
write-host "Resource Group1: $resourceGroupVNet1 vnet: $vnet1Name" -ForegroundColor Green
write-host "Resource Group2: $resourceGroupVNet2 vnet: $vnet2Name" -ForegroundColor Green
write-host "Resource Group3: $resourceGroupVNet3 vnet: $vnet3Name" -ForegroundColor Green

$parameters=@{
              "location1" = $vnet1.Location;
              "location2" = $vnet2.Location;
              "location3" = $vnet3.Location;
              "resourceGroupVNet1" = $resourceGroupVNet1;
              "resourceGroupVNet2" = $resourceGroupVNet2;
              "resourceGroupVNet3" = $resourceGroupVNet3;
              "vnet1Name" = $vnet1Name;
              "vnet2Name" = $vnet2Name;
              "vnet3Name" = $vnet3Name
              }

$runTime=Measure-Command {
  write-host "running ARM template:"$templateFile -ForegroundColor Cyan
  New-AzResourceGroupDeployment  -Name $rgDeployment -ResourceGroupName $resourceGroupVNet1 -TemplateFile $templateFile -TemplateParameterObject $parameters -Verbose
}

write-host -ForegroundColor Yellow "runtime: "$runTime.ToString()