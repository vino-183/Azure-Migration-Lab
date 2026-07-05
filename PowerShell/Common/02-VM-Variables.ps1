#---------------------------------------
# Web VM Configuration
#---------------------------------------

$WebVMName           = "web-vm"
$WebNicName          = "web-vm-nic"
$WebComputerName     = "WEB01"
$WebVMSize           = "Standard_B2s"

#---------------------------------------
# Web VM Image Info
#---------------------------------------

$ImagePublisher = "MicrosoftWindowsServer"
$ImageOffer = "WindowsServer"
$ImageSku = "2022-datacenter-azure-edition"
$ImageVersion = "latest"

#---------------------------------------
# Web VM Credentials
#---------------------------------------

$WebVMAdminUsername    = "azureadmin"

#---------------------------------------
# SQL VM configuration
#---------------------------------------

$SqlVMName           = "sql-vm"
$SqlNicName          = "sql-vm-nic"
$SqlVMComputerName     = "SQL01"
$SqlVMSize           = "Standard_B2s"

#---------------------------------------
# SQL VM Image Info
#---------------------------------------

$SqlVMImagePublisher   = "MicrosoftWindowsServer"
$SqlVMImageOffer       = "WindowsServer"
$SqlVMImageSku         = "2022-datacenter-azure-edition"

#---------------------------------------
# SQL VM Credentials
#---------------------------------------

$SqlVMAdminUsername    = "azureadmin"