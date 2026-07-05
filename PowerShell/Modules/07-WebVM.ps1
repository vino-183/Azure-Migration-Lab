<#
================================================================================
Script      : 08-WebVM.ps1
Purpose     : Deploys the SmartHotel Web Server virtual machine

Author      : Vino
Framework   : Azure Migration Framework
Version     : 1.2.0

Dependencies
------------
- AzureHelpers.ps1
- Constants.ps1
- 01-Global-Variables.ps1
- 02-VM-Variables.ps1
- 03-Network-Variables.ps1
#>

[CmdletBinding(SupportsShouldProcess)]
param()

# Phase 1 - Validate Prerequisites

# Import common modules
. "$PSScriptRoot\..\Common\AzureHelpers.ps1"
. "$PSScriptRoot\..\Common\01-Global-Variables.ps1"
. "$PSScriptRoot\..\Common\02-VM-Variables.ps1"
. "$PSScriptRoot\..\Common\03-Network-Variables.ps1"

if (-not (Test-LabPrerequisites)) {
    Write-LabLog "Prerequisite validation failed." -Level ERROR
    return
}

Write-LabLog "Starting Web VM deployment..."

# Phase 2 - Verify Dependencies
Write-LabLog "=== Phase 2: Verifying Dependencies ===" -Level INFO

$resourceGroup = Test-ResourceGroupIfExists -ResourceGroupName $ResourceGroupName
if (-not $resourceGroup) {
    Write-LabLog "Resource Group '$ResourceGroupName' not found." -Level ERROR
    return
}
Write-LabLog "Resource Group '$ResourceGroupName' found." -Level SUCCESS

# Phase 3 - Create/Retrieve Web VM
Write-LabLog "=== Phase 3: Create/Retrieve Web VM ===" -Level INFO

$WebVM = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $WebVMName -ErrorAction SilentlyContinue

if ($WebVM) {
    Write-LabLog "VM '$WebVMName' already exists." -Level SUCCESS
}
else {
    Write-LabLog "VM '$WebVMName' not found. Creating new VM..." -Level INFO

    # Validate VNet and Subnet
    $vnet   = Get-AzVirtualNetwork -Name $VNetName -ResourceGroupName $ResourceGroupName -ErrorAction Stop
    $subnet = $vnet.Subnets | Where-Object { $_.Name -eq $WebSubnetName }
    if (-not $subnet) { Write-LabLog "Subnet '$WebSubnetName' not found in VNet '$VNetName'." -Level ERROR; return }

    # Validate NSG
    $webNsg = Get-AzNetworkSecurityGroup -Name $WebNsgName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
    if (-not $webNsg) { Write-LabLog "NSG '$WebNsgName' not found." -Level ERROR; return }

    # Validate NIC
    $webNic = Get-AzNetworkInterface -Name $WebNicName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
    if (-not $webNic) {
        Write-LabLog "Creating Network Interface '$WebNicName'..." -Level INFO
        $webNic = New-AzNetworkInterface -Name $WebNicName -ResourceGroupName $ResourceGroupName -Location $Location `
            -SubnetId $subnet.Id -NetworkSecurityGroupId $webNsg.Id -PublicIpAddressId $webPip.Id -ErrorAction Stop
    }
    else {
        Write-LabLog "Network Interface '$WebNicName' already exists." -Level SUCCESS
    }

    # Prompt for credentials

    if ($PSCmdlet.ShouldProcess($WebVMName, "Create Azure Virtual Machine configuration"))
{
    Write-LabLog "Prompting for local administrator credentials..." -Level INFO
    $Credential = Get-Credential -UserName $WebVMAdminUsername

    # Build VM configuration
    $vmConfig = New-AzVMConfig -VMName $WebVMName -VMSize $WebVMSize | `
        Set-AzVMOperatingSystem -Windows -ComputerName $WebComputerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate | `
        Set-AzVMSourceImage -PublisherName $WebVMImagePublisher -Offer $WebVMImageOffer -Skus $WebVMImageSku -Version "latest" | `
        Add-AzVMNetworkInterface -Id $webNic.Id
}
    # Create VM
    Write-LabLog "Creating VM '$WebVMName'..." -Level INFO
    try {
        if ($PSCmdlet.ShouldProcess($WebVMName, "Create Azure Virtual Machine")) {
            $WebVM = New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $vmConfig -ErrorAction Stop
        }
        Write-LabLog "VM '$WebVMName' created successfully." -Level SUCCESS
    }
    catch {
        Write-LabLog $_.Exception.Message -Level ERROR
        throw
    }
}

# Phase 4 - Deployment Verification
Write-LabLog "=== Phase 4: Verifying Web VM Deployment ===" -Level INFO

if (-not $WebVM) {
    Write-LabLog "Web VM does not exist. Verification skipped." -Level WARNING
    Write-LabLog "Deployment was executed in WhatIf mode. No resources were created." -Level INFO
    return
}

$vmStatus = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $WebVMName -Status
Write-LabLog "VM '$WebVMName' provisioning state: $($vmStatus.ProvisioningState)" -Level INFO
Write-LabLog "VM '$WebVMName' power state: $($vmStatus.Statuses | Where-Object { $_.Code -like 'PowerState/*' } | Select-Object -ExpandProperty DisplayStatus)" -Level INFO

# Phase 5 - Completion Logging
Write-LabLog "Web VM deployment completed." -Level SUCCESS

# Phase 6 - Deployment Summary
Write-LabLog "=== Deployment Summary ===" -Level INFO
Write-LabLog "VM Name        : $WebVMName"
Write-LabLog "VM Size        : $WebVMSize"
Write-LabLog "NIC Name       : $WebNicName"
Write-LabLog "Subnet Name    : $WebSubnetName"
Write-LabLog "Image Publisher: $WebVMImagePublisher"
Write-LabLog "Image Offer    : $WebVMImageOffer"
Write-LabLog "Image SKU      : $WebVMImageSku"
Write-LabLog "Admin Username : $WebVMAdminUsername"
Write-LabLog "Computer Name  : $WebComputerName"

