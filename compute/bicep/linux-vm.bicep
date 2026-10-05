@description('Location for all compute resources.')
param location string = resourceGroup().location

@description('Name of the Virtual Machine.')
param vmName string = 'vm-workload-01'

@description('VM size for educational compute workload.')
param vmSize string = 'Standard_B1s'

@description('Administrator username for the Linux VM.')
param adminUsername string = 'azureuser'

@description('SSH public key for Linux authentication.')
@secure()
param adminSshPublicKey string

@description('Name of the existing Virtual Network.')
param vnetName string = 'vnet-core-lab'

@description('Name of the existing subnet to connect the private NIC.')
param subnetName string = 'snet-workload'

@description('Resource tags applied to compute resources.')
param tags object = {
  environment: 'learning'
  project: 'azure-fundamentals-lab'
  owner: 'rafael-support-lab'
}

// Reference to existing Virtual Network and Subnet (no public IP created)
resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  parent: vnet
  name: subnetName
}

// Private Network Interface Card (NIC) with Zero Public IP Ingress
resource networkInterface 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: '${vmName}-nic'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig-private'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnet.id
          }
        }
      }
    ]
  }
}

// Linux Virtual Machine Definition with Managed Disk and Key-Based SSH
resource virtualMachine 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: vmName
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
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
        name: '${vmName}-osdisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        deleteOption: 'Delete'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
  }
}

output vmId string = virtualMachine.id
output vmName string = virtualMachine.name
output privateIpAddress string = networkInterface.properties.ipConfigurations[0].properties.privateIPAddress
