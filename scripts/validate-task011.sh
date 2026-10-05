#!/usr/bin/env bash
# ==============================================================================
# validate-task011.sh
# Automated Local Validation Workflow for Task 011: Compute, Storage & PowerShell
# Strictly validated locally - Zero cloud deployment executed.
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "============================================================"
echo "Task 011: Local Infrastructure Validation & Tooling Check"
echo "Repository: ${REPO_ROOT}"
echo "============================================================"

# 1. Validate Compute Linux VM Bicep
echo "[*] Validating compute/bicep/linux-vm.bicep..."
if az bicep build --file "${REPO_ROOT}/compute/bicep/linux-vm.bicep" --stdout > /dev/null; then
    echo "[PASS] Compute VM Bicep"
else
    echo "[FAIL] Compute VM Bicep compilation failed"
    exit 1
fi

# 2. Validate Compute VMSS Bicep
echo "[*] Validating compute/bicep/vm-scale-set.bicep..."
if az bicep build --file "${REPO_ROOT}/compute/bicep/vm-scale-set.bicep" --stdout > /dev/null; then
    echo "[PASS] Compute VMSS Bicep"
else
    echo "[FAIL] Compute VMSS Bicep compilation failed"
    exit 1
fi

# 3. Validate Compute Container Instance Bicep
echo "[*] Validating compute/bicep/container-instance.bicep..."
if az bicep build --file "${REPO_ROOT}/compute/bicep/container-instance.bicep" --stdout > /dev/null; then
    echo "[PASS] Compute ACI Bicep"
else
    echo "[FAIL] Compute ACI Bicep compilation failed"
    exit 1
fi

# 4. Validate Storage Account Bicep
echo "[*] Validating storage/bicep/storage.bicep..."
if az bicep build --file "${REPO_ROOT}/storage/bicep/storage.bicep" --stdout > /dev/null; then
    echo "[PASS] Storage Bicep"
else
    echo "[FAIL] Storage Bicep compilation failed"
    exit 1
fi

# 5. Validate Storage Lifecycle JSON
echo "[*] Validating storage/lifecycle-management.json..."
if jq empty "${REPO_ROOT}/storage/lifecycle-management.json"; then
    echo "[PASS] Storage lifecycle JSON"
else
    echo "[FAIL] Storage lifecycle JSON syntax validation failed"
    exit 1
fi

# 6. Validate PowerShell 7+
echo "[*] Validating PowerShell interpreter..."
if pwsh -NoProfile -Command "if (\$PSVersionTable.PSVersion.Major -ge 7) { exit 0 } else { exit 1 }"; then
    echo "[PASS] PowerShell 7+"
else
    echo "[FAIL] PowerShell 7+ not detected"
    exit 1
fi

# 7. Validate Az PowerShell Module
echo "[*] Validating Az PowerShell module installation..."
if pwsh -NoProfile -Command "if (Get-Module -ListAvailable -Name Az.Accounts) { exit 0 } else { exit 1 }"; then
    echo "[PASS] Az PowerShell module"
else
    echo "[FAIL] Az PowerShell module not found"
    exit 1
fi

echo "------------------------------------------------------------"
echo "[*] Running PowerShell environment diagnostics..."
pwsh -NoProfile -File "${REPO_ROOT}/powershell/Test-AzureLabEnvironment.ps1"
echo "------------------------------------------------------------"

echo "Task 011 local validation completed successfully."
echo "No Azure cloud deployment was performed."
echo "============================================================"
