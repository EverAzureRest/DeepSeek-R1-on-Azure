targetScope = 'subscription'
//parameter block
param computeResourceGroupName string
param networkResourceGroupName string
@allowed([
  'Standard_NC80adi_H100_v5'
  'Standard_NC24'
  'Standard_NC24r'
  ])
param vmSku string
param location string
param vmSShKeyPath string = '~/.ssh/id_rsa.pub'
param vmUsername string

//resource block

resource computeResourceGroup 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: computeResourceGroupName
  location: location
}

resource networkResourceGroup 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: networkResourceGroupName
  location: location
}

module network './network.bicep' = {
  name: 'network'
  scope: networkResourceGroup
  params: {
    location: location
  }
}

module compute './compute.bicep' = {
  name: 'compute'
  scope: computeResourceGroup
  params: {
    location: location
    vmSku: vmSku
    subnetId: network.outputs.VMsubnetID
    sshKeyPath: vmSShKeyPath
    vmUsername: vmUsername
  }
}
