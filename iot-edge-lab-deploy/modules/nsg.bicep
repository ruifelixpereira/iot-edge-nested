@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the network security group')
param nsgName string

@description('Layer 4 subnet address prefix')
param layer4SubnetPrefix string = '10.0.4.0/24'

@description('Layer 3 subnet address prefix')
param layer3SubnetPrefix string = '10.0.3.0/24'

@description('Layer 2 subnet address prefix')
param layer2SubnetPrefix string = '10.0.2.0/24'


resource nsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'ParentChildREST'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: layer2SubnetPrefix
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
      {
        name: 'ParentChildAMQP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '5671'
          sourceAddressPrefix: layer2SubnetPrefix
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
        }
      }
      {
        name: 'ParentChildMQTT'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '8883'
          sourceAddressPrefix: layer2SubnetPrefix
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 140
          direction: 'Inbound'
        }
      }
      {
        name: 'DenyParentChildREST'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 220
          direction: 'Inbound'
        }
      }
      {
        name: 'DenyParentChildAMQP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '5671'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 230
          direction: 'Inbound'
        }
      }
      {
        name: 'DenyParentChildMQTT'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '8883'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 240
          direction: 'Inbound'
        }
      }
      {
        name: 'default-allow-22'
        properties: {
          priority: 110
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '22'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

output networkSecurityGroupId string = nsg.id
