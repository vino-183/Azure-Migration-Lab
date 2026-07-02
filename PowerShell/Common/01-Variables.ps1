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
$Location = "centralindia"

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
$VNetAddressSpace = "10.10.0.0/16"

#---------------------------------------------------------
# Subnets
#---------------------------------------------------------
$WebSubnetName = "snet-web"
$WebSubnetPrefix = "10.10.1.0/24"

$BackendSubnetName = "snet-backend"
$BackendSubnetPrefix = "10.10.2.0/24"

$BastionSubnetName = "AzureBastionSubnet"
$BastionSubnetPrefix = "10.10.3.0/26"

#---------------------------------------------------------
# Network Security Groups
#---------------------------------------------------------
$WebNSGName = "$Prefix-web-nsg"
$BackendNSGName = "$Prefix-backend-nsg"

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