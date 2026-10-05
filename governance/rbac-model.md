# Azure Role-Based Access Control (RBAC) Architecture

## Scope Hierarchy & Inheritance

Permissions in Azure Resource Manager (ARM) follow a hierarchical tree structure:

```
Root Management Group
       |
Management Groups (e.g. Corporate, Sandbox)
       |
Subscriptions (Billing & Resource Quota Boundary)
       |
Resource Groups (e.g. rg-azure-infra-lab)
       |
Individual Resources (e.g. vnet-infra-lab)
```

### Inheritance Mechanics
- Permissions assigned at a parent level (e.g. Subscription) are inherited downward by all child containers and resources.
- Lower-level scopes cannot revoke permissions granted at higher levels.
- Best Practice: Grant access at the lowest feasible scope (Resource Group or specific resource) to prevent excessive privilege sprawl.

---

## Role Definitions & Anatomy

An Azure RBAC Role Definition is an abstraction containing operations categorized into `actions`, `notActions`, `dataActions`, and `notDataActions`:

```json
{
  "Name": "Virtual Network Operator",
  "IsCustom": true,
  "Description": "Permits administration of virtual networks and subnets without firewall rule modification.",
  "Actions": [
    "Microsoft.Network/virtualNetworks/read",
    "Microsoft.Network/virtualNetworks/write",
    "Microsoft.Network/virtualNetworks/subnets/read",
    "Microsoft.Network/virtualNetworks/subnets/write"
  ],
  "NotActions": [
    "Microsoft.Network/networkSecurityGroups/*",
    "Microsoft.Authorization/*/Write",
    "Microsoft.Authorization/*/Delete"
  ],
  "AssignableScopes": [
    "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-azure-infra-lab"
  ]
}
```

---

## Least Privilege Operational Personas

### 1. Reader Role
- **Permitted Operations**: `*/read`
- **Application**: Auditors, Tier 1 monitoring dashboards, compliance scanners.
- **Security Boundary**: Inability to execute mutation APIs (`write`, `delete`, `action`).

### 2. Contributor Role
- **Permitted Operations**: `*`
- **Denied Operations**: `Microsoft.Authorization/*/Write`, `Microsoft.Authorization/*/Delete`
- **Application**: Support N2 / Infrastructure engineers deploying IaC and managing daily operational tasks.
- **Security Boundary**: Inability to grant other identities access or alter role assignments.

### 3. User Access Administrator Role
- **Permitted Operations**: `Microsoft.Authorization/*`
- **Application**: Security administrators managing identity grants.
- **Security Boundary**: Separated from workload deployment duties.
