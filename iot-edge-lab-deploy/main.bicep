// Execute this main file to configure nested IoT Edge lab.

// Parameters
@minLength(2)
@maxLength(10)
@description('Prefix for all resource names.')
param prefix string

@description('Azure region used for the deployment of all resources.')
param location string = resourceGroup().location

@description('Virtual network address prefix')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Layer 4 subnet address prefix')
param layer4SubnetPrefix string = '10.0.4.0/24'

@description('Layer 3 subnet address prefix')
param layer3SubnetPrefix string = '10.0.3.0/24'

@description('Layer 2 subnet address prefix')
param layer2SubnetPrefix string = '10.0.2.0/24'

/*
@description('User name for the Virtual Machine.')
param adminUsername string

@description('SSH Key or password for the Virtual Machine. SSH key is recommended.')
@secure()
param adminPasswordOrKey string
*/

// Variables
var name = toLower('${prefix}')

// Create a short, unique suffix, that will be unique to each resource group
var uniqueSuffix = substring(uniqueString(resourceGroup().id), 0, 4)


// IoT Hub
module iothub 'modules/iothub.bicep' = { 
  name: 'ioth-${name}-${uniqueSuffix}-deployment'
  params: {
    location: location
    iotHubName: 'ioth-${name}-${uniqueSuffix}'
  }
}

// Storage
module storage 'modules/storage.bicep' = { 
  name: 'st${name}${uniqueSuffix}-deployment'
  params: {
    location: location
    storageAccountName: 'st${name}${uniqueSuffix}'
  }
}

// Virtual network and network security group
module nsg 'modules/nsg.bicep' = { 
  name: 'nsg-${name}-${uniqueSuffix}-deployment'
  params: {
    location: location
    layer4SubnetPrefix: layer4SubnetPrefix
    layer3SubnetPrefix: layer3SubnetPrefix
    layer2SubnetPrefix: layer2SubnetPrefix
    nsgName: 'nsg-${name}-${uniqueSuffix}'
  }
}

module vnet 'modules/vnet.bicep' = { 
  name: 'vnet-${name}-${uniqueSuffix}-deployment'
  params: {
    location: location
    virtualNetworkName: 'vnet-${name}-${uniqueSuffix}'
    networkSecurityGroupId: nsg.outputs.networkSecurityGroupId
    vnetAddressPrefix: vnetAddressPrefix
    layer4SubnetPrefix: layer4SubnetPrefix
    layer3SubnetPrefix: layer3SubnetPrefix
    layer2SubnetPrefix: layer2SubnetPrefix
  }
  dependsOn: [
    nsg
  ]
}

/*
// Layer 4 VM
module layer4vm 'modules/edge.bicep' = { 
  name: 'vm-layer4-${name}-${uniqueSuffix}-deployment'
  params: {
    location: location
    vmName: 'vm-layer4-${name}-${uniqueSuffix}'
    adminUsername: adminUsername
    adminPasswordOrKey: adminPasswordOrKey
    subnetId: '${vnet.outputs.vnetId}/subnets/subnet-layer4'
    iothubName: iothub.outputs.iotHubName
  }
  dependsOn: [
    iothub
    vnet
  ]
}

// Layer 3 VM
module layer3vm 'modules/edge.bicep' = { 
  name: 'vm-layer3-${name}-${uniqueSuffix}-deployment'
  params: {
    location: location
    vmName: 'vm-layer3-${name}-${uniqueSuffix}'
    adminUsername: adminUsername
    adminPasswordOrKey: adminPasswordOrKey
    subnetId: '${vnet.outputs.vnetId}/subnets/subnet-layer3'
    iothubName: iothub.outputs.iotHubName
  }
  dependsOn: [
    iothub
    vnet
  ]
}

// Layer 2 VM
module layer2vm 'modules/edge.bicep' = { 
  name: 'vm-layer2-${name}-${uniqueSuffix}-deployment'
  params: {
    location: location
    vmName: 'vm-layer2-${name}-${uniqueSuffix}'
    adminUsername: adminUsername
    adminPasswordOrKey: adminPasswordOrKey
    subnetId: '${vnet.outputs.vnetId}/subnets/subnet-layer2'
    iothubName: iothub.outputs.iotHubName
  }
  dependsOn: [
    iothub
    vnet
  ]
}
*/

output iothubName string = iothub.outputs.iotHubName
output vnetId string = vnet.outputs.vnetId
