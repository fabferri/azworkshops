#
################# Input parameters #################
$subscriptionName  = "AzDev"     
$location          = "eastus"
$rgDeployment      = "dep01"
$armTemplateFile   = "step08-er.json"
####################################################

$pathFiles      = Split-Path -Parent $PSCommandPath
$templateFile   = "$pathFiles\$armTemplateFile"

If (Test-Path -Path $pathFiles\init.txt) {
        Get-Content $pathFiles\init.txt | Foreach-Object{
        $var = $_.Split('=')
        Try {New-Variable -Name $var[0].Trim() -Value $var[1].Trim() -ErrorAction Stop}
        Catch {Set-Variable -Name $var[0].Trim() -Value $var[1].Trim()}}}
Else {Write-Warning "init.txt file not found, please change to the directory where these scripts reside ($pathFiles) and ensure this file is present.";Return}



$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
If (Test-Path -Path $ScriptDir\er.txt) {
        Get-Content $ScriptDir\er.txt | Foreach-Object{
        $var = $_.Split('=')
        Try {New-Variable -Name $var[0].Trim() -Value $var[1].Trim() -ErrorAction Stop}
        Catch {Set-Variable -Name $var[0].Trim() -Value $var[1].Trim()}}}
Else {Write-Warning "er.txt file not found, please change to the directory where these scripts reside ($ScriptDir) and ensure this file is present.";Return}

$subscr=Get-AzSubscription -SubscriptionName $subscriptionName
Select-AzSubscription -SubscriptionId $subscr.Id

# compose the resource group name
$resourceGroupVNet1 ="Company"+ $companyId+"-01"
$vnet1Name = "vnet-hub"
$ercircuitName=$erCircuitId.split('/')[-1]
write-host "ExpressRoute circuit Id...........: "$erCircuitId -ForegroundColor Green
write-host "ExpressRoute circuit authorization: "$authorizationKey -ForegroundColor Green
write-host "ExpresRoute circuit name..........: "$erCircuitName -ForegroundColor Yellow



####
Write-Host (Get-Date)' - ' -NoNewline
Write-Host "checking Resource Group: "$resourceGroupVNet1 -ForegroundColor Cyan
Try {$rg = Get-AzResourceGroup -Name $resourceGroupVNet1  -ErrorAction Stop
     Write-Host "  resource group $resourceGroupVNet1 found!" -ForegroundColor Yellow}
Catch {write-host "resource group $resourceGroupVNet1 does not exit"; Exit}


Try {$vnet1 = Get-AzVirtualNetwork -ResourceGroupName $resourceGroupVNet1 -Name $vnet1Name -ErrorAction Stop
     Write-Host "  vnet $vnet1Name found! " -ForegroundColor Yellow}
Catch {write-host "vnet $vnet1Name does not exit"; Exit} 
####

$parameters=@{
              "location"=$vnet1.Location
              "resourceGroupVNet1"= $resourceGroupVNet1;
              "companyId" = $companyId;
              "vnet1Name" = $vnet1Name;
              "erCircuitId"=$erCircuitId;
              "authorizationKey"=$authorizationKey;
              "erCircuitName"=$erCircuitName
              }


$runTime=Measure-Command {
  write-host "running ARM template:"$templateFile -ForegroundColor Cyan
  New-AzResourceGroupDeployment  -Name $rgDeployment -ResourceGroupName $resourceGroupVNet1 -TemplateFile $templateFile -TemplateParameterObject $parameters -Verbose
}

write-host -ForegroundColor Yellow "runtime: "$runTime.ToString()