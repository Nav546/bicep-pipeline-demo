// ============================================================
// Lab 04 - Implement Virtual Networking
// Add these resources alongside your existing storage account
// and VNet resources in main.bicep
// ============================================================

@description('Location for all resources')
param location string = resourceGroup().location

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

