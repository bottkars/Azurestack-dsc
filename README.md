# Azurestack-Kickstart

This repo is a Collection of scripts to run after AzureStack ASDK Installations 
The Idea is to have base components/logins stored in a json template and credentials stored in session variables.
The Consistent Approach allws you to "Bootstrap" your Shell session with the 99_bootstrap script(s)
The Bootstrap Scripts wll read the user / admin json files having envronment data stored from the Homedirectory
# ALL SCRIPTS IN THE REPO NOT MENTIONED HERE ARE STILL IN TRANSITIONING FROM MY YOLD TOOLS AND NOT TESTED

to install the Azuer Stack Kickstart, simply type in 
```Powershell
install-script azurestack-kickstart -Scope CurrentUser -Force
Azurestack-Kickstart.ps1
```
the command will run itsself in elevated Mode and will:  
   - disable updates
   - Install GitSCM, Chrome and Shortcuts for the Portals
   - Clone into Azuerstack-Kickstart Distro
![azurestack-kickstart](https://user-images.githubusercontent.com/8255007/34120361-abf1a93e-e425-11e7-827e-98fceb33c8f3.gif)  

Once finished, CD into Azurestack-DSC.
create an admin.json file in your Homedirectory ( copy the admin.json.example fro the root of the distro as reference)


## example admin.json
```json
{
"Domain": "azurestack",
"VMPassword": "Password123!",
"VMuser": "azureuser",
"TenantName": "contoso.onmicrosoft.com",
"subscriptionID": "8c21cadc-9e41-459e-bf4b-919aa2fad975",
"SubscriptionOwner": "Administrator@contoso.com.com", 
"PrivilegedEndpoint": "azs-ercs01.azurestack.local",
"serviceuser": "masadmin",
"cloudadmin": "cloudadmin",
"AZSTools_Location": "D:\\AzureStack-Tools",
"AzureRMProfile": "2017-03-09-profile",
"AzureSTackModuleVersion": "1.2.11",
"KeyvaultDnsSuffix": "adminvault.local.azurestack.external",
"ArmEndpoint": "https://adminmanagement.local.azurestack.external",
"location": "local",
"SQLRPadmin": "SQLRPadmin",
"MySQLRPadmin": "MySQLRPadmin",
"ISOpath": "D:\\ISO",
"Updatepath": "D:\\Updates"
}
```


## initial powershell modules config

To set the initial stack configuration and install Powershell Modules run:
```Powershell
D:\azurestack-dsc\admin\03_initial_stack.ps1
```
The Command will run itself in elevated Mode
![image]![image](https://user-images.githubusercontent.com/8255007/33956253-4c7f325e-e03e-11e7-8bc9-86c480d74424.png)

this task can be repeated at any time to update the AzureStack Powershell environment

## register the stack
```Powershell
D:\azurestack-dsc\admin\06_register_stack.ps1
```
this will use your setiings from admin.json to register your azurestack


# Starting the customizations

we have to load now our admin environment
```Powershell
 D:\azurestack-dsc\admin\99_bootstrap.ps1
```  
![image](https://user-images.githubusercontent.com/8255007/33956638-7bd6c8d6-e03f-11e7-88b0-2293a6dd66bb.png)  
![image](https://user-images.githubusercontent.com/8255007/33956656-84f953b6-e03f-11e7-9018-27266d2a0ae6.png)  

## deploy Base Plans

```Powershell
D:\azurestack-dsc\admin\10_deploy_base_plans_and_quotas.ps1
```  
![image](https://user-images.githubusercontent.com/8255007/33957262-636e5f0a-e041-11e7-8c36-05a15bf939d8.png)  

## deploy Windows Marketplace Items from ISO
this needs to run in an Admin Session ...  
```Powershell
D:\azurestack-dsc\admin\99_bootstrap.ps1
D:\azurestack-dsc\admin\11_deploy_windows_marketplace_image.ps1
```
![image](https://user-images.githubusercontent.com/8255007/33983160-65a941c8-e0b3-11e7-8bb2-8200074af068.png)  

you can create Bulk Marketplace Images by using:
```Powershell
$KB = (get-content D:\azurestack-dsc\admin\windowsupdate.json | ConvertFrom-Json) |  Sort-Object  -Property Date | Select-Object KB | Where-Object KB -ne ""
$KB | D:\azurestack-dsc\admin\11_deploy_windows_marketplace_image.ps1 -ISOPath 'D:\updates\' -UpdatePath D:\updates\
```
this will batch create Marketplace Items for All Windows Server 2016 KB´s listed in the included windowsupdate.json   
the process is 
- checking if SKU and Version already in Marketplace
- eval the Steps
- download updates if not available
- clean up orphan vhd / cab files  
the msu files remain in the $updatepath
![image](https://user-images.githubusercontent.com/8255007/34031744-164f69ca-e173-11e7-803a-d846d9571acd.png)

# user scripts
# example user.json file
```json
{
"Domain": "azurestack",
"VMuser": "azureuser",
"VMPassword": "Password123!",
"TenantName": "contoso.onmicrosoft.com",
"azsuser": "azsuser1",
"cloudadmin": "cloudadmin",
"AZSTools_Location": "D:\\AzureStack-Tools",
"AzureRMProfile": "2017-03-09-profile",
"AzureSTackModuleVersion": "1.2.11",
"KeyvaultDnsSuffix": "adminvault.local.azurestack.external",
"ArmEndpoint": "https://management.local.azurestack.external",
"StackIP": "10.204.16.82"
} 
```
# user bootstrapping   
once the use has created his config file, he can bootstrap from his powershell to get permanent variables in the session.  
```Powershell
.\user\99_bootstrap_user.ps1
```
![image](https://user-images.githubusercontent.com/8255007/34080665-12e337dc-e342-11e7-9c41-d68fb3b972c3.png)  


## creating Windows VM Scalesets using  -osImageSkuVersion
If the Cloudadmin has provided differnt osImageSKU´s from above, we can   
```Powershell  
PS C:\Users\bottk\Azurestack-dsc> .\user\60_new-azsserver2016vmss.ps1 -vmssName myssdemo -osImageSkuVersion 14393.729.20170130
```  
This creates a new vmscaleset with the os image version 14393.729.20170130  
![image](https://user-images.githubusercontent.com/8255007/34080434-3c129e4e-e33e-11e7-97ee-03fd66bccd4f.png)  

we can verify the properties of the scaleset :  

![image](https://user-images.githubusercontent.com/8255007/34080443-7a25f834-e33e-11e7-8923-af75dc42ae5a.png)  






