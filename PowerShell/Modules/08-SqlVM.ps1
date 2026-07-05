<#
================================================================================
Script      : 08-SqlVM.ps1
Purpose     : Deploys the SmartHotel SQL Server virtual machine

Author      : Vino
Framework   : Azure Migration Framework
Version     : 1.2.0

Dependencies
------------
- AzureHelpers.ps1
- 01-Global-Variables.ps1
- 02-VM-Variables.ps1
- 03-Network-Variables.ps1
#>

#-----------------------------------------------------------
# Phase 0 - Design Discussion
#-----------------------------------------------------------      

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

Write-LabLog "Starting SQL VM deployment..."

# Phase 2 - Verify Dependencies
Write-LabLog "=== Phase 2: Verifying Dependencies ===" -Level INFO

$resourceGroup = Test-ResourceGroupIfExists -ResourceGroupName $ResourceGroupName
if (-not $resourceGroup) {
    Write-LabLog "Resource Group '$ResourceGroupName' not found." -Level ERROR
    return
}
Write-LabLog "Resource Group '$ResourceGroupName' found." -Level SUCCESS

# Phase 3 - Create/Retrieve SQL VM
Write-LabLog "=== Phase 3: Create/Retrieve SQL VM ===" -Level INFO

$SqlVM = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $SqlVMName -ErrorAction SilentlyContinue

if ($SqlVM) {
    Write-LabLog "VM '$SqlVMName' already exists." -Level SUCCESS
}
else {
    Write-LabLog "VM '$SqlVMName' not found. Creating new VM..." -Level INFO

    # Validate VNet and Subnet
    $vnet   = Get-AzVirtualNetwork -Name $VNetName -ResourceGroupName $ResourceGroupName -ErrorAction Stop
    $subnet = $vnet.Subnets | Where-Object { $_.Name -eq $BackendSubnetName }
    if (-not $subnet) { Write-LabLog "Subnet '$BackendSubnetName' not found in VNet '$VNetName'." -Level ERROR; return }

    # Validate NSG
    $sqlNsg = Get-AzNetworkSecurityGroup -Name $BackendNSGName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
    if (-not $sqlNsg) { Write-LabLog "NSG '$BackendNSGName' not found." -Level ERROR; return }

    # Validate NIC
    $sqlNic = Get-AzNetworkInterface -Name $SqlNicName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
    if (-not $sqlNic) {
        Write-LabLog "Creating Network Interface '$SqlNicName'..." -Level INFO
        $sqlNic = New-AzNetworkInterface -Name $SqlNicName -ResourceGroupName $ResourceGroupName -Location $Location `
            -SubnetId $subnet.Id -NetworkSecurityGroupId $sqlNsg.Id -PublicIpAddressId $sqlPip.Id -ErrorAction Stop
    }
    else {
        Write-LabLog "Network Interface '$SqlNicName' already exists." -Level SUCCESS
    }

    # Prompt for credentials

    if ($PSCmdlet.ShouldProcess($SqlVMName, "Create Azure Virtual Machine configuration"))
{
    Write-LabLog "Prompting for local administrator credentials..." -Level INFO
    $Credential = Get-Credential -UserName $SqlVMAdminUsername

    # Build VM configuration
    $vmConfig = New-AzVMConfig -VMName $SqlVMName -VMSize $SqlVMSize | `
        Set-AzVMOperatingSystem -Windows -ComputerName $SqlComputerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate | `
        Set-AzVMSourceImage -PublisherName $SqlVMImagePublisher -Offer $SqlVMImageOffer -Skus $SqlVMImageSku -Version "latest" | `
        Add-AzVMNetworkInterface -Id $sqlNic.Id
}
    # Create VM
    Write-LabLog "Creating VM '$SqlVMName'..." -Level INFO
    try {
        if ($PSCmdlet.ShouldProcess($SqlVMName, "Create Azure Virtual Machine")) {
            $SqlVM = New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $vmConfig -ErrorAction Stop
        }
        Write-LabLog "VM '$SqlVMName' created successfully." -Level SUCCESS
    }
    catch {
        Write-LabLog $_.Exception.Message -Level ERROR
        throw
    }
}


# Phase 4 - Deployment Verification
Write-LabLog "=== Phase 4: Verifying SQL VM Deployment ===" -Level INFO

if (-not $SqlVM) {
    Write-LabLog "SQL VM does not exist. Verification skipped." -Level WARNING
    Write-LabLog "Deployment was executed in WhatIf mode. No resources were created." -Level INFO
    return
}

$vmStatus = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $SqlVMName -Status
Write-LabLog "VM '$SqlVMName' provisioning state: $($vmStatus.ProvisioningState)" -Level INFO

# Phase 5 - Completion Logging
Write-LabLog "SQL VM deployment completed." -Level SUCCESS

# Phase 6 - Deployment Summary
Write-LabLog "=== Deployment Summary ===" -Level INFO
Write-LabLog "VM Name        : $SqlVMName"
Write-LabLog "VM Size        : $SqlVMSize"
Write-LabLog "NIC Name       : $SqlNicName"
Write-LabLog "Subnet Name    : $$BackendSubnetName"
Write-LabLog "Image Publisher: $SqlVMImagePublisher"
Write-LabLog "Image Offer    : $SqlVMImageOffer"
Write-LabLog "Image SKU      : $SqlVMImageSku"
Write-LabLog "Admin Username : $SqlVMAdminUsername"
Write-LabLog "Computer Name  : $SqlVMComputerName"
Write-LabLog "Location       : $Location"
Write-LabLog "Resource Group Name : $ResourceGroupName"
Write-LabLog "VNet Name      : $vnet.Name"