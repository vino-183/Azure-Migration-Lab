# Import the logging module
. "$PSScriptRoot\..\Common\Logging.ps1"

Write-LabLog -Message "Azure Migration Lab has started."
Write-LabLog -Message "Creating Resource Group..." -Level INFO
Write-LabLog -Message "Storage Account already exists." -Level WARNING
Write-LabLog -Message "Resource Group created successfully." -Level SUCCESS
Write-LabLog -Message "Failed to create Virtual Network." -Level ERROR
