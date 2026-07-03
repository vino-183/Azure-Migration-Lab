<#
================================================================================
Script:     02-ResourceGroup.ps1
Purpose:    Creates an Azure Resource Group if it does not already exist.
Author:     Vinodh Azure Migration Lab
Version:    1.0.0
================================================================================
Learning Objectives
-------------------
✓ Dot sourcing
✓ Parameter validation
✓ Azure Resource Groups
✓ Idempotent scripting
✓ Error handling
================================================================================
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$Location
)
# Import common modules
. "$PSScriptRoot\..\Common\Logging.ps1"
. "$PSScriptRoot\..\Common\Validation.ps1"
# Validate prerequisites
if (-not (Test-LabPrerequisites)) {
    Write-LabLog "Prerequisite validation failed. Deployment aborted." -Level ERROR
    exit 1
}
Write-LabLog "Checking if Resource Group '$ResourceGroupName' exists..."

$resourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue

if ($null -eq $resourceGroup) {

    if ($PSCmdlet.ShouldProcess($ResourceGroupName, "Create Resource Group")) {

        Write-LabLog "Creating Resource Group '$ResourceGroupName'..."

        try {
            New-AzResourceGroup `
                -Name $ResourceGroupName `
                -Location $Location `
                -ErrorAction Stop | Out-Null

            Write-LabLog "Resource Group created successfully." -Level SUCCESS
        }
        catch {
            Write-LabLog $_.Exception.Message -Level ERROR
            throw
        }
    }
}
else {
    Write-LabLog "Resource Group '$ResourceGroupName' already exists." -Level WARNING
}