// main.bicep
// Demo template: deploys a Storage Account
// This is the "source of truth" - same idea as your az104-disk5 lab, just a different resource type

param location string = resourceGroup().location
param storageAccountNamePrefix string = 'demostor'
param skuName string = 'Standard_GRS'

// Generates a unique name so re-running this doesn't clash with an existing storage account
var storageAccountName = '${storageAccountNamePrefix}${uniqueString(resourceGroup().id)}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: skuName
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
  }
}

output storageAccountName string = storageAccount.name
output storageAccountId string = storageAccount.id
