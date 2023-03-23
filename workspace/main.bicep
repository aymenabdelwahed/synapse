// Draft - Draft - Draft
// Bicep Module for the creation of a Synapse Workspace

@description('Specifies the name of the Synapse Workspace.')
param synapseWorkSpaceName string

@description('The name of the managed Resource Group')
param managedResourceGroupName string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('sqlAdministratorLoginUser.')
param sqlAdministratorLogin string

@description('sqlAdministratorLoginPassword.')
@secure()
param sqlAdministratorLoginPassword string
param storageAccountName string
param defaultDataStorageFilesystemName string
param fileSystemName string

@description('Tags of the Synapse Workspace resource.')
param tags object = {}

var datalakeUrlFormat = 'https://{0}.dfs.core.windows.net'

resource synapseWorkspace 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name: synapseWorkSpaceName
  location: location
  tags: tags
  properties: {
    managedResourceGroupName: managedResourceGroupName
    sqlAdministratorLogin: sqlAdministratorLogin
    sqlAdministratorLoginPassword: sqlAdministratorLoginPassword
    defaultDataLakeStorage:{
      accountUrl: format(datalakeUrlFormat, datalakegen2.name)
      createManagedPrivateEndpoint: true
      filesystem: fileSystemName
      resourceId: datalakegen2.id
    }
    azureADOnlyAuthentication: true
    trustedServiceBypassEnabled: false
    publicNetworkAccess: 'Enabled'
  }
  identity:{
    type:'SystemAssigned'
  }
}

output SynapseWorkSpaceName string = synapseWorkspace.name
output SynapseWorkSpaceResourceId string = synapseWorkspace.id
output developmentEndpoint string = synapseWorkspace.properties.connectivityEndpoints.dev
output webEndpoint string = synapseWorkspace.properties.connectivityEndpoints.web
