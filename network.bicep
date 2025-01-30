param location string

resource vn 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: 'myVnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.0.1.0/26'
        }
      }
      {
        name: 'VirtualMachineSubnet'
        properties: {
          addressPrefix: '10.0.2.0/24'
        }
      }
    ]
  }
}

resource pubip 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: (uniqueString(resourceGroup().id, '-pip'))
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2020-11-01' = {
  name: (uniqueString(resourceGroup().id, 'Bastion'))
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'myBastionIpConfig'
        properties: {
          subnet: {
            id: vn.properties.subnets[0].id
          }
          publicIPAddress: {
            id: pubip.id
          }
        }
      }
    ]
  }
}

output VMsubnetID string = vn.properties.subnets[1].id
