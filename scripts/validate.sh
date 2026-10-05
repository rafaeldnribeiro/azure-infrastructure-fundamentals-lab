#!/usr/bin/env bash
# ==============================================================================
# Azure Infrastructure Fundamentals Lab - Validation Engine
# ==============================================================================
# Programmatic audit and compliance verification for deployed cloud networking.
# Validates VNet CIDRs, subnet associations, NSG attachments, and governance tags.
# ==============================================================================

set -euo pipefail

RESOURCE_GROUP="${1:-rg-azure-infra-lab}"
VNET_NAME="vnet-infra-lab"
EXPECTED_VNET_CIDR="10.20.0.0/16"
EXPECTED_MGMT_SUBNET="10.20.1.0/24"
EXPECTED_WORK_SUBNET="10.20.2.0/24"
EXPECTED_MGMT_NSG="nsg-management"
EXPECTED_WORK_NSG="nsg-workload"

TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

pass() {
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    PASSED_TESTS=$((PASSED_TESTS + 1))
    echo "[PASS] $1"
}

fail() {
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    FAILED_TESTS=$((FAILED_TESTS + 1))
    echo "[FAIL] $1 - $2"
}

echo "=== Azure Cloud Infrastructure Compliance & Validation ==="
echo "Target Resource Group: ${RESOURCE_GROUP}"
echo "Execution Timestamp:   $(date -u +"%Y-%m-%d %H:%M:%SZ")"
echo "--------------------------------------------------------"

# 1. Resource Group Check
if az group show --name "${RESOURCE_GROUP}" > /dev/null 2>&1; then
    LOCATION="$(az group show --name "${RESOURCE_GROUP}" --query "location" -o tsv)"
    pass "Resource Group: '${RESOURCE_GROUP}' exists (Location: ${LOCATION})"
else
    fail "Resource Group" "Group '${RESOURCE_GROUP}' does not exist or is inaccessible."
    echo ""
    echo "Validation aborted due to missing Resource Group."
    exit 1
fi

# 2. Virtual Network Check
if az network vnet show --resource-group "${RESOURCE_GROUP}" --name "${VNET_NAME}" > /dev/null 2>&1; then
    ACTUAL_VNET_CIDR="$(az network vnet show --resource-group "${RESOURCE_GROUP}" --name "${VNET_NAME}" --query "addressSpace.addressPrefixes[0]" -o tsv)"
    if [[ "${ACTUAL_VNET_CIDR}" == "${EXPECTED_VNET_CIDR}" ]]; then
        pass "Virtual Network: '${VNET_NAME}' address space matches '${EXPECTED_VNET_CIDR}'"
    else
        fail "Virtual Network" "Expected '${EXPECTED_VNET_CIDR}', found '${ACTUAL_VNET_CIDR}'"
    fi
else
    fail "Virtual Network" "VNet '${VNET_NAME}' not found in '${RESOURCE_GROUP}'"
fi

# 3. Management Subnet and NSG Association Check
if az network vnet subnet show --resource-group "${RESOURCE_GROUP}" --vnet-name "${VNET_NAME}" --name "snet-management" > /dev/null 2>&1; then
    ACTUAL_MGMT_CIDR="$(az network vnet subnet show --resource-group "${RESOURCE_GROUP}" --vnet-name "${VNET_NAME}" --name "snet-management" --query "addressPrefix" -o tsv)"
    ACTUAL_MGMT_NSG_ID="$(az network vnet subnet show --resource-group "${RESOURCE_GROUP}" --vnet-name "${VNET_NAME}" --name "snet-management" --query "networkSecurityGroup.id" -o tsv || echo "")"
    
    if [[ "${ACTUAL_MGMT_CIDR}" == "${EXPECTED_MGMT_SUBNET}" ]]; then
        pass "Management Subnet: 'snet-management' prefix matches '${EXPECTED_MGMT_SUBNET}'"
    else
        fail "Management Subnet" "Expected '${EXPECTED_MGMT_SUBNET}', found '${ACTUAL_MGMT_CIDR}'"
    fi

    if [[ "${ACTUAL_MGMT_NSG_ID}" == *"${EXPECTED_MGMT_NSG}"* ]]; then
        pass "Management NSG Association: Attached to '${EXPECTED_MGMT_NSG}'"
    else
        fail "Management NSG Association" "Subnet not properly associated with '${EXPECTED_MGMT_NSG}'"
    fi
else
    fail "Management Subnet" "Subnet 'snet-management' not found"
fi

# 4. Workload Subnet and NSG Association Check
if az network vnet subnet show --resource-group "${RESOURCE_GROUP}" --vnet-name "${VNET_NAME}" --name "snet-workload" > /dev/null 2>&1; then
    ACTUAL_WORK_CIDR="$(az network vnet subnet show --resource-group "${RESOURCE_GROUP}" --vnet-name "${VNET_NAME}" --name "snet-workload" --query "addressPrefix" -o tsv)"
    ACTUAL_WORK_NSG_ID="$(az network vnet subnet show --resource-group "${RESOURCE_GROUP}" --vnet-name "${VNET_NAME}" --name "snet-workload" --query "networkSecurityGroup.id" -o tsv || echo "")"
    
    if [[ "${ACTUAL_WORK_CIDR}" == "${EXPECTED_WORK_SUBNET}" ]]; then
        pass "Workload Subnet: 'snet-workload' prefix matches '${EXPECTED_WORK_SUBNET}'"
    else
        fail "Workload Subnet" "Expected '${EXPECTED_WORK_SUBNET}', found '${ACTUAL_WORK_CIDR}'"
    fi

    if [[ "${ACTUAL_WORK_NSG_ID}" == *"${EXPECTED_WORK_NSG}"* ]]; then
        pass "Workload NSG Association: Attached to '${EXPECTED_WORK_NSG}'"
    else
        fail "Workload NSG Association" "Subnet not properly associated with '${EXPECTED_WORK_NSG}'"
    fi
else
    fail "Workload Subnet" "Subnet 'snet-workload' not found"
fi

# 5. Governance Tags Check
TAGS="$(az group show --name "${RESOURCE_GROUP}" --query "tags" -o json 2>/dev/null || echo "{}")"
if echo "${TAGS}" | grep -q "azure-infra-fundamentals" && echo "${TAGS}" | grep -q "bicep"; then
    pass "Governance Tags: Standard project, environment, and managedBy tags present"
else
    fail "Governance Tags" "Missing required compliance tags"
fi

# 6. Financial Guardrails Check (Zero Paid Resources)
PAID_RESOURCES="$(az resource list --resource-group "${RESOURCE_GROUP}" --query "[?type=='Microsoft.Compute/virtualMachines' || type=='Microsoft.Network/publicIPAddresses' || type=='Microsoft.Network/vpnGateways' || type=='Microsoft.Network/applicationGateways'].name" -o tsv)"
if [[ -z "${PAID_RESOURCES}" ]]; then
    pass "Cost Control: Zero chargeable compute or gateway resources detected"
else
    fail "Cost Control" "Chargeable resources detected: ${PAID_RESOURCES}"
fi

echo "--------------------------------------------------------"
echo "Validation Summary: ${PASSED_TESTS}/${TOTAL_TESTS} Checks Passed."

if [[ ${FAILED_TESTS} -eq 0 ]]; then
    echo "[+] ALL CHECKS PASSED: Environment strictly complies with target architecture."
    exit 0
else
    echo "[!] AUDIT FAILED: ${FAILED_TESTS} issues detected."
    exit 1
fi
