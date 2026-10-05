# Azure Resource Locks: Accidental Deletion & Mutation Prevention

## Conceptual Overview

Azure Resource Locks provide a mechanism to prevent accidental deletion or unwanted modification of critical infrastructure components.

Locks apply to all users, service principals, and administrators (including users with **Owner** role), enforcing an intentional step before destructive operations can be executed.

---

## Lock Types

| Lock Type | CLI Parameter | Allowed Operations | Blocked Operations |
| :--- | :--- | :--- | :--- |
| **CanNotDelete** | `CanNotDelete` | Read, Update, Modify resource configurations | Delete resource, Purge resource group |
| **ReadOnly** | `ReadOnly` | Read configurations, Query metrics | Any modification, Configuration update, Deletion |

---

## Scope Inheritance & Mechanics

Locks follow strict downward hierarchy:
- A lock applied at a **Subscription** applies to all resource groups and resources within that subscription.
- A lock applied at a **Resource Group** applies to all existing and future child resources inside that group.
- The most restrictive lock always takes precedence.

---

## Why Resource Locks Do Not Replace Azure RBAC

- **RBAC**: Controls authorization boundaries based on identity (*Who* is allowed to call actions).
- **Resource Locks**: Establish guardrails against human error and automated script mistakes (*What* actions are restricted, regardless of who invokes them).
- **Operational Reality**: An **Owner** has permission to delete a resource. However, if a `CanNotDelete` lock is present, the deletion request is blocked with HTTP status `409 Conflict`. The Owner must explicitly remove the lock before executing the deletion, creating a deliberate safety checkpoint.

---

## Enterprise Support Scenario

In production environments, core networking resources (Hub VNets, ExpressRoute circuits, and primary DNS zones) are protected with `CanNotDelete` locks. This prevents cleanup scripts, decommissioning automations, or well-intentioned junior operators from inadvertently taking down organizational connectivity.

---

## Azure CLI Configuration Reference

*Example only — not executed against an Azure subscription.*

```bash
# Apply a CanNotDelete lock to the Resource Group
az lock create \
  --name "lock-prevent-accidental-deletion" \
  --lock-type CanNotDelete \
  --resource-group "rg-azure-infra-lab" \
  --notes "Protects core network foundation against accidental teardown"

# Inspect active locks on the Resource Group
az lock list \
  --resource-group "rg-azure-infra-lab" \
  --output table

# Remove the lock prior to authorized decommissioning
az lock delete \
  --name "lock-prevent-accidental-deletion" \
  --resource-group "rg-azure-infra-lab"
```
