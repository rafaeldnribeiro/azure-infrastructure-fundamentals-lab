targetScope = 'resourceGroup'

@description('Azure region for all resources in this deployment')
param location string = 'brazilsouth'

@description('Deployment environment identifier')
param environment string = 'lab'

@description('Standard governance and cost allocation tags')
param tags object = {
  project: 'azure-infra-fundamentals'
  environment: 'lab'
  managedBy: 'bicep'
  purpose: 'learning'
}

// Deploy Network Infrastructure Module
module network 'network.bicep' = {
  name: 'networkDeployment'
  params: {
    location: location
    tags: tags
  }
}

// Outputs for verification and pipeline integration
output deployedEnvironment string = environment
output deployedLocation string = location
output vnetName string = network.outputs.vnetName
output vnetId string = network.outputs.vnetId
output managementSubnetId string = network.outputs.managementSubnetId
output workloadSubnetId string = network.outputs.workloadSubnetId
output managementNsgId string = network.outputs.managementNsgId
output workloadNsgId string = network.outputs.workloadNsgId
