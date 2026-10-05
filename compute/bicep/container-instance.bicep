@description('Location for all container instance resources.')
param location string = resourceGroup().location

@description('Name of the Container Group.')
param containerGroupName string = 'aci-educational-demo'

@description('Public demonstration container image.')
param image string = 'mcr.microsoft.com/azuredocs/aci-helloworld:latest'

@description('CPU cores allocated to the container.')
param cpuCores int = 1

@description('Memory in GB allocated to the container.')
param memoryInGb string = '1.5'

@description('TCP port exposed by the container.')
param port int = 80

@description('Resource tags applied to container resources.')
param tags object = {
  environment: 'learning'
  project: 'azure-fundamentals-lab'
  owner: 'rafael-support-lab'
}

// Educational Azure Container Instance (ACI)
// Note: Statically validated in local lab. No cloud deployment executed.
resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: containerGroupName
  location: location
  tags: tags
  properties: {
    containers: [
      {
        name: 'aci-demo-app'
        properties: {
          image: image
          resources: {
            requests: {
              cpu: cpuCores
              memoryInGB: json(memoryInGb)
            }
          }
          ports: [
            {
              port: port
              protocol: 'TCP'
            }
          ]
        }
      }
    ]
    osType: 'Linux'
    restartPolicy: 'OnFailure'
    ipAddress: {
      type: 'Public'
      ports: [
        {
          port: port
          protocol: 'TCP'
        }
      ]
      dnsNameLabel: '${containerGroupName}-${uniqueString(resourceGroup().id)}'
    }
  }
}

output containerGroupId string = containerGroup.id
output containerGroupName string = containerGroup.name
