<#
================================================================================
Script:     01-Variables.ps1
Purpose:    Central configuration for the Azure Migration Lab
Author:     Vinodh Azure Migration Lab
================================================================================
#>

#---------------------------------------------------------
# Azure Region
#---------------------------------------------------------
$Location = "Central India"

#---------------------------------------------------------
# Resource Group
#---------------------------------------------------------
$ResourceGroupName = "rg-smarthotel-lab"

#---------------------------------------------------------
# Naming Prefix
#---------------------------------------------------------
$Prefix = "smarthotel"

#---------------------------------------------------------
# Virtual Network
#---------------------------------------------------------
$VNetName = "$Prefix-vnet"
$AddressSpace = "10.0.0.0/16"

#---------------------------------------------------------
# Subnets
#---------------------------------------------------------
$FrontEndSubnetName = "FrontendSubnet"
$FrontEndSubnetPrefix = "10.0.1.0/24"

$BackEndSubnetName = "BackendSubnet"
$BackEndSubnetPrefix = "10.0.2.0/24"

$BastionSubnetName = "AzureBastionSubnet"
$BastionSubnetPrefix = "10.0.3.0/26"

#---------------------------------------------------------
# Network Security Groups
#---------------------------------------------------------
$WebNSGName = "$Prefix-web-nsg"
$SqlNSGName = "$Prefix-sql-nsg"

#---------------------------------------------------------
# Public IPs
#---------------------------------------------------------
$WebPublicIPName = "$Prefix-web-pip"
$BastionPublicIPName = "$Prefix-bastion-pip"

#---------------------------------------------------------
# Bastion
#---------------------------------------------------------
$BastionName = "$Prefix-bastion"

#---------------------------------------------------------
# Virtual Machines
#---------------------------------------------------------
$WebVMName = "$Prefix-web"

$SqlVMName = "$Prefix-sql"

#---------------------------------------------------------
# VM Size
# B2s keeps costs reasonable for a lab.
#---------------------------------------------------------
$VMSize = "Standard_B2s"

#---------------------------------------------------------
# Operating System
#---------------------------------------------------------
$ImagePublisher = "MicrosoftWindowsServer"
$ImageOffer = "WindowsServer"
$ImageSku = "2022-datacenter-azure-edition"
$ImageVersion = "latest"

#---------------------------------------------------------
# Administrator Credentials
# Prompted only once.
#---------------------------------------------------------
$Credential = Get-Credential -Message "Enter the local administrator account for both VMs"

#---------------------------------------------------------
# Storage Account
# Storage account names must be globally unique and
# contain only lowercase letters and numbers.
#---------------------------------------------------------
$Random = Get-Random -Minimum 1000 -Maximum 9999

$StorageAccountName = ("st" + $Prefix.Replace("-","") + $Random).ToLower()

#---------------------------------------------------------
# Recovery Services Vault
#---------------------------------------------------------
$RecoveryVaultName = "$Prefix-rsv"

#---------------------------------------------------------
# Log Analytics Workspace
#---------------------------------------------------------
$LogAnalyticsWorkspace = "$Prefix-law"

#---------------------------------------------------------
# Tags
#---------------------------------------------------------
$Tags = @{
    Environment = "Lab"
    Project     = "AzureMigration"
    Owner       = "Vinodh"
    CreatedBy   = "PowerShell"
}

#---------------------------------------------------------
# Output
#---------------------------------------------------------
Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host " Azure Migration Lab Configuration Loaded"
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "Location          : $Location"
Write-Host "Resource Group    : $ResourceGroupName"
Write-Host "VNet              : $VNetName"
Write-Host "Web VM            : $WebVMName"
Write-Host "SQL VM            : $SqlVMName"
Write-Host "Storage Account   : $StorageAccountName"
Write-Host "Recovery Vault    : $RecoveryVaultName"
Write-Host "Log Analytics     : $LogAnalyticsWorkspace"
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""