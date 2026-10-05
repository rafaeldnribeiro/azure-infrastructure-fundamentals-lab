# Tier 2 (N2) Troubleshooting Runbooks: Azure Infrastructure

This document details structured diagnostic workflows and incident remediation runbooks for Azure cloud infrastructure, bridging operational Support N2 methodologies with cloud platform engineering.

---

## Runbook 1: Bicep Deployment Failure (Syntax / Schema Validation)

### Symptom
Executing `az deployment group create` fails immediately during template evaluation or compilation with `InvalidTemplate` or `BCP` error codes.

### Diagnosis
1. Template compilation failed locally before submission to Azure Resource Manager.
2. Parameter mismatches or undeclared required fields occurred in a module invocation.

### Diagnostic Commands
```bash
# Test local Bicep compilation and view linter warnings
az bicep build --file bicep/main.bicep --stdout

# Run Azure Resource Manager pre-flight validation
az deployment group validate \
  --resource-group rg-azure-infra-lab \
  --template-file bicep/main.bicep \
  --parameters bicep/main.bicepparam
```

### Probable Cause
Missing target scope definition, missing required parameter types, or malformed resource symbolic names in `main.bicep` or `network.bicep`.

### Remediation
1. Inspect line numbers returned by `az bicep build`.
2. Ensure parameter decorators (`@description`, parameter default values) adhere to Microsoft Bicep specifications.
3. Verify that module references point to relative file paths containing valid exports.

### Validation
Re-run compilation:
```bash
az bicep build --file bicep/main.bicep --stdout > /dev/null && echo "Validation Passed"
```

---

## Runbook 2: Regional Resource Availability or Policy Restriction

### Symptom
Deployment fails with error `LocationNotAvailableForResourceType` or `RequestDisallowedByPolicy`.

### Diagnosis
The selected Azure region does not support the requested API version for that resource type, or an Azure Policy constraint enforces specific region whitelisting.

### Diagnostic Commands
```bash
# Query available resource providers and locations for Virtual Networks
az provider show \
  --namespace Microsoft.Network \
  --query "resourceTypes[?resourceType=='virtualNetworks'].locations" \
  -o json

# Inspect active Azure Policy assignments on the subscription/group
az policy assignment list \
  --resource-group rg-azure-infra-lab \
  -o table
```

### Probable Cause
Target subscription is locked to specific geography or tenant policies restrict provisioning to compliant zones.

### Remediation
1. Adjust the `location` parameter in `bicep/main.bicepparam` to an approved region (e.g. `brazilsouth`, `eastus2`).
2. Re-test with what-if analysis:
```bash
az deployment group what-if \
  --resource-group rg-azure-infra-lab \
  --template-file bicep/main.bicep \
  --parameters bicep/main.bicepparam
```

### Validation
Confirm resource group accepts region deployment:
```bash
az group show --name rg-azure-infra-lab --query "location" -o tsv
```

---

## Runbook 3: Overlapping CIDR Address Spaces in Subnets

### Symptom
Azure Resource Manager rejects template deployment with error code `NetcfgInvalidSubnet`: "Subnet prefix is not valid within the virtual network address space".

### Diagnosis
A subnet's declared CIDR prefix either falls outside the VNet's address space or collides with another existing subnet block.

### Diagnostic Commands
```bash
# Query current VNet address prefixes
az network vnet show \
  --resource-group rg-azure-infra-lab \
  --name vnet-infra-lab \
  --query "addressSpace.addressPrefixes" \
  -o table

# Inspect all allocated subnet prefixes in the VNet
az network vnet subnet list \
  --resource-group rg-azure-infra-lab \
  --vnet-name vnet-infra-lab \
  --query "[].{Name:name, Prefix:addressPrefix}" \
  -o table
```

### Probable Cause
Subnet prefix calculations overlap (for example attempting to create two subnets in `10.20.1.0/24` and `10.20.1.128/25`, or placing `10.21.0.0/24` inside a `10.20.0.0/16` VNet).

### Remediation
1. Calculate discrete, non-overlapping subnet allocations:
   - Supernet: `10.20.0.0/16`
   - Management: `10.20.1.0/24` (`10.20.1.0` - `10.20.1.255`)
   - Workload: `10.20.2.0/24` (`10.20.2.0` - `10.20.2.255`)
2. Update `bicep/network.bicep` parameters accordingly.

### Validation
Run automated validator:
```bash
./scripts/validate.sh rg-azure-infra-lab
```

---

## Runbook 4: Network Security Group (NSG) Traffic Misconfiguration

### Symptom
Internal traffic between management nodes and workload services times out or is rejected unexpectedly.

### Diagnosis
NSG priority evaluation evaluates a higher-priority `Deny` rule before reaching the expected `Allow` rule, or rule source/destination CIDRs are inverted.

### Diagnostic Commands
```bash
# List all effective security rules for management NSG ordered by priority
az network nsg rule list \
  --resource-group rg-azure-infra-lab \
  --nsg-name nsg-management \
  --query "sort_by([].{Priority:priority, Name:name, Access:access, Direction:direction, Protocol:protocol, Source:sourceAddressPrefix, Dest:destinationAddressPrefix, Port:destinationPortRange}, &Priority)" \
  -o table

# Verify which NSG is attached to which subnet
az network vnet subnet list \
  --resource-group rg-azure-infra-lab \
  --vnet-name vnet-infra-lab \
  --query "[].{Subnet:name, NSG:networkSecurityGroup.id}" \
  -o table
```

### Probable Cause
In Azure NSGs, rules are evaluated in ascending numerical order of priority (100 to 4096). A broad `DenyAll` rule placed with lower numerical value (e.g. 500) overrides any subsequent `Allow` rules (e.g. 1000).

### Remediation
1. Maintain explicit priority intervals (e.g. increments of 100):
   - Custom specific allows: 1000 - 1999
   - Inter-tier routing: 2000 - 2999
   - Explicit catch-all denies: 4000
2. Ensure NSG ID references in `bicep/network.bicep` bind `nsg-management` to `snet-management` and `nsg-workload` to `snet-workload`.

### Validation
Verify output with `./scripts/validate.sh`:
```bash
[PASS] Management NSG Association: Attached to 'nsg-management'
[PASS] Workload NSG Association: Attached to 'nsg-workload'
```
