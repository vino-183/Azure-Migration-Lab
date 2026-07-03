#Phase 0 - Design Discussion

<#
================================================================================
Script:     06-AzureBastion.ps1
Purpose:    Creates Azure Bastion resources for the Azure Migration Lab
================================================================================
#>

[CmdletBinding(SupportsShouldProcess)]
param()

# Import common modules

. "$PSScriptRoot\..\Common\AzureHelpers.ps1"
. "$PSScriptRoot\..\Common\01-Variables.ps1"

Write-LabLog "Starting Azure Bastion deployment..."

#-----------------------------------------------------------
#Phase 1 - Validate Prerequisites
#-----------------------------------------------------------

if(-not (Test-LabPrerequisites)) {
    Write-LabLog "Prerequisite validation failed." -Level ERROR
    return
}

#-----------------------------------------------------------
# Phase 2 - Dependencies validation
#-----------------------------------------------------------

Write-LabLog "=== Phase 2: Verifying Dependencies ===" -Level INFO

$resourceGroup = Test-ResourceGroupIfExists -ResourceGroupName $ResourceGroupName
if (-not $resourceGroup) {
    Write-LabLog "Resource Group '$ResourceGroupName' not found." -Level ERROR
    return
}
Write-LabLog "Resource Group '$ResourceGroupName' found." -Level SUCCESS

$vnet = Test-VNetIfExists -ResourceGroupName $ResourceGroupName -VNetName $VNetName
if (-not $vnet) {
    Write-LabLog "Virtual Network '$VNetName' not found." -Level ERROR
    return
}
Write-LabLog "Virtual Network '$VNetName' found." -Level SUCCESS

$bastionSubnet = Test-SubnetIfExists -VirtualNetwork $vnet -SubnetName $BastionSubnetName
if (-not $bastionSubnet) {
    Write-LabLog "Subnet '$BastionSubnetName' not found in VNet '$VNetName'." -Level ERROR
    return
}
Write-LabLog "Subnet '$BastionSubnetName' found in VNet '$VNetName'." -Level SUCCESS

$bastionPip = Test-PublicIpIfExists -ResourceGroupName $ResourceGroupName -PublicIpName $BastionPublicIPName
if (-not $bastionPip) {
    Write-LabLog "Bastion Public IP '$BastionPublicIPName' not found. Will be created in Phase 3." -Level WARNING
} else {
    Write-LabLog "Bastion Public IP '$BastionPublicIPName' found." -Level SUCCESS
}

#-----------------------------------------------------------
#Phase 3 - Create/Get Azure Bastion
#-----------------------------------------------------------

Write-LabLog "=== Phase 3: Creating or Retrieving Azure Bastion ===" -Level INFO

$bastion = Get-AzBastion -Name $BastionName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue

if (-not $bastion) {

    if ($PSCmdlet.ShouldProcess($BastionName, "Create Azure Bastion")) {

        Write-LabLog -Message "Azure Bastion '$BastionName' not found. Creating..." -Level WARNING

        $bastion = New-AzBastion `
            -ResourceGroupName $ResourceGroupName `
            -Name $BastionName `
            -PublicIpAddress $bastionPip `
            -VirtualNetwork $vnet `
            -Location $Location `
            -Sku $BastionSku

        Write-LabLog -Message "Azure Bastion '$BastionName' created successfully." -Level SUCCESS
    }
}
else {
    Write-LabLog -Message "Azure Bastion '$BastionName' already exists." -Level SUCCESS
}

#-----------------------------------------------------------
#Phase 4 - Deployment Verification
#-----------------------------------------------------------

Write-LabLog "=== Phase 4: Verifying Azure Bastion Deployment ===" -Level INFO

if (-not $bastion) {

    Write-LabLog `
        -Message "Azure Bastion does not exist. Verification skipped." `
        -Level WARNING

    Write-LabLog `
        -Message "Deployment was executed in WhatIf mode. No resources were created." `
        -Level INFO

    return
}
#Phase 5 - Completion Logging

Write-LabLog "=== Phase 5: Completion Logging ===" -Level INFO

if ($bastion.ProvisioningState -eq "Succeeded") {
    Write-LabLog "Azure Bastion '$BastionName' deployment succeeded." -Level SUCCESS
} else {
    Write-LabLog "Azure Bastion '$BastionName' provisioning state: $($bastion.ProvisioningState)" -Level ERROR
    return
}

#-----------------------------------------------------------
#Phase 6 - Deployment Summary
#-----------------------------------------------------------
if ($bastion) {
Write-LabLog ("Name : {0}" -f $bastionPip.Name)

Write-LabLog "=========================================================" -Level INFO
Write-LabLog "Deployment Summary - Bastion Public IP" -Level INFO
Write-LabLog "=========================================================" -Level INFO

Write-LabLog ("Name                : {0}" -f $bastionPip.Name) -Level INFO
Write-LabLog ("Resource Group      : {0}" -f $bastionPip.ResourceGroupName) -Level INFO
Write-LabLog ("Location            : {0}" -f $bastionPip.Location) -Level INFO
Write-LabLog ("SKU                 : {0}" -f $bastionPip.Sku.Name) -Level INFO
Write-LabLog ("Virtual Network     : {0}" -f $bastionPip.VirtualNetwork) -Level INFO
Write-LabLog ("Public IP Address   : {0}" -f $bastionPip.IpAddress) -Level INFO
Write-LabLog ("Provisioning State  : {0}" -f $bastionPip.ProvisioningState) -Level INFO

Write-LabLog "=========================================================" -Level INFO
}