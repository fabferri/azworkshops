<properties
pageTitle= 'Example of workshop with mix of Azure networking technology'
description= "Workshop with Azure private link, VNet peering, ExpressRoute"
documentationcenter: na
services=""
documentationCenter="na"
authors="fabferri"
manager=""
editor=""/>

<tags
   ms.service="configuration-Example-Azure"
   ms.devlang="na"
   ms.topic="article"
   ms.tgt_pltfrm="na"
   ms.workload="na"
   ms.date="21/11/2019"
   ms.author="fabferri" />

## Azure networking workshop: private link, VNet peering, ExpressRoute
Here an Azure networking workshop based on list of ARM templates (.json files). Each ARM template deploys a list of network components and VMs; the ARM is executed by running powershell script, with same name:


| powershell script  | ARM template              | Description                   |
| :----------------- | :------------------------ |:----------------------------- |
|`step01-hubvnet.ps1`|`step01-hubvnet.json` | - creates the hub vnet with different subnets:<br>- frontend subnet and backedn subnet to deploy an internal load balacer in high availability port<br>- two Azure VMs with ip forwarding enabled<br>- a bastion host <br>- an Azure firewall<br>- a dmz subnet with an Azure VM|
|`step02-vnet2.ps1`| `step02-vnet2.json`| it create the vnet2 with two private endpoints, one to access to the SQL DB and another one to access to a storage account|
|`step03-vnet3.ps1`| `step03-vnet3.json`|it creates the vnet3|
|`step04-servicevnet.ps1`|`step04-servicevnet.json`| it create the service vnet with a service link, load balancer and two VMs|
|`step05-vnetpeering.ps1`| `step05-vnetpeering.json`| it create two vnet peering: <br>- vnet peering between hub-vnet and vnet2<br>- vnet peering between hub-vnet and vnet3|
| `step06-vnet3-priv-endpoint.ps1`| `step06-vnet3-priv-endpoint.json`| it create the private endpoint in vnet3 to access to the service provider deployed in service vnet |
| `step07-vnet2-priv-endpoint.ps1`|`step07-vnet2-priv-endpoint.json`| it create the private endpoint in vnet2 to access to the service provider deployed in service vnet|
| `step08-er.ps1`| `step08-er.json`|create an ExpressRoute gateway and connection with the existing ExpressRoute circuit. the ExpressRoute circuit is deployed in different Azure subscription. the ARM template requires an authorization code to link to the existing Expressroute circuit.|
| `step09-udr-hubvnet.ps1`|`step09-udr-hubvnet.json`| creates the UDR in the dmzsubnet of hub vnet|
| `step10-udr-vnet2.ps1` |`step10-udr-vnet2.json`|create the UDR in the subnet2 of vnet2|
| `step11-udr-vnet3.ps1`|`step11-udr-vnet3.json`| create the UDR in the subnet2 of vnet3|

*Before running the step1,step2, step3 and step4 set your own values in the variables * **ADMINISTRATOR_USERNAME** _and_ **ADMINISTRATOR_PASSWORD**



The network diagram is shown below:

[![1]][1]


[![2]][2]

### <a name="step1"></a>1. Adviced actions after execution of step1:
1. connect to the vmdmz via bastion
2. browse to http:// 10.X.1.36
3. browse to http:// 10.X.1.37
4. connect via SSH to the nva0 and run the command: **sysctl net.ipv4.ip_forward** to check ip forwarding has been enabled (value 1: IP forwarding enabled, value 0: IP forwarding enabled)
5. Check the ilb has the right frontend IP
6. Check the backend pool of ilb: you should see nva1, nva2 as backed VMs 
7. Enable the icmp echo in vmdmz (windows firewall)

### <a name="step2"></a>2. Adviced actions after execution of step2:

1. connect to the vm0
2. enable icmp echo in windows firewall
3. browse in the deployment to take note the name of 
   - storage account
   - SQL server
4. run in cmd shell
   ```console
   nslookup <sqlserverName>.database.windows.net
   nslookup <storageaccountName>.blob.core.windows.net
   ```
   The naming need to be translated in private IP

5. download and install "Azure Storage Explorer" in the vm0
   
   https://go.microsoft.com/fwlink/?LinkId=708343&clcid=0x409
6. download and install "SQL Management Studio" in the vm0

   https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-ver15
7. By Storage Explorer connect to the storage account
8. By SQL Management Studio connect to the SQL server 
9. In windows firewall, enable the icmp echo in vm0


<!--Image References-->

[1]: ./media/network-diagram.png "network diagram"
[2]: ./media/network-diagram-details.png "network diagram with details"

<!--Link References-->

