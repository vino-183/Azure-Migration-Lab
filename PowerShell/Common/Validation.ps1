<#
================================================================================
Script:     Validation.ps1
Purpose:    Common validation functions
Version:    1.0.0
================================================================================
#>

function Test-LabPrerequisites {

    [CmdletBinding()]
    param()

    Write-LabLog "Validating prerequisites..."

    # Verify Az PowerShell module
    try {
        if (-not (Get-Module -Name Az)) {
    Import-Module Az -ErrorAction Stop
}

Write-LabLog "Az PowerShell module loaded successfully." -Level SUCCESS
    }
    catch {
        Write-LabLog "Unable to load the Az PowerShell module." -Level ERROR
        return $false
    }

    # Verify Azure Login
    try {
        Get-AzContext -ErrorAction Stop | Out-Null
        Write-LabLog "Azure authentication verified." -Level SUCCESS
    }
    catch {
        Write-LabLog "You are not connected to Azure." -Level ERROR
        return $false
    }

    return $true
}