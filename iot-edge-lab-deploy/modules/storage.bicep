@description('Location for all resources.')
param location string = resourceGroup().location

@description('Storage account name.')
param storageAccountName string

var storageAccountType = 'Standard_LRS'

resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'StorageV2'
}

output storageId string = storage.id
