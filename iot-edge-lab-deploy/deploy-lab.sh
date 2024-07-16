#!/bin/bash

# variables
prefix='lab3'

#
# Create lab infra
#

# Create resource group
az group create --name nested-iot --location westus

# Deploy Bicep template
outputs=$(az deployment group create \
  --resource-group nested-iot \
  --template-file ./main.bicep \
  --parameters prefix=${prefix} \
  --query properties.outputs)

iothub_name=$(echo $outputs | jq -r '.iothubName.value')
vnet_id=$(echo $outputs | jq -r '.vnetId.value')

#
# Create devices
#
# Create layer 4 (top gateway) device
#az iot hub device-identity create -n ${iothub_name} -d 'layer4' --ee

# Create layer 3 (middle) device
#az iot hub device-identity create -n ${iothub_name} -d 'layer3' --ee
#az iot hub device-identity parent set -d 'layer3' --pd 'layer4' -n ${iothub_name}

# Create layer 2 (downstream) device
#az iot hub device-identity create -n ${iothub_name} -d 'layer2' --ee
#az iot hub device-identity parent set -d 'layer2' --pd 'layer3' -n ${iothub_name}

#
# Create edge VMs
#

# Layer 4
layer4_hostname=$(az deployment group create \
  --resource-group nested-iot \
  --template-file ./modules/edge.bicep \
  --parameters vmNameLabel="layer4" \
  --parameters prefix=${prefix} \
  --parameters hierarchyLayer='layer4' \
  --parameters adminUsername='azureuser' \
  --parameters adminPasswordOrKey="$(< ~/.ssh/id_rsa.pub)" \
  --parameters subnetId="${vnet_id}/subnets/subnet-layer4" \
  --parameters deviceConnectionString=$(az iot hub device-identity show-connection-string --device-id "layer4" --hub-name ${iothub_name} -o tsv) \
  --query properties.outputs.private_ip.value)

# Layer 3
layer3_hostname=$(az deployment group create \
  --resource-group nested-iot \
  --template-file ./modules/edge.bicep \
  --parameters vmNameLabel="layer3" \
  --parameters prefix=${prefix} \
  --parameters hierarchyLayer='layer3' \
  --parameters parentHostname=${layer4_hostname} \
  --parameters adminUsername='azureuser' \
  --parameters adminPasswordOrKey="$(< ~/.ssh/id_rsa.pub)" \
  --parameters subnetId="${vnet_id}/subnets/subnet-layer3" \
  --parameters deviceConnectionString=$(az iot hub device-identity show-connection-string --device-id "layer3" --hub-name ${iothub_name} -o tsv) \
  --query properties.outputs.private_ip.value)

# Layer 2
layer2_hostname=$(az deployment group create \
  --resource-group nested-iot \
  --template-file ./modules/edge.bicep \
  --parameters vmNameLabel="layer2" \
  --parameters prefix=${prefix} \
  --parameters hierarchyLayer='layer2' \
  --parameters parentHostname=${layer3_hostname} \
  --parameters adminUsername='azureuser' \
  --parameters adminPasswordOrKey="$(< ~/.ssh/id_rsa.pub)" \
  --parameters subnetId="${vnet_id}/subnets/subnet-layer2" \
  --parameters deviceConnectionString=$(az iot hub device-identity show-connection-string --device-id "layer2" --hub-name ${iothub_name} -o tsv) \
  --query properties.outputs.private_ip.value)
