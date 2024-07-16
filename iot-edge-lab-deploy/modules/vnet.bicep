@description('Location for all resources.')
param location string = resourceGroup().location

@description('VNET name')
param virtualNetworkName string

@description('Virtual network address prefix')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Layer 4 subnet address prefix')
param layer4SubnetPrefix string = '10.0.4.0/24'

@description('Layer 3 subnet address prefix')
param layer3SubnetPrefix string = '10.0.3.0/24'

@description('Layer 2 subnet address prefix')
param layer2SubnetPrefix string = '10.0.2.0/24'

@description('Group ID of the network security group')
param networkSecurityGroupId string

// Variables
var subnetLayer4Name = 'subnet-layer4'
var subnetLayer3Name = 'subnet-layer3'
var subnetLayer2Name = 'subnet-layer2'


resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: subnetLayer4Name
        properties: {
          addressPrefix: layer4SubnetPrefix
          networkSecurityGroup: {
            id: networkSecurityGroupId
          }
        }
      }
      {
        name: subnetLayer3Name
        properties: {
          addressPrefix: layer3SubnetPrefix
          networkSecurityGroup: {
            id: networkSecurityGroupId
          }
        }
      }
      {
        name: subnetLayer2Name
        properties: {
          addressPrefix: layer2SubnetPrefix
          networkSecurityGroup: {
            id: networkSecurityGroupId
          }
        }
      }
    ]
  }
}

output vnetId string = virtualNetwork.id
