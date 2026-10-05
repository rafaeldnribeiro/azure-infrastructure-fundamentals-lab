using 'main.bicep'

param location = 'brazilsouth'
param environment = 'lab'
param tags = {
  project: 'azure-infra-fundamentals'
  environment: 'lab'
  managedBy: 'bicep'
  purpose: 'learning'
}
