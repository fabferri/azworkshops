<properties
pageTitle= 'Example of workshop with mix of Azure networking tecnology'
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
Here a workshop of Azure networking components.
The workshop is based on list of ARM templates (.json files); each file can be run by powershell (with same name):

* **step01-hubvnet.ps1** creates the hub vnet with different subnets: 
   - frontend subnet and backedn subnet to deploy an internal load balacer in high availability port
   - two Azure VMs with ip forwarding enabled
   - a bastion host
   - an Azure firewall
   - a dmz subnet with an Azure VM
  
  *Before running the step1, change the* **ADMINISTROR_USERNAME** *and* **ADMINISTRATOR_PASSWORD**

* **step02-vnet2.ps1**: it create the vnet2 with two private endpoints, one to access to the SQL DB and another one to access to a storage account
  
  *Before running the step2, change the* **ADMINISTROR_USERNAME** *and* **ADMINISTRATOR_PASSWORD**

* **step03-vnet3.ps1**: it creates the vnet3

  *Before running the step3, change the* **ADMINISTROR_USERNAME** *and* **ADMINISTRATOR_PASSWORD**

* **step04-servicevnet.ps1**: it create the service vnet with a service link, load balancer and two VMs 

  *Before running the step4, change the* **ADMINISTROR_USERNAME** *and* **ADMINISTRATOR_PASSWORD**

* **step05-vnetpeering.ps1**: it create two vnet peering:
   - vnet peering between hub-vnet and vnet2
   - vnet peering between hub-vnet and vnet3
* **step06-vnet3-priv-endpoint.ps1**: it create the private endpoint in vnet3 to access to the service provider deployed in service vnet
* **step07-vnet2-priv-endpoint.ps1**: it create the private endpoint in vnet2 to access to the service provider deployed in service vnet
* **step08-er.ps1**: create an ExpressRoute gateway and connection with the existing ExpressRoute circuit. the ExpressRoute circuit is deployed in different Azure subscription. the ARM template requires an authorization code to link to the existing Expressroute circuit.
* **step09-udr-hubvnet.ps1**: creates the UDR in the dmzsubnet of hub vnet 
* **step10-udr-vnet2.ps1** :create the UDR in the subnet2 of vnet2
* **step11-udr-vnet3.ps1**: create the UDR in the subnet2 of vnet3


The network diagram is shown below:

[![1]][1]


[![2]][2]

### <a name="step1"></a>1. Actions after execution of step1:
1. connect to the vmdmz via bastion
2. browse to http:// 10.X.1.36
3. browse to http:// 10.X.1.37
4. connect via SSH to the nva0 and run the command: **sysctl net.ipv4.ip_forward** to check the ip forwarding has been enabled
5. Check the ilb has the right frontend IP
6. Check the backend pool of ilb: you should see nva1, nva2 as backed VMs 
7. Enable the icmp echo in vmdmz (windows firewall)

### <a name="step2"></a>2. Actions after execution of step2:

1. connect to the vm0
2. change the windows firewall to enable icmp (ping)
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
9. Enable the icmp echo in vm0 (windows firewall)


<!--Image References-->

[1]: ./media/network-diagram.png "network diagram"
[2]: ./media/network-diagram-details.png "network diagram with details"

<!--Link References-->

