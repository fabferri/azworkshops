#
# powershell script to run the ARM template
# 
#
################# Input parameters #################
$subscriptionName  = "AzDev"     
$location          = "eastus"
$rgDeployment      = "dep01"
$armTemplateFile   = "step10-udr-vnet2.json"
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
$resourceGroupVNet2 ="Company"+ $companyId+"-02"
$vnet2Name = "vnet2"


####
Write-Host (Get-Date)' - ' -NoNewline
Write-Host "checking Resource Group $resourceGroupVNet2" -ForegroundColor Cyan
Try {$rg = Get-AzResourceGroup -Name $resourceGroupVNet2  -ErrorAction Stop
     Write-Host "  resource group $resourceGroupVNet2 found!" -ForegroundColor Yellow}
Catch {write-host "resource group $resourceGroupVNet2 does not exit"; Exit}


Try {$vnet2 = Get-AzVirtualNetwork -ResourceGroupName $resourceGroupVNet2 -Name $vnet2Name -ErrorAction Stop
     Write-Host "  vnet $vnet2Name exists! " -ForegroundColor Yellow}
Catch {write-host "vnet $vnet2Name does not exit"; Exit} 

$parameters=@{
              "companyId" = $companyId;
              "location2" = $vnet2.Location;
              "resourceGroupVNet2" = $resourceGroupVNet2;
              "vnet2Name" = $vnet2Name;

              }

$runTime=Measure-Command {
  write-host "running ARM template:"$templateFile -ForegroundColor Cyan
  New-AzResourceGroupDeployment  -Name $rgDeployment -ResourceGroupName $resourceGroupVNet2 -TemplateFile $templateFile -TemplateParameterObject $parameters -Verbose
}

write-host -ForegroundColor Yellow "runtime: "$runTime.ToString()