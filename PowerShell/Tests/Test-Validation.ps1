# Import common modules
. "$PSScriptRoot\..\Common\Logging.ps1"
. "$PSScriptRoot\..\Common\Validation.ps1"

Write-LabLog "Starting prerequisite validation..." -Level INFO

$result = Test-LabPrerequisites

Write-Host "Result Type: $($result.GetType().FullName)"
Write-Host "Result Value:"
$result

if ($result) {
    Write-LabLog "All prerequisite checks passed." -Level SUCCESS
}
else {
    Write-LabLog "Prerequisite validation failed." -Level ERROR
}