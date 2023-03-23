// Bicep Module for the creation of a Backend Storage for the Synapse Workspace

@description("")
param storageAccountName string

@description("")
param storageAccountKind string = 'StorageV2'

@description("")
param storageAccountSku string = 'Standard_LRS'

@description("")
param minimumTlsVersion string = 'TLS1_2'

@description('Optional. Location for the Data Lake Store. Defaults to the ResourceGroup location')
param location string = resourceGroup().location

@description('Tags of the resources.')
param tags object = {}

resource datalakegen2 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageAccountName
  kind: storageAccountKind
  location: location
  tags: tags
  properties:{
    minimumTlsVersion: minimumTlsVersion
    isHnsEnabled: true
  }
  sku: {
    name: storageAccountSku
  }
}

resource blob 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  parent: datalakegen2
  name:  'default'
}

resource containera 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = {
  name: '${datalakegen2.name}/default/${defaultDataStorageFilesystemName}'
  properties: {
    publicAccess: 'None'
  }
} 

output StorageAccountName string = storageAccountName
output StorageAccountId string = resourceId('Microsoft.Storage/storageAccounts', storageAccountName)
output BlobContainerName string = defaultDataStorageFilesystemName
