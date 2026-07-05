#---------------------------------------------------------
# Virtual Network
#---------------------------------------------------------
$VNetName = "$Prefix-vnet"
$VNetAddressSpace = "10.10.0.0/16"

#---------------------------------------------------------
# Subnets
#---------------------------------------------------------
$WebSubnetName = "snet-web"
$WebSubnetAddressPrefix = "10.10.1.0/24"

$BackendSubnetName = "snet-backend"
$BackendSubnetAddressPrefix = "10.10.2.0/24"

$BastionSubnetName = "AzureBastionSubnet"
$BastionSubnetAddressPrefix = "10.10.3.0/26"

#---------------------------------------------------------
# Network Security Groups
#---------------------------------------------------------
$WebNSGName = "$Prefix-web-nsg"
$BackendNSGName = "$Prefix-backend-nsg"

#---------------------------------------------------------
# Public IPs
#---------------------------------------------------------
$WebPublicIPName = "$Prefix-web-pip"
$BastionPublicIPName = "$Prefix-bastion-pip"

$PublicIPSku = "Standard"
$PublicIPAllocationMethod = "Static"

#---------------------------------------------------------
# Bastion
#---------------------------------------------------------
$BastionName = "$Prefix-bastion"
$BastionSku = "Standard"

$WebNicName          = "web-vm-nic"