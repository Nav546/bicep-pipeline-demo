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

// ------------------------------------------------------------
// Task 1 & 2: CoreServicesVnet + ManufacturingVnet with subnets
// ------------------------------------------------------------

resource coreServicesVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'CoreServicesVnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.20.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'SharedServicesSubnet'
        properties: {
          addressPrefix: '10.20.10.0/24'
        }
      }
      {
        name: 'DatabaseSubnet'
        properties: {
          addressPrefix: '10.20.20.0/24'
        }
      }
    ]
  }
}

resource manufacturingVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'ManufacturingVnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.30.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'SensorSubnet1'
        properties: {
          addressPrefix: '10.30.10.0/24'
          networkSecurityGroup: {
            id: sensorNsg.id
          }
        }
      }
      {
        name: 'SensorSubnet2t'
        properties: {
          addressPrefix: '10.30.21.0/24'
        }
      }
    ]
  }
}

// ------------------------------------------------------------
// Task 3: Application Security Group + Network Security Group
// ------------------------------------------------------------

resource sensorAsg 'Microsoft.Network/applicationSecurityGroups@2023-09-01' = {
  name: 'SensorVMsAsg'
  location: location
}

resource sensorNsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: 'SensorSubnet1Nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-Web-Inbound-ASG'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: [
            '80'
            '443'
          ]
          sourceAddressPrefix: '*'
          destinationApplicationSecurityGroups: [
            {
              id: sensorAsg.id
            }
          ]
        }
      }
      {
        name: 'Deny-Internet-Outbound'
        properties: {
          priority: 4096
          direction: 'Outbound'
          access: 'Deny'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
        }
      }
    ]
  }
}
