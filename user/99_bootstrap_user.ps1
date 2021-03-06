﻿[CmdletBinding(HelpUri = "https://github.com/bottkars/azurestack-dsc")]
param (
[Parameter(ParameterSetName = "1", Mandatory = $false,Position = 1)][ValidateScript({ Test-Path -Path $_ })]$Defaultsfile="$HOME/user.json",
[switch]$noconnect
)
if (!(Test-Path $Defaultsfile))
{
    Write-Warning "$Defaultsfile file does not exist.please copy from user.json.example"
    Break
}
else
    {
    Write-Host -ForegroundColor Gray " ==>loading Admin Enviromment from $Defaultsfile"
    try {
        $User_Defaults = Get-Content $Defaultsfile | ConvertFrom-Json -ErrorAction SilentlyContinue   
    }
    catch {
        Write-Host "could not load $Defaultsfile, maybe a format error ?"
        break
    }
    
    Write-Output $User_Defaults
    }
if (!$User_Defaults.azsuser)
    {
       Write-Warning "azsuser is not set in $defaultsfile. Please add entry and retry" 
       Break 
    }
$Global:azsuser = $User_Defaults.azsuser

if (!$User_Defaults.tenantname)
    {
       Write-Warning "tenantname is not set in $defaultsfile. Please add entry and retry" 
       Break 
    }
$Global:TenantName = $User_Defaults.TenantName
$global:azsuseraccount = "$Global:azsuser@$Global:TenantName"

if (!$User_Defaults.AZSTools_Location)
    {
       Write-Warning "AZSTools_Location is not set in $defaultsfile. Please add entry and retry" 
       Break 
    }
$global:AZS_MODULES_ROOT = $User_Defaults.AZSTools_Location

if (!$User_Defaults.VMuser)
    {
       Write-Warning "VMuser is not set in $defaultsfile. Please add entry and retry" 
       Break 
    }
$Global:VMUser= $User_Defaults.VMuser


if (!$User_Defaults.VMPassword)
    {
       Write-Warning "VMpassword is not set in $defaultsfile. Please add entry and retry" 
       Break 
    }
$Global:VMPassword = $User_Defaults.VMPassword | ConvertTo-SecureString -AsPlainText -Force

if (!$azsuser_credentials)
    {
    $azsuser_credentials = Get-Credential -Message "Enter Azure User Password for $global:azsuser" -UserName $global:azsuseraccount
    }
Import-Module AzureRM.AzureStackAdmin
Import-Module "$global:AZS_MODULES_ROOT\Connect\AzureStack.Connect.psm1"
if (!$User_Defaults.ArmEndpoint)
    {
       Write-Warning "ArmEndpoint is not set in $defaultsfile. Please add entry and retry" 
       Break 
    }
$Global:ArmEndpoint = $User_Defaults.ArmEndpoint
if (!$User_Defaults.GraphAudience)
    {
       Write-Warning "GraphAudience is not set in $defaultsfile. Please add entry and retry" 
       Break 
    }
$Global:GraphAudience = $User_Defaults.GraphAudience
if (!$User_Defaults.StackIP)
    {
       Write-Warning "StackIP is not set in $defaultsfile. Please add entry and retry" 
       Break 
    }
$Global:StackIP = $User_Defaults.StackIP
if (!$User_Defaults.location)
    {
       Write-Warning "VMpassword is not set in $defaultsfile. Please add entry and retry" 
       Break 
    }
$Global:AZS_Location = $User_Defaults.location


######
if (!$noconnect.IsPresent)
    {
    Write-Host -ForegroundColor White "[==>]Adding Arm Endpoint $($Global:ArmEndpoint) to Environment" -NoNewline   
    Add-AzureRMEnvironment `
      -Name "AzureStackUser" `
      -ArmEndpoint $Global:ArmEndpoint |out-null
    Write-Host -ForegroundColor Green "[Done]"
    Write-Host -ForegroundColor White "[==>]Setting Graph Audience $($Global:GraphAudience)" -NoNewline  
    Set-AzureRmEnvironment `
      -Name "AzureStackUser" `
      -GraphAudience $Global:GraphAudience | Out-Null
    Write-Host -ForegroundColor Green "[Done]"
    
    Write-Host -ForegroundColor White "[==>]Getting Tenantid for $($Global:TenantName)" -NoNewline  
    $Global:TenantID = Get-AzsDirectoryTenantId `
      -AADTenantName "$Global:TenantName" `
      -EnvironmentName "AzureStackUser" 
    Write-Host -ForegroundColor Green "[Done]"
    Write-Host -ForegroundColor White "[==>]Performin Login for $($Global:azsuseraccount )" -NoNewline  
    try {
      $azsuser_RM_Account = Login-AzureRmAccount `
      -EnvironmentName "AzureStackUser" `
      -TenantId $Global:TenantID `
      -Credential $azsuser_credentials `
      -ErrorAction SilentlyContinue
        }
    catch {
      Write-Host "Could not Login with $($Global:azsuser)
      Maybe not connected to Stack or wrong password ?"  
      break      
    }
    Write-Host -ForegroundColor Green "[Done]"

    $global:azsuser_credentials  = $azsuser_credentials
    $Global:azsuser_RM_Account = $azsuser_RM_Account
    }
