<#
================================================================================
Script:     Logging.ps1
Purpose:    Common logging functions for Azure Migration Lab
Author:     Vinodh Azure Migration Lab
Version:    1.0.0
================================================================================
#>

function Write-LabLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [ValidateSet("INFO","WARNING","ERROR","SUCCESS")]
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    switch ($Level) {
        "INFO"    { $color = "Cyan" }
        "WARNING" { $color = "Yellow" }
        "ERROR"   { $color = "Red" }
        "SUCCESS" { $color = "Green" }
    }

    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
}