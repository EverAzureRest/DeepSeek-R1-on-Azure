param location string
param vmSku string
param subnetId string
param sshKeyPath string
param vmUsername string

var cloudInit = base64(loadTextContent('./cloud-init.yml'))

resource vm 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: 'DeepSeek-Host'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSku
    }
    osProfile: {
      computerName: 'DeepSeek-Host'
      adminUsername: vmUsername
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: sshKeyPath
            }
          ]
        }
      }
      customData: cloudInit
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '22.04-LTS'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        diskSizeGB: 1023
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: subnetId
        }
      ]
    }
  }
}

resource nvidiaGPUDriver 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = {
  name: 'NvidiaGPUDriver'
  parent: vm
  location: location
  properties: {
    publisher: 'Microsoft.HPCPack'
    type: 'NvidiaGPUDriver'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    settings: {
      gpuDriverVersion: '535.54'
    }
  }
}
