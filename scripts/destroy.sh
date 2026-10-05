#!/usr/bin/env bash
# ==============================================================================
# Azure Infrastructure Fundamentals Lab - Controlled Decommissioning
# ==============================================================================
# Safely tears down the cloud lab resources, removing resource locks if present
# and ensuring explicit human confirmation prior to execution.
# ==============================================================================

set -euo pipefail

RESOURCE_GROUP="${1:-rg-azure-infra-lab}"

echo "=== Azure Cloud Lab Teardown & Resource Decommission ==="
echo "Target Resource Group: ${RESOURCE_GROUP}"
echo "--------------------------------------------------------"

if ! az group show --name "${RESOURCE_GROUP}" > /dev/null 2>&1; then
    echo "[!] Resource Group '${RESOURCE_GROUP}' does not exist or was already deleted."
    exit 0
fi

echo "[*] Discovering active resources in '${RESOURCE_GROUP}':"
az resource list --resource-group "${RESOURCE_GROUP}" --output table

echo ""
echo "[!] WARNING: This operation will permanently delete all resources listed above."
read -r -p "Type 'destroy' to confirm deletion: " CONFIRMATION

if [[ "${CONFIRMATION}" != "destroy" ]]; then
    echo "[-] Deletion aborted by user. No resources were modified."
    exit 0
fi

# Check and remove resource locks if configured
echo "[*] Checking for resource locks..."
LOCKS="$(az lock list --resource-group "${RESOURCE_GROUP}" --query "[].id" -o tsv 2>/dev/null || echo "")"
if [[ -n "${LOCKS}" ]]; then
    echo "[*] Removing resource lock(s)..."
    for lock in ${LOCKS}; do
        az lock delete --ids "${lock}"
        echo "[+] Deleted lock: ${lock}"
    done
fi

echo "[*] Deleting Resource Group '${RESOURCE_GROUP}'..."
az group delete --name "${RESOURCE_GROUP}" --yes --no-wait

echo "[+] Decommission request submitted successfully."
echo "[+] The Resource Group and all associated resources are being asynchronously purged by Azure."
