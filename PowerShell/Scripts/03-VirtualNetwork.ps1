<#
================================================================================
Script:     03-VirtualNetwork.ps1
Purpose:    Creates the Virtual Network and Subnets
================================================================================
#>

[CmdletBinding(SupportsShouldProcess)]
param()

# Import common modules
. "$PSScriptRoot\..\Common\Logging.ps1"
. "$PSScriptRoot\..\Common\Validation.ps1"
. "$PSScriptRoot\..\Common\01-Variables.ps1"

Write-LabLog "Starting Virtual Network deployment..."

# Validate prerequisites
if (-not (Test-LabPrerequisites)) {
    Write-LabLog "Prerequisite validation failed." -Level ERROR
    return
}

Write-LabLog "Prerequisites passed successfully." -Level SUCCESS

# Check if the Virtual Network already exists
Write-LabLog "Checking if Virtual Network '$VNetName' exists..."

$vnet = Get-AzVirtualNetwork `
    -ResourceGroupName $ResourceGroupName `
    -Name $VNetName `
    -ErrorAction SilentlyContinue

if ($null -ne $vnet) {
    Write-LabLog "Virtual Network '$VNetName' already exists." -Level WARNING
    return
}

# Verify Resource Group exists
Write-LabLog "Verifying Resource Group '$ResourceGroupName'..."

$resourceGroup = Get-AzResourceGroup `
    -Name $ResourceGroupName `
    -ErrorAction SilentlyContinue

if ($null -eq $resourceGroup) {
    Write-LabLog "Resource Group '$ResourceGroupName' was not found." -Level ERROR
    return
}

Write-LabLog "Resource Group '$ResourceGroupName' found." -Level SUCCESS

# Create subnet configuration objects
Write-LabLog "Building subnet configuration objects..."

$webSubnet = New-AzVirtualNetworkSubnetConfig `
    -Name $WebSubnetName `
    -AddressPrefix $WebSubnetPrefix

$sqlSubnet = New-AzVirtualNetworkSubnetConfig `
    -Name $SqlSubnetName `
    -AddressPrefix $SqlSubnetPrefix

$bastionSubnet = New-AzVirtualNetworkSubnetConfig `
    -Name $BastionSubnetName `
    -AddressPrefix $BastionSubnetPrefix

Write-LabLog "Subnet configuration objects created successfully." -Level SUCCESS

if ($PSCmdlet.ShouldProcess($VNetName, "Create Virtual Network")) {

    Write-LabLog "Creating Virtual Network '$VNetName'..."

    New-AzVirtualNetwork `
        -Name $VNetName `
        -ResourceGroupName $ResourceGroupName `
        -Location $Location `
        -AddressPrefix $VNetAddressSpace `
        -Subnet $webSubnet, $sqlSubnet, $bastionSubnet `
        -Tag $Tags `
        -ErrorAction Stop

    Write-LabLog "Virtual Network created successfully." -Level SUCCESS
}

if ($PSCmdlet.ShouldProcess($VNetName, "Create Virtual Network")) {

    Write-LabLog "Creating Virtual Network '$VNetName'..."

    New-AzVirtualNetwork `
        -Name $VNetName `
        -ResourceGroupName $ResourceGroupName `
        -Location $Location `
        -AddressPrefix $VNetAddressSpace `
        -Subnet $webSubnet, $sqlSubnet, $bastionSubnet `
        -Tag $Tags `
        -ErrorAction Stop

    Write-LabLog "Virtual Network '$VNetName' created successfully." -Level SUCCESS
}