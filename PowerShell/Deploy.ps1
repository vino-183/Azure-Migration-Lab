. "$PSScriptRoot\Framework.ps1"

Write-Step "Azure Migration Framework Deployment"

$modules = Get-ChildItem `
    -Path "$PSScriptRoot\PowerShell\Modules" `
    -Filter "*.ps1" |
    Sort-Object Name

foreach ($module in $modules) {

    try {
        & $module.FullName
    }
    catch {

        Write-LabLog `
            -Message "Deployment failed in $module" `
            -Level ERROR

        throw
    }
}