# Tier 2 (N2) Cloud Governance & Access Troubleshooting

This runbook documents structured incident investigation playbooks for cloud governance, access boundaries, policy violations, and lock restrictions in Microsoft Azure.

---

## Scenario 1: Contributor Deployment Blocked by Azure Policy

### Symptom
An infrastructure engineer assigned the built-in **Contributor** role attempts to deploy a new Virtual Network via Bicep, but the deployment fails with error code `RequestDisallowedByPolicy`.

### Hypothesis
An active Azure Policy assignment intercepts the resource properties and returns a `Deny` enforcement decision, overriding the user's RBAC privileges.

### Diagnosis
1. Examine the error payload returned by Azure Resource Manager for the specific policy assignment ID and rule evaluation details.
2. Determine which resource property triggered the denial.

### Diagnostic Commands
```bash
# View deployment error details from recent operation logs
az deployment group show \
  --resource-group rg-azure-infra-lab \
  --name deploy-infra \
  --query "properties.error.details" \
  -o json

# Query effective policy assignments applied to the resource group
az policy assignment list \
  --resource-group rg-azure-infra-lab \
  --query "[].{Name:name, PolicyDefId:policyDefinitionId, Enforce:enforcementMode}" \
  -o table
```

### Root Cause
The Bicep parameter file specified `location = 'westeurope'`, but policy `allowed-locations` restricts provisioning strictly to `brazilsouth` and `eastus`.

### Remediation
1. Adjust the parameter file `bicep/main.bicepparam` to target an authorized region (`brazilsouth`).
2. If genuine business necessity requires an additional region, request an exemption or policy definition update through the Cloud Governance team.

### Validation
Re-run deployment pre-flight validation:
```bash
az deployment group what-if \
  --resource-group rg-azure-infra-lab \
  --template-file bicep/main.bicep \
  --parameters bicep/main.bicepparam
```

---

## Scenario 2: Modification Denied Due to Reader Role Assignment

### Symptom
A support engineer can inspect and list network interfaces, subnets, and routing tables in the Azure Portal or CLI, but any attempt to add an NSG rule fails with error `AuthorizationFailed`: "The client does not have authorization to perform action 'Microsoft.Network/networkSecurityGroups/securityRules/write'".

### Hypothesis
The user has been assigned the **Reader** role rather than **Network Contributor** or **Contributor** on the target resource group.

### Diagnosis
Inspect the effective Azure RBAC role assignments granted to the principal.

### Diagnostic Commands
```bash
# Check the signed-in user object ID
USER_ID="$(az ad signed-in-user show --query "id" -o tsv)"

# List all role assignments granted to this user on the Resource Group
az role assignment list \
  --assignee "${USER_ID}" \
  --resource-group rg-azure-infra-lab \
  --query "[].{Role:roleDefinitionName, Scope:scope}" \
  -o table
```

### Root Cause
The engineer's identity is assigned the built-in **Reader** role (`*/read`), which explicitly excludes mutation (`write`) and deletion (`delete`) permissions.

### Remediation
1. Submit an access elevation request adhering to Just-In-Time (JIT) access principles.
2. An administrator with **User Access Administrator** or **Owner** grants **Network Contributor** scoped specifically to `rg-azure-infra-lab`.

### Validation
Verify updated role assignments:
```bash
az role assignment list \
  --assignee "${USER_ID}" \
  --resource-group rg-azure-infra-lab \
  --output table
```

---

## Scenario 3: Resource Group Deletion Fails Due to CanNotDelete Lock

### Symptom
Running `./scripts/destroy.sh` or executing `az group delete` fails with HTTP error `409 Conflict`: "The scope cannot perform delete operation because following scope(s) are locked: 'lock-prevent-accidental-deletion'".

### Hypothesis
A `CanNotDelete` resource lock is active at the Resource Group or Subscription level, preventing deletion APIs from executing.

### Diagnosis
Query active resource locks on the target container.

### Diagnostic Commands
```bash
# Check for active resource locks
az lock list \
  --resource-group rg-azure-infra-lab \
  --output table
```

### Root Cause
A safety lock was placed on `rg-azure-infra-lab` to protect core network subnets from unintended destruction.

### Remediation
1. Verify with the incident commander or infrastructure owner that the teardown is authorized.
2. Remove the specific lock ID using `az lock delete`:
```bash
az lock delete \
  --name "lock-prevent-accidental-deletion" \
  --resource-group rg-azure-infra-lab
```

### Validation
Confirm lock removal, then re-execute deletion:
```bash
az lock list --resource-group rg-azure-infra-lab --output table
./scripts/destroy.sh rg-azure-infra-lab
```

---

## Scenario 4: Resource Reported Non-Compliant Due to Missing Tags

### Symptom
The cloud compliance dashboard flags `vnet-infra-lab` as "Non-Compliant" under organizational governance reporting.

### Hypothesis
The resource was provisioned without one or more mandatory metadata tags required by the organizational tagging policy.

### Diagnosis
Compare the resource's actual tags against the required tags specified in `require-tags.policy.json`.

### Diagnostic Commands
```bash
# Query compliance states for resources in the Resource Group
az policy state list \
  --resource-group rg-azure-infra-lab \
  --query "[?complianceState=='NonCompliant'].{Resource:resourceId, Policy:policyDefinitionName}" \
  -o table

# Inspect actual tags on the flagged Virtual Network
az network vnet show \
  --resource-group rg-azure-infra-lab \
  --name vnet-infra-lab \
  --query "tags" \
  -o json
```

### Root Cause
The resource was missing the mandatory `owner` tag, containing only `project`, `environment`, and `managedBy`.

### Remediation
1. Update `bicep/main.bicep` and `bicep/main.bicepparam` to include the `owner` tag.
2. Or immediately patch the tags via Azure CLI:
```bash
az resource update \
  --resource-group rg-azure-infra-lab \
  --name vnet-infra-lab \
  --resource-type "Microsoft.Network/virtualNetworks" \
  --set tags.owner="rafael.dn.ribeiro@gmail.com"
```

### Validation
Trigger an on-demand compliance scan:
```bash
az policy state trigger-scan \
  --resource-group rg-azure-infra-lab \
  --no-wait
```
Confirm compliance state returns `Compliant`.
