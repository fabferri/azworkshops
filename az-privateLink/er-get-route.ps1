# powershell to get the routing table of the ER gateway
$subscriptionName  = "AzDev"     
$location          = "eastus"
$armTemplateFile   = "step01-hubvnet.json"
####################################################

$pathFiles      = Split-Path -Parent $PSCommandPath

If (Test-Path -Path $pathFiles\init.txt) {
        Get-Content $pathFiles\init.txt | Foreach-Object{
        $var = $_.Split('=')
        Try {New-Variable -Name $var[0].Trim() -Value $var[1].Trim() -ErrorAction Stop}
        Catch {Set-Variable -Name $var[0].Trim() -Value $var[1].Trim()}}}
Else {Write-Warning "init.txt file not found, please change to the directory where these scripts reside ($pathFiles) and ensure this file is present.";Return}

# compose the resource group name
$rgName = "Company"+ $companyId+"-01"
$gtName = "er-gtw1"


$subscr = Get-AzSubscription -SubscriptionName $subscriptionName
Select-AzSubscription -SubscriptionId $subscr.Id

$ipfirstOctect="10"
$ipsecondOctect=$companyId
$ipthirdOctect="1"
$ip1=$ipfirstOctect+"."+$ipsecondOctect+"."+$ipthirdOctect+".228"
$ip2=$ipfirstOctect+"."+$ipsecondOctect+"."+$ipthirdOctect+".229"

write-host
write-host "Route learned in the ER gateway:" -ForegroundColor Green
Get-AzVirtualNetworkGatewayLearnedRoute -VirtualNetworkGatewayName $gtName -ResourceGroupName $rgName | ft
write-host "---------------------------------------------------------" -ForegroundColor Green
write-host
write-host "Route advertised from the ER gateway to on-premises:" -ForegroundColor Yellow
Get-AzVirtualNetworkGatewayAdvertisedRoute -VirtualNetworkGatewayName $gtName -ResourceGroupName $rgName -Peer 10.12.1.228 | ft
Get-AzVirtualNetworkGatewayAdvertisedRoute -VirtualNetworkGatewayName $gtName -ResourceGroupName $rgName -Peer 10.12.1.229 | ft

