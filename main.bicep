// main.bicep
// Demo template: deploys a Storage Account and a Virtual Network
// This is the "source of truth" - same idea as your az104-disk5 lab, just different resource types

param location string = resourceGroup().location
param storageAccountNamePrefix string = 'demostor'
param skuName string = 'Standard_GRS'
param vnetName string = 'demo-vnet'
param vnetAddressPrefix string = '10.0.0.0/16'
param subnetName string = 'demo-subnet'
param subnetAddressPrefix string = '10.0.1.0/24'

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

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressPrefix
        }
      }
    ]
  }
}

output storageAccountName string = storageAccount.name
output storageAccountId string = storageAccount.id
output vnetName string = vnet.name
output vnetId string = vnet.id
