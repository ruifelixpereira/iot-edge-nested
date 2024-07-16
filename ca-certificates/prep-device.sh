#!/bin/bash

layer=$1

### Copy device certificate ###

# If the device certificate and keys directories don't exist, create, set ownership, and set permissions
sudo mkdir -p /var/aziot/certs
sudo chown aziotcs:aziotcs /var/aziot/certs
sudo chmod 755 /var/aziot/certs

sudo mkdir -p /var/aziot/secrets
sudo chown aziotks:aziotks /var/aziot/secrets
sudo chmod 700 /var/aziot/secrets

# Copy full-chain device certificate and private key into the correct directory
sudo cp iot-edge-device-ca-${layer}-full-chain.cert.pem /var/aziot/certs
sudo cp iot-edge-device-ca-${layer}.key.pem /var/aziot/secrets

### Root certificate ###

# Copy root certificate into the /certs directory
sudo cp azure-iot-test-only.root.ca.cert.pem /var/aziot/certs

# Copy root certificate into the CA certificate directory and add .crt extension.
# The root certificate must be in the CA certificate directory to install it in the certificate store.
# Use the appropriate copy command for your device OS or if using EFLOW.

# For Ubuntu and Debian, use /usr/local/share/ca-certificates/
sudo cp azure-iot-test-only.root.ca.cert.pem /usr/local/share/ca-certificates/azure-iot-test-only.root.ca.cert.pem.crt

# Give aziotcs ownership to certificates
# Read and write for aziotcs, read-only for others
sudo chown -R aziotcs:aziotcs /var/aziot/certs
sudo find /var/aziot/certs -type f -name "*.*" -exec chmod 644 {} \;

# Give aziotks ownership to private keys
# Read and write for aziotks, no permission for others
sudo chown -R aziotks:aziotks /var/aziot/secrets
sudo find /var/aziot/secrets -type f -name "*.*" -exec chmod 600 {} \;

# Verify permissions of directories and files
sudo ls -Rla /var/aziot

# Update the certificate store
# For Ubuntu or Debian - use update-ca-certificates
sudo update-ca-certificates