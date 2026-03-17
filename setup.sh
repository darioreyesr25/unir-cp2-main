#!/bin/bash

# Configure only the Resource Group
RESOURCE_GROUP="rg-cnd-cp2-dev"

# If you want to force a specific ACR name, export it before running this script:
#   export ACR_NAME=acrcndcp2dev
# Otherwise the script tries to autodetect it from the RG.

echo "🔍 Fetching Azure resources..."

# Determine ACR name (override via env var if provided)
if [ -z "${ACR_NAME:-}" ]; then
  ACR_NAME=$(az acr list --resource-group "$RESOURCE_GROUP" --query "[0].name" -o tsv | tr -d '\r')
fi

# If autodetect fails, force a known name (adjust as needed)
if [ -z "${ACR_NAME:-}" ]; then
  ACR_NAME="acrcndcp2dev"
  echo "⚠️  ACR name could not be detected; forcing ACR_NAME=$ACR_NAME"
fi

# Validate ACR name (must be 5-50 alphanumeric characters)
if [[ ! "${ACR_NAME}" =~ ^[a-z0-9]{5,50}$ ]]; then
  echo "⚠️  Invalid ACR_NAME ('$ACR_NAME'); forcing to 'acrcndcp2dev'"
  ACR_NAME="acrcndcp2dev"
fi

# Automatically get the VM name from the resource group
VM_NAME=$(az vm list --resource-group "$RESOURCE_GROUP" --query "[0].name" -o tsv | tr -d '\r')

# Get ACR credentials
ACR_USERNAME=$(az acr credential show --name "$ACR_NAME" --query username -o tsv | tr -d '\r')
ACR_PASSWORD=$(az acr credential show --name "$ACR_NAME" --query passwords[0].value -o tsv | tr -d '\r')

# Get the ACR login server
ACR_LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --query loginServer -o tsv | tr -d '\r')

# Get the public IP of the VM
VM_IP=$(az vm show -d -g "$RESOURCE_GROUP" -n "$VM_NAME" --query publicIps -o tsv | tr -d '\r')

# Export variables to the current session
echo "🔐 Saving credentials..."
export ACR_NAME="$ACR_NAME"
export ACR_LOGIN_SERVER="$ACR_LOGIN_SERVER"
export ACR_USERNAME="$ACR_USERNAME"
export ACR_PASSWORD="$ACR_PASSWORD"
export VM_NAME="$VM_NAME"
export VM_IP="$VM_IP"

echo "✅ Done! Variables set for this session."
