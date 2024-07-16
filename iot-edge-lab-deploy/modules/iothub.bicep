// --- Parameters
@description('Define the iotHub name.')
param iotHubName  string 

@description('The Azure region in which all resources should be deployed.')
param location string = resourceGroup().location

@description('The SKU to use for the IoT Hub.')
param skuName string = 'S1'

@description('The number of IoT Hub units.')
param skuUnits int = 1

// --- Resources
resource iothub 'Microsoft.Devices/IotHubs@2021-07-02' = {
  name: iotHubName
  location: location
  sku: {
    name: skuName
    capacity: skuUnits
  }
  properties: {}
}

output iotHubName string = iothub.name
