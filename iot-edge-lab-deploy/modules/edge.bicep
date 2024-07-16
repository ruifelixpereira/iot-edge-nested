// Parameters
@minLength(2)
@maxLength(10)
@description('Prefix for all resource names.')
param prefix string

@description('The location of the resources.')
param location string = resourceGroup().location

@description('Virtual Machine name label.')
param vmNameLabel string

@description('Type of edge in the hierarchy.')
@allowed([
  'layer2'
  'layer3'
  'layer4'
])
param hierarchyLayer string

@description('If the device has a parent in the hirarchy, this is the parent device hostname.')
param parentHostname string = ''

@description('Device connection string on IoT Hub.')
param deviceConnectionString string

@description('User name for the Virtual Machine.')
param adminUsername string

@description('SSH Key or password for the Virtual Machine. SSH key is recommended.')
@secure()
param adminPasswordOrKey string

@description('Type of authentication to use on the Virtual Machine. SSH key is recommended.')
@allowed([
  'sshPublicKey'
  'password'
])
param authenticationType string = 'sshPublicKey'

@description('VM size')
param vmSize string = 'Standard_D2_v5'

@description('The Ubuntu version for the VM. This will pick a fully patched image of this given Ubuntu version.')
param ubuntuOSVersion string = '22_04-lts'

@description('Subnet where the VM will have a private IP')
@secure()
param subnetId string

// Variables
var name = toLower('${prefix}')
var vmName = 'vm-${vmNameLabel}-${name}'
var imagePublisher = 'Canonical'
var imageOffer = '0001-com-ubuntu-server-jammy'
var nicName = 'nic-${vmName}'
var linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${adminUsername}/.ssh/authorized_keys'
        keyData: adminPasswordOrKey
      }
    ]
  }
}
var dcs = deviceConnectionString
var self_hostname = nic.properties.ipConfigurations[0].properties.privateIPAddress
var parent_hostname = parentHostname

var isLayer4 = hierarchyLayer == 'layer4'
var isLayer3 = hierarchyLayer == 'layer3'
var cloudinitScriptLayer4 = base64('#cloud-config\n\napt:\n  preserve_sources_list: true\n  sources:\n    msft.list:\n      source: "deb https://packages.microsoft.com/ubuntu/22.04/prod jammy main"\n      key: |\n        -----BEGIN PGP PUBLIC KEY BLOCK-----\n        Version: GnuPG v1.4.7 (GNU/Linux)\n\n        mQENBFYxWIwBCADAKoZhZlJxGNGWzqV+1OG1xiQeoowKhssGAKvd+buXCGISZJwT\n        LXZqIcIiLP7pqdcZWtE9bSc7yBY2MalDp9Liu0KekywQ6VVX1T72NPf5Ev6x6DLV\n        7aVWsCzUAF+eb7DC9fPuFLEdxmOEYoPjzrQ7cCnSV4JQxAqhU4T6OjbvRazGl3ag\n        OeizPXmRljMtUUttHQZnRhtlzkmwIrUivbfFPD+fEoHJ1+uIdfOzZX8/oKHKLe2j\n        H632kvsNzJFlROVvGLYAk2WRcLu+RjjggixhwiB+Mu/A8Tf4V6b+YppS44q8EvVr\n        M+QvY7LNSOffSO6Slsy9oisGTdfE39nC7pVRABEBAAG0N01pY3Jvc29mdCAoUmVs\n        ZWFzZSBzaWduaW5nKSA8Z3Bnc2VjdXJpdHlAbWljcm9zb2Z0LmNvbT6JATUEEwEC\n        AB8FAlYxWIwCGwMGCwkIBwMCBBUCCAMDFgIBAh4BAheAAAoJEOs+lK2+EinPGpsH\n        /32vKy29Hg51H9dfFJMx0/a/F+5vKeCeVqimvyTM04C+XENNuSbYZ3eRPHGHFLqe\n        MNGxsfb7C7ZxEeW7J/vSzRgHxm7ZvESisUYRFq2sgkJ+HFERNrqfci45bdhmrUsy\n        7SWw9ybxdFOkuQoyKD3tBmiGfONQMlBaOMWdAsic965rvJsd5zYaZZFI1UwTkFXV\n        KJt3bp3Ngn1vEYXwijGTa+FXz6GLHueJwF0I7ug34DgUkAFvAs8Hacr2DRYxL5RJ\n        XdNgj4Jd2/g6T9InmWT0hASljur+dJnzNiNCkbn9KbX7J/qK1IbR8y560yRmFsU+\n        NdCFTW7wY0Fb1fWJ+/KTsC4=\n        =J6gs\n        -----END PGP PUBLIC KEY BLOCK----- \npackages:\n  - moby-cli\n  - moby-engine\nruncmd:\n  - dcs="${dcs}"\n  - self_hostname="${self_hostname}"\n  - |\n      set -x\n      (\n\n        # Wait for docker daemon to start\n        while [ $(ps -ef | grep -v grep | grep docker | wc -l) -le 0 ]; do \n          sleep 3\n        done\n\n        apt install -y aziot-edge\n\n        if [ ! -z $dcs ]; then\n          mkdir /etc/aziot\n          wget https://raw.githubusercontent.com/ruifelixpereira/iot-edge-nested/iot-edge-lab-deploy/config/config-layer4.toml -O /etc/aziot/config.toml\n          sed -i "s#\\(connection_string = \\).*#\\1\\"$dcs\\"#g" /etc/aziot/config.toml\n          sed -i "s#\\(hostname = \\).*#\\1\\"$self_hostname\\"#g" /etc/aziot/config.toml\n          iotedge config apply -c /etc/aziot/config.toml\n        fi\n\n      ) &\n')
var cloudinitScriptLayer3 = base64('#cloud-config\n\napt:\n  preserve_sources_list: true\n  sources:\n    msft.list:\n      source: "deb https://packages.microsoft.com/ubuntu/22.04/prod jammy main"\n      key: |\n        -----BEGIN PGP PUBLIC KEY BLOCK-----\n        Version: GnuPG v1.4.7 (GNU/Linux)\n\n        mQENBFYxWIwBCADAKoZhZlJxGNGWzqV+1OG1xiQeoowKhssGAKvd+buXCGISZJwT\n        LXZqIcIiLP7pqdcZWtE9bSc7yBY2MalDp9Liu0KekywQ6VVX1T72NPf5Ev6x6DLV\n        7aVWsCzUAF+eb7DC9fPuFLEdxmOEYoPjzrQ7cCnSV4JQxAqhU4T6OjbvRazGl3ag\n        OeizPXmRljMtUUttHQZnRhtlzkmwIrUivbfFPD+fEoHJ1+uIdfOzZX8/oKHKLe2j\n        H632kvsNzJFlROVvGLYAk2WRcLu+RjjggixhwiB+Mu/A8Tf4V6b+YppS44q8EvVr\n        M+QvY7LNSOffSO6Slsy9oisGTdfE39nC7pVRABEBAAG0N01pY3Jvc29mdCAoUmVs\n        ZWFzZSBzaWduaW5nKSA8Z3Bnc2VjdXJpdHlAbWljcm9zb2Z0LmNvbT6JATUEEwEC\n        AB8FAlYxWIwCGwMGCwkIBwMCBBUCCAMDFgIBAh4BAheAAAoJEOs+lK2+EinPGpsH\n        /32vKy29Hg51H9dfFJMx0/a/F+5vKeCeVqimvyTM04C+XENNuSbYZ3eRPHGHFLqe\n        MNGxsfb7C7ZxEeW7J/vSzRgHxm7ZvESisUYRFq2sgkJ+HFERNrqfci45bdhmrUsy\n        7SWw9ybxdFOkuQoyKD3tBmiGfONQMlBaOMWdAsic965rvJsd5zYaZZFI1UwTkFXV\n        KJt3bp3Ngn1vEYXwijGTa+FXz6GLHueJwF0I7ug34DgUkAFvAs8Hacr2DRYxL5RJ\n        XdNgj4Jd2/g6T9InmWT0hASljur+dJnzNiNCkbn9KbX7J/qK1IbR8y560yRmFsU+\n        NdCFTW7wY0Fb1fWJ+/KTsC4=\n        =J6gs\n        -----END PGP PUBLIC KEY BLOCK----- \npackages:\n  - moby-cli\n  - moby-engine\nruncmd:\n  - dcs="${dcs}"\n  - self_hostname="${self_hostname}"\n  - parent_hostname="${parent_hostname}"\n  - |\n      set -x\n      (\n\n        # Wait for docker daemon to start\n        while [ $(ps -ef | grep -v grep | grep docker | wc -l) -le 0 ]; do \n          sleep 3\n        done\n\n        apt install -y aziot-edge\n\n        if [ ! -z $dcs ]; then\n          mkdir /etc/aziot\n          wget https://raw.githubusercontent.com/ruifelixpereira/iot-edge-nested/iot-edge-lab-deploy/config/config-layer3.toml -O /etc/aziot/config.toml\n          sed -i "s#\\(connection_string = \\).*#\\1\\"$dcs\\"#g" /etc/aziot/config.toml\n          sed -i "s#\\(hostname = \\).*#\\1\\"$self_hostname\\"#g" /etc/aziot/config.toml\n          sed -i "s#\\(parent_hostname = \\).*#\\1\\"$parent_hostname\\"#g" /etc/aziot/config.toml\n          iotedge config apply -c /etc/aziot/config.toml\n        fi\n\n      ) &\n')
var cloudinitScriptLayer2 = base64('#cloud-config\n\napt:\n  preserve_sources_list: true\n  sources:\n    msft.list:\n      source: "deb https://packages.microsoft.com/ubuntu/22.04/prod jammy main"\n      key: |\n        -----BEGIN PGP PUBLIC KEY BLOCK-----\n        Version: GnuPG v1.4.7 (GNU/Linux)\n\n        mQENBFYxWIwBCADAKoZhZlJxGNGWzqV+1OG1xiQeoowKhssGAKvd+buXCGISZJwT\n        LXZqIcIiLP7pqdcZWtE9bSc7yBY2MalDp9Liu0KekywQ6VVX1T72NPf5Ev6x6DLV\n        7aVWsCzUAF+eb7DC9fPuFLEdxmOEYoPjzrQ7cCnSV4JQxAqhU4T6OjbvRazGl3ag\n        OeizPXmRljMtUUttHQZnRhtlzkmwIrUivbfFPD+fEoHJ1+uIdfOzZX8/oKHKLe2j\n        H632kvsNzJFlROVvGLYAk2WRcLu+RjjggixhwiB+Mu/A8Tf4V6b+YppS44q8EvVr\n        M+QvY7LNSOffSO6Slsy9oisGTdfE39nC7pVRABEBAAG0N01pY3Jvc29mdCAoUmVs\n        ZWFzZSBzaWduaW5nKSA8Z3Bnc2VjdXJpdHlAbWljcm9zb2Z0LmNvbT6JATUEEwEC\n        AB8FAlYxWIwCGwMGCwkIBwMCBBUCCAMDFgIBAh4BAheAAAoJEOs+lK2+EinPGpsH\n        /32vKy29Hg51H9dfFJMx0/a/F+5vKeCeVqimvyTM04C+XENNuSbYZ3eRPHGHFLqe\n        MNGxsfb7C7ZxEeW7J/vSzRgHxm7ZvESisUYRFq2sgkJ+HFERNrqfci45bdhmrUsy\n        7SWw9ybxdFOkuQoyKD3tBmiGfONQMlBaOMWdAsic965rvJsd5zYaZZFI1UwTkFXV\n        KJt3bp3Ngn1vEYXwijGTa+FXz6GLHueJwF0I7ug34DgUkAFvAs8Hacr2DRYxL5RJ\n        XdNgj4Jd2/g6T9InmWT0hASljur+dJnzNiNCkbn9KbX7J/qK1IbR8y560yRmFsU+\n        NdCFTW7wY0Fb1fWJ+/KTsC4=\n        =J6gs\n        -----END PGP PUBLIC KEY BLOCK----- \npackages:\n  - moby-cli\n  - moby-engine\nruncmd:\n  - dcs="${dcs}"\n  - parent_hostname="${parent_hostname}"\n  - |\n      set -x\n      (\n\n        # Wait for docker daemon to start\n        while [ $(ps -ef | grep -v grep | grep docker | wc -l) -le 0 ]; do \n          sleep 3\n        done\n\n        apt install -y aziot-edge\n\n        if [ ! -z $dcs ]; then\n          mkdir /etc/aziot\n          wget https://raw.githubusercontent.com/ruifelixpereira/iot-edge-nested/iot-edge-lab-deploy/config/config-layer2.toml -O /etc/aziot/config.toml\n          sed -i "s#\\(connection_string = \\).*#\\1\\"$dcs\\"#g" /etc/aziot/config.toml\n          sed -i "s#\\(parent_hostname = \\).*#\\1\\"$parent_hostname\\"#g" /etc/aziot/config.toml\n          iotedge config apply -c /etc/aziot/config.toml\n        fi\n\n      ) &\n')

var cloudinitScript = isLayer4 ? cloudinitScriptLayer4 : isLayer3 ? cloudinitScriptLayer3 : cloudinitScriptLayer2

resource nic 'Microsoft.Network/networkInterfaces@2021-08-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPasswordOrKey
      customData: cloudinitScript
      linuxConfiguration: ((authenticationType == 'password') ? json('null') : linuxConfiguration)
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: ubuntuOSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

//output private_ssh string = 'ssh ${vm.properties.osProfile.adminUsername}@${nic.properties.ipConfigurations[0].properties.privateIPAddress}'
output private_ip string = nic.properties.ipConfigurations[0].properties.privateIPAddress
