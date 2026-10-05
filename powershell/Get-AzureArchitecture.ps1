<#
.SYNOPSIS
    PowerShell architectural validation script for Azure lab resources.
.DESCRIPTION
    Equivalent PowerShell implementation of validate.sh. Safely checks for an
    active authenticated Azure context before attempting any remote ARM query.
    If no context is found, logs an informative notice and exits gracefully.
#>

param (
    [string]$ResourceGroupName = "rg-azure-fundamentals-lab"
)

Write-Host "=========================================="
Write-Host "Azure Architecture Inspector (PowerShell)"
Write-Host "Target Resource Group: $ResourceGroupName"
Write-Host "=========================================="

# 1. Inspect Azure Context Safely
$context = Get-AzContext -ErrorAction SilentlyContinue

if (-not $context -or [string]::IsNullOrEmpty($context.Account.Id)) {
    Write-Host "[INFO] No active Azure context."
    Write-Host "[INFO] Cloud resource inspection skipped safely."
    Write-Host "[INFO] To inspect live cloud resources in future iterations, authenticate via Connect-AzAccount."
    Write-Host "=========================================="
    exit 0
}

Write-Host "[+] Authenticated Account : $($context.Account.Id)"
Write-Host "[+] Target Subscription   : $($context.Subscription.Name) ($($context.Subscription.Id))"
Write-Host ""

# 2. Query Resource Group
try {
    $rg = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction Stop
    Write-Host "[PASS] Resource Group found: $($rg.ResourceGroupName) (Location: $($rg.Location), State: $($rg.ProvisioningState))"
} catch {
    Write-Host "[FAIL] Resource Group '$ResourceGroupName' not found or inaccessible: $_"
    exit 1
}

# 3. Query Virtual Network
try {
    $vnets = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
    if ($vnets) {
        foreach ($v in $vnets) {
            Write-Host "[PASS] Virtual Network: $($v.Name) (Address Space: $($v.AddressSpace.AddressPrefixes -join ', '))"
            foreach ($snet in $v.Subnets) {
                Write-Host "  -> Subnet: $($snet.Name) ($($snet.AddressPrefix))"
            }
        }
    } else {
        Write-Host "[INFO] No Virtual Networks found in resource group."
    }
} catch {
    Write-Host "[WARN] Unable to list Virtual Networks: $_"
}

# 4. Query Network Security Groups
try {
    $nsgs = Get-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
    if ($nsgs) {
        foreach ($nsg in $nsgs) {
            Write-Host "[PASS] NSG: $($nsg.Name) ($($nsg.SecurityRules.Count) custom rules)"
        }
    } else {
        Write-Host "[INFO] No Network Security Groups found in resource group."
    }
} catch {
    Write-Host "[WARN] Unable to list Network Security Groups: $_"
}

# 5. Query Storage Accounts
try {
    $stgs = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
    if ($stgs) {
        foreach ($stg in $stgs) {
            Write-Host "[PASS] Storage Account: $($stg.StorageAccountName) (Kind: $($stg.Kind), Sku: $($stg.Sku.Name))"
        }
    } else {
        Write-Host "[INFO] No Storage Accounts found in resource group."
    }
} catch {
    Write-Host "[WARN] Unable to list Storage Accounts: $_"
}

# 6. Query Virtual Machines
try {
    $vms = Get-AzVM -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
    if ($vms) {
        foreach ($vm in $vms) {
            Write-Host "[PASS] Virtual Machine: $($vm.Name) (Size: $($vm.HardwareProfile.VmSize), OS: $($vm.StorageProfile.OsDisk.OsType))"
        }
    } else {
        Write-Host "[INFO] No Virtual Machines found in resource group."
    }
} catch {
    Write-Host "[WARN] Unable to list Virtual Machines: $_"
}

Write-Host "=========================================="
Write-Host "Architectural inspection complete."
Write-Host "=========================================="
