<#
.SYNOPSIS
    Validates local PowerShell and Azure Az module environment for educational lab.
.DESCRIPTION
    Checks PowerShell version (>= 7.0), verifies installed Az modules (Accounts, Resources,
    Network, Storage, Compute), and safely inspects Azure authentication context.
#>

$ErrorActionPreference = "Continue"

Write-Host "=========================================="
Write-Host "Azure Lab Environment Diagnostic (Local)"
Write-Host "=========================================="

# 1. Check PowerShell Version
$psVersion = $PSVersionTable.PSVersion
if ($psVersion.Major -ge 7) {
    Write-Host "[PASS] PowerShell ($($psVersion.ToString()))"
} else {
    Write-Host "[FAIL] PowerShell version ($($psVersion.ToString())) is below minimum required (7.0+)"
    exit 1
}

# 2. Check Az Top-Level Module
$azModule = Get-Module -ListAvailable -Name Az | Select-Object -First 1
if ($azModule -or (Get-InstalledModule -Name Az -ErrorAction SilentlyContinue)) {
    Write-Host "[PASS] Az module"
} else {
    Write-Host "[WARN] Az meta-module list pending, checking component modules..."
}

# 3. Check Critical Az Submodules
$requiredModules = @(
    "Az.Accounts",
    "Az.Resources",
    "Az.Network",
    "Az.Storage",
    "Az.Compute"
)

foreach ($mod in $requiredModules) {
    $found = Get-Module -ListAvailable -Name $mod | Select-Object -First 1
    if ($found) {
        Write-Host "[PASS] $mod ($($found.Version))"
    } else {
        Write-Host "[FAIL] Missing required module: $mod"
    }
}

# 4. Safe Context Check (Zero Cloud Authentication Required)
try {
    if (Get-Command -Name Get-AzContext -ErrorAction SilentlyContinue) {
        $context = Get-AzContext -ErrorAction SilentlyContinue
        if ($context) {
            Write-Host "[INFO] Active Azure context: $($context.Account.Id)"
        } else {
            Write-Host "[INFO] Azure authentication not active (Local validation mode)"
        }
    } else {
        Write-Host "[INFO] Azure authentication not active"
    }
} catch {
    Write-Host "[INFO] Azure authentication not active"
}

Write-Host "=========================================="
Write-Host "Diagnostic validation complete."
Write-Host "=========================================="
