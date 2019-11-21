#
# powershell script to run the ARM template
# 
################# Input parameters #################
$subscriptionName  = "AzDev"     
$location          = "eastus"
$rgDeployment      = "dep01"
$armTemplateFile   = "step11-udr-vnet3.json"
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
$vnet3Name = "vnet3"

####
Write-Host (Get-Date)' - ' -NoNewline
Write-Host "checking Resource Group $resourceGroupVNet3" -ForegroundColor Cyan
Try {$rg = Get-AzResourceGroup -Name $resourceGroupVNet3  -ErrorAction Stop
     Write-Host '  resource group $resourceGroupVNet3 found!' -ForegroundColor Yellow}
Catch {write-host "resource group $resourceGroupVNet3 does not exit"; Exit}


Try {$vnet3 = Get-AzVirtualNetwork -ResourceGroupName $resourceGroupVNet3 -Name $vnet3Name -ErrorAction Stop
     Write-Host "  vnet $vnet3Name exists! " -ForegroundColor Yellow}
Catch {write-host "vnet $vnet3Name does not exit"; Exit} 

$parameters=@{
              "companyId" = $companyId;
              "location3" = $vnet3.Location;
              "resourceGroupVNet3" = $resourceGroupVNet3;
              "vnet3Name" = $vnet3Name;
              }

$runTime=Measure-Command {
  write-host "running ARM template:"$templateFile -ForegroundColor Cyan
  New-AzResourceGroupDeployment  -Name $rgDeployment -ResourceGroupName $resourceGroupVNet3 -TemplateFile $templateFile -TemplateParameterObject $parameters -Verbose
}

write-host -ForegroundColor Yellow "runtime: "$runTime.ToString()