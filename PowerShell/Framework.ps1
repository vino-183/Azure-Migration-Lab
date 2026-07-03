# Framework.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Load common libraries
. "$PSScriptRoot\PowerShell\Common\AzureHelpers.ps1"
. "$PSScriptRoot\PowerShell\Common\01-Variables.ps1"

Write-LabLog -Message "Azure Migration Framework initialized." -Level INFO