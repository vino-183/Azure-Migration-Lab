[CmdletBinding(
    SupportsShouldProcess = $true,
    ConfirmImpact = 'High'
)]
param()

# Import common modules
. "$PSScriptRoot\..\Common\AzureHelpers.ps1"
. "$PSScriptRoot\..\Common\01-Global-Variables.ps1"
. "$PSScriptRoot\..\Common\02-VM-Variables.ps1"
. "$PSScriptRoot\..\Common\03-Network-Variables.ps1"

function Remove-VMResources {
    param(
        [string]$vmName
    )

    Write-LabLog "Starting cleanup for VM '$vmName'..." -Level INFO

    # Get VM object safely
    $vm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $vmName -ErrorAction SilentlyContinue
    if (-not $vm) {
        Write-LabLog "VM '$vmName' not found. Skipping." -Level WARN
        return
    }

    # Remove VM
    if ($PSCmdlet.ShouldProcess($vmName, "Delete Virtual Machine")) {
        try {
            Remove-AzVM -ResourceGroupName $ResourceGroupName -Name $vmName -Force
            Write-LabLog "VM '$vmName' deletion initiated." -Level INFO
        }
        catch {
            Write-LabLog "Failed to delete VM '$vmName': $($_.Exception.Message)" -Level ERROR
            return
        }
    }

    # Wait until VM is fully deleted
    do {
        Start-Sleep -Seconds 5
        $vmCheck = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $vmName -ErrorAction SilentlyContinue
    } until (-not $vmCheck)

    # Remove OS Disk
    $osDiskName = $vm.StorageProfile.OsDisk.Name
    if ($PSCmdlet.ShouldProcess($osDiskName, "Delete OS Disk")) {
        try {
            Remove-AzDisk -ResourceGroupName $ResourceGroupName -Name $osDiskName -Force
            Write-LabLog "OS Disk '$osDiskName' removed." -Level INFO
        }
        catch {
            Write-LabLog "Failed to remove OS Disk '$osDiskName': $($_.Exception.Message)" -Level ERROR
        }
    }

    # Remove Data Disks (future-proof)
    foreach ($disk in $vm.StorageProfile.DataDisks) {
        if ($PSCmdlet.ShouldProcess($disk.Name, "Delete Data Disk")) {
            try {
                Remove-AzDisk -ResourceGroupName $ResourceGroupName -Name $disk.Name -Force
                Write-LabLog "Data Disk '$($disk.Name)' removed." -Level INFO
            }
            catch {
                Write-LabLog "Failed to remove Data Disk '$($disk.Name)': $($_.Exception.Message)" -Level ERROR
            }
        }
    }

    # Get NIC
    $nic = Get-AzNetworkInterface -ResourceGroupName $ResourceGroupName | Where-Object { $_.VirtualMachine.Id -match $vmName }
    if ($nic) {
        # Public IP check
        if ($nic.IpConfigurations.PublicIpAddress) {
            $pipId = $nic.IpConfigurations.PublicIpAddress.Id
            $pip = Get-AzPublicIpAddress -ResourceGroupName $ResourceGroupName | Where-Object { $_.Id -eq $pipId }
            if ($pip -and $PSCmdlet.ShouldProcess($pip.Name, "Delete Public IP")) {
                try {
                    Remove-AzPublicIpAddress -ResourceGroupName $ResourceGroupName -Name $pip.Name -Force
                    Write-LabLog "Public IP '$($pip.Name)' removed." -Level INFO
                }
                catch {
                    Write-LabLog "Failed to remove Public IP '$($pip.Name)': $($_.Exception.Message)" -Level ERROR
                }
            }
        }

        # Remove NIC itself
        if ($PSCmdlet.ShouldProcess($nic.Name, "Delete NIC")) {
            try {
                Remove-AzNetworkInterface -ResourceGroupName $ResourceGroupName -Name $nic.Name -Force
                Write-LabLog "NIC '$($nic.Name)' removed." -Level INFO
            }
            catch {
                Write-LabLog "Failed to remove NIC '$($nic.Name)': $($_.Exception.Message)" -Level ERROR
            }
        }
    }

    # Verification
    if (-not(Get-AzVM -ResourceGroupName $ResourceGroupName -Name $vmName -ErrorAction SilentlyContinue)) {
        Write-LabLog "Verified: VM '$vmName' deleted." -Level SUCCESS
    }
    else {
        Write-LabLog "Verification failed: VM '$vmName' still exists." -Level ERROR
    }
}

# --- Delete WebVM ---
Remove-VMResources -vmName $WebVMName

# --- Delete SqlVM ---
Remove-VMResources -vmName $SqlVMName

Write-LabLog "Cleanup completed for WebVM and SqlVM." -Level SUCCESS
