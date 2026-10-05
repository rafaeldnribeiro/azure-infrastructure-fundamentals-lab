#!/usr/bin/env bash
# ==============================================================================
# Azure Infrastructure Fundamentals Lab - Deployment Automation
# ==============================================================================
# Automates validation, Resource Group creation, pre-flight what-if analysis,
# and Bicep infrastructure deployment.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

RESOURCE_GROUP="${1:-rg-azure-infra-lab}"
LOCATION="${2:-brazilsouth}"
TEMPLATE_FILE="${REPO_ROOT}/bicep/main.bicep"
PARAMS_FILE="${REPO_ROOT}/bicep/main.bicepparam"
DEPLOYMENT_NAME="deploy-infra-$(date +%Y%m%d-%H%M%S)"

echo "=== [1/5] Verifying Azure CLI Authentication ==="
if ! az account show > /dev/null 2>&1; then
    echo "[!] Azure CLI is not authenticated."
    echo "[*] Please run 'az login' interactively to establish an active session."
    exit 1
fi

ACCOUNT_USER="$(az account show --query "user.name" -o tsv 2>/dev/null || echo "Authenticated User")"
echo "[+] Authenticated as: ${ACCOUNT_USER}"

echo "=== [2/5] Validating and Compiling Bicep Templates ==="
if ! command -v az > /dev/null 2>&1; then
    echo "[!] Azure CLI ('az') is not installed."
    exit 1
fi

echo "[*] Running Bicep linter and compiler validation..."
az bicep build --file "${TEMPLATE_FILE}" --stdout > /dev/null
echo "[+] Bicep syntax and schema validated successfully."

echo "=== [3/5] Checking Resource Group ==="
if az group show --name "${RESOURCE_GROUP}" > /dev/null 2>&1; then
    echo "[+] Resource Group '${RESOURCE_GROUP}' already exists."
else
    echo "[*] Creating Resource Group '${RESOURCE_GROUP}' in region '${LOCATION}'..."
    az group create \
        --name "${RESOURCE_GROUP}" \
        --location "${LOCATION}" \
        --tags project=azure-infra-fundamentals environment=lab managedBy=bicep purpose=learning \
        --output table
    echo "[+] Resource Group created."
fi

echo "=== [4/5] Executing Pre-Flight What-If Analysis ==="
echo "[*] Calculating predicted infrastructure changes..."
az deployment group what-if \
    --resource-group "${RESOURCE_GROUP}" \
    --template-file "${TEMPLATE_FILE}" \
    --parameters "${PARAMS_FILE}" \
    --no-pretty-print

echo "=== [5/5] Deploying Infrastructure via Bicep ==="
echo "[*] Starting deployment '${DEPLOYMENT_NAME}'..."
az deployment group create \
    --name "${DEPLOYMENT_NAME}" \
    --resource-group "${RESOURCE_GROUP}" \
    --template-file "${TEMPLATE_FILE}" \
    --parameters "${PARAMS_FILE}" \
    --output table

echo ""
echo "=== Deployment Completed Successfully ==="
echo "[+] Run './scripts/validate.sh ${RESOURCE_GROUP}' to verify the provisioned state."
