@description('Azure region for network resources')
param location string

@description('Standard resource tags')
param tags object

@description('VNet address prefix')
param vnetAddressPrefix string = '10.20.0.0/16'

@description('Management subnet prefix')
param managementSubnetPrefix string = '10.20.1.0/24'

@description('Workload subnet prefix')
param workloadSubnetPrefix string = '10.20.2.0/24'

// Network Security Group for Management Subnet
resource nsgManagement 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: 'nsg-management'
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowVNetInbound'
        properties: {
          description: 'Allow internal VNet communication for management tools'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: managementSubnetPrefix
          access: 'Allow'
          priority: 1000
          direction: 'Inbound'
        }
      }
      {
        name: 'DenyInternetInbound'
        properties: {
          description: 'Explicitly drop all direct inbound traffic from public internet'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4000
          direction: 'Inbound'
        }
      }
    ]
  }
}

// Network Security Group for Workload Subnet
resource nsgWorkload 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: 'nsg-workload'
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowManagementToWorkload'
        properties: {
          description: 'Allow management subnet traffic to workload tier'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: managementSubnetPrefix
          destinationAddressPrefix: workloadSubnetPrefix
          access: 'Allow'
          priority: 1000
          direction: 'Inbound'
        }
      }
      {
        name: 'DenyInternetInbound'
        properties: {
          description: 'Explicitly drop all direct inbound traffic from public internet'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4000
          direction: 'Inbound'
        }
      }
    ]
  }
}

// Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: 'vnet-infra-lab'
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'snet-management'
        properties: {
          addressPrefix: managementSubnetPrefix
          networkSecurityGroup: {
            id: nsgManagement.id
          }
        }
      }
      {
        name: 'snet-workload'
        properties: {
          addressPrefix: workloadSubnetPrefix
          networkSecurityGroup: {
            id: nsgWorkload.id
          }
        }
      }
    ]
  }
}

output vnetId string = vnet.id
output vnetName string = vnet.name
output managementSubnetId string = vnet.properties.subnets[0].id
output workloadSubnetId string = vnet.properties.subnets[1].id
output managementNsgId string = nsgManagement.id
output workloadNsgId string = nsgWorkload.id
