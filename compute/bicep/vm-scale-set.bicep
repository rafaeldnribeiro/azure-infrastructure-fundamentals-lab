@description('Location for all VMSS resources.')
param location string = resourceGroup().location

@description('Name of the Virtual Machine Scale Set.')
param vmssName string = 'vmss-workload-lab'

@description('VM size for scale set instances.')
param vmSku string = 'Standard_B1s'

@description('Initial instance count for the scale set.')
@minValue(1)
@maxValue(10)
param instanceCount int = 2

@description('Administrator username for VMSS Linux instances.')
param adminUsername string = 'azureuser'

@description('SSH public key for Linux VMSS authentication.')
@secure()
param adminSshPublicKey string

@description('Name of the existing Virtual Network.')
param vnetName string = 'vnet-core-lab'

@description('Name of the existing subnet to connect the scale set private NICs.')
param subnetName string = 'snet-workload'

@description('Resource tags applied to VMSS resources.')
param tags object = {
  environment: 'learning'
  project: 'azure-fundamentals-lab'
  owner: 'rafael-support-lab'
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  parent: vnet
  name: subnetName
}

resource vmScaleSet 'Microsoft.Compute/virtualMachineScaleSets@2023-09-01' = {
  name: vmssName
  location: location
  tags: tags
  sku: {
    name: vmSku
    tier: 'Standard'
    capacity: instanceCount
  }
  properties: {
    upgradePolicy: {
      mode: 'Manual'
    }
    virtualMachineProfile: {
      osProfile: {
        computerNamePrefix: 'vmss-node'
        adminUsername: adminUsername
        linuxConfiguration: {
          disablePasswordAuthentication: true
          ssh: {
            publicKeys: [
              {
                path: '/home/${adminUsername}/.ssh/authorized_keys'
                keyData: adminSshPublicKey
              }
            ]
          }
        }
      }
      storageProfile: {
        imageReference: {
          publisher: 'Canonical'
          offer: '0001-com-ubuntu-server-jammy'
          sku: '22_04-lts-gen2'
          version: 'latest'
        }
        osDisk: {
          caching: 'ReadWrite'
          createOption: 'FromImage'
          managedDisk: {
            storageAccountType: 'Standard_LRS'
          }
        }
      }
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: '${vmssName}-nic'
            properties: {
              primary: true
              ipConfigurations: [
                {
                  name: 'ipconfig-private'
                  properties: {
                    subnet: {
                      id: subnet.id
                    }
                  }
                }
              ]
            }
          }
        ]
      }
    }
  }
}

output vmssId string = vmScaleSet.id
output vmssName string = vmScaleSet.name
output capacity int = instanceCount
