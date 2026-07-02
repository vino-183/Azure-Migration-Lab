<#
================================================================================
Script:     04-NetworkSecurityGroups.ps1
Purpose:    Creates Network Security Groups for the Azure Migration Lab
================================================================================
#>

[CmdletBinding(SupportsShouldProcess)]
param()

# Import common modules
. "$PSScriptRoot\..\Common\Logging.ps1"
. "$PSScriptRoot\..\Common\Validation.ps1"
. "$PSScriptRoot\..\Common\01-Variables.ps1"

Write-LabLog "Starting Network Security Group deployment..."

# Validate prerequisites
if (-not (Test-LabPrerequisites)) {
    Write-LabLog "Prerequisite validation failed." -Level ERROR
    return
}

Write-LabLog "Prerequisites passed successfully." -Level SUCCESS

#---------------------------------------------------------
# Create Web Network Security Group
#---------------------------------------------------------

Write-LabLog "Checking if Network Security Group '$WebNSGName' exists..."

$webNSG = Get-AzNetworkSecurityGroup `
    -ResourceGroupName $ResourceGroupName `
    -Name $WebNSGName `
    -ErrorAction SilentlyContinue

if ($null -eq $webNSG) {

    if ($PSCmdlet.ShouldProcess($WebNSGName, "Create Web Network Security Group")) {

        Write-LabLog "Creating Network Security Group '$WebNSGName'..."

        $webNSG = New-AzNetworkSecurityGroup `
            -ResourceGroupName $ResourceGroupName `
            -Location $Location `
            -Name $WebNSGName `
            -Tag $Tags

        Write-LabLog "Network Security Group '$WebNSGName' created successfully." -Level SUCCESS
    }

}
else {

    Write-LabLog "Network Security Group '$WebNSGName' already exists." -Level WARNING

}

# Add the HTTP Allow rule

Write-LabLog "Adding HTTP rule to '$WebNSGName'..."

$webNSG = Add-AzNetworkSecurityRuleConfig `
    -Name "Allow-HTTP" `
    -NetworkSecurityGroup $webNSG `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 100 `
    -SourceAddressPrefix Internet `
    -SourcePortRange * `
    -DestinationAddressPrefix * `
    -DestinationPortRange 80 `
    -Access Allow

# Commit the changes back to Azure
if ($PSCmdlet.ShouldProcess($WebNSGName, "Add HTTP Rule")) {

    Set-AzNetworkSecurityGroup `
        -NetworkSecurityGroup $webNSG

    Write-LabLog "HTTP rule added successfully." -Level SUCCESS
}

#---------------------------------------------------------
# Create Backend Network Security Group
#---------------------------------------------------------

Write-LabLog "Checking if Network Security Group '$BackendNSGName' exists..."

$backendNSG = Get-AzNetworkSecurityGroup `
    -ResourceGroupName $ResourceGroupName `
    -Name $BackendNSGName `
    -ErrorAction SilentlyContinue

if ($null -eq $backendNSG) {

    if ($PSCmdlet.ShouldProcess($BackendNSGName, "Create Backend Network Security Group")) {

        Write-LabLog "Creating Network Security Group '$BackendNSGName'..."

        $backendNSG = New-AzNetworkSecurityGroup `
            -ResourceGroupName $ResourceGroupName `
            -Location $Location `
            -Name $BackendNSGName `
            -Tag $Tags

        Write-LabLog "Network Security Group '$BackendNSGName' created successfully." -Level SUCCESS
    }

}
else {

    Write-LabLog "Network Security Group '$BackendNSGName' already exists." -Level WARNING

}

# Add the HTTP Allow rule

Write-LabLog "Adding Allow-SQL-From-Web rule to '$BackendNSGName'..."

$backendNSG = Add-AzNetworkSecurityRuleConfig `
    -Name "Allow-SQL-From-Web" `
    -NetworkSecurityGroup $backendNSG `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 100 `
    -SourceAddressPrefix $WebSubnetPrefix `
    -SourcePortRange * `
    -DestinationAddressPrefix * `
    -DestinationPortRange 1433 `
    -Access Allow

# Commit the changes back to Azure
if ($PSCmdlet.ShouldProcess($BackendNSGName, "Add Allow-SQL-From-Web Rule")) {

    Set-AzNetworkSecurityGroup `
        -NetworkSecurityGroup $backendNSG

    Write-LabLog "Allow-SQL-From-Web rule added successfully." -Level SUCCESS
}
#---------------------------------------------------------
#Associate Web NSG with Web Subnet
#------------------------------------------------.

    # get the subnet object for the web subnet first

$webSubnet = $vnet.Subnets |
    Where-Object Name -eq $WebSubnetName

    # associate the NSG with the subnet

Write-LabLog "Associating Network Security Group '$WebNSGName' with Subnet '$WebSubnetName'..."

$webSubnet.NetworkSecurityGroup = $webNSG


#---------------------------------------------------------
#Associate Backend NSG with Backend Subnet
#------------------------------------------------.

    # get the subnet object for the backend subnet first

$backendSubnet = $vnet.Subnets |
    Where-Object Name -eq $BackendSubnetName

Write-LabLog "Associating Network Security Group '$BackendNSGName' with Subnet '$BackendSubnetName'..."

    # associate the NSG with the subnet

$backendSubnet.NetworkSecurityGroup = $backendNSG

#---------------------------------------------------------
#Update Virtual Network
#---------------------------------------------------------
    # Commit Virtual Network changes back to Azure

if ($PSCmdlet.ShouldProcess($VNetName, "Associate Network Security Groups with Subnets")) {

    Set-AzVirtualNetwork `
        -VirtualNetwork $vnet

    Write-LabLog "Network Security Groups associated successfully." -Level SUCCESS
}
