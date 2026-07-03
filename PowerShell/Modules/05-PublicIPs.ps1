<#
================================================================================
Script:     05-PublicIPs.ps1
Purpose:    Creates Public IP resources for the Azure Migration Lab
================================================================================
#>

[CmdletBinding(SupportsShouldProcess)]
param()

# Import common modules

. "$PSScriptRoot\..\Common\Logging.ps1"
. "$PSScriptRoot\..\Common\Validation.ps1"
. "$PSScriptRoot\..\Common\01-Variables.ps1"

Write-LabLog "Starting Public IP deployment..."

# Phase 1 - Validate prerequisites

if(-not (Test-LabPrerequisites)) {
    Write-LabLog "Prerequisite validation failed." -Level ERROR
    return
}

# Phase 2 - Verify Resource Group

Write-LabLog "Verifying Resource Group '$ResourceGroupName'..."

$resourceGroup = Get-AzResourceGroup `
    -Name $ResourceGroupName `
    -ErrorAction SilentlyContinue

if ($null -eq $resourceGroup) {
    Write-LabLog "Resource Group '$ResourceGroupName' was not found." -Level ERROR
    return
}

Write-LabLog "Resource Group '$ResourceGroupName' found." -Level SUCCESS

# Phase 3 - Create/Get Bastion Public IP

    # check whether the public IP already exists

    $BastionPublicIP = Get-AzPublicIpAddress `
    -ResourceGroupName $ResourceGroupName `
    -Name $BastionPublicIPName `
    -ErrorAction SilentlyContinue

    if (-not $BastionPublicIP) {
        Write-LabLog "Checking if Public IP '$BastionPublicIPName' exists..."

Write-LabLog "Public IP '$BastionPublicIPName' not found."

Write-LabLog "Creating Public IP '$BastionPublicIPName'..."
    
    # if not found -shouldprocess - create the public IP -save the object in memory

        if ($PSCmdlet.ShouldProcess($BastionPublicIPName, "Create Bastion Public IP")) {

            $BastionPublicIP = New-AzPublicIpAddress `
                -ResourceGroupName $ResourceGroupName `
                -Location $Location `
                -Name $BastionPublicIPName `
                -Sku $PublicIPSku `
                -AllocationMethod $PublicIPAllocationMethod `
                -Tag $Tags

            Write-LabLog "Public IP '$BastionPublicIPName' created successfully." -Level SUCCESS
        }
    }
    # if found - log a warning and save the object in memory
    else {
        Write-LabLog "Public IP '$BastionPublicIPName' already exists." -Level WARNING
    }

# Phase 4 - Deployment Verification

    Write-LabLog "Verifying Public IP '$BastionPublicIPName'..."

    $bastionPublicIP = Get-AzPublicIpAddress `
        -ResourceGroupName $ResourceGroupName `
        -Name $BastionPublicIPName `
        -ErrorAction SilentlyContinue

# Phase 5 - Completion Logging

    if ($null -eq $BastionPublicIP) {
        Write-LabLog "Public IP '$BastionPublicIPName' was not found after deployment." -Level ERROR
        return
    }

    else {
        Write-LabLog "Public IP '$BastionPublicIPName' is available for Azure Bastion deployment." -Level SUCCESS
    }

# Phase 6 - Deployment Summary

Write-Host "========================================================="
Write-Host "Deployment Summary - Bastion Public IP"
Write-Host "========================================================="
Write-Host ("Name                : {0}" -f $BastionPublicIP.Name)
Write-Host ("Resource Group      : {0}" -f $BastionPublicIP.ResourceGroupName)
Write-Host ("Location            : {0}" -f $BastionPublicIP.Location)
Write-Host ("SKU                 : {0}" -f $BastionPublicIP.Sku.Name)
Write-Host ("Allocation Method   : {0}" -f $BastionPublicIP.PublicIpAllocationMethod)
Write-Host ("IP Address          : {0}" -f $BastionPublicIP.IpAddress)
Write-Host ("Provisioning State  : {0}" -f $BastionPublicIP.ProvisioningState)
Write-Host "========================================================="
